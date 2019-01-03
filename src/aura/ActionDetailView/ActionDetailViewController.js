({
	myAction : function(component, event, helper) {
		
	},
    
    init: function(component, event, helper) {
        console.log('in Action detail Page');
        console.log('in Action detail Ids@@@',component.get("v.recordId"));
        //var productlist = JSON.stringify(event.getParam("viewRecordId"));
        component.set('v.cadColumns', [
            {label: 'Sequence Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, target: '_self', sortable: true}},
            { label: 'Status',  fieldName: 'status', type: 'text', sortable: true },
            { label: 'Type', fieldName: 'recordType', type: 'text', sortable: true},
            { label: 'Activation', fieldName: 'activation', type: 'text', sortable: true},
            { label: 'Participants', fieldName: 'participants', type: 'number', sortable: true}
        ]);
        
        component.set('v.partColumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, target: '_self', sortable: true}},
            { label: 'Priority', fieldName: 'priority', type: 'number', sortable: true },
            { label: 'Company', fieldName: 'company', type: 'text', sortable: true},
            { label: 'Type', fieldName: 'objType', type: 'text', sortable: true},
            { label: 'Email', fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', fieldName: 'phone', type: 'phone', sortable: true}
        ]);
        
        helper.getData(component, event, helper);
    },

    editAction : function(component, event, helper) {
        console.log('In edit function');
    	var id = component.get('v.recordId');
        helper.editRecord(component, event, id);
	}
    
    
    
})