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
            } 
            console.log("In step one validation isValid",isValid);
        }else if(getCurrentStep == 2){
        	var criterionValid = helper.validateCriterion(component, event, helper, 'entryCriterionComponent');
        	component.set('v.hasError', !(criterionValid));
        	if (criterionValid){
                component.set("v.currentStep", "3");
            }
        }else if(getCurrentStep == 3){
        	var criterionValid = helper.validateCriterion(component, event, helper, 'exitCriterionComponent');
            component.set('v.hasError', !(criterionValid));
            if (criterionValid){
                component.set("v.currentStep", "4");
            }
        }
        return isValid;
        
    },
    
    createCadenceAction :function(component, event, helper){
        var isValid = true;
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
        return isValid;
    },
    
    saveCadence:function(component, event, helper){
        console.log('##########################save function called##################');
        var action = component.get("c.saveCadence");
        var cadObj = component.get("v.newCadence");
        var lstCadAction = component.get("v.cadenceActionList");
        var entranceCriteriaSet = JSON.stringify(component.get("v.entranceCriteriaSet"));
        var exitCriteriaSet = JSON.stringify(component.get("v.exitCriteriaSet"));
        cadObj.RDNACadence__Entrance_Criteria__c = entranceCriteriaSet;
        cadObj.RDNACadence__Exit_Criteria__c = exitCriteriaSet;
        var caIdsList = component.get("v.caIdsList");
        action.setParams({
            cadenceObj :  cadObj,
            listCadenceAction : lstCadAction,
            caIdsList : caIdsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               	console.log('**************saved***********************');
            	var recordId = response.getReturnValue();	
	        	var eventObj = component.getEvent("CadenceComponentSaveEvt");
		        eventObj.setParams({
		            "isEdit": false,
		            "recordId": recordId
		        }).fire();
		        component.set("v.currentStep", "1");
            }else{
            	console.log('**************Error to save***********************');
            }
        });
        $A.enqueueAction(action)
    },
    
    validateCriterion : function(component, event, helper, cmpId) {
        console.log('cmp Id',cmpId);
    	var entryCriterion = component.find(cmpId);
    	var isValid = entryCriterion.validateCriterion();
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
        	component.set('v.hasError', !(criterionValid));
        	if(!criterionValid) {
        		component.set("v.currentStep", "2");
        		return false;
        	}
    	}
    	if(step>3) {
        	var criterionValid = helper.validateCriterion(component, event, helper, 'exitCriterionComponent');
        	component.set('v.hasError', !(criterionValid));
        	if(!criterionValid) {
        		component.set("v.currentStep", "3");
        		return false;
        	}
    	}
    	return true;
    },
    
})