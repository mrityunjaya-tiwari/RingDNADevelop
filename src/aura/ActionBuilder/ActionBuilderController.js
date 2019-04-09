({
    doInit: function(component, event, helper) {
        component.set('v.spinner', true);
        var actionWrapper;
        var id = component.get('v.recordId');
        var action = component.get("c.getActionWrapper");
        helper.createObjectData(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                actionWrapper= response.getReturnValue();
                component.set('v.newAction', actionWrapper.action);
                if(id != null) {
                    if(id != '') {
                        component.set('v.disableActionType' , true);
                        helper.getData(component, event, helper, id);                       
                    }
                }
                component.set('v.spinner', false);
            }else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    onCancel: function(component, event, helper){
        helper.onCancel(component, event);
    },
    onNext: function(component, event, helper){
        var isValid = helper.validateEmailActionBuilder(component, event,helper);
        if (isValid){
            component.set('v.isNextEnable' , false);
        } else {
            component.set('v.isValidationError',true);
        }
    },
    clickBack: function(component, event, helper){
        component.set('v.currentStep','1');
        var currentStep = component.get('v.currentStep');
    },
    createAction: function(component, event, helper) {
        helper.createAction(component, event,helper);
    },
})