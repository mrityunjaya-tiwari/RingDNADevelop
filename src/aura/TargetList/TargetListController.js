({
    init : function(component, event, helper) {
        console.log('In target list init method');
        
        var rowActions = helper.getRowActions.bind(this, component);
        component.set('v.columns', [
            { label: 'Name', fieldName: 'linkName', type: 'url', sortable:'true', 
             typeAttributes: {label: { fieldName: 'name' }, target: '_self', sortable: true}},
            { label: 'Priority', fieldName: 'priority', type: 'number', sortable: true },
            { label: 'Company', fieldName: 'companyLink', type: 'url', sortable:'true', 
             typeAttributes: {label: { fieldName: 'company' }, target: '_self', sortable: true}, cellAttributes: 
             {class: 'ringdna-company-td'}},
            { label: 'Type', fieldName: 'type', type: 'text', sortable: true},
            { label: 'Email', fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', fieldName: 'phone', type: 'phone', sortable: true,cellAttributes:
             { class: 'ringdna-phone-row'}},
            { label: 'Next Action', fieldName: 'linknextAction', type: 'url', sortable: 'true',
             typeAttributes: {label: { fieldName: 'linkActionName' }, target: '_self', sortable: true}, cellAttributes:
             { iconName: {fieldName: 'actionIcon'}, class: 'ringdna-phone-td', iconPosition: 'left', iconAlternativeText: 'Call'}},
            { type: 'action', typeAttributes: { rowActions: rowActions }} 
        ]);
        
       
        helper.getData(component, event, helper);
        helper.removeCss(component, event, helper); 
        
    },
    
    handleDatatableEvent : function(component, event, helper) {
        console.log('handling the event');
        var rowsSelected = event.getParam("rowsSeleted");
        console.log(rowsSelected);
        var row = event.getParam("row");
        var actionName = event.getParam("actionName");
        if(rowsSelected != undefined) {
            component.set('v.selectedRows', rowsSelected);
        }
        if(actionName != undefined) {
            console.log('See the action = '+ actionName);
            console.log(row);
            helper.performActions(component, event, helper, actionName, row);
        }
    },
    
    removeActions : function(component, event, helper) {
        var rows = component.get('v.selectedRows');
        component.set('v.rowsToDelete', rows);
        //helper.setPhoneLink(component, event, helper);
        component.set('v.showModal', true);
    },
    
    deletePartActions : function(component, event, helper) {
        var records = component.get("v.rowsToDelete");
        console.log('checking records');
        console.log(records);
        var ids = [];
        for(var i=0; i<records.length; i++) {
            ids.push(records[i].participantActionsId);
        }
        console.log('checking again');
        console.log(ids);
        helper.deleteParticipantActions(component, event, helper, ids);
        component.set('v.showModal', false);
    },
    
    cancel : function(component, event, helper) {
        component.set('v.showModal', false);
    },
    setPhoneLink : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                helper.setPhoneLink(component, event, helper);
            }), 500
        );
    },
    handlePagination: function(component, event, helper) {
       // helper.clearFilter(component);
        window.setTimeout(
            $A.getCallback(function() {
                helper.setPhoneLink(component, event, helper);
            }), 100
        );
    },
    pageUpdated : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                helper.setPhoneLink(component, event, helper);
            }), 100
        );
    },
    updateTargetList:function(component, event, helper){
        helper.getData(component, event, helper);
    },
    
    searchInputText: function(component, event, helper){
        window.setTimeout(
            $A.getCallback(function() {
                helper.applyMultipleFilters(component, event, helper);
            }), 1500
        );
    },
    filterObjectType: function(component, event, helper){
        helper.applyMultipleFilters(component, event, helper);
    },
    filterCadenceType: function(component, event, helper){
        helper.applyMultipleFilters(component, event, helper);
    },
    filterActionType: function(component, event, helper){
        helper.applyMultipleFilters(component, event, helper);
    },
    /* onSelectChange : function(component, event, helper){
        var selectComponent = component.find('recordSize');
        component.set('v.recordsPerPage', selectComponent.get('v.value'));
        helper.getData(component, event, helper);
       
    }
    
    */
    
})