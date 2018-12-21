({
	getData : function(component, event, helper) {

        component.set('v.spinner', true);
        var id = component.get('v.recordId');
        console.log( 'in getData Helper ',id);
        if(id == null || id === undefined) {
        	helper.openRecordList();
        	return;
        }
       
        var action = component.get('c.getActionData');
        action.setParams({actionId : id});
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.record', data.action);
                
                //Making url for cadence rows
                var cadRecords = data.cadWrapper;
                cadRecords.forEach(function(record) {
                	record.linkName = '/'+record.id;
                }); 	
                component.set('v.cadRawData', cadRecords);                
                
                var partRecords = data.participantList;
                partRecords.forEach(function(record) {
                	record.linkName = '/'+record.id;
                }); 	
                component.set('v.partRawData', partRecords);
                component.set('v.spinner', false);
                console.log('v.spinner',component.get('v.spinner')); 
            } else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    editRecord : function(component, event, id) {
         var myUserContext = component.get("v.themeName");
         console.log('In edit function helper id',id); 
         console.log('In edit function helper myUserContext',myUserContext); 
         if(myUserContext == 'Theme3') {
        	window.location = '/apex/EditActionDetails?id='+id;
        } 
        else {
               var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef  : "c:ActionDetails" ,
                    componentAttributes : {
                        "recordId" : id
                    }
                });
                evt.fire(); 
        }
    },
    openRecordList : function(component, event) {
        console.log( 'in openRecordList Helper ');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef  : "c:CadenceActionList" ,
            componentAttributes : {
            }
        });
        evt.fire();
    },
    
})