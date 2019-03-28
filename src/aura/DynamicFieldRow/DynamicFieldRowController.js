// latest working
({
     doInit: function(component, event, helper) {
        /*helper.getuserWrapperList(component, event, helper);
        var fields = component.get("v.fieldList");
        var newObj = component.get("v.objectInstance");
         console.log('newObj:'+ JSON.stringify(newObj));
        var parentFieldList = component.get("v.parentFieldList");
        var childFieldList = component.get("v.childFieldList");
        if (newObj && newObj.fieldDataType){
            component.set("v.fieldDataType", newObj.fieldDataType);
        }
        if(newObj){
            try {
                for(var fieldObj in fields){
                    var field = fields[fieldObj];
                    if (field.fieldName == newObj.fieldName){
                        component.set("v.listPicklistValues", field.listPicklistValues);
                        component.set("v.fieldDataType", field.fieldDataType);
                    }
                    var fieldLabel =  field.fieldLabel;
                    if (fieldLabel.indexOf(".") != -1) {
                        var pos = fieldLabel.indexOf("."); 
                        component.set("v.childRecordType" , fieldLabel.slice(0, pos));
                        var newLabel  = fieldLabel.slice(pos + 1, fieldLabel.length);
                        childFieldList.push({
                            'fieldName': field.fieldName,
                            'fieldLabel': newLabel, 
                        });
                    }else{
                        parentFieldList.push({
                            'fieldName': field.fieldName,
                            'fieldLabel': field.fieldLabel, 
                        });
                    }
                }
                component.set("v.parentFieldList", parentFieldList);
                component.set("v.childFieldList", childFieldList);
            }
            catch(err) {
                
            }
            
        }else{
            
        }
        helper.getOperatorList(component, event, helper);
        */
        var AllFieldList = component.get("v.AllFieldList");
        helper.getuserWrapperList(component, event, helper);
		helper.getDandBCompanyWrapperList(component, event, helper);
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
    
})