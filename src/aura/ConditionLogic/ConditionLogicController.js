({
   	 validateConditions : function(component, event, helper) {
        var sc = component.get('v.selectedCondition');
        if (sc == 'Custom logic'){
            helper.valueChangeValidation(component, event, helper);
        }
        
        var a = component.find('formValidationId');
        if(a === undefined) {
            return true;
        }
        var isValid = a.get('v.validity').valid;
        a.showHelpMessageIfInvalid();
        
        return isValid;
    },
      
    valueChangeValidation : function(component, event, helper) {
        helper.valueChangeValidation(component, event, helper);     
    },
    
    valueChangeCriteriaList : function(component, event, helper) {
       helper.valueChangeCriteriaList(component, event, helper);
	}
    

})