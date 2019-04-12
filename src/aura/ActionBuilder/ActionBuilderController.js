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
            component.set('v.isEmailTemplateList' , true);
        } else {
            component.set('v.isValidationError',true);
        }
    },
    clickBack: function(component, event, helper){
       var EmailTemplateList = component.get('v.isEmailTemplateList'); 
        if(EmailTemplateList == true){
            component.set('v.isEmailTemplateList', false);
            component.set('v.isNextEnable', true);
        }
        else{
           component.set('v.currentStep','1'); 
        }
    },
    createAction: function(component, event, helper) {
       var newAct = component.get("v.newAction");
       if(newAct.type == 'Email'){
            if(newAct.templateId != undefined && newAct.templateId.length > 0){
            	helper.createAction(component, event,helper);
            }
            else{
                component.set('v.isValidationError',true);
            }          
        }
        else{
            helper.createAction(component, event,helper);
        }
    },
})