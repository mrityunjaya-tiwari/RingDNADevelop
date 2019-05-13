({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Sequence Name', fieldName: 'linkName', type: 'url', sortable:'true',
             typeAttributes: {label: { fieldName: 'name' }, tooltip: {fieldName: 'name'}, target: '_self', sortable: true}},
            { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
            { label: 'Type', fieldName: 'objType', type: 'text', sortable: true},
            { label: 'Activation', fieldName: 'activation', type: 'text', sortable: true},
            { label: 'Participants', fieldName: 'participants', type: 'number', sortable: true}
            
        ]);
        helper.fetchData(cmp, helper);
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
    saveCadence: function(cmp, event, helper){
        var selectedRows=cmp.get('v.selectedRows');
        console.log(selectedRows.length==0);
        if(selectedRows.length==0){
            cmp.set('v.sequenceNotSelected',true);
        }else{
            helper.saveCadence(cmp, event, helper);
        }
    },
    setSelectedRow: function(cmp, event, helper){
        helper.setSelectedRow(cmp, event, helper);   
    },
    onCancel : function(cmp, event, helper){
        window.history.back();
    },
    okMessage: function(cmp, event, helper){
        cmp.set("v.showModalMessage", false);
    }
})