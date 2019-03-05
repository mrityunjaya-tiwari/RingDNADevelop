({
    
    doInit : function(component, event, helper) {
        /*var totalRecords = component.get('v.total'),
            recordsPerPage = component.get('v.pageOffset');
        
        //getting total number of pages
        var totalPages = Math.ceil(totalRecords/recordsPerPage);
        component.set('v.pages', totalPages);
        
        if(totalRecords == 0) {
            component.set('v.page', 0);
        } else {
            component.set('v.page', 1);
            helper.firePageEvent(component, event);
        }*/
        
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
    },
    
    nextPage : function(component, event, helper) {
        var curPage = component.get('v.page');
        component.set('v.page', curPage+1);
        helper.firePageEvent(component, event);
    },
    
    lastPage : function(component, event, helper) {
        var curPage = component.get('v.pages');
        component.set('v.page', curPage);
        helper.firePageEvent(component, event);
        
    },
    
    previousPage : function(component, event, helper) {
        var curPage = component.get('v.page');
        component.set('v.page', curPage-1);
        helper.firePageEvent(component, event);
    },
    
    firstPage : function(component, event, helper) {
        component.set('v.page', 1);
        helper.firePageEvent(component, event);
    },
    
    onSelectChange : function(component, event, helper){
        var selectComponent = component.find('recordSize');
        component.set('v.pageOffset', selectComponent.get('v.value')); 
        var pg = component.get('v.pageOffset');
        var totalRecords = component.get('v.total');        
        var totalPages = Math.ceil(totalRecords/pg);
        component.set('v.pages', totalPages);
        component.set('v.page', 1);
        helper.firePageEvent(component, event);
        
    }
})