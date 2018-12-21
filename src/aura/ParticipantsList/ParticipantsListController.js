({
	doInit : function(component, event, helper) {

        console.log('In controller');
        var noOFColumns = 6;
        var  width = screen.width/noOFColumns;
        width = width -31.2;
        component.set('v.columns', [ 
            { label: 'Name', initialWidth: width,fieldName: 'linkName', type: 'url', sortable:'true', 
            	typeAttributes: {label: { fieldName: 'name' }, target: '_self', sortable: true}},
            { label: 'Priority', initialWidth: width, fieldName: 'priority', type: 'number', sortable: true },
            { label: 'Company',  initialWidth:width, fieldName: 'company', type: 'text', sortable: true},
            { label: 'Status', initialWidth: width,  fieldName: 'status', type: 'text', sortable: true},
            { label: 'Email', initialWidth:width, fieldName: 'email', type: 'email', sortable: true},
            { label: 'Phone', initialWidth: width, fieldName: 'phone', type: 'phone', sortable: true, cellAttributes:
                { class: 'ringdna-phone-row'}}
        ]);

        helper.getData(component, event, helper); 
	},
	
	handleDatatableEvent : function(component, event, helper) {
		var rows = event.getParam("rowsSeleted");
		component.set('v.selectedRows', rows);
	},
	
	toggleActivation : function(component, event, helper) {
		console.log('In activation');
		helper.toggleParticipantsActivation(component, event, helper);
	},
	
	refreshData : function(component, event, helper) {
		console.log('Showing data of participant');
		helper.getData(component, event, helper);
	},

})