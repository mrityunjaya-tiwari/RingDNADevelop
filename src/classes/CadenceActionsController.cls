public class CadenceActionsController {
    @AuraEnabled
    public static CadenceActionWrapper getActionList(){
        List<action__C> actionList = [Select id, Name, type__C from Action__C];
        CadenceActionWrapper wrapperObj = new CadenceActionWrapper();
        wrapperObj.actionList = actionList;
        wrapperObj.actionTypeList = getActionTypeList(actionList);
        return wrapperObj;
    } 
    public class CadenceActionWrapper{
        @AuraEnabled public List<action__C> actionList;
        @AuraEnabled public List<string> actionTypeList;
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
}