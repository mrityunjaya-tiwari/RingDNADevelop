({
    setCurrentStepIndex : function(component, event, helper) {
        helper.setCurrentStepIndex(component, event, helper);
    },
    init : function(component, event, helper) {
        var currentStepClass = 'slds-size_1-of-4';
        component.set('v.currentStepClass', currentStepClass);
        var listOfLabels = component.get('v.listOfLabels');
        listOfLabels.push('Cadence Details');
        listOfLabels.push('Cadence Entrance Criteria');
        listOfLabels.push('Cadence Exit Criteria');
        listOfLabels.push('Cadence Actions');
        component.set('v.listOfLabels', listOfLabels);
        
    },
    setPbCss:function(component, event, helper){
        console.log('In setPbCss');
        var secId =  component.get('v.currentStep');
        var params = event.getParam('arguments');
        if (params) {
            component.set('v.hasError', params.hasError);
            component.set('v.pbSteps' , --secId );
        }
    }
})