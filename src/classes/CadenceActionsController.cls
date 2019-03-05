public class CadenceActionsController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    @AuraEnabled
    public static CadenceActionWrapper getActionList(){
        List<action__C> actionList = [Select id, Name, type__C, Activation_Type__c from Action__C];
        CadenceActionWrapper wrapperObj = new CadenceActionWrapper();
        wrapperObj.actionList = actionList;
        wrapperObj.actionTypeList = getActionTypeList(actionList);
        wrapperObj.contactCriListSA = CadenceController.getFieldsForSA(CadenceConstants.CONTACT_OBJECT_NAME);
        wrapperObj.leadCriListSA = CadenceController.getFieldsForSA(CadenceConstants.LEAD_OBJECT_NAME);
        return wrapperObj;
    } 
    public class CadenceActionWrapper{
        @AuraEnabled public List<action__C> actionList;
        @AuraEnabled public List<string> actionTypeList;
        @AuraEnabled public List<Criterion>  contactCriListSA;
        @AuraEnabled public List<Criterion>  leadCriListSA;
    }
    public static List<String> getActionTypeList(List<Action__C> actionList){
        List<String> actionTypeList = new List<String>();
        for (Action__C actObj : actionList){
            if(!actionTypeList.contains(actObj.type__c)){
                actionTypeList.add(actObj.type__c);
            }
        }
        return actionTypeList;
    }
   
    @AuraEnabled
    public static UiInputList createListForUIInput(){
        UiInputList uilObj = new UiInputList();
        uilObj.pList = CadenceService.getPicklistValues(nameSpace+'CadenceAction__c', nameSpace+'Priority__c');
        return uilObj;
    }
    
    public class UiInputList{
        @AuraEnabled
        public List<String> pList;        
        public UiInputList(){
        pList = new List<String>();           
        }
    }
    
    public class CadenceActionWrapperNew{
        @AuraEnabled public List<action__C> actionList;
        @AuraEnabled public List<string> actionTypeList;
        @AuraEnabled public List<CriterionWrapper> fieldList = New List<CriterionWrapper>{New CriterionWrapper()};
    }
    
    @AuraEnabled
    public static CadenceActionWrapperNew getActionListNew(String type){
        System.debug('getActionListNew:Type='+type);
        List<action__C> actionList = [Select id, Name, type__C, Activation_Type__c from Action__C];
        CadenceActionWrapperNew wrapperObj = new CadenceActionWrapperNew();
        wrapperObj.actionList = actionList;
        wrapperObj.actionTypeList = getActionTypeList(actionList);
        wrapperObj.fieldList = CadenceController.getFieldsForSANew(type);
        return wrapperObj;
    } 
 
}