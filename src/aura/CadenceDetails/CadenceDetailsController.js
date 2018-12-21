({
    doInit : function(component, event, helper) {
        var cadenceObj = component.get("v.newCadence");
        if(cadenceObj.Id !=null){
            component.set('v.disableCadenceType' , true);
        }
        helper.createListForInput(component);
    },
    validateForm: function(component, event, helper) {
        var isValid = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (isValid){
            helper.fireRecordTypeChangedEvent(component, event, helper);
            component.set('v.disableCadenceType' , true);
        }
        return isValid;
    },
    
    fireRecordTypeChangedEvent: function(component, event, helper) {
        helper.fireRecordTypeChangedEvent(component, event, helper);
    },
    
    
})