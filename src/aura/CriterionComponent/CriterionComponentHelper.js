({
	getObjectFields: function(component, recordType){
		var fieldList = component.get("c.getFields");
		fieldList.setParams({objectStr: recordType});
		fieldList.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var result = response.getReturnValue();
				component.set("v.fieldList", result);
			}else{
				console.log('failed with status:',response);
			}
		});
		$A.enqueueAction(fieldList);
	},
	
	handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowListObj = component.get("v.criteriaSet.criterions");
        delete rowListObj[ronIndex+1];
        var criterias = Object.values(rowListObj);
        rowListObj={};
        for(var index=0;index<criterias.length;index++){
        	rowListObj[index+1]=criterias[index];
        }
        component.set("v.criteriaList", Object.values(rowListObj));
        component.set("v.criteriaSet.criterions", rowListObj);
    },
    
    initializeCriteriaList: function(component, helper){
    	var criteriaSet = component.get("v.criteriaSet");
    	if(criteriaSet!=null){
    		var criteriaList = Object.values(criteriaSet.criterions);
    		component.set("v.criteriaList", criteriaList);
    	}else{
    		var criteriaList = [];
    		criteriaList.push(helper.initializeCriteriaArray());
    		component.set("v.criteriaList", criteriaList);
    		
			var newCriteriaSet = helper.initializeCriteriaSet();
			newCriteriaSet.criterions = helper.prepareCriterions(criteriaList)
			component.set("v.criteriaSet", newCriteriaSet);
    	}
    },
    
    createObjectData: function(component, helper, event) {
    	var criteriaSet = component.get("v.criteriaSet");
    	if(criteriaSet==null){
			component.set("v.criteriaSet", helper.initializeCriteriaSet());
    	}
        var rowList = component.get("v.criteriaList");
        var max=0;
        if(rowList.length>0){
        	max=rowList.length;
        }
        rowList.push(helper.initializeCriteriaArray());
        var rowListObj= helper.prepareCriterions(rowList);
        var cadenceId = component.get("v.cadence");
        component.set("v.criteriaSet.criterions", rowListObj);
        component.set("v.criteriaList", rowList);
    },
    
    prepareCriterions: function(criteriaList){
    	var criterions={}; 
        for(var i=0;i<criteriaList.length;i++){
        	criterions[i+1]= criteriaList[i];
        }
        return criterions;	
    },
    
    initializeCriteriaSet: function(){
    	return {
				'criterionPriorityFormula': '',
				'condition': 'All of the conditions are met (AND)',
				'executionCriterion': 'Conditions are met',
				'criterions': {
					
				}
			};
    },
    
    initializeCriteriaArray : function(){
    	return {
				'fieldDataType': '',
				'fieldName': '',
				'fieldLabel':'',
				'operation': '',
				'value': '',
				'id': 1
			};
    }
    
    
})