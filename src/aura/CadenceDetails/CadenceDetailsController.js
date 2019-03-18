({
    doInit : function(component, event, helper) {
        var cadenceObj = component.get("v.newCadence");
        if(cadenceObj.Id !=null){
            component.set('v.disableCadenceType' , true);
        }
        helper.createListForInput(component);
    },
    validateForm: function(component, event, helper) {
		var cadenceObj = component.get("v.newCadence");
        var name = cadenceObj.name;
        cadenceObj.name = name.trim();
        component.set("v.newCadence", cadenceObj);
        var isValid = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (isValid){
            //helper.fireRecordTypeChangedEvent(component, event, helper);
            component.set('v.disableCadenceType' , true);
        }
        return isValid;
    },
    
    fireRecordTypeChangedEvent: function(component, event, helper) {
        helper.fireRecordTypeChangedEvent(component, event, helper);
    },
    
    setFocus: function(component, event, helper) {
        var a = component.find("formValidationId");
        a[1].focus();
   },
})
