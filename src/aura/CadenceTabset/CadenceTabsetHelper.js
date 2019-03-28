({
	helperMethod : function() {
		
	},
	
	activateCadence : function(component, event, helper) {
		var cadence = component.get('v.newCadence');
        var action = component.get('c.activateCadence');
        component.set('v.isActive', false);
		action.setParams({
			"cadId" : cadence.id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.newCadence.status', true);
				helper.refreshParts(component, event, helper);
                component.set('v.isActive', true);
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	diactivateCadence : function(component, event, helper) {
		var cadence = component.get('v.newCadence');
		var action = component.get('c.deactivateCadence');
        component.set('v.isActive', false);
		action.setParams({
			"cadId" : cadence.id
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.newCadence.status', false);
                component.set('v.isActive', true);
			}
		}); 
		$A.enqueueAction(action);		
	},
	
	refreshParts : function(component, event, helper) {
		component.set('v.refreshParticipant', true);
	},
	
})