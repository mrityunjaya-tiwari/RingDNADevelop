({
    doInit: function(component, event, helper) {
        component.get('v.disableActionType');
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
})