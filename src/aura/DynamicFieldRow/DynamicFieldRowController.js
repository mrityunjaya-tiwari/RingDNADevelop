({
	doInit: function(component, event, helper) {
		
		var fields = component.get("v.fieldList");
        var newObj = component.get("v.objectInstance");
        if(newObj){
        	for(var fieldObj in fields){
	            var field = fields[fieldObj];
            	if (field.fieldName == newObj.fieldName){
	                component.set("v.listPicklistValues", field.listPicklistValues);
	                component.set("v.fieldDataType", field.fieldDataType);
	            }
	        }
        }else{
        	/*newObj =  {
						'fieldDataType': '',
						'fieldName': '',
						'operation': '',
						'value': '',
						'id': 1
					}*/
			//component.set("v.objectInstance" , newObj);
        }
        helper.getOperatorList(component, event, helper);
    },
	setPicklistValues: function(component, event, helper){
        var fields = component.get("v.fieldList");
        var newObj = component.get("v.objectInstance");
        for(var fieldObj in fields){
            var field = fields[fieldObj];
            if(field.fieldDataType == "String"){
                component.set("v.objectInstance.value", "");
            }
            
            if (field.fieldName == newObj.fieldName){
                component.set("v.listPicklistValues", field.listPicklistValues);
                component.set("v.fieldDataType", field.fieldDataType);
                newObj.fieldDataType = field.fieldDataType;
            }
        }
        helper.getOperatorList(component, event, helper);
    },
    
    removeRow : function(component, event, helper){
        var pageIndex = component.get("v.rowIndex");
        var eventObj = component.getEvent("DynamicFieldRowEvent");
        eventObj.setParams({
            ronIndex: pageIndex
        }).fire();
    },
    
    validateForm : function(component, event, helper) {
        var isValid = component.find('criterion').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);  
        return isValid;
    },
    
    disablUnitInput:function(component, event, helper){
        helper.disablUnitInput(component, event, helper);
    },
    
})