({
	helperMethod : function() {
		
	},
    
    firePageEvent : function(component, event) {
 		var curPage = component.get('v.page');
        var paginationEvent = component.getEvent("cadencePagination");
        paginationEvent.setParams({
            currentPage: curPage
        }).fire();
	}
})