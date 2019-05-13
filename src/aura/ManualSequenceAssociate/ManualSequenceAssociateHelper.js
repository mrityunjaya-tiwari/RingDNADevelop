({
    fetchData: function (cmp, helper) {
        cmp.set('v.spinner' , true);
        var type=cmp.get('v.recordType');
        if(type == null || type == undefined || type == ''){
            cmp.set('v.showAssociationAlert' , true);
        }else{
            cmp.set('v.showAssociationAlert' , false);
        }
        var action = cmp.get('c.getCadenceDataByRecordType'); 
        action.setParams({ recordType : type });
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
        var key = primer ? function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
        function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {            
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }, 
    saveCadence: function(cmp, event, helper){     
        var selectedRows=cmp.get('v.selectedRows');
        var sequenceId=selectedRows[0].cadId;
        var participants=cmp.get('v.participants');
        cmp.set('v.spinner' , true);
        var action = cmp.get('c.saveParticipants');
        action.setParams({ sequenceId : sequenceId,
                          participantIds : participants});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var errorRecords = response.getReturnValue();
                if(errorRecords>0){
                    cmp.set('v.noOfErrorRecords', errorRecords);
                    cmp.set('v.showModalMessage', true);
                }else{
                    window.history.back();
                }
                cmp.set('v.spinner', false);
            } else {
                cmp.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);    	      
    },
    setSelectedRow: function(cmp, event, helper) {
        cmp.set('v.sequenceNotSelected',false);
        var selectedRows = event.getParam('selectedRows');
        if(selectedRows.length>0) {
            cmp.set('v.selectedRows', selectedRows);       
        }         
    },
})