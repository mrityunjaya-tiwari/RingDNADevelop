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
        else if (newAction.type == 'Call'){
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
        } else if (newAction.type == 'Email'){
            var actionType=component.get("v.newAction").type;
            var columnsJson = [ {label: actionType+' Template Name', fieldName: 'name', type: 'text' ,sortable:'true'}];
            if(actionType=='Email'){
                columnsJson.push({label: 'Template Type', fieldName: 'teams', type: 'text',sortable:'true'});
                columnsJson.push({label: 'Description', fieldName: 'template', type: 'text',sortable:'true'});
            }
            else{
                columnsJson.push( {label: 'Team', fieldName: 'teams', type: 'text',sortable:'true'});
            }
            columnsJson.push({type: "button", typeAttributes: {
                label: 'Preview',
                name: 'View',
                variant:'base',
                title: 'View',
                disabled: false,
                value: 'view',
                iconPosition: 'right'
            } , cellAttributes: { alignment: 'right' }});
            columnsJson.push({type: "button", typeAttributes: {
                label: { fieldName: 'selectButtonLabel'},
                disabled: {fieldName: 'disableselectButton'},
                name: 'Edit',
                title: 'Edit',
                value: 'edit',
                iconPosition: 'left'
            }});
            component.set('v.columns',columnsJson);
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
                component.set("v.rowActionTemplateList", response.getReturnValue());   var newAction = component.get('v.newAction'); 
                var data = component.get('v.rowActionTemplateList');
                data = data.map(function(rowData) { 
                    if (rowData.id === newAction.templateId) {
                        rowData.selectButtonLabel = 'Selected';
                        if (newAction.type == 'Email'){
                            rowData.disableselectButton = true;
                        }
                    }else{
                        rowData.selectButtonLabel = 'Select';
                        rowData.disableselectButton = false;
                    }
                    return rowData;
                });
                component.set("v.rowActionTemplateList", data);
                helper.setData(component, event, helper);
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
    getFolderType : function(component, event, helper) {
        component.set('v.spinner', true);
        var actionType = component.get("v.newAction").type;
        var action = component.get("c.getFolderType");
        action.setParams({
            actionType :actionType
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set("v.templateFolderList", response.getReturnValue());
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    applyFilters : function(component, event, helper){
    	var data = component.get('v.rowActionTemplateList');
        var folderFilter = component.get('v.folderFilter');
        var filterData=[];
        if(folderFilter !=''){
            for(var item in data){
                if(data[item].folderId ==folderFilter ){
                    filterData.push(data[item]);
                }
            }
            component.set('v.rowActionTemplateList',filterData);
        }else{
        	helper.getData(component, event, helper);
        }
        helper.setData(component, event, helper);
    }
})