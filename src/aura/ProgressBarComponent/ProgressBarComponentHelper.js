({
    setCurrentStepIndex : function(component,event, helper) {
        //alert('setCurrentStepIndex helper');
        var ctarget = event.currentTarget;      
        var secId = ctarget.dataset.value;     
        var hasError = component.get('v.hasError');
        component.set('v.currentStepChanged' ,++secId );
       
    }
})