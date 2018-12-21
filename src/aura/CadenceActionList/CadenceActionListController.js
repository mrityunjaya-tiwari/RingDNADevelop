({
    init: function (cmp, event, helper) {
        var rowActions = helper.getRowActions.bind(this, cmp);

        cmp.set('v.columns', [
            {label: 'Cadence Action', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, target: '_self', sortable: true}},
            { label: 'Type', fieldName: 'type', type: 'text', sortable: true },
            { label: 'Number of Cadences', fieldName: 'cadences', type: 'number', sortable: true},
            { label: 'Number of Participants', fieldName: 'participants', type: 'number', sortable: true},
            { label: 'Effectivity', fieldName: 'effectivity', type: 'percentage', sortable: true}, 
            { type: 'action', typeAttributes: { rowActions: rowActions }, cellAttribute : { class: 'rdna-menu-button'} } 
        ]);

        helper.fetchData(cmp, helper);
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var	row = event.getParam('row');
        var	rows = [];
        rows.push(row);

        switch (action.name) {
            case 'view':
                helper.viewDetails(cmp, event, row['actionId']);
                break;
            case 'edit':
                helper.editRecord(cmp, event, row['actionId'])
                break;
            case 'delete':
                cmp.set('v.deleteActionRows', rows);
                cmp.set('v.showModal', true);
                break;
        }
    },
    
    deleteCadenceActions: function(cmp, event, helper) {
        var rows = cmp.get('v.deleteActionRows');
        console.log('deleting data = ');
        console.log(JSON.stringify(rows));
        helper.deleteAction(cmp, rows, helper);
        cmp.set('v.showModal', false); 
    }, 
    
    deleteCadActions: function(cmp, event, helper) {
        var rows = cmp.get('v.rowsSelected');
        cmp.set('v.deleteActionRows', rows);
        cmp.set('v.showModal', true);
   },
   
    cancelActionDeletion : function(cmp, event, helper) {
        cmp.set('v.showModal', false);
        var rows = [];
        cmp.set('v.deleteActionRows', rows);
    },
    
    showDeleteAction: function(cmp, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        if(selectedRows.length>0) {
	        cmp.set('v.newActionEnable', false);    
        } else {
            cmp.set('v.newActionEnable', true);
        }
        cmp.set('v.rowsSelected', selectedRows);
    },
  
    handleComponentEvent: function(cmp, event, helper) {
        console.log('In console of handle');
        var curPage = event.getParam("currentPage");
        console.log(curPage);
        cmp.set('v.currentPage', curPage);
        helper.setData(cmp);
    },
    
    updateColumnSorting: function(cmp, event, helper) {
    	var columns = cmp.get('v.columns');
    	var fieldName = event.getParam('fieldName');
    	for(var i=0; i<columns.length; i++) {
    		if(columns[i]['fieldName'] == fieldName) {
    			cmp.set('v.sortBy', columns[i]['label']);
    		}
    		if(fieldName == 'linkName') {
    			cmp.set('v.sortBy', 'Name');
    		}
    	}
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection, helper);    
    },
    
     newAction: function(cmp, event, helper) {
        console.log('Enter Here');
        var myUserContext = cmp.get("v.themeName");
		console.log('newAction myUserContext',myUserContext); 
        
        if(myUserContext === undefined) {
            	console.log('I am in undefined');
               var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef  : "c:ActionDetails" ,
                    componentAttributes : {
                    }
                });
                evt.fire(); 
        } else if(myUserContext == 'Theme3'  || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
        	window.location = '/apex/EditActionDetails';
        } 
    },
    
})