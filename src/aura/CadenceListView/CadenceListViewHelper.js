({
	
    fetchData: function (cmp, helper) {
        cmp.set('v.spinner' , true);
        var action = cmp.get('c.getCadenceData'); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.cadId;
                });
                cmp.set('v.rawData', records);  
                helper.setData(cmp);
                cmp.set('v.spinner', false);
            } else {
               
                cmp.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);         
    },
    
    setData : function(cmp) {
    	var allData = cmp.get('v.rawData'),
        	totalNumberOfRecords = allData.length,
        	currentPage = cmp.get('v.currentPage'),
        	recordsPerPage = cmp.get('v.rowsToLoad');
        
           
        if(recordsPerPage > totalNumberOfRecords) {
            cmp.set('v.data', allData.slice(0,recordsPerPage));
            
        } else if(currentPage*recordsPerPage >= totalNumberOfRecords) {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,totalNumberOfRecords));
           
        } else {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,currentPage*recordsPerPage));
        }
        
        cmp.set('v.totalNumberOfRows', totalNumberOfRecords); 
        
    },
    
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Edit Sequence',
            'name': 'edit'
        }];
        actions.push({
            'label': 'Delete Sequence',
            'name': 'delete'
        });
        actions.push({
                'label': 'View Sequence',
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
 	       ids.push(row['cadId']);    
        }
        var action = cmp.get('c.deleteCadences');
        action.setParams({ cadIds : ids });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var allRows = cmp.get('v.rawData');
                for(var i=0; i<rows.length; i++) {
                    var rowIndex = allRows.indexOf(rows[i]);
                    allRows.splice(rowIndex, 1);
                }
                
                cmp.set('v.rawData', allRows);
                helper.setData(cmp);	                
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
    
    viewCadence : function(cmp, event, id) {
        var myUserContext = cmp.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/Cadence?isedit=false&id='+id;
        }
        else if(myUserContext == undefined){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CadenceComponent",
                componentAttributes : {
                    "recordId" : id,
                    "isEdit" : false
                }
            });
            evt.fire();
        }        
    },
    
    editCadence : function(cmp, event, id) {
        var myUserContext = cmp.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/Cadence?isedit=True&id='+id;
        }
       else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:CadenceComponent" ,
                componentAttributes : {
                    "recordId" : id,
                    "isEdit" : true
                }
            });
            evt.fire();
        }
	},
})
