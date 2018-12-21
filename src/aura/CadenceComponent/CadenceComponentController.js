({
    doInit : function(component, event, helper) {
        helper.getCadenceData(component, helper);
    },
    
    handleCadenceComponentEvt: function(component, event, helper){
        var isEdit = event.getParam("isEdit"); 
        component.set('v.isEdit', isEdit);
    },
    
    CadenceComponentSaveEvt : function(component, event, helper) {
        var recordId = event.getParam("recordId");
        var isEdit = event.getParam("isEdit");
        component.set('v.recordId', recordId);
        component.set('v.isEdit', isEdit);
        helper.getCadenceData(component, helper);
    },
    setPhoneLink : function(component, event, helper) {
        helper.setPhoneRow(component, event, helper);
        window.setTimeout(
            $A.getCallback(function() {
                helper.setPhoneRow(component, event, helper);
            }), 100
        );
	},
    
})