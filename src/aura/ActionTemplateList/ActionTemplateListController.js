({
    initActionTemplateTable : function(component, event, helper) {
        var isSMSaction = component.get('v.isSMSAction');
        var newAction  = component.get('v.newAction');
        helper.setTableColunm(component, event , helper);
        var rowActionTemplateList = component.get("v.rowActionTemplateList");
        if (rowActionTemplateList.length == 0 ){
            helper.getData(component, event , helper);
        }else{
            helper.setData(component, event, helper);
        }
    },
    viewRecord : function(component, event, helper) {
        var row = event.getParam('row');
        var recordId = row.id;
        var actionName = event.getParam('action').name;
        if ( actionName == 'Edit' ) {
            var data = component.get('v.actionTemplateList');
            data = data.map(function(rowData) {
                if (rowData.id === row.id) {
                    rowData.selectButtonLabel = 'Selected';
                    component.set('v.newAction.templateId', rowData.id);
                    component.set('v.newAction.templateName', rowData.name);
                    rowData.disableselectButton = true;
                }else{
                    rowData.selectButtonLabel = 'Select';
                    rowData.disableselectButton = false;
                }
                return rowData;
            });
            component.set("v.actionTemplateList", data);
        } else if ( actionName == 'View') {
            component.set('v.isModal', true);
            var newAction = component.get('v.newAction');
            component.set('v.actionType', newAction.type);
            component.set('v.actionName', row.name);
            component.set('v.actionDesc', row.template);
        }
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
        }
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection, helper);    
    },    
})