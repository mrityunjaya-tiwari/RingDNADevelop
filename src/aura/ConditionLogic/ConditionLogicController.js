({
	myAction : function(component, event, helper) {
		
	},
	
	validateConditions : function(component, event, helper) {
		console.log('I am in validate condition');
		var a = component.find('formValidationId');
		console.log('@@@@@a is = '+a);
		if(a === undefined) {
			return true;
		}
		var isValid = a.get('v.validity').valid;
		a.showHelpMessageIfInvalid();
        return isValid;
	},
	
})