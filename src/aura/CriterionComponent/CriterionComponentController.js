({
	doInit: function(component, event, helper) {
       // helper.updateCriteriaList(component, event, helper);
		helper.initializeCriteriaList(component,helper);
    },
	
	loadFields : function(component, event, helper){
		var recordType = event.getParam("recordType");
		helper.getObjectFields(component, recordType);
	},
	
	handleDynamicRowEvent: function(component, event, helper){
        helper.handleCadDynamicRowEvent(component, event, helper);
    },
    
    AddNewRow : function(component, event, helper){
        helper.createObjectData(component, helper, event);    
    }, 
    
    getCriteriaList: function(component, event, helper){
    
    },
	
	validateCriterion : function(component, event, helper) {
		var isValid = true;
		var criterions = component.find("dynamicRow");
       console.log('criterions', JSON.stringify(criterions));
		if(criterions == undefined) {
			return false;
		}
		if(criterions.length === undefined) {
			var temp = criterions.validateForm();
			if(!temp) {
				isValid = false;
			}
		} else {
			for(var i=0; i<criterions.length; i++) {
                /*if(criterions[i]== criterions[i+1]){
                    console.log('equal');
                    isValid = false;
                }*/
				var temp1 = criterions[i].validateForm();
                
				if(!temp1) {
					isValid = false;
				}
			}
		} 
		
		var customLogic = component.find("customLogic");
		var customValid = customLogic.validateConditions();
		if(!customValid) {
			isValid = false;
		}
		return isValid;
	}
	
})