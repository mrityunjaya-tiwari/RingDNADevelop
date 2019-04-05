({
    doInit : function(component, event, helper) {
        var hostName = window.location.hostname;
        console.log('hostName',hostName);
        console.log('path Name ',window.location.pathname);
        var pageReference = component.get("v.pageReference");
        console.log('pId',pageReference.state.pId);
        console.log('template_id',pageReference.state.template_id);
        component.set('v.recordId',pageReference.state.pId);
        component.set('v.emailTemplateId',pageReference.state.template_id);
        helper.getData(component, event, helper);
    },
    nativeEmailSend : function(component, event, helper){
        //For error dialog
        if(component.find('to').get('v.parentId')==''){
            component.set('v.showErrorMessage',true);
        }
        else{
            var redirectUrlaccessToken ='';
            var mailTo= JSON.stringify(component.get('v.mailTo'));
            //var mailFrom= component.find('mailFrom').get('v.value');
            var mailCc= JSON.stringify(component.get('v.mailCc'));
            var mailBcc= JSON.stringify(component.get('v.mailBcc'));
            var subject= component.find('subject').get('v.value');
            var body= component.find('body').get('v.value');
            var action = component.get("c.sendEmail");
            var currentPageUrl = component.get("v.currentUrl");
            var participantId= component.get('v.recordId');
            var emailTemplateId= component.get('v.emailTemplateId');
            console.log('currentPageUrl',currentPageUrl);
            action.setParams({ 
                "mailTo":mailTo,"mailCc":mailCc,
                "mailBcc":mailBcc,"subject":subject,"body":body,participantId : participantId,
                templateId :emailTemplateId
            }); 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") { 
                    var isredirect = response.getReturnValue();
                    if(isredirect ==true){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef  : "RDNACadence2:TargetList" ,
                            componentAttributes : {
                            }
                        });
                        evt.fire();
                    }
                }
                else{
                }
                
            });
            $A.enqueueAction(action);
        }
        
        
    },
    okMessage : function(component, event, helper) {
        component.set('v.showErrorMessage', false);
    },
    cancelBtn: function(component, event, helper){
        console.log('Cancel');
        var action =component.get("c.Cancel");
        action.setParams({isCancel :true });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") { 
                var isredirect = response.getReturnValue();
                if(isredirect ==true){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef  : "RDNACadence2:TargetList" ,
                        componentAttributes : {
                        }
                    });
                    evt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})