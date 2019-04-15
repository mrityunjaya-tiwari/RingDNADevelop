({
    helperMethod : function() {     
    },
    handleOnload : function(component, event, helper) {
        var parentId = component.get("v.parentId");
        if(component.find("lookup")){
            component.find("lookup").set("v.value", parentId);
        }
        var fieldName = component.get("v.fieldName");
        if (fieldName.indexOf(".") != -1) {
            var pos = fieldName.indexOf("."); 
            component.set("v.recordType" , fieldName.slice(0, pos));
            component.set("v.fieldName" , fieldName.slice(pos + 1, fieldName.length));
        }
    },
    handleOnSelect:function(component, event, helper){
        var ddElement  = component.find("validateLookups");
        var value = ddElement.get("v.value");
        $A.util.removeClass(ddElement, "slds-has-error slds-input:active"); 
        component.set("v.parentId", value);
        return true;
    },
    handleOnSubmit : function(component, event, helper) {
        var value = component.find("lookup").get("v.value");
        var required = component.get("v.isRequired");
        if (value){
            $A.util.removeClass(component.find("lookup"), "slds-has-error slds-input:active"); 
            component.set("v.parentId", value);
            return true;
        }else{
            if(required){
               $A.util.addClass(component.find("lookup"), "slds-has-error slds-input:active");   
            }
           component.set("v.parentId",'');
            return false;
        }
    },
})