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
                cmp.set('v.spinner', false);
            } else {
                cmp.set('v.spinner', false);
                console.log('In error');
            }
        });
        $A.enqueueAction(action);         
    },
    
    setData : function(cmp) {
        
        console.log('in set data function');
        console.log(cmp.get('v.rawData'));
    	var allData = cmp.get('v.rawData'),
        	totalNumberOfRecords = allData.length,
        	currentPage = cmp.get('v.currentPage'),
        	recordsPerPage = cmp.get('v.rowsToLoad');
		console.log('I am in set data');
        
        cmp.set('v.totalNumberOfRows', totalNumberOfRecords);        
        if(recordsPerPage > totalNumberOfRecords) {
            cmp.set('v.data', allData.slice(0,recordsPerPage));
            console.log('v.data');
            cmp.set('v.currentPage', 1);
        } else if(currentPage*recordsPerPage >= totalNumberOfRecords) {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,totalNumberOfRecords));
            cmp.set('v.currentPage', currentPage-1);
        } else {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,currentPage*recordsPerPage));
        }
        
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
		console.log(ids);
        
        var action = cmp.get('c.deleteActions');
        action.setParams({ actionIds : ids });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var allRows = cmp.get('v.rawData');
                for(var i=0; i<rows.length; i++) {
                    var rowIndex = allRows.indexOf(rows[i]);
 			        allRows.splice(rowIndex, 1);
                }
                cmp.set('v.rawData', allRows);
                console.log(allRows);
                helper.setData(cmp);
                console.log('Delete Successful');	                
            } else {
                console.log('Delete Failed due to following error -');
                console.log(response.errors);
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
        console.log('In view detail');
        console.log(id);
        var myUserContext = cmp.get("v.themeName");
        console.log('In view detail myUserContext',myUserContext);
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