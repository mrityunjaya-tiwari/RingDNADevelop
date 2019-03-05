({
	doInit : function(component, event, helper) {
        var noOFColumns = 5;
        var  width = screen.width/noOFColumns;
        width = width -31.2;
        component.set('v.columns', [ 
            { label: 'Name', initialWidth: width,fieldName: 'linkName', type: 'url', sortable:'true', 
            	typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            {label: 'Company', fieldName: 'linkcompany', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'company' }, target: '_self', sortable: true}, cellAttributes: 
             {class: 'ringdna-company-td'}
            },
            { label: 'Status', initialWidth: width,  fieldName: 'status', type: 'text', sortable: true},
            { label: 'Email', initialWidth:width, fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', initialWidth: width, fieldName: 'phone', type: 'phone', sortable: true, cellAttributes:
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