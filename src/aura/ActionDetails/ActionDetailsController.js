({
    doInit: function(component, event, helper) {
        component.set('v.disableActivationType', false);
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
                component.set('v.listEmailTemplate', actionWrapper.listEmailTemplate);
                component.set('v.listSmsTemplate', actionWrapper.listSmsTemplate);
                component.set('v.listCallTemplate', actionWrapper.listCallTemplate);
                component.set('v.listVMTemplate', actionWrapper.listVMTemplate);
                component.set('v.UpdateFieldList', actionWrapper.wrapperTaskFields); 
                component.set('v.listToShowInTemplateType', actionWrapper.listSmsTemplate);
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
        $A.enqueueAction(action)
    },
    
    clickCreate: function(component, event, helper) {
        
        var newAct = component.get("v.newAction");
        var name = newAct.name;
        if (name){
            newAct.name = name.trim();
        }
        component.set("v.newAction", newAct);
        var isValidActioin = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
            
        }, true);
        if(isValidActioin && newAct.type == 'Task'){
            isValidActioin = helper.validateFieldsToUpdateComponent(component, event, helper);
        }
        if(isValidActioin){
            helper.createAction(component, event,helper);
        }
    },
    
    createAction : function(component, event,helper) {
        helper.createAction(component, event,helper);
    },
    updateActionType: function (component, event, helper) {
        helper.updateActionType(component, event, helper);       
    },
    AddNewRow : function(component, event, helper){
        helper.createObjectData(component, event);    
    },
    removeRow : function(component, event, helper){
        helper.removeDeletedRow(component, event); 
    },
    onCancel: function(component, event, helper){
        helper.onCancel(component, event);
    },
    handleCadDynamicRowEvent: function(component, event, helper){
        helper.handleCadDynamicRowEvent(component, event, helper);
    },
})