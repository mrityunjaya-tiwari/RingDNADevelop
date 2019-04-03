({
    doInit: function(component, event, helper) {
        component.set('v.spinner', true);
        var actionWrapper;
        var id = component.get('v.recordId');
        var action = component.get("c.getActionWrapper");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner', false);
                actionWrapper= response.getReturnValue();
                component.set('v.newAction', actionWrapper.action);
                component.set('v.UpdateFieldList', actionWrapper.wrapperTaskFields);
                if(id != null) {
                    if(id != '') {
                        component.set('v.disableActionType' , true);
                        helper.getData(component, event, helper, id);                       
                    }
                }
                component.set('v.spinner', false);
            }else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action)
    },
    onCancel: function(component, event, helper){
        helper.onCancel(component, event);
    },
    clickBack: function(component, event, helper){
        component.set('v.currentStep','1');
    },
    createAction: function(component, event, helper) {
        var newAct = component.get("v.newAction");
        // We can use it for validate if action type is email.
        //if(newAct.type == 'Email' && newAct.templateId == null ){
            helper.createAction(component, event,helper);
        //}
    },
})