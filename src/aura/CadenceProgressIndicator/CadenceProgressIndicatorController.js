({
    doInit : function(component, event, helper) {
        var childCmp = component.find("PBComp");
        childCmp.setErrorMethod(false);
    },
    
    moveNext : function(component,event,helper){
        helper.validateForm(component,event,helper);
        var childCmp = component.find("PBComp");
        childCmp.setErrorMethod(component.get('v.hasError'));
    },
    
    save : function(component,event,helper){
        var isValid = true;
        isValid = helper.validateForm(component,event,helper);
        isValid = helper.createCadenceAction(component,event,helper);
        if (isValid){
            helper.saveCadence(component,event,helper);
        } else{
            var childCmp = component.find("PBComp");
            childCmp.setErrorMethod(! isValid);
        }
    },
    setCurrentSteps: function(component,event,helper){
        var currentStep = component.get("v.currentStepChanged");
        
        if (currentStep == 1){
            
            var isValid = helper.validatePrevForms(component,event,helper, 2);
            if(isValid) {
                component.set("v.currentStep", "1");
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            } else{
                component.set("v.currentStepChanged", --currentStep );
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }
        } else if (currentStep == 2){
            var isValid = helper.validatePrevForms(component,event,helper, 2);
            if(isValid) {
                component.set("v.currentStep", "2");
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            } else{
                component.set("v.currentStepChanged", --currentStep );
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }
        } else if (currentStep == 3){
            var isValid = helper.validatePrevForms(component,event,helper, 3);
            if(isValid) {
                component.set("v.currentStep", "3");
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }  else{
                component.set("v.currentStepChanged", --currentStep );
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }
        } else if (currentStep == 4){
            var isValid = helper.validatePrevForms(component,event,helper, 4);
            if(isValid) {
                component.set("v.currentStep", "4");
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }  else{
                component.set("v.currentStepChanged", --currentStep );
                var childCmp = component.find("PBComp");
                childCmp.setErrorMethod(! isValid);
            }
        }
    },
    selectFromHeaderStep1 : function(component,event,helper){
        var isValid = helper.validatePrevForms(component,event,helper, 2);
        if(isValid) {
            component.set("v.currentStep", "1");
        }
    },
    
    selectFromHeaderStep2 : function(component,event,helper){
        var isValid = helper.validatePrevForms(component,event,helper, 2);
        if(isValid) {
            component.set("v.currentStep", "2");
        } 
    },
    
    selectFromHeaderStep3 : function(component,event,helper){
        var isValid = helper.validatePrevForms(component,event,helper, 3);
        if(isValid) {
            component.set("v.currentStep", "3");
        } 
    },
    
    selectFromHeaderStep4 : function(component,event,helper){
        var isValid = helper.validatePrevForms(component,event,helper, 4);
        if(isValid) {
            component.set("v.currentStep", "4");
        } 
    },
    
    onChangeOfRecordType: function(component,event,helper){
        //component.set("v.entranceCriteriaSet",component.get("v.entranceCriteriaSet"));
        component.set("v.newCadence", component.get("v.newCadence"));
        component.set("v.cadenceActionList", component.get("v.cadenceActionList"));
    },
    
    goToListView : function(component, event, helper) {
        var myUserContext = component.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/CadenceListView';
        } 
        else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:CadenceListView" ,
                componentAttributes : {}
            });
            evt.fire();
        }
    }
})