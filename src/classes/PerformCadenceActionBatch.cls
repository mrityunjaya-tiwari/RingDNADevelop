public class PerformCadenceActionBatch implements Database.Batchable<sObject>, Database.stateful {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    public String objType;

    public PerformCadenceActionBatch(String objType) {
        this.objType = objType;
    }
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = formQuery(objType);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> objList) {
        CadenceService.processParticipantsWithCadences(objList, objType, false);
    }
    
    public void finish(Database.BatchableContext bc) {
    }
     
    private String formQuery(String objType){
        
        Set<String> allowedFields = new Set<String>();
        String query = 'Select ';
        SObjectType r = ((SObject)(Type.forName('Schema.'+objType).newInstance())).getSObjectType();
        Map<String, Schema.SObjectField> fieldMap  = r.getDescribe().fields.getMap();
        
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                continue; 
            }
            String fieldName = fieldDescribe.getName();
            allowedFields.add(fieldName);
        }
        query += String.join(new List<String>(allowedFields), ',');
        query += ' FROM '+ objType + ' WHERE '+nameSpace+'isActivated__c = true';
        return query;
    } 
}