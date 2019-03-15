({
    doInit : function(component, event, helper) {
        helper.getCadenceData(component, helper);
        //helper.getCadenceDataNew(component, helper);
    },
    
    handleCadenceComponentEvt: function(component, event, helper){
        var isEdit = event.getParam("isEdit"); 
        console.log('isEdit:'+isEdit);
        component.set('v.isEdit', isEdit);
    },
    
    CadenceComponentSaveEvt : function(component, event, helper) {
        console.log('CadenceComponentSaveEvt:');
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
     // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        component.set("v.SpinnerForSync", false);
    },
    settedSequenceType: function(component,event,helper){
        var settedSequenceType = component.get("v.settedSequenceType");
        if(settedSequenceType){
         helper.getObjectFieldsList(component, event, helper);
         //helper.getObjectFieldsListNew(component, event, helper);   
        }        
    },
   
    
})