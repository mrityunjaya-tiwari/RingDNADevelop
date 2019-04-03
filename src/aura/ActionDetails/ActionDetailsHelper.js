({
    createCallAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type','Call');
        console.log('action-type',component.get('v.newAction.type'));
        component.set('v.newAction.activationType','Manual');
        component.set('v.disableActivationType', true);
        component.set("v.isActionTypeRequired", false);
        
        var myUserContext = cmp.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/CadenceActionList';
        } 
        else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "RDNACadence5:CadenceActionList" ,
                componentAttributes : {                   
                }
            });
            evt.fire()  
        }        
    },
    createEmailAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'Email');
        component.set("v.isActionTypeRequired", true);
        component.set('v.disableActivationType', false);        
    },
    createSMSAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'SMS');
        component.set('v.newAction.activationType','Manual');
        component.set('v.disableActivationType', true);
        component.set("v.isActionTypeRequired", false);
        component.set('v.currentStep' , '2');
    },
    createTaskAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'Task');
        component.set('v.newAction.activationType','Manual');
        component.set('v.disableActivationType', true);
        component.set("v.isActionTypeRequired", false);
    },
    validateActionName: function(component, event, helper){
        var newAct = component.get("v.newAction");
        var name = newAct.name;
        if (name){
            newAct.name = name.trim();
        }
        component.set("v.newAction", newAct);        
    },
})