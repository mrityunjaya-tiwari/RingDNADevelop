({
    helperMethod : function() {
        
    },
    fireRecordTypeChangedEvent: function(component, event, helper) {
        component.set('v.settedSequenceType', true);
    }, 
    createListForInput : function (component){
        var fieldList = component.get("c.createListForUIInput");
        component.set('v.spinner', true);
		fieldList.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var result = response.getReturnValue();
                var mpList = result.mpList;
				component.set('v.mpList', mpList);
                component.set('v.atList', result.atList);
                component.set('v.spinner', true);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        var cadence = component.get('v.newCadence');
                        component.set('v.newCadence', cadence);
                        component.set('v.spinner', false);
                    }), 500
                );}
		});
		$A.enqueueAction(fieldList);
    },
})
