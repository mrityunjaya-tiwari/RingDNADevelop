({
    doInit: function(component, event, helper){
        /*component.set('v.spinner',true);
        var action = component.get("c.getActionList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionWrapper = response.getReturnValue();
                component.set('v.actionList', actionWrapper.actionList);
                component.set('v.actionTypeList', actionWrapper.actionTypeList);                
                component.set('v.contactFieldList', actionWrapper.contactCriListSA);
                component.set('v.leadFieldList', actionWrapper.leadCriListSA);
                helper.setDataToEdit(component, event, helper);
                //component.set('v.spinner',false);
            } else{
                //component.set('v.spinner',false);
            }
            
             component.set('v.ISLoad', true);
            component.set('v.spinner',false);
        });
        //Sprint198-What is the use of this: newCadence
        //var newCadence = component.get("v.newCadence");
        $A.enqueueAction(action)*/
        helper.doInitNew(component, event, helper);
    },
    // Use to set action type according to button input and add new cadenceAction for cadence
    AddNewCadenceActions: function (component, event, helper) {
        component.set('v.isValidationError', false);
        var selectedActionType = event.getParam("value");
        var rowList = component.get("v.cadenceActionList");
        rowList.push({
            'sobjectType': 'RDNACadence2__CadenceAction__c'
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