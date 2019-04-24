({
    getData : function(component, event, helper) {
        component.set('v.spinner', true);
        var action = component.get('c.getData');
        var participantId = component.get('v.recordId');
        component.set('v.mailTo',participantId);
        var emailTemplateId = component.get('v.emailTemplateId');
        action.setParams({
            participantId :  participantId,
            emailTemplateId : emailTemplateId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.recordType', result.recordTypeAPI);
                component.set('v.sequenceAction', result.sequenceActionAPI);
                component.find('body').set('v.value',result.emailTemplateBody);   
                component.find('subject').set('v.value',result.emailTemplateSubject);     
            }else {
                component.set('v.spinner', false);
            }
            component.set('v.childComponentActivation', true);           
        });
        $A.enqueueAction(action);        
    },
})