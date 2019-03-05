({
	helperMethod : function() {
		
	},
	
	activateCadence : function(component, event, helper) {
		var cadence = component.get('v.newCadence');
        //var action = component.get('c.activateCadence');
		var action = component.get('c.activateCadenceNew');
		action.setParams({
			"cadId" : cadence.Id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
            console.log('state', state);
			if(state === 'SUCCESS'){
                
				component.set('v.newCadence.RDNACadence2__Status__c', true);
				helper.refreshParts(component, event, helper);
                component.set('v.isActive', false);
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	diactivateCadence : function(component, event, helper) {
		var cadence = component.get('v.newCadence');
		var action = component.get('c.deactivateCadence');
		action.setParams({
			"cadId" : cadence.Id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.newCadence.RDNACadence2__Status__c', false);
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	refreshParts : function(component, event, helper) {
		component.set('v.refreshParticipant', true);
	},
	
})