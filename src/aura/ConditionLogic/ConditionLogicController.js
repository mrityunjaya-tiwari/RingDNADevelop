({
	myAction : function(component, event, helper) {
		
	},
	
	validateConditions : function(component, event, helper) {
		var a = component.find('formValidationId');
		if(a === undefined) {
			return true;
		}
		var isValid = a.get('v.validity').valid;
		a.showHelpMessageIfInvalid();
        return isValid;
	},
	
})