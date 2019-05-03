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
        var count =0;
        for(var index=0;index<criterias.length;index++){
        	rowListObj[index+1]=criterias[index];
            count++;
        }
        component.set("v.criteriaList", Object.values(rowListObj));
        component.set("v.criteriaSet.criterions", rowListObj);
        component.set("v.criteriaListCount", count);
    },
    
    initializeCriteriaList: function(component, helper){
        var criteriaSet = component.get("v.criteriaSet"); 
    	if(criteriaSet!=null){
    		var criteriaList = Object.values(criteriaSet.criterions);
    		component.set("v.criteriaList", criteriaList);
            component.set("v.criteriaListCount", criteriaList.length); 
        }else{
    		var criteriaList = [];
    		criteriaList.push(helper.initializeCriteriaArray());
    		component.set("v.criteriaList", criteriaList);
            component.set("v.criteriaListCount", criteriaList.length);
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
        component.set("v.criteriaListCount", max+1);
        
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
    },
    updateCriteriaList: function(component, event, helper){
        var cfList = component.get("v.contactFieldList");
        var afList = component.get("v.accountFieldList");
        for(var i in afList){
            var obj = afList[i];
            cfList.push({
                'sobjectType': 'Criterion',
                'fieldDataType':  obj.fieldDataType,
                'fieldName' :  'Account.' + obj.fieldName,
                'fieldLabel': 'Account.' +obj.fieldLabel,
                'listPicklistValues' :obj.listPicklistValues
            });
        }
        component.set("v.contactFieldList", cfList)
        var lfList = component.get("v.leadFieldList");
        
        var dbList = component.get("v.dbFieldList");
        for(var j in dbList){
            var dbObj = dbList[j];
            lfList.push({
                'sobjectType': 'Criterion',
                'fieldDataType':  dbObj.fieldDataType,
                'fieldName' :  'DandBCompany.' + dbObj.fieldName,
                'fieldLabel': 'DandBCompany.' + dbObj.fieldLabel,
                'listPicklistValues' :dbObj.listPicklistValues
            });
        }
        component.set("v.leadFieldList", lfList);
    },
    
    
})