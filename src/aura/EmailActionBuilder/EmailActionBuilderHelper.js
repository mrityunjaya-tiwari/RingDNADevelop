({
    createSFDCEmail : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.emailType','SFDC');
        }
    },
    createNativeEmail : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.emailType','NATIVE');
        }
    },
    createManualEmail : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.activationType','Manual');
            component.set('v.newAction.deliveryPreference','');
        }
    },
    createAutomaticEmail : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.activationType','Automatic');
        }
    },
    createImmediateAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.deliveryPreference','Immediate');
        }
    },
    createWeekdayAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.deliveryPreference','Weekdays');
        }
    },
    createAnyDayAction : function(component, event,helper) {
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.deliveryPreference','AnyDay');
        }
    },
    validateActionName: function(component, event, helper){ 
        var newAct = component.get("v.newAction");
        var name = newAct.name;
        if (name){
            newAct.name = name.trim();
        }
        component.set("v.newAction", newAct);   
        if(newAct.name == '' || newAct.name == null){
            component.find('formValidationId').showHelpMessageIfInvalid();
            return true;
        }else{
            return true;
        }
    },
})