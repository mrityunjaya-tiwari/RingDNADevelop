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
            component.set('v.isNextEnable' , false);
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'Call'){
            component.set('v.currentStep' , '2');
            component.set('v.isNextEnable' , false);
        }        
    },
    createEmailAction : function(component, event, helper){
        var newAct = component.get("v.newAction");
        var isValid = helper.validateActionName(component, event,helper);
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.type', 'Email');
            component.set('v.isNextEnable' , true);
            component.set("v.isActionTypeRequired", true);
            component.set('v.disableActivationType', false);  
        }
        if (isValid && newAct.type == 'Email'){
            component.set('v.currentStep' , '2');
            component.set('v.isNextEnable' , true);
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
            component.set('v.isNextEnable' , false);
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'SMS'){
            component.set('v.currentStep' , '2');  
            component.set('v.isNextEnable' , false);
        }
    },
    createTaskAction : function(component, event, helper){
        var newAct = component.get("v.newAction");
        var isValid = helper.validateActionName(component, event,helper);
        if(newAct.id == '' || newAct.id == null){
            component.set('v.newAction.type', 'Task');
            component.set('v.isNextEnable' , false);
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }
        if (isValid && newAct.type == 'Task'){
            component.set('v.currentStep' , '2');
            component.set('v.isNextEnable' , false);
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