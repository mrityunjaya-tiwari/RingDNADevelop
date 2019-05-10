({
    getOperatorList: function(component, event, helper){
        var dataType = component.get("v.fieldDataType");
        var operatorList = helper.getOperatorListFromMap(dataType.toUpperCase());
        component.set("v.operatorList",operatorList);
    },
    
    getOperatorListFromMap : function(datatype){
        var dataTypeOperatorsMap={};
	    dataTypeOperatorsMap['MULTIPICKLIST']=[{'label':'Does not equal','value':'not_equals'},
                                               {'label':'Equals','value':'equals'}];
											
        dataTypeOperatorsMap['PICKLIST']=[{'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'}];
        
        dataTypeOperatorsMap['STRING']=  [{'label':'Contains','value':'contains'},
                                          {'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'},
                                          {'label':'Starts with','value':'start_with'}];
        
        dataTypeOperatorsMap['PHONE']=  [ {'label':'Does not equal','value':'not_equals'},
                                         {'label':'Equals','value':'equals'}];
        
        dataTypeOperatorsMap['DATE']=  [{'label':'Does not equal','value':'not_equals'},
                                        {'label':'Equals','value':'equals'},
                                        {'label':'Greater than','value':'greater'},
                                        {'label':'Greater than or equal','value':'greater_or_equals'},
                                        {'label':'Less than','value':'less_than'},
                                        {'label':'Less than or equal','value':'less_or_equals'}];
        
        dataTypeOperatorsMap['DATETIME']=  [{'label':'Does not equal','value':'not_equals'},
                                            {'label':'Equals','value':'equals'},
                                            {'label':'Greater than','value':'greater'},
                                            {'label':'Greater than or equal','value':'greater_or_equals'},
                                            {'label':'Less than','value':'less_than'},
                                            {'label':'Less than or equal','value':'less_or_equals'}];
        
        dataTypeOperatorsMap['BOOLEAN']= [{'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'}];
        
        dataTypeOperatorsMap['EMAIL']= [{'label':'Does not equal','value':'not_equals'},
                                        {'label':'Equals','value':'equals'}];
        
        dataTypeOperatorsMap['REFERENCE']= [{'label':'Does not equal','value':'not_equals'},
                                            {'label':'Equals','value':'equals'}];
        
        
        dataTypeOperatorsMap['NUMBER']=  [{'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'},
                                          {'label':'Greater than','value':'greater'},
                                          {'label':'Greater than or equal','value':'greater_or_equals'},
                                          {'label':'Less than','value':'less_than'},
                                          {'label':'Less than or equal','value':'less_or_equals'}];
        
        return dataTypeOperatorsMap[datatype];
    },
    getuserAndDnBWrapperList : function(component, event, helper) { 
        var action = component.get("c.getUserAndDandBWrappers");
        action.setCallback(this, function(response){
            var status =  response.getState(); 
            if (status == 'SUCCESS'){
                var userAndDnBWrapperList = response.getReturnValue();                
                component.set('v.dandBCompanyWrapperList', userAndDnBWrapperList.dandbWrapper);
                component.set('v.userWrapperList', userAndDnBWrapperList.userWrapper);
                
            }
        });
        $A.enqueueAction(action);
        
    },
})