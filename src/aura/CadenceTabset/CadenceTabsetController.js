({
	init : function(component, event, helper) {
	},

    editCadence:function(component, event, helper){
        component.set('v.currentStep', component.get('v.tabToVisible'));
        var eventObj = component.getEvent("CadenceComponentEvt");
            eventObj.setParams({
                isEdit: true 
            }).fire();
	},
	
	handleDatatableEvent : function(component, event, helper) {
		var rows = event.getParam("rowsSeleted");
        component.set('v.selectedRows', rows);
		if(rows.length > 0) {
			component.set('v.showSavePartButton', true);
		} else {
			component.set('v.showSavePartButton', false);
		}
	},
	
	saveParticipants : function(component, event, helper) {
		var rows = component.get('v.selectedRows');
		component.set('v.toggleRows', rows);
		component.set('v.showSavePartButton', false);
	},
	
	cadActivation : function(component, event, helper) {
		helper.activateCadence(component, event, helper);
	},
	
	deactivateCad : function(component, event, helper) {
		helper.diactivateCadence(component, event, helper);
	},
})