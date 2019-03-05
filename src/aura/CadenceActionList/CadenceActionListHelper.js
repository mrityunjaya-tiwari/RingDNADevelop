({
    fetchData: function (cmp, helper) {
        cmp.set('v.spinner', true);
        var action = cmp.get('c.fetchCadenceActions'); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records = response.getReturnValue();
                var myUserContext = cmp.get("v.themeName");
                
                records.forEach(function(record){
                    if (myUserContext == 'Theme3') {
                        record.linkName = '/apex/ActionDetailView?id='+record.actionId;
                    }
                    else
                        record.linkName = '/'+record.actionId;
                });
                cmp.set('v.rawData', records);  
                helper.setData(cmp);
                cmp.set('v.isOnload', false);
                cmp.set('v.spinner', false);
            } else {
                cmp.set('v.spinner', false);
                
            }
        });
        $A.enqueueAction(action);         
    },
    
    setData : function(cmp) {
        var allData = cmp.get('v.rawData');
        var totalNumberOfRecords = allData.length;
        var currentPage1 = cmp.get('v.currentPage');
        var recordsPerPage = cmp.get('v.rowsToLoad');
       
        if(recordsPerPage > totalNumberOfRecords) {
            cmp.set('v.data', allData.slice(0,recordsPerPage));
        } else if(currentPage1*recordsPerPage >= totalNumberOfRecords) {
            cmp.set('v.data', allData.slice((currentPage1-1)*recordsPerPage,totalNumberOfRecords));
        } else {
              cmp.set('v.data', allData.slice((currentPage1-1)*recordsPerPage,currentPage1*recordsPerPage));
        }
        cmp.set('v.totalNumberOfRows', totalNumberOfRecords); 
    },
    
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Edit Action',
            'name': 'edit'
        }];
        actions.push({
            'label': 'Delete Action',
            'name': 'delete'
        });
        actions.push({
            'label': 'View Action',
            'name': 'view'
        });
        
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    
    deleteAction: function(cmp, rows, helper) {
        var ids = [];
        for(var i=0; i<rows.length; i++) {
            var row = rows[i]; 
            ids.push(row['actionId']);    
        }
        var action = cmp.get('c.deleteActions');
        action.setParams({ actionIds : ids });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var actionDeleteMessageWrapper = response.getReturnValue();
                if(actionDeleteMessageWrapper.name.length > 0){
                    if(actionDeleteMessageWrapper.deletedCount > 0){
            			actionDeleteMessageWrapper.name = actionDeleteMessageWrapper.deletedCount + ' actions deleted! and Cannot delete these action(s) :{'+ actionDeleteMessageWrapper.name + '} as they are already associated with any sequence.'; 
        			}else{
            		    actionDeleteMessageWrapper.name = 'Cannot delete these action(s) :{'+ actionDeleteMessageWrapper.name + '} as they are already associated with any sequence.'; 
        		    }
                    cmp.set('v.showModalMessage', true);
                    cmp.set('v.deleteActionMessage', actionDeleteMessageWrapper.name);
                }
                
                var allRows = cmp.get('v.rawData');
                for(var i=0; i<rows.length; i++) {
                    var rowIndex = allRows.indexOf(rows[i]);
                    var row = rows[i]; 
                    if (!actionDeleteMessageWrapper.actionIds.includes(row['actionId'])){
                        allRows.splice(rowIndex, 1);
                    }
                }
                
                cmp.set('v.rawData', allRows);
                helper.setData(cmp);
                
            } else {
                
            }
        });
        $A.enqueueAction(action);
    },
    
    sortData: function (cmp, fieldName, sortDirection, helper) {
        var data = cmp.get("v.rawData");
        var reverse = sortDirection !== 'asc';
        if (fieldName == 'linkName') {
            fieldName = 'name';
        }
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.rawData", data);
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
    
    viewDetails : function(cmp, event, id) {
        
        var myUserContext = cmp.get("v.themeName");
        
        if(myUserContext == 'Theme3'  || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/ActionDetailView?id='+id;
        } 
        else if( myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ActionDetailView" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire()  
        }
    },
    
    editRecord : function(cmp, event, id) {
        var myUserContext = cmp.get("v.themeName");  
        if(myUserContext == 'Theme3'  || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/EditActionDetails?id='+id;
        } 
        else if( myUserContext == undefined){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:ActionDetails" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire(); 
        }
    },
    
})