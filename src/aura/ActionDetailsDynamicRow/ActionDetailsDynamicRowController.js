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
        return isValidActioin;
    }
})