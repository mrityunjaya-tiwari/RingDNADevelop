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
                    component.set('v.isNextEnable' , true); 
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
        var currentStep = component.get('v.currentStep');
       	if(currentStep =='1' || currentStep==1){
            var childCmp = component.find("newActionDetails");
            childCmp.actionDetailsMethod();  
        }
        else{
            var isValid = helper.validateEmailActionBuilder(component, event,helper);
            if (isValid){
                component.set('v.isNextEnable' , false);
                component.set('v.isEmailTemplateList' , true);
            } else {
                component.set('v.isValidationError',true);
            }
        } 
    },
    clickBack: function(component, event, helper){
       	var EmailTemplateList = component.get('v.isEmailTemplateList');
        if(EmailTemplateList == true){
            component.set('v.isEmailTemplateList', false);
            component.set('v.isNextEnable', true);
        }
        else{
        }
    },
    createAction: function(component, event, helper) {
        var newAct = component.get("v.newAction");
        var isValid;
        if(newAct.type == 'Email'){
            if(newAct.templateId != undefined && newAct.templateId != ''){
                isValid = true;
            }
            else{
                isValid = false;
                component.set('v.isValidationError',true);
            }          
        }else if(newAct.type == 'Task'){
            var taskActionDetails = component.find("taskActionDetails");
            if (taskActionDetails){
                isValid = taskActionDetails.validationTask();
            }
        }else{
            isValid = true;
        }
        if (isValid){
            helper.createAction(component, event,helper);
        }
    },
})
