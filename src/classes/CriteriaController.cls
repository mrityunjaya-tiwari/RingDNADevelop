public with sharing class CriteriaController {
    @AuraEnabled
    public static List<Criterion> getFields(String objectStr){
    	List<Criterion> criterions = CadenceService.getFieldsWithLabels(objectStr);
    	System.debug('### criterions '+ criterions);
        
        return criterions;
    	//return CadenceService.getFieldsWithLabels(objectStr);
    }
    
    
}