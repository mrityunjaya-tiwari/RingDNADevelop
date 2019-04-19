public class PerformCadenceActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    public String objType;
    public String parentObj;
    public list<string> listOfobjecttype;
    
    public PerformCadenceActionBatch(List<String> listOfObjTypeAndParent) { 
        this.listOfobjecttype = listOfObjTypeAndParent; 
         if(listOfObjTypeAndParent != null && listOfObjTypeAndParent.size() > 0)
             this.objType=listOfObjTypeAndParent[0];
    }
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //String query = formQuery(objType, parentObj);
        //Set<string>  ids =new Set<string>{'0060o00001E3CrdAAF'}; 
        String query = formQuery(listOfobjecttype) ;//+' where id IN :ids';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> objList) {
        system.debug('execute');
        Map<Id, SObject> parentMap = new Map<Id, SObject>();
        CadenceService.processParticipantsWithCadences(objList, parentMap, objType, false);
       
    }
    
    public void finish(Database.BatchableContext bc) {
    }
    
    public static String formQuery(List<String> objList){
        List<CriterionWrapper> criterionWrapperList =  CadenceService.getFieldsWithLabelsForBatch(objList);
        String objecttype;
        if(objList != null && objList.size() > 0)
            objecttype=objList[0];
        String query = 'Select ';
        Set<String> allowedFields = new Set<String>();
        for(CriterionWrapper wrapper : criterionWrapperList ){
            for(Criterion criteria : wrapper.fieldsDetail ){
                //query += criteria.fieldName + ',';
                allowedFields.add(criteria.fieldName);
            }
        }
        //query = query.substring(0,query.length()-1);
        if(nameSpace != ''  && allowedFields.size() > 0){
            String apiNameWithNamespace;
            for(String fld : allowedFields){
                apiNameWithNamespace = nameSpace + fld;
                if(allowedFields.contains(apiNameWithNamespace)){
                    allowedFields.remove(fld); 
                }
            }
        }
        query += String.join(new List<String>(allowedFields), ',');
        query += ' FROM '+ objecttype + '';
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