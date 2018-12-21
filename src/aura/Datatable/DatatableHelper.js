({
    setData : function(cmp, helper) {

    	if(cmp.get('v.rawData') == null) {
    		return;
    	} 
    	
        var allData = cmp.get('v.rawData'),
        	totalNumberOfRecords = allData.length,
        	currentPage = cmp.get('v.currentPage'),
        	recordsPerPage = cmp.get('v.rowsToLoad');
		
        cmp.set('v.totalNumberOfRows', totalNumberOfRecords);   
        console.log(totalNumberOfRecords);
        if(totalNumberOfRecords == 0) {
            return;
        }

        if(recordsPerPage > totalNumberOfRecords) {
            cmp.set('v.data', allData.slice(0,recordsPerPage));
            cmp.set('v.currentPage', 1);
        } else if(currentPage*recordsPerPage >= totalNumberOfRecords) {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,totalNumberOfRecords));
        } else {
            cmp.set('v.data', allData.slice((currentPage-1)*recordsPerPage,currentPage*recordsPerPage));
        }
        
    },
    
    sortData: function (cmp, fieldName, sortDirection, helper) {
        if (cmp.get('v.selectedNoOfRecords')){
            var data = cmp.get("v.data");
        }else {
            var data = cmp.get("v.rawData");
        }
        
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

})