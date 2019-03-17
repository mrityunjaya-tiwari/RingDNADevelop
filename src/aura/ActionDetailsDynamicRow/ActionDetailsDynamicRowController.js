({
    doInit: function(component, event, helper) {
        helper.updateTaskField(component, event, helper);
    },
    updateTaskField : function(component, event, helper){
        helper.updateTaskField(component, event, helper);
    },
    
    removeRow : function(component, event, helper){
        var pageIndex = component.get("v.currentIndex");
        var eventObj = component.getEvent("cadDynamicRowEvent");
        eventObj.setParams({
            ronIndex: pageIndex
        }).fire();
    },
    validateDynamicRowForm:function(component, event, helper){
        var isValidActioin = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(isValidActioin){
            var LookupFieldComponent = component.find('LookupFieldComponentInAD');
            if (LookupFieldComponent){
                if(LookupFieldComponent.length === undefined) {
                    isValidActioin = LookupFieldComponent.validateLookUpField();
                }else{
                    for(var i=0; i<LookupFieldComponent.length; i++) {
                        var temp = LookupFieldComponent[i].validateLookUpField();
                        if(!temp) {
                            isValidActioin = false;
                        }
                    }
                }
            }
        }
        return isValidActioin;
    }
})