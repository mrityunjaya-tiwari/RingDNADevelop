({
    doInit : function(component, event, helper) {
    	var pageReference = component.get("v.pageReference");
        if(pageReference != undefined && pageReference !=''){
             component.set('v.recordId',pageReference.state.pId);
        	 component.set('v.emailTemplateId',pageReference.state.template_id);
             component.set('v.partActionId',pageReference.state.sequencePart_id);
        }
        helper.getData(component, event, helper);
    },
    nativeEmailSend : function(component, event, helper){
        //For error dialog
        if(component.find('to').get('v.parentId')==''){
            component.set('v.showErrorMessage',true);
        }
        else{
            var mailTo= JSON.stringify(component.get('v.mailTo'));
            var mailCc= JSON.stringify(component.get('v.mailCc'));
            var mailBcc= JSON.stringify(component.get('v.mailBcc'));
            var subject= component.find('subject').get('v.value');
            var body= component.find('body').get('v.value');
            var action = component.get("c.sendNativeEmail");
            var participantId= component.get('v.recordId');
            var emailTemplateId= component.get('v.emailTemplateId');
            var partActionId= component.get('v.partActionId');
            var emailParamJson =[{"mailTo":mailTo,"mailCc":mailCc,
                "mailBcc":mailBcc,"subject":subject,"body":body,"participantId" : participantId,
                "templateId" :emailTemplateId,"sequenceActionId" :partActionId}];
            action.setParams({ 
                nativeEmailParam :JSON.stringify(emailParamJson)
            }); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") { 
                    var isredirect = response.getReturnValue();
                    if(isredirect ==true){
                        var myUserContext = component.get("v.themeName");
                        if(myUserContext == 'Theme3'  || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
                             window.location = '/apex/TargetList';
                         }else{
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef  : "c:TargetList" ,
                                componentAttributes : {
                                }
                            });
                            evt.fire();
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
	},
    okMessage : function(component, event, helper) {
        component.set('v.showErrorMessage', false);
    },
    cancelBtn: function(component, event, helper){
        var myUserContext = component.get("v.themeName");
        if(myUserContext == 'Theme3'  || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/TargetList';
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({componentDef  : "c:TargetList" ,componentAttributes : {}});
            evt.fire();
        }
    }
})