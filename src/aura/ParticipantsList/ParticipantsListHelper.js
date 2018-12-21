({
	getData : function(component, event, helper) {

        var id = component.get('v.recordId');
        console.log('id is = ');
        console.log(id);
        var action = component.get('c.getCadenceParticipantsData');
        action.setParams({cadId : id});
  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record){
                   record.linkName = '/'+record.id;
                });
                component.set('v.rawData', records);
                component.set('v.setPhoneLink', true);
                console.log('size of data');
            }
        });
        $A.enqueueAction(action);  
    },
    
    toggleParticipantsActivation : function(component, event, helper) {
    	console.log('in change handler');
    	var rows = component.get('v.toggleRows'); 
    	console.log('rows ' , rows);
    	if(rows.length<1) {
    		return;
    	}
    	var rowsJson = JSON.stringify(rows);
    	var action = component.get('c.togglePartActivation');
    	action.setParams({selectedRows : rowsJson});
    	action.setCallback(this, function(response){
    		var state = response.getState();
    		if(state === "SUCCESS") {
                console.log('state ' , state);
    			helper.getData(component, event, helper);
    			var childCmp = component.find("datatable1");
    			childCmp.clearRowSelection();
    		} else {
    			console.log(response.getError()); 
    		}
    	});
    	$A.enqueueAction(action);
    },
    
})