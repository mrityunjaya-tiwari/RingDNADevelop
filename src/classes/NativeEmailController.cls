public class NativeEmailController {
    @AuraEnabled
    public static Boolean sendEmail(String mailTo, String mailCc, String mailBcc, String subject, String body,String participantId,String templateId){
        Boolean isNativeEmailSend =sendEmailDirectly(mailTo, mailCc, mailBcc, subject, body);
        if(isNativeEmailSend != null && !isNativeEmailSend){
           sendEmailSfdc(participantId,templateId);
            return true;
        }
        
        return null;
    }
    
    public class CadenceTypeWrapper {
        @AuraEnabled public String recordType;
        @AuraEnabled public String sequenceActionAPI;
        @AuraEnabled public String recordTypeAPI;
        @AuraEnabled public String emailTemplateData;
    }
    
    @AuraEnabled
    public static CadenceTypeWrapper getData(String participantId,String emailTemplateId){
        Id pId = Id.ValueOf(participantId);
        Sequence_Action__c sequenceAction=[SELECT Cadence_Type__c FROM Sequence_Action__c WHERE Lead_ID__c = :pId OR Contact_Id__c =: pId LIMIT 1];
        EmailTemplate emailTemp = [Select id,Body from EmailTemplate where id=:emailTemplateId];
        CadenceTypeWrapper obj=new CadenceTypeWrapper();
        obj.recordType=sequenceAction.Cadence_Type__c;
        obj.sequenceActionAPI=cadenceConstants.NAMESPACE+'Sequence_Action__c';
        
        if(obj.recordType=='Contact'){
            obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Contact_Id__c';
        }else{
            obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Lead_Id__c';
        }
        if(emailTemp != null)
        obj.emailTemplateData = emailTemp.Body != null ? resolveMergeFields(participantId, emailTemp.Body):''; //new change

        System.debug('Object---'+obj);
        return obj;
    }
    
    public static String resolveMergeFields(String pid, String body){
        
        String objectName=Id.valueOf(pid).getSObjectType().getDescribe().getName();
        Map<String,String> mapofFieldsWithLabels = getObjectFieldsType(objectName);
        System.debug('mapofFieldsWithLabels key '+mapofFieldsWithLabels.keyset());
        System.debug('mapofFieldsWithLabels'+mapofFieldsWithLabels.values());
        String queryFields='';
        String query='SELECT Id';
        while(body.substringBetween('{!','}')!=null){
            String exp=body.substringBetween('{!','}');
            String obj=exp.substringBefore('.');
            System.debug('obj'+obj);
            if(mapofFieldsWithLabels.containskey(obj) || objectName.endsWithIgnoreCase(obj)){
                System.debug('Test'+mapofFieldsWithLabels.get(obj));
                query =','+mapofFieldsWithLabels.get(obj);
            }
            String field=exp.substringAfter('.');
            if(obj==objectName){
                queryFields+= ', '+cadenceConstants.NAMESPACE+field;
                body=body.replace('{!'+exp+'}','{@'+exp+'}');
            }else{
                body=body.replace('{!'+exp+'}','');
            }
        }
        //queryFields=queryFields.removeEnd(', ');    
        query= query+' FROM '+ objectName 
                +' WHERE Id = :pid' ;
        System.debug('query--'+query);
        sObject obj=Database.query(query);
        System.debug(obj);
        while(body.substringBetween('{@','}')!=null){
            String exp=body.substringBetween('{@','}');
            body=body.replace('{@'+exp+'}',(String)obj.get(exp.substringAfter('.')));
        }
           
        System.debug('body--'+body);  
        return body;
        
    }
    
    @AuraEnabled
    public static Boolean sendEmailDirectly(String mailTo, String mailCc, String mailBcc, String subject, String body){
        return false;
    }
    
    @AuraEnabled
    public static Boolean Cancel(Boolean isCancel){
        return isCancel;
    }
    
    Public static void sendEmailSfdc(String participantId,String templateId){
        Id partId = participantId;
        Id templateIds = templateId ;
        List<Messaging.MassEmailMessage> emailsToSend = new  List<Messaging.MassEmailMessage>();
        emailsToSend.add(createEmailMessage(partId,templateIds));
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
            System.debug('emailsToSend'+emailsToSend);
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