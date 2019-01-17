({
	myAction : function(component, event, helper) {
		
	},
    
    init: function(component, event, helper) {
        console.log('in Action detail Page');
        console.log('in Action detail Ids@@@',component.get("v.recordId"));
         var id = component.get('v.recordId');
        //var productlist = JSON.stringify(event.getParam("viewRecordId"));
        if(id != null){
        component.set('v.cadColumns', [
            {label: 'Sequence Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            { label: 'Status',  fieldName: 'status', type: 'text', sortable: true },
            { label: 'Type', fieldName: 'recordType', type: 'text', sortable: true},
            { label: 'Activation', fieldName: 'activation', type: 'text', sortable: true},
            { label: 'Participants', fieldName: 'participants', type: 'number', sortable: true}
        ]);
        
        component.set('v.partColumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            { label: 'Priority', fieldName: 'priority', type: 'number', sortable: true },
            {label: 'Company', fieldName: 'linkcompany', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'company' }, target: '_self', sortable: true}, cellAttributes: 
             {class: 'ringdna-company-td'}
            },
            { label: 'Type', fieldName: 'objType', type: 'text', sortable: true},
            { label: 'Email', fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', fieldName: 'phone', type: 'phone', sortable: true , cellAttributes: 
             {class: 'ringdna-phone-td'} }
        ]);
        
            helper.getData(component, event, helper);}
       
        
        
    },

    editAction : function(component, event, helper) {
        console.log('In edit function');
    	var id = component.get('v.recordId');
        //helper.setCompanyRow(component, event, helper);
        helper.editRecord(component, event, id);
	},
    setCompanyRow : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                helper.setCompanyRow(component, event, helper);
            }), 500
        );
    },
    handlePagination: function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                helper.setCompanyRow(component, event, helper);
            }), 100
        );
    },
    
    
    
})