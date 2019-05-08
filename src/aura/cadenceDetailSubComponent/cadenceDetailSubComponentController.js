({
	myAction : function(component, event, helper) {
		
	},
    validateForm: function(component, event, helper) {
        var validExpense = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(validExpense){
            var eventObj = component.getEvent("cadDynamicRowEvent");
            eventObj.setParams({
                isValid: true
            }).fire();
        }else{
            var eventObj = component.getEvent("cadDynamicRowEvent");
            eventObj.setParams({
                isValid: false
            }).fire();
        }
    },
})