// latest working
({
     doInit: function(component, event, helper) {
        var AllFieldList = component.get("v.AllFieldList");
        helper.getuserAndDnBWrapperList(component, event, helper);		
        for(var i=0;AllFieldList.length > i;i++){
            var fields =AllFieldList[i]["fieldsDetail"];
            var newObj = component.get("v.objectInstance");
            if (newObj && newObj.fieldDataType){
                component.set("v.fieldDataType", newObj.fieldDataType);
            }
            if(newObj){
                try {
                    for(var fieldObj in fields){
                        var field = fields[fieldObj];
                        if (field.fieldName == newObj.fieldName){
                            component.set("v.listPicklistValues", field.listPicklistValues);
                            component.set("v.picklistApiNameAndValues", field.picklistApiNameAndValues);
                            component.set("v.fieldDataType", field.fieldDataType);
                        }
                    }
                }
                catch(err) {
                    
                }
                
            }
        }
        helper.getOperatorList(component, event, helper); 
    },
    setPicklistValues: function(component, event, helper){
        var AllFieldList = component.get("v.AllFieldList");
       
        var newObj = component.get("v.objectInstance");
        for(var i=0;AllFieldList.length > i;i++){
            var fields =AllFieldList[i]["fieldsDetail"];
            for(var fieldObj in fields){
                var field = fields[fieldObj];
                if(field.fieldDataType == "String"){
                    component.set("v.objectInstance.value", "");
                }
                
                if (field.fieldName == newObj.fieldName){
                    component.set("v.listPicklistValues", field.listPicklistValues);
                    component.set("v.picklistApiNameAndValues", field.picklistApiNameAndValues);
                    component.set("v.fieldDataType", field.fieldDataType);
                    newObj.fieldDataType = field.fieldDataType;
                    if(field.fieldDataType == "Reference"){
                        var LookupFieldComponent = component.find('LookupFieldComponent');
                        if (LookupFieldComponent){
                            if(LookupFieldComponent.length === undefined) {
                                LookupFieldComponent.resetLookUpField(field.fieldName);
                            }else{
                                for(var i=0; i<LookupFieldComponent.length; i++) {
                                    LookupFieldComponent[i].resetLookUpField(field.fieldName);
                                }
                            }
                        }
                    }
                }
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
        if(isValid){
            var LookupFieldComponent = component.find('LookupFieldComponent');
            if (LookupFieldComponent){
                if(LookupFieldComponent.length === undefined) {
                    isValid = LookupFieldComponent.validateLookUpField();
                }else{
                    for(var i=0; i<LookupFieldComponent.length; i++) {
                        var temp = LookupFieldComponent[i].validateLookUpField();
                        if(!temp) {
                            isValid = false;
                        }
                    }
                }
            }
        }
        return isValid;
    },
    
    disablUnitInput:function(component, event, helper){
        helper.disablUnitInput(component, event, helper);
    },
    
	validateEmptyInput: function (component, event, helper) {
        var inputcomponent = event.getSource();
        var inputValue = inputcomponent.get('v.value').trim();
        inputcomponent.set('v.value', inputValue);
    }
})