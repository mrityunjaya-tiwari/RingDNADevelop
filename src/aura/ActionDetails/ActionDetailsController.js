({
    doInit: function(component, event, helper) {
		var id = component.get('v.recordId');
        component.get('v.disableActionType');
    },
    selectCallAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == undefined || newAct.id == ''){
            component.set('v.newAction.type', 'Call');
        }
        helper.actionNextBtnEnable(component, event,helper);
    },
    selectEmailAction : function(component, event,helper) {
       var newAct = component.get("v.newAction");
       if(newAct.id == undefined || newAct.id == ''){
        	component.set('v.newAction.type', 'Email');
        }
        helper.actionNextBtnEnable(component, event,helper);
    },
    selectSMSAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == undefined || newAct.id == ''){
        	component.set('v.newAction.type', 'SMS');
        }
        helper.actionNextBtnEnable(component, event,helper);
    },
    selectTaskAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == undefined || newAct.id == ''){
        	component.set('v.newAction.type', 'Task');
        }
        helper.actionNextBtnEnable(component, event,helper);
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