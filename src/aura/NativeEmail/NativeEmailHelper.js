({
    getData : function(component, event, helper) {
        component.set('v.spinner', true);
        var action = component.get('c.getData');
        var participantId = component.get('v.recordId');
        component.set('v.mailTo',participantId);
        console.log(participantId);
        var emailTemplateId = component.get('v.emailTemplateId');
        console.log('emailTemplateId',emailTemplateId); //new change
        action.setParams({
            participantId :  participantId,
            emailTemplateId : emailTemplateId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(JSON.stringify(result));
                console.log(result.recordTypeAPI);
                component.set('v.recordType', result.recordTypeAPI);
                console.log(component.get('v.recordType'));
                component.set('v.sequenceAction', result.sequenceActionAPI);
                component.set('v.spinner', false);
                component.find('body').set('v.value',result.emailTemplateData);
                
            }
            
            else {
                console.log('got an error in fething data');
                component.set('v.spinner', false);
            }
            component.set('v.setup', true);
            console.log('after',component.get('v.recordType'));  
            
        });
        $A.enqueueAction(action);
        
    },
})