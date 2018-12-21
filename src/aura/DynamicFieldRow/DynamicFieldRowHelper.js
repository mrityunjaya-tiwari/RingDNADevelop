({
	getOperatorList: function(component, event, helper){
    	var dataType = component.get("v.fieldDataType");
    	var operatorList = helper.getOperatorListFromMap(dataType.toUpperCase());
    	component.set("v.operatorList",operatorList);
    },
    
    getOperatorListFromMap : function(datatype){
    	var dataTypeOperatorsMap={};
    	dataTypeOperatorsMap['PICKLIST']=[{'label':'Contains','value':'contains'},
                                          {'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'},
										  {'label':'Starts with','value':'start_with'}];
											
											
		dataTypeOperatorsMap['STRING']=  [{'label':'Contains','value':'contains'},
                                          {'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'},
										  {'label':'Starts with','value':'start_with'}];
											
		dataTypeOperatorsMap['BOOLEAN']= [{'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'}];
											
											
		dataTypeOperatorsMap['NUMBER']=  [{'label':'Does not equal','value':'not_equals'},
                                          {'label':'Equals','value':'equals'},
										  {'label':'Greater than','value':'greater'},
										  {'label':'Greater than or equal','value':'greater_or_equals'},
										  {'label':'Less than','value':'less_than'},
										   {'label':'Less than or equal','value':'less_or_equals'}];
		
		return dataTypeOperatorsMap[datatype];
    }
})