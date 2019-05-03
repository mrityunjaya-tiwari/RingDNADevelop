({
    validateForm :function(component, event, helper) {
    	var isValid = true;
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "1"){
        	var objCompB = component.find('compB');
        	var isValid = objCompB.validateForm();
        	component.set('v.hasError', !(isValid));
        	if (isValid){
                component.set("v.currentStep", "2");
                component.set("v.currentStepChanged", "2");
            } 
        }else if(getCurrentStep == 2){
            var criterionValid = helper.validateCriterion(component, event, helper, 'entryCriterionComponent');
        	var hasDuplicates=helper.checkDuplicates(component,event,helper,component.get("v.entranceCriteriaSet").criterions);
            component.set('v.hasError', (!criterionValid || hasDuplicates));
            component.set("v.duplicateEntranceCriteria",hasDuplicates);
            if (criterionValid && !(hasDuplicates)){
                component.set("v.currentStep", "3");
                component.set("v.currentStepChanged", "3");
            }
        }else if(getCurrentStep == 3){
            var criterionValid = helper.validateCriterion(component, event, helper, 'exitCriterionComponent');
            var hasDuplicates=helper.checkDuplicates(component,event,helper,component.get("v.exitCriteriaSet").criterions);
            component.set('v.hasError', (!criterionValid || hasDuplicates));
            component.set("v.duplicateExitCriteria",hasDuplicates);
            if (criterionValid && !(hasDuplicates)){
                component.set("v.currentStep", "4");
                component.set("v.currentStepChanged", "4");
            }
        }
        return isValid;
        
    },
    
    createCadenceAction :function(component, event, helper){
        
        var isValid = true;
        try {
            var createCadenceActionComponent = component.find('createCadenceActionComponent');
            isValid = createCadenceActionComponent.createCadenceAction();
            if (createCadenceActionComponent.length){
                for (var index in createCadenceActionComponent){
                    var obj = createCadenceActionComponent[index];
                    var isValidRow = obj.createCadenceAction();
                    if (!isValidRow){
                        isValid = isValidRow;
                    }
                }
            }else{
                isValid = createCadenceActionComponent.createCadenceAction();
            }
        }
        catch(err) {
            isValid = false;
        }
        return isValid;
    },
    
    saveCadence:function(component, event, helper){
        component.set('v.spinner' , true);
        component.set('v.newSequence', true);
        var action = component.get("c.saveCadence");
        var cadObj = component.get("v.newCadence");
        var lstCadAction = component.get("v.cadenceActionList");
        var entranceCriteriaSet = JSON.stringify(component.get("v.entranceCriteriaSet"));
        var exitCriteriaSet = JSON.stringify(component.get("v.exitCriteriaSet"));
        cadObj.entranceCriteria = entranceCriteriaSet;
        cadObj.exitCriteria = exitCriteriaSet;
        var caIdsList = component.get("v.caIdsList");
        var sequenceWrapper = JSON.stringify(cadObj); 
        var listCadenceActionString = JSON.stringify(lstCadAction);
        action.setParams({ 
            cadenceObjString :  sequenceWrapper,
            listCadenceActionString : listCadenceActionString,
            caIdsList : caIdsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var recordId = response.getReturnValue();
               var myUserContext =component.get("v.themeName");
               component.set("v.SaveDisable", true);
                
                 if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                    window.location = '/apex/Cadence?isedit=false&id='+recordId;
                }
                else if(myUserContext == undefined){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:CadenceComponent",
                        componentAttributes : {
                            "recordId" : recordId,
                            "isEdit" : false
                        }
                    });
                    evt.fire();
                }
            }            
            component.set('v.spinner' , false);
        });
        component.set("v.SaveDisable",false);
        $A.enqueueAction(action)
    },
    
    validateCriterion : function(component, event, helper, cmpId) {
        var isValid;
        try{
            var entryCriterion = component.find(cmpId);
        	isValid = entryCriterion.validateCriterion();
        }
        catch(err){
            isValid = false;
        }
        return isValid;
    },

    validatePrevForms : function(component, event, helper, step) {

    	if(step>1) {
        	var objCompB = component.find('compB');
        	var isValid = objCompB.validateForm();
        	component.set('v.hasError', !(isValid));
        	if(!isValid) {
        		component.set("v.currentStep", "1");
        		return false;
        	}
    	}
    	if(step>2) {
        	var criterionValid = helper.validateCriterion(component, event, helper, 'entryCriterionComponent');
			var hasDuplicates=helper.checkDuplicates(component,event,helper,component.get("v.entranceCriteriaSet").criterions);
            component.set('v.hasError', (!criterionValid || hasDuplicates));
            component.set("v.duplicateEntranceCriteria",hasDuplicates);
            if (!criterionValid || hasDuplicates){
        		component.set("v.currentStep", "2");
        		return false;
        	}
    	}
    	if(step>3) {
        	var criterionValid = helper.validateCriterion(component, event, helper, 'exitCriterionComponent');
        	var hasDuplicates=helper.checkDuplicates(component,event,helper,component.get("v.exitCriteriaSet").criterions);
            component.set('v.hasError', (!criterionValid || hasDuplicates));
            component.set("v.duplicateExitCriteria",hasDuplicates);
            if (!criterionValid || hasDuplicates){
        		component.set("v.currentStep", "3");
        		return false;
        	}
    	}
    	return true;
    },
	checkDuplicates : function(component, event, helper, criteriaSet) {
        var criteriaSet2=criteriaSet; 
        var criterions=JSON.stringify(criteriaSet).split("},");
        var size=criterions.length;
        var criteriaSetIndex=1, criteriaSet2Index;
        for(criteriaSetIndex=1;criteriaSetIndex<=size;criteriaSetIndex++){
            for(criteriaSet2Index=criteriaSetIndex+1;criteriaSet2Index<=size;criteriaSet2Index++){
                if(criteriaSet[criteriaSetIndex].fieldName==criteriaSet2[criteriaSet2Index].fieldName &&
                   criteriaSet[criteriaSetIndex].operation==criteriaSet2[criteriaSet2Index].operation &&
                   criteriaSet[criteriaSetIndex].value==criteriaSet2[criteriaSet2Index].value){
                    return true;
                }
            }
        }
        return false;
    },
    
})