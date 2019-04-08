({
    createCallAction : function(component, event, helper){
        var isValid = helper.validateActionName(component, event,helper);
        var newAct = component.get("v.newAction");
        if(newAct.id == '' || newAct.id == null){
			if (newAct.type != 'Call'){
                var emptyList = [];
                component.set('v.rowActionTemplateList', emptyList);
            }
            helper.validateActionName(component, event,helper);
            component.set('v.newAction.type','Call');
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'Call'){
            component.set('v.currentStep' , '2');
            component.set('v.isSMSAction' , false);
            component.set('v.isTaskAction' , false);
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
			if (newAct.type != 'SMS'){
                var emptyList = [];
                component.set('v.rowActionTemplateList', emptyList);
            }
            component.set('v.newAction.type', 'SMS');
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'SMS'){
            component.set('v.currentStep' , '2');            
            component.set('v.isTaskAction' , false);
            component.set('v.isSMSAction' , true);
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
        if (isValid && newAct.type == 'Task'){
            component.set('v.currentStep' , '2');
            component.set('v.isTaskAction' , true);            
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