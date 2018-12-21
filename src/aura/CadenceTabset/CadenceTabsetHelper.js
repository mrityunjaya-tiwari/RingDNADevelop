({
	helperMethod : function() {
		
	},
	
	activateCadence : function(component, event, helper) {
        //component.set('v.isActive', true);
		var cadence = component.get('v.newCadence');
		var action = component.get('c.activateCadence');
		console.log('console for cad Id');
		console.log(cadence.Id)
		action.setParams({
			"cadId" : cadence.Id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.newCadence.RDNACadence__Status__c', true);
				helper.refreshParts(component, event, helper);
                component.set('v.isActive', false);
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	diactivateCadence : function(component, event, helper) {
		console.log('INactivae cadence ');
		var cadence = component.get('v.newCadence');
		var action = component.get('c.deactivateCadence');
		action.setParams({
			"cadId" : cadence.Id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.newCadence.RDNACadence__Status__c', false);
				console.log("######### Cad Diactivated #####################");
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	refreshParts : function(component, event, helper) {
		component.set('v.refreshParticipant', true);
	},
	
})