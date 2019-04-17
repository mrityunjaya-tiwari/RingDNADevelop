public class NativeEmailController {
    @AuraEnabled
    public static Boolean sendEmail(String mailTo, String mailCc, String mailBcc, String subject, String body,String participantId,String templateId,String sequenceActionId){
        Boolean isValid=isValidEmail(mailTo);
        if(isValid){
        	Boolean isNativeEmailSend =CadenceService.SendNativeEmail(New list<NativeEmailMessage>());
            if(isNativeEmailSend != null && !isNativeEmailSend){
                sendSfdcEmail(participantId,templateId,sequenceActionId,mailCc,mailBcc);
                return true;
            }  
        }
        return false;
    }
    
    public class NativeEmailWrapper {
        @AuraEnabled public String recordType;
        @AuraEnabled public String sequenceActionAPI;
        @AuraEnabled public String recordTypeAPI;
        @AuraEnabled public String emailTemplateBody;
        @AuraEnabled public String emailTemplateSubject;
    }
    
    @AuraEnabled
    public static NativeEmailWrapper getData(String participantId,String emailTemplateId){
        Id pId = Id.ValueOf(participantId);
        Sequence_Action__c sequenceAction=[SELECT Cadence_Type__c FROM Sequence_Action__c WHERE Lead_ID__c = :pId OR Contact_Id__c =: pId LIMIT 1];
        EmailTemplate emailTemp = [Select id,Body from EmailTemplate where id=:emailTemplateId];
        NativeEmailWrapper obj=new NativeEmailWrapper();
        obj.recordType=sequenceAction.Cadence_Type__c;
        obj.sequenceActionAPI=cadenceConstants.NAMESPACE+'Sequence_Action__c';        
        if(obj.recordType=='Contact'){
            obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Contact_Id__c';
        }else{
            obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Lead_Id__c';
        }
        if(emailTemp != null){
            NativeEmailMessage emailMessage=resolveMergeFields(participantId, emailTemplateId);
            obj.emailTemplateBody=emailMessage.body;
            obj.emailTemplateSubject=emailMessage.subject;
        }
        return obj;
    }
    
   public static NativeEmailMessage resolveMergeFields(String participantId, String emailTemplateId){
        Messaging.SingleEmailMessage[] previewEmails = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage firstPreviewEmail = new Messaging.SingleEmailMessage();
        firstPreviewEmail.setUseSignature(false);
        NativeEmailMessage emailMessage=new NativeEmailMessage();
        firstPreviewEmail.setSaveAsActivity(false);
        List<String> sendTo=new List<String>();
        sendTo.add('dummy@gmail.com');
        firstPreviewEmail.setToAddresses(sendTo);
        firstPreviewEmail.setTemplateId(Id.valueOf(emailTemplateId));
        firstPreviewEmail.setTargetObjectId(Id.valueOf(participantId));
        previewEmails.add(firstPreviewEmail);
        Messaging.SingleEmailMessage secondPreviewEmail = new Messaging.SingleEmailMessage();
        previewEmails.add(secondPreviewEmail);
        List<Messaging.SendEmailResult> previewResult;
        try{
            previewResult = Messaging.sendEmail(previewEmails);
        }
        catch (Exception e) {
            emailMessage.subject=firstPreviewEmail.subject;
            emailMessage.body=firstPreviewEmail.plainTextBody;
        }
        return emailMessage;
    }
    
    public static String sendSfdcEmail(String participantId,string templateId,string sequenceActionId,string mailCc,string mailBcc){
        List<Messaging.SingleEmailMessage> emailsToSend = new  List<Messaging.SingleEmailMessage>();
        List<Sequence_Action__c> listOfSequence_Action = new List<Sequence_Action__c>();
        List<Task> tasksToCreate = new List<Task>();
        emailsToSend.add(createEmailMessage(participantId,templateId,mailCc,mailBcc));
        Sequence_Action__c partAct = new Sequence_Action__c(Id=sequenceActionId);
        partAct.Actual_Execution_Date__c = System.Now();
        partAct.isActionPerformed__c = true;
        listOfSequence_Action.add(partAct);
        tasksToCreate.add(CadenceService.getEmailTask(partAct.Id,partAct.Name,participantId,templateId));
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
            if (results != null && results.get(0).isSuccess()) {
                if(listOfSequence_Action != null && listOfSequence_Action.size()>0){
                	update listOfSequence_Action;
                }
                if(tasksToCreate != null && tasksToCreate.size()>0){
                	upsert tasksToCreate;
               }
            }
        }
        
        //Updating dates on remaining participant objects 
        List<Sequence_Action__c> sequenceActionList = CadenceSelector.getParticipantActions(new Set<Id>{sequenceActionId});
        Id participantIds  = (Id)participantId;
        String objType = participantIds.getSObjectType().getDescribe().getName();
        Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantAction(new Set<Id>{participantIds},objType);
        List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
        for(Sequence_Action__c sa : sequenceActionList) { 
            Id partId = sa.Lead_Id__c == null ? sa.Contact_Id__c : sa.Lead_Id__c; 
            saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, partActionsMap.get(partId)));
        }
        if(!saToUpdate.isEmpty()) {
            update saToUpdate;
        }
        return null;
    }
    
    public static Messaging.SingleEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId,Id mailCc,Id mailBcc){
        List<String> listofemailParticipant = new List<String>{sObjectId,mailCc,mailBcc}; 
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        String objName = sObjectId.getSObjectType().getDescribe().getName();
        for(Sobject sobj : Database.query('Select Id,Email,Name from '+objName +' where Id In :listofemailParticipant')){
            if(sobj.get('Id') == sObjectId && sobj.get('Email') != null){
                singleEmail.setToAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
            }
            if(sobj.get('Id') == mailCc && sobj.get('Email') != null){
              	singleEmail.setCcAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
            }
            else if(sobj.get('Id') == mailBcc && sobj.get('Email') != null){
            	singleEmail.setBccAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
            }
        }
        singleEmail.setTargetObjectId(sObjectId);
        singleEmail.setSaveAsActivity(false);
        singleEmail.setTemplateId(EmailTemplateId);
		return singleEmail; 
    }
    private static boolean isValidEmail(String participantId){
        Id participantIds ;
        if(participantId != null){
             participantIds = (Id)participantId;
        }
        String objName = participantIds.getSObjectType().getDescribe().getName();
        Sobject sobj = Database.query('Select Id,Email,Name from '+objName +' where Id =: participantIds');
      	if(sobj != null && sobj.get('Email') != null){
       		return true;
        }
        return false;
    }
    public static Map<String,String> getObjectFieldsType(String objType) {
        Map<String, String> objectFieldDataTypeMap = new Map<String,String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            Schema.sObjectField fieldAPIName = fieldMap.get(fieldName);
            String nameLable = fieldAPIName.getDescribe().getLabel();
            objectFieldDataTypeMap.put(nameLable, fieldAPIName.getDescribe().getName());
        }
        return objectFieldDataTypeMap;
    }
}