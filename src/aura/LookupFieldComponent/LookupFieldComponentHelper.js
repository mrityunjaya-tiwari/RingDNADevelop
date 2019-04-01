({
    helperMethod : function() {
        
    },
    handleOnload : function(component, event, helper) {
        try{
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
            var updatedFieldName = component.get("v.fieldName");
            if (updatedFieldName == 'CreatedById' || updatedFieldName == 'LastModifiedById' || updatedFieldName == 'OwnerId' || updatedFieldName == 'DandbCompanyId'){
                component.set('v.isLookup', "false");
                component.set('v.isDnBCompanyId', "false");
                component.set("v.fieldName", parentId);
                if(updatedFieldName == 'DandbCompanyId'){
                component.set('v.isDnBCompanyId', "true");
            }
            }
        }catch(err){
            
        }
        
    },
    handleOnSelect:function(component, event, helper){
        try{
            var ddElement  = component.find("validateLookups");
            var value = ddElement.get("v.value"); 
            if (value == 'CreatedById' || value == 'LastModifiedById' || value == 'OwnerId' || value == ""){
                $A.util.removeClass(ddElement, "customRequired");
                $A.util.addClass(ddElement, "customRequiredMessage");
                $A.util.addClass(ddElement, "slds-has-error slds-input:active");
                return false;
            }else{
                $A.util.removeClass(ddElement, "customRequiredMessage");
                $A.util.removeClass(ddElement, "slds-has-error slds-input:active"); 
                $A.util.addClass(ddElement, "customRequired");
                component.set("v.parentId", value);
                return true;
            }
        }catch(err){
            
        }
        
    },
    handleOnSubmit : function(component, event, helper) {
        try{
            var value = component.find("lookup").get("v.value");
            if (value){
                $A.util.removeClass(component.find("lookup"), "customRequiredMessage");
                $A.util.removeClass(component.find("lookup"), "slds-has-error slds-input:active"); 
                $A.util.addClass(component.find("lookup"), "customRequired");
                component.set("v.parentId", value);
                return true;
            }else{
                $A.util.removeClass(component.find("lookup"), "customRequired");
                $A.util.addClass(component.find("lookup"), "customRequiredMessage");
                $A.util.addClass(component.find("lookup"), "slds-has-error slds-input:active"); 
                return false;
            }
            
        }catch(err){
            
        }
        
    },
})