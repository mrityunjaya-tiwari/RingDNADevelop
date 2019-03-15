({
    doInit: function(component, event, helper){
        helper.getCadenceActionsData(component, event, helper);
    },
    
    // Use to set action type according to button input and add new cadenceAction for cadence
    AddNewCadenceActions: function (component, event, helper) {
        component.set('v.isValidationError', false);
        var selectedActionType = event.getParam("value");
        var rowList = component.get("v.cadenceActionList");
        rowList.push({
            'sobjectType': 'SequenceAction'
        });
        var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");
        actionTypeListForCadenceAction.push(selectedActionType);
        component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);
        component.set("v.actionType", selectedActionType);
        component.set("v.cadenceActionList", rowList);
    },
    handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowList = component.get("v.cadenceActionList");
        var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");
        actionTypeListForCadenceAction.splice(ronIndex, 1);
        component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);
        rowList.splice(ronIndex, 1);
        component.set("v.cadenceActionList", rowList);
        helper.updateCadenceActionIndex(component, event, helper);
    }, 
    // Method is use to validate form and set cadenceAction object
    createCadenceAction:function(component, event, helper){
        var isValid = helper.validateCadenceActionComponent(component, event, helper);
        return isValid;
    },
    createNewAction : function(component, event, helper){
       component.set('v.createAction', true); 
        
    }
})