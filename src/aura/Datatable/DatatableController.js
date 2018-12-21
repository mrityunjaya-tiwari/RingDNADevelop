({
	doInit : function(component, event, helper) {
        console.log('in datatable init');
		helper.setData(component, event, helper);
	}, 
    dataUpdated:function(component){
        if (component.get('v.data').length == 0 && component.get('v.selectedNoOfRecords')){
            component.set('v.isListView', false);
        }
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action'),
        	row = event.getParam('row'),
        	rows = [];
        rows.push(row);
		
        var datatableEvent = component.getEvent("datatableEvt");
        datatableEvent.setParams({
            row : row,
            actionName : action.name
        }).fire();
    },
    
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var datatableEvent = component.getEvent("datatableEvt");
        datatableEvent.setParams({
            rowsSeleted : selectedRows
        }).fire();
    },
    
    updateColumnSorting : function(cmp, event, helper) {
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
    
    handleComponentEvent : function(component, event, helper) {
        var curPage = event.getParam("currentPage");
        component.set('v.currentPage', curPage);
        helper.setData(component);
        var rowsSelected = [];
    	component.set('v.selectedRows', rowsSelected);
        
    },
    
    deselectRows : function(component, event, helper) {
    	var rowsSelected = [];
    	component.set('v.selectedRows', rowsSelected);
    },
    
   
})