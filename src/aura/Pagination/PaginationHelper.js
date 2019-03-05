({
    firePageEvent : function(component, event) {
 		var curPage = component.get('v.page');
        var paginationEvent = component.getEvent("cadencePagination");
        paginationEvent.setParams({
            currentPage: curPage
        }).fire();
	},
    
   setPagination : function(component) {
       var totalRecords = component.get('v.total'),
            recordsPerPage = component.get('v.pageOffset'),
            currentPage =  component.get('v.page');

        //getting total number of pages
        var totalPages = Math.ceil(totalRecords/recordsPerPage);
       component.set('v.total', totalRecords);
       component.set('v.pages', totalPages);     
        if(recordsPerPage > totalRecords) {
            component.set('v.page', 1);
            helper.firePageEvent(component, event);
        } else if(currentPage > totalPages) {
            component.set('v.page', currentPage -1);
            helper.firePageEvent(component, event);
        } 
    }
})