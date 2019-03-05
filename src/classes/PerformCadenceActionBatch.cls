public class PerformCadenceActionBatch implements Database.Batchable<sObject>, Database.stateful {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    public String objType;
    public String parentObj;

    public PerformCadenceActionBatch(String objType, String parentObj) { 
        this.objType = objType; 
        this.parentObj = parentObj;  
    }
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = formQuery(objType, parentObj);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> objList) {
        Map<Id, SObject> parentMap = new Map<Id, SObject>();
        CadenceService.processParticipantsWithCadences(objList, parentMap, objType, false);
    }
    
    public void finish(Database.BatchableContext bc) {
    }
     
    public String formQuery(String objType, String parentObj){
        String query = 'Select ';
        List<String> allowedFields = new List<String>(getObjectFields(objType, false));
        query += String.join(allowedFields, ',');
        if(parentObj != null && !parentObj.equals('')) {
            allowedFields = new List<String>(getObjectFields(parentObj, true));
            if(!allowedFields.isEmpty()) {
                query = query+',';
	            query += String.join(allowedFields, ',');
	        }
        }	
        query += ' FROM '+ objType ; 
        return query;
    }
    
    public static Set<String> getObjectFields(String objType, Boolean parentField) {
        Set<String> allowedFields = new Set<String>();
        SObjectType r;
        try {
            r = ((SObject)(Type.forName('Schema.'+objType).newInstance())).getSObjectType();
        } catch(Exception e) {
            return allowedFields;
        }
        
        Map<String, Schema.SObjectField> fieldMap  = r.getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                continue; 
            }
            if(parentField) {
            	allowedFields.add(objType + '.' + fieldDescribe.getName());    
            } else {
                allowedFields.add(fieldDescribe.getName());
            } 
        }
        return allowedFields;
    }
    
    
}