({
    doInit: function(component, event, helper) {
        component.set('v.spinner', true);
        var actionWrapper;
        var id = component.get('v.recordId');
        var action = component.get("c.getActionWrapper");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                actionWrapper= response.getReturnValue();
                component.set('v.newAction', actionWrapper.action);
                component.set('v.UpdateFieldList', actionWrapper.wrapperTaskFields);
                if(id != null) {
                    if(id != '') {
                        component.set('v.disableActionType' , true);
                        helper.getData(component, event, helper, id);                       
                    }
                }
                component.set('v.spinner', false);
            }else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action)
    },
    createCallAction : function(component, event,helper) {
        helper.createCallAction(component, event,helper);
    },
    createEmailAction : function(component, event,helper) {
        helper.createEmailAction(component, event,helper);
    },
    createSMSAction : function(component, event,helper) {
        helper.createSMSAction(component, event,helper);
    },
    createTaskAction : function(component, event,helper) {
        helper.createTaskAction(component, event,helper);
    },
    onCancel: function(component, event, helper){
        helper.onCancel(component, event);
    },
    clickBack: function(component, event, helper){
        component.set('v.currentStep','1');
    },
    createAction: function(component, event, helper) {
        var newAct = component.get("v.newAction");
        var name = newAct.name;
        if (name){
            newAct.name = name.trim();
        }
        console.log('name', name);
        component.set("v.newAction", newAct);
        console.log('act1',component.get('v.newAction'));
        if(true){
            console.log('create999');
            helper.createAction(component, event,helper);
        }
    },
})