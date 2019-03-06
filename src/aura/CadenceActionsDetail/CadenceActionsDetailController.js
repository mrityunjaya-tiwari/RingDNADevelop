({
    doInit: function(component, event, helper) {
        var cadenceAction = component.get("v.cadenceAction");
        if(!(cadenceAction.Id)){           
            helper.sectionToggle(component, event,'detailDiv');
            
        }
        // To add a row by default
        helper.createRowToFieldsUpdate(component, event, helper);
        // Set contact felds data
        helper.setContactFieldsList(component, event, helper);
        // Set lead felds data
        helper.setLeadFieldsList(component, event, helper);
        // Used for edit cadence actions
        helper.setDataForEdit(component, event, helper);
        helper.createListForInput(component);
        //component.set("v.setFieldsToUpdate", true); 
        //component.set('v.fieldOptionsValue', true);
    },
    
    // Toggle details section 
    sectionToggle : function(component, event, helper) {
        helper.sectionToggle(component,event,'detailDiv');
    },
    
    // remove cadenceActions row
    removeRow : function(component, event, helper){
         component.set('v.showModal', true);
         
    },
    
    // Used to set cadence action object
    setActionObject : function(component, event, helper){       
        helper.setActionObject(component, event, helper);
    },
    // Added new row for set fields to update
    createRowToFieldsUpdate: function(component, event, helper){
        helper.createRowToFieldsUpdate(component, event, helper);
    },
    // used to remove rows from fields to update
    handleCadDynamicRowEvent: function(component, event, helper){
        helper.handleCadDynamicRowEvent(component, event, helper);
    },
    // Method is used to set 'Fields_To_Update_Action__c' and 'Action_Criterion__c' on cadenceAction object.
    // Also used for validation also
    getfieldsToUpdate: function(component, event, helper) {         
        var isValid = true;
        // Used to validate cadenceAction detail.
        isValid = helper.validateCADetail(component, event, helper);
        if (!isValid){
            return isValid;
        }
        var setFieldsToUpdate = component.get("v.setFieldsToUpdate");
        // used to set 'Fields_To_Update_Action__c'
        if (setFieldsToUpdate == true || setFieldsToUpdate == 'true'){
            isValid = helper.validateFieldsToUpdateComponent(component, event, helper);
            if (isValid){
                helper.setFieldsToUpdateJsonOnCadenceAction(component, event, helper);
            } else{
                return isValid;
            }
        }else{
            var cadenceAction= component.get("v.cadenceAction");
            cadenceAction.RDNACadence__Fields_To_Update_Action__c = '';
            component.set("v.cadenceAction", cadenceAction);
        }
        var setCriteriaFields = component.get("v.setCriteriaFields");
        if (setCriteriaFields == 'true' || setCriteriaFields == true ){
            isValid = helper.validateCriterion(component, event, helper);
            if (isValid){
                helper.setActionCriteria(component, event, helper);
            } else{
                return isValid;
            }
        }else{
            var cadenceAction= component.get("v.cadenceAction");
            cadenceAction.RDNACadence__Action_Criterion__c = '';
            component.set("v.cadenceAction", cadenceAction);
        }
        return isValid;
    },
    // Used to add and remove 'Fields to update' section.
    handleFieldSelectChange:function(component, event, helper){
        component.set("v.setFieldsToUpdate",component.get("v.fieldOptionsValue"));
    },
    // Used to add and remove 'action criteria section' section.
    handleCriteriaSelectChange:function(component, event, helper){
        component.set("v.setCriteriaFields",component.get("v.criteriaOptionsValue"));
    },
    // used to disable input for immediate cadence actions.
    disablUnitInput:function(component, event, helper){
        helper.disablUnitInput(component, event, helper);
    },
    
    updatePriorityNumber:function(component, event, helper){        
        var cadenceAction= component.get("v.cadenceAction");             
        if(cadenceAction.RDNACadence__Priority__c == 'High' ){          
            component.set("v.cadenceAction.RDNACadence__Priority_number__c", 1);          
        }
        else if(cadenceAction.RDNACadence__Priority__c == 'Medium'){
            component.set("v.cadenceAction.RDNACadence__Priority_number__c", 2);            
        }
        else{
            component.set("v.cadenceAction.RDNACadence__Priority_number__c", 3);            
        }
        component.set("v.cadenceAction",cadenceAction);       
    },
    listUpdated : function(component, event, helper){
        var cadenceActionObj = component.get("v.cadenceAction");
        var currentIndex = component.get('v.currentIndex');
        cadenceActionObj.RDNACadence__Index__c = currentIndex;
    },
    
    deleteActions: function(component, event, helper) {
        var pageIndex = component.get("v.currentIndex");
        var eventObj = component.getEvent("cadDynamicRowEvent");
        var cadenceAction = component.get("v.cadenceAction");
        if((cadenceAction.Id)){
            var caIdsList = component.get("v.caIdsList");
            caIdsList.push(cadenceAction.Id);
            component.set("v.caIdsList", caIdsList);
        }
        eventObj.setParams({
            ronIndex: pageIndex
        }).fire();
    },
    
    cancelActionDeletion : function(cmp, event, helper) {
        cmp.set('v.showModal', false);
        
    },
    
    
})