({
    setTableColunm :function(component, event, helper) {
        var newAction = component.get('v.newAction');
        if(newAction.type == 'SMS'){
        component.set('v.columns', [
            {label: 'SMS Template Name', fieldName: 'name', type: 'text' ,sortable:'true'},
            {label: 'Team', fieldName: 'teams', type: 'text',sortable:'true'}, 
            {type: "button", typeAttributes: {
                label: 'Preview',
                name: 'View',
                variant:'base',
                title: 'View',
                disabled: false,
                value: 'view',
                iconPosition: 'right'
            } , cellAttributes: { alignment: 'right' }},
            {type: "button", typeAttributes: {
                label: { fieldName: 'selectButtonLabel'},
                disabled: {fieldName: 'disableselectButton'},
                name: 'Edit',
                title: 'Edit',
                value: 'edit',
                iconPosition: 'left'
            }}
        ]);
        }        
        else{
         component.set('v.columns', [
            {label: 'Call Notes Template Name', fieldName: 'name', type: 'text' ,sortable:'true'},
            {label: 'Team', fieldName: 'teams', type: 'text',sortable:'true'}, 
            {type: "button", typeAttributes: {
                label: 'Preview',
                name: 'View',
                variant:'base',
                title: 'View',
                disabled: false,
                value: 'view',
                iconPosition: 'right'
            } , cellAttributes: { alignment: 'right' }},
            {type: "button", typeAttributes: {
                label: { fieldName: 'selectButtonLabel'},
                disabled: {fieldName: 'disableselectButton'},
                name: 'Edit',
                title: 'Edit',
                value: 'edit',
                iconPosition: 'left'
            }}
        ]);            
        }
    },
    getData : function(component, event, helper) {
        component.set('v.spinner', true);
        var newAction  = component.get('v.newAction');
        var actionType = newAction.type;
        var action = component.get("c.fetchActionTemplates");
        action.setParams({
            type : actionType
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set("v.rowActionTemplateList", response.getReturnValue());            
                helper.setData(component, event, helper);
                var newAction = component.get('v.newAction'); 
                var data = component.get('v.actionTemplateList');
                data = data.map(function(rowData) { 
                    if (rowData.id === newAction.templateId) {
                        rowData.selectButtonLabel = 'Selected';
                        rowData.disableselectButton = true;
                    }else{
                        rowData.selectButtonLabel = 'Select';
                        rowData.disableselectButton = false;
                    }
                    return rowData;
                });
                component.set("v.actionTemplateList", data);
            }
            component.set('v.spinner', false);           
        });
        $A.enqueueAction(action);
    },
    setData :  function(component, event, helper) {
        var currentPage1 = component.get('v.currentPage');
        var recordsPerPage = component.get('v.rowsToLoad');
        var allData = component.get('v.rowActionTemplateList');
        var totalNumberOfRecords = allData.length;
        component.set('v.totalNumberOfRows', totalNumberOfRecords) ;
        if(recordsPerPage > totalNumberOfRecords) {
            component.set('v.actionTemplateList', allData.slice(0,recordsPerPage));
        } else if(currentPage1*recordsPerPage >= totalNumberOfRecords) {
            component.set('v.actionTemplateList', allData.slice((currentPage1-1)*recordsPerPage,totalNumberOfRecords));
        } else {
            component.set('v.actionTemplateList', allData.slice((currentPage1-1)*recordsPerPage,currentPage1*recordsPerPage));
        }
        component.set('v.totalNumberOfRows', totalNumberOfRecords); 
    },
    sortData: function (cmp, fieldName, sortDirection, helper) {
        var data = cmp.get("v.rowActionTemplateList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.rowActionTemplateList", data);
        helper.setData(cmp);
    },   
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }, 
    
})