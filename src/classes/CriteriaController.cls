public with sharing class CriteriaController {
    @AuraEnabled
    public static List<Criterion> getFields(String objectStr){
    	List<Criterion> criterions = CadenceService.getFieldsWithLabels(objectStr);
        return criterions;
    }
    
    
}