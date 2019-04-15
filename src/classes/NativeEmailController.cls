public class NativeEmailController {
    @AuraEnabled
    public static Boolean sendEmail(String mailTo, String mailCc, String mailBcc, String subject, String body,String participantId,String templateId,String sequenceActionId){
        Boolean isNativeEmailSend =CadenceService.SendNativeEmail(New list<NativeEmailMessage>());
        if(isNativeEmailSend != null && !isNativeEmailSend){
            sendSfdcEmail(participantId,templateId,sequenceActionId);
            return true;
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
    
    public static void sendSfdcEmail(String participantId,string templateId,string sequenceActionId){
        List<Messaging.MassEmailMessage> emailsToSend = new  List<Messaging.MassEmailMessage>();
        List<Sequence_Action__c> listOfSequence_Action = new List<Sequence_Action__c>();
        emailsToSend.add(createEmailMessage(participantId,templateId));
        Sequence_Action__c partAct = new Sequence_Action__c(Id=sequenceActionId);
        partAct.Actual_Execution_Date__c = System.Now();
        partAct.isActionPerformed__c = true;
        listOfSequence_Action.add(partAct);
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
            if (results != null && results.get(0).isSuccess()) {
                if(listOfSequence_Action != null && listOfSequence_Action.size()>0){
                    update listOfSequence_Action;
                }
            }
        }
    }
    
    public static Messaging.MassEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId){
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectIds(new List<Id>{sObjectId});
        mail.setTemplateId(EmailTemplateId);
        return mail; 
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