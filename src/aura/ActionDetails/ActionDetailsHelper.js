({
    createCallAction : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            helper.validateActionName(component, event,helper);
            component.set('v.newAction.type','Call');
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        
    },
    createEmailAction : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            helper.validateActionName(component, event,helper);
            component.set('v.newAction.type', 'Email');
            component.set("v.isActionTypeRequired", true);
            component.set('v.disableActivationType', false);  
        }
    },
    createSMSAction : function(component, event, helper){
        var isValid = helper.validateActionName(component, event,helper);
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.type', 'SMS');
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'SMS'){
            component.set('v.currentStep' , '2');
        }
    },
    createTaskAction : function(component, event, helper){
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
            helper.validateActionName(component, event,helper);
            component.set('v.newAction.type', 'Task');
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
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
            return false;
        }else{
            return true;
        }
    },
})