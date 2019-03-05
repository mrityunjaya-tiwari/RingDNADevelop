({
    doInit: function(component, event, helper) {
        component.set('v.disableActivationType', false);
        var listEmailTemplate;
        var id = component.get('v.recordId');
        var action = component.get("c.initCadenceActionData");
        helper.createObjectData(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                listEmailTemplate= response.getReturnValue();
                component.set('v.listEmailTemplate', listEmailTemplate.listEmailTemplate);
                component.set('v.listSmsTemplate', listEmailTemplate.listSmsTemplate);
                component.set('v.listCallTemplate', listEmailTemplate.listCallTemplate);
                component.set('v.listVMTemplate', listEmailTemplate.listVMTemplate);
                component.set('v.wrapperTaskFields', listEmailTemplate.wrapperTaskFields);
                component.set('v.listToShowInTemplateType', listEmailTemplate.listSmsTemplate);
                if(id != null) {
                    if(id != '') {
                        component.set('v.disableActionType' , true);
    	                helper.getData(component, event, helper, id);  
		            }
                }               
            }
        });
        $A.enqueueAction(action)
    },
    
    clickCreate: function(component, event, helper) {        
        var newAct = component.get("v.newAction");
        var name = newAct.Name;
        newAct.Name = name.trim();
        component.set("v.newAction", newAct);
        var isValidAction = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
            
        }, true);
        if(isValidAction && newAct.RDNACadence2__Type__c == 'Task'){
            isValidAction = helper.validateFieldsToUpdateComponent(component, event, helper);
        }
        if(isValidAction){
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