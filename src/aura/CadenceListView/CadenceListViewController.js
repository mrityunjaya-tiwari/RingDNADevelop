({
    init: function (cmp, event, helper) {
        var rowActions = helper.getRowActions.bind(this, cmp);
        cmp.set('v.columns', [
            {label: 'Sequence Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
            { label: 'Type', fieldName: 'objType', type: 'text', sortable: true},
            { label: 'Activation', fieldName: 'activation', type: 'text', sortable: true},
            { label: 'Participants', fieldName: 'participants', type: 'number', sortable: true}, 
            { type: 'action', typeAttributes: { rowActions: rowActions } } 
        ]);
        helper.fetchData(cmp, helper);
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action'),
            row = event.getParam('row'),
            rows = [];
        rows.push(row);
        
        switch (action.name) {
            case 'view':
                helper.viewCadence(cmp, event, row['cadId']);
                break;
            case 'edit':
                helper.editCadence(cmp, event, row['cadId'])
                break;
            case 'delete':
                cmp.set('v.deleteActionRows', rows); 
                cmp.set('v.showModal', true);
                break;
        }
    },
    
    deleteCadenceActions: function(cmp, event, helper) {
        var rows = cmp.get('v.deleteActionRows');
        
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
        
        var curPage = event.getParam("currentPage");
        
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
    
    newCadence : function(cmp, event, helper) {
        var myUserContext = cmp.get("v.themeName");      
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/Cadence?isedit=True';
        } 
        else if(myUserContext == undefined){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:CadenceComponent" ,
                componentAttributes : {
                    "isEdit" : true
                }
            });
            evt.fire();
        }
    }
})