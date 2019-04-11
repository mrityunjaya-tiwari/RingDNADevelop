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
        var updatedFieldName = component.get("v.fieldName");
        if (updatedFieldName == 'CreatedById' || updatedFieldName == 'LastModifiedById' || updatedFieldName == 'OwnerId'){
            component.set('v.isLookup', "false");
            component.set("v.fieldName", parentId);
        }else{
            component.set('v.isLookup', "true");
        }
    },
    handleOnload : function(component, event, helper) {
       helper.handleOnload(component, event, helper);
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