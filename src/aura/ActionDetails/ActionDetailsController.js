({
    doInit: function(component, event, helper) {
		var id = component.get('v.recordId');
        component.get('v.disableActionType');
    },
    createCallAction : function(component, event,helper) {
        helper.createCallAction(component, event,helper);
    },
    createEmailAction : function(component, event,helper) {
        helper.createEmailAction(component, event,helper);
    },
    createSMSAction : function(component, event,helper) {
        helper.createSMSAction(component, event,helper);
    },
    createTaskAction : function(component, event,helper) {
        helper.createTaskAction(component, event,helper);
    },
    isNextStepEnable  : function(component, event,helper) {
        var action = component.get('v.newAction');
        if(action.type != undefined && action.type !='' && action.name != undefined && action.name !='' ){
            component.set('v.isNextEnable' , true); 
        }
        else{
            component.set('v.isNextEnable' , false);  
        }
    },
    createAction :function(component, event,helper) {
        var actionType = component.get('v.newAction.type');
       	if(actionType =='Call'){
             helper.createCallAction(component, event,helper);
        }
        else if(actionType =='Email'){
             helper.createEmailAction(component, event,helper);
        }
        else if(actionType =='SMS'){
             helper.createSMSAction(component, event,helper);
        }
        else if(actionType =='Task'){
             helper.createTaskAction(component, event,helper);
        }
    }
})