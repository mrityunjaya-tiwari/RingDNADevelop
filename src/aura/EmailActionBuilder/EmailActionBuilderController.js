({
    doInit: function(component, event, helper) {
       console.log('disableactiontype-AB', component.get('v.disableActionType'));
    },
    createSFDCEmail : function(component, event,helper) {
        helper.createSFDCEmail(component, event,helper);
    },
    createNativeEmail : function(component, event,helper) {
        helper.createNativeEmail(component, event,helper);
    },
    createManualEmail : function(component, event,helper) {
        helper.createManualEmail(component, event,helper);
    },
    createAutomaticEmail : function(component, event,helper) {
        helper.createAutomaticEmail(component, event,helper);
    },
    createImmediateAction : function(component, event,helper) {
        helper.createImmediateAction(component, event,helper);
    },
    createWeekdayAction : function(component, event,helper) {
        helper.createWeekdayAction(component, event,helper);
    },
    createAnyDayAction : function(component, event,helper) {
        helper.createAnyDayAction(component, event,helper);
    },
})