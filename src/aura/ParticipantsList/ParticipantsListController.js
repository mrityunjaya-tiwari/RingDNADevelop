({
	doInit : function(component, event, helper) {
        component.set('v.columns', [ 
            { label: 'Name', fieldName: 'linkName', type: 'url', sortable:'true', 
            	typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            {label: 'Company', fieldName: 'linkcompany', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'company' }, target: '_self', sortable: true}, cellAttributes: 
             {class: 'ringdna-company-td'}
            },
            { label: 'Status', fieldName: 'status', type: 'text', sortable: true},
            { label: 'Email', fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', fieldName: 'phone', type: 'phone', sortable: true, cellAttributes:
                { class: 'ringdna-phone-td'}}
        ]);

        helper.getData(component, event, helper); 
	},
	
	handleDatatableEvent : function(component, event, helper) {
		var rows = event.getParam("rowsSeleted");
		component.set('v.selectedRows', rows);
	},
	
	toggleActivation : function(component, event, helper) {
		helper.toggleParticipantsActivation(component, event, helper);
	},
	
	refreshData : function(component, event, helper) {
		helper.getData(component, event, helper);
	},

})