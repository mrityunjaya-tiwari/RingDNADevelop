({
    doInit : function(component, event, helper) {        
    },
    resetLookUpField :function(component, event, helper) {
        var params = event.getParam('arguments');
        var parentId = component.get("v.parentId");
        if (params) {
            var fieldName = params.fieldName;
            component.set("v.fieldName", fieldName);
        }
        component.set('v.isLookup', "true");
        component.set("v.fieldName", parentId);
    },
    handleOnload : function(component, event, helper) {
       helper.handleOnload(component, event, helper);
       component.set('v.spinner', false);
    },
    
    handleOnSubmit : function(component, event, helper) {
        helper.handleOnSubmit(component, event, helper);
    },
    handleOnSelect:function(component, event, helper){
        helper.handleOnSelect(component, event, helper);
    },
    validateLookUpField:function(component, event, helper){
        var isLookup = component.get('v.isLookup');
        if (isLookup == 'true' || isLookup == true){
            return helper.handleOnSubmit(component, event, helper);
        }else{
            return helper.handleOnSelect(component, event, helper);
        }
    }
})