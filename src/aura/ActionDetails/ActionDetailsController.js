({
    doInit: function(component, event, helper) {
        component.set('v.disableActivationType', false);
        component.set('v.spinner', true);
        var listEmailTemplate;
        var id = component.get('v.recordId');
        var action = component.get("c.initCadenceActionData");
        helper.createObjectData(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                listEmailTemplate= response.getReturnValue();
                //console.log('listEmailTemplate.listEmailTemplate:'+ JSON.stringify(listEmailTemplate.listEmailTemplate));
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
                component.set('v.spinner', false);
            }else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action)
    },
    
    clickCreate: function(component, event, helper) {
        
        var newAct = component.get("v.newAction");
        var name = newAct.Name;
        newAct.Name = name.trim();
        component.set("v.newAction", newAct);
        var isValidActioin = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
            
        }, true);
        if(isValidActioin && newAct.RDNACadence2__Type__c == 'Task'){
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