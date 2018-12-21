public with sharing class ActionDetailController {

	public static String nameSpace = CadenceConstants.NAMESPACE;
    public static String TASK_OBJECT_STRING = 'Task';

    @AuraEnabled
    public static ActionDetailController.InitActionData initCadenceActionData() {
        ActionDetailController.InitActionData initActionObj = new ActionDetailController.InitActionData();
        initActionObj.listEmailTemplate = CadenceService.getEmailTemplates();
        initActionObj.wrapperTaskFields = CadenceService.getFields(TASK_OBJECT_STRING);
        return initActionObj;
    }

    public class InitActionData {
        @AuraEnabled public List<EmailTemplate> listEmailTemplate;
        @AuraEnabled public List<wrapperTaskField> wrapperTaskFields;
        public InitActionData(){
            listEmailTemplate = new List<EmailTemplate>();
            wrapperTaskFields = new List<wrapperTaskField>();
        }
    }

    @AuraEnabled
    public static Action__c saveAction(Action__c act, Task taskObj) {
        if (act.Type__c == TASK_OBJECT_STRING){
            Task taskObjToCreateJson = taskObj;
            act.Task_Description__c = JSON.serialize(taskObjToCreateJson);
        }
        upsert act;
        return act;
    }
    public class wrapperTaskField {
        @AuraEnabled public String key;
        @AuraEnabled public String value;
        @AuraEnabled public String dataType;
        @AuraEnabled public List<String> listPicklistValues;
    }

    public static void updateFieldValue(SObject obj, String fieldName, String value, String fieldType) {
		system.debug(fieldType);
        if(fieldType.equalsIgnoreCase('currency') || fieldType.equalsIgnoreCase('double') || fieldType.equalsIgnoreCase('percent') || fieldType.equalsIgnoreCase('decimal')) {
            obj.put(fieldName, Decimal.valueOf(value)); 
        } else if(fieldType.equalsIgnoreCase('boolean')) {
            obj.put(fieldName, boolean.valueOf(value));
        } else if(fieldType.equalsIgnoreCase('date')) {
            obj.put(fieldName, date.valueOf(value));
        } else if(fieldType.equalsIgnoreCase('datetime')) {
            obj.put(fieldName, datetime.valueOf(value));
        } else if(fieldType.equalsIgnoreCase('integer') || fieldType.equalsIgnoreCase('Number') ) {
            obj.put(fieldName, Integer.valueOf(value));
        } else if(fieldType.equalsIgnoreCase('reference')){
            obj.put(fieldName, ID.valueOf(value));
        } else {
            obj.put(fieldName, value);
        }   
    }
    
    @AuraEnabled
    public static ActionDetailController.ActionDataWrapper getActionData(Id actionId) {
        ActionDetailController.ActionDataWrapper actionDataWrapper = new ActionDetailController.ActionDataWrapper();
        Action__c action = [Select Id, Name, Activation_Type__c, Task_Description__c, Template_Id__c, Template_Name__c, Type__c From Action__c where Id = :actionId];
        actionDataWrapper.action = action;	
        if((action.Task_Description__c != null) && action.Task_Description__c != '') {
	        Map<String, Object> taskObjs = (Map<String, Object>)JSON.deserializeUntyped(action.Task_Description__c);
            taskObjs.remove('attributes');
            List<wrapperTaskField> wrapperTaskFieldObjs = new List<wrapperTaskField>();
            for(String key : taskObjs.keySet()) {
                wrapperTaskField wrapperTaskFieldObj = new wrapperTaskField();
                wrapperTaskFieldObj.key = key;
                wrapperTaskFieldObj.value = String.valueOf(taskObjs.get(key));
                wrapperTaskFieldObjs.add(wrapperTaskFieldObj);
            }
			actionDataWrapper.taskList = wrapperTaskFieldObjs;              
        }
        return actionDataWrapper;
    }
    public class ActionDataWrapper {
        @AuraEnabled public Action__c action;
        @AuraEnabled public List<wrapperTaskField> taskList; 
    }
}