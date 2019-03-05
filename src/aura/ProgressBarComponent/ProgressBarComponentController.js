({
    setCurrentStepIndex : function(component, event, helper) {
        //alert('setCurrentStepIndex');
        helper.setCurrentStepIndex(component, event, helper);
    },
    init : function(component, event, helper) {
        var currentStepClass = 'slds-size_1-of-4';
        component.set('v.currentStepClass', currentStepClass);
        var listOfLabels = component.get('v.listOfLabels');
        listOfLabels.push('Sequence Details');
        listOfLabels.push('Sequence Entrance Criteria');
        listOfLabels.push('Sequence Exit Criteria');
        listOfLabels.push('Sequence Actions');
        component.set('v.listOfLabels', listOfLabels);
        
    },
    setPbCss:function(component, event, helper){
        var secId =  component.get('v.currentStep');
        var params = event.getParam('arguments');
        if (params) {
            component.set('v.hasError', params.hasError);
            component.set('v.pbSteps' , --secId );
        }
    }
})