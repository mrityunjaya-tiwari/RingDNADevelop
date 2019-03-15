({
    // Toggle details section 
    sectionToggle : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    // Added new row for set fields to update
    createRowToFieldsUpdate: function(component, event, helper){
       var rowList = component.get("v.rowToCreateFieldsToUpdate");        
            rowList.push({
                'sobjectType': 'wrapperTaskField',
                'key': '',
                'value': ''
            });        
        component.set("v.rowToCreateFieldsToUpdate", rowList);
    },
    // Set action object according to cadenceAction object 
    setActionObject : function(component, event, helper){
        var cadenceActionObj = component.get("v.cadenceAction");
        var actionList = component.get("v.allActionsList");
        var currentIndex = component.get('v.currentIndex');
        cadenceActionObj.index = currentIndex;
        
        for(var index in actionList){
            var actionObj = actionList[index];
            var actionId = actionObj.id;
            
            
            if (cadenceActionObj.actionId == actionId){
                component.set("v.actionObject", actionObj);
                cadenceActionObj.name = actionObj.name;
                
                if (actionObj.activationType == 'Manual'){
                    component.set('v.showPriority', 'True');
                    var cmpTarget = component.find('updatePriorityChanges');
                    $A.util.removeClass(cmpTarget, 'slds-size_1-of-3');
                    $A.util.addClass(cmpTarget, 'slds-size_1-of-4');
                     
                    var pList= component.get('v.pList');
                    var cAct = component.get('v.cadenceAction');
                    if (cAct != undefined && (cAct.priority === undefined ||cAct.priority == '' )){                      
                        cAct.priority = pList[1];
                        cAct.priorityNumber = 2;
                    }
                    
                    component.set('v.cadenceAction', cAct);
                }else{
                   
                    var cAct = component.get('v.cadenceAction');
                    cAct.priority = '';
                    cAct.priorityNumber = 0;
                    component.set('v.cadenceAction', cAct);
                    component.set('v.showPriority', 'false');
                    var cmpTarget = component.find('updatePriorityChanges');
                    $A.util.removeClass(cmpTarget, 'slds-size_1-of-4');
                    $A.util.addClass(cmpTarget, 'slds-size_1-of-3');
                }
            }
            
        }
    },
    // used to remove rows from fields to update
    handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowList = component.get("v.rowToCreateFieldsToUpdate");
        rowList.splice(ronIndex, 1);
        component.set("v.rowToCreateFieldsToUpdate", rowList);
    },
    // Used to validate cadenceAction detail.
    validateCADetail:function(component, event, helper){
        var isValidActioin = component.find('formValidationId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        return isValidActioin;
    },
    // Check Validation for sub component - ActionDetailsDynamicRow
    validateFieldsToUpdateComponent:function(component, event, helper){
        var dynamicROw = [];
        dynamicROw = component.find('dynamicROw');
        if(dynamicROw === undefined) {
            return false;
        }
        var  isValid = true;
        if (dynamicROw.length >= 1){
            for (var index in dynamicROw){
                var obj = dynamicROw[index];
                var isValidRow = obj.validateDynamicRowForm();
                if (!isValidRow){
                    isValid = isValidRow;
                }
            }
        }else{
            isValid = dynamicROw.validateDynamicRowForm();
        }
        return isValid;
        
    },
    // Method is used to set 'Fields_To_Update_Action__c'
    setFieldsToUpdateJsonOnCadenceAction: function(component, event, helper){
        var wrapperFieldsData= component.get("v.rowToCreateFieldsToUpdate");
        var newCadence= component.get("v.newCadence");
        var cadenceAction= component.get("v.cadenceAction");
        var newObject;
        if  (newCadence.recordType =='Contact'){
            newObject = component.get("v.ContactObj");
        }else {
            newObject = component.get("v.LeadObj");
        }
        for(var index in wrapperFieldsData){
            var wrapperTOCreateObject= wrapperFieldsData[index];
            var key = wrapperTOCreateObject.key;
            var value = wrapperTOCreateObject.value;
            newObject[key] =  value;
        }
        cadenceAction.fieldsToUpdateAction = JSON.stringify(newObject);
        component.set("v.cadenceAction", cadenceAction);
        
    },
    // Method is used to set 'Action_Criterion__c'
    setActionCriteria:function(component, event, helper){
        var cadenceAction= component.get("v.cadenceAction");
        cadenceAction.actionCriterion = JSON.stringify(component.get("v.entranceCriteriaSet"));
        component.set("v.cadenceAction", cadenceAction);
    },
    // Method is used to edit cadenceAction detail
    setDataForEdit:function(component, event, helper){
        var cadenceActionObj = component.get("v.cadenceAction");
        if (cadenceActionObj.fieldsToUpdateAction && cadenceActionObj.fieldsToUpdateAction != ''){
            component.set("v.fieldOptionsValue", "true"); 
            component.set("v.setFieldsToUpdate", "true"); 
            var obj = JSON.parse(cadenceActionObj.fieldsToUpdateAction);
            var listOfKey = Object.keys(obj);
            var rowList = [];
            for (var index in listOfKey){
                var key = listOfKey[index];
                var value = obj[key];
                if (key !='sobjectType'){
                    rowList.push({
                        'sobjectType': 'wrapperTaskField',
                        'key': key,
                        'value': value
                    });
                }
            }
            component.set("v.rowToCreateFieldsToUpdate", rowList);
            
        }
        if (cadenceActionObj.actionCriterion){
            component.set("v.criteriaOptionsValue", "true");
            var actionCriteriaSet = JSON.parse(cadenceActionObj.actionCriterion);
            component.set("v.entranceCriteriaSet", actionCriteriaSet);
            component.set("v.setCriteriaFields", true);
        }
        var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");
        var index = component.get("v.currentIndex");
        component.set("v.actionType", actionTypeListForCadenceAction[index]);       
        helper.createActionTypeList(component, event, actionTypeListForCadenceAction[index]);
        helper.setActionObject(component, event, helper);
        helper.disablUnitInput(component, event, helper);
       
    },
    // Create a list of action for selected action type
    createActionTypeList: function(component, event, actionType){
        var actionList =  component.get('v.allActionsList');
        var actionListOfType = [];
        for(var index in actionList){
            if(actionList[index].type == actionType){
                actionListOfType.push(actionList[index]);
            }
        }
        component.set('v.actionList',actionListOfType);
        component.set('v.cadenceAction',component.get('v.cadenceAction'));
    },
    
    // used to disable input for immediate cadence actions.
    disablUnitInput:function(component, event, helper){
        var cadObj = component.get("v.cadenceAction");
        if (cadObj.triggerType == 'Immediate'){
            component.set("v.disableInput",false);
            cadObj.day ='';
            cadObj.RDNACadence4__Hour__c ='';
        }else if (cadObj.triggerType == 'Time Based'){
            component.set("v.disableInput",true);
            
            if (!cadObj.day){
                cadObj.day = 0;
            }
            if (!cadObj.hour){
                cadObj.hour = 0;
            }
        } else {
            component.set("v.disableInput",false);
            cadObj.day ='';
            cadObj.hour ='';
        }
        component.set("v.cadenceAction", cadObj);
    },
    // Set lead felds data
    setLeadFieldsList:function(component, event, helper){
        var leadFieldList = component.get("v.leadFieldList");
        var wrapperLeadFields = component.get("v.wrapperLeadFields");
        for(var i in leadFieldList){
            var obj = leadFieldList[i];
            
            wrapperLeadFields.push({
                'sobjectType': 'wrapperLeadFields',
                'dataType': obj.fieldDataType,
                'apiName' : obj.fieldName,
                'key': obj.fieldLabel,
                'value': obj.fieldLabel,
                'listPicklistValues' :obj.listPicklistValues
            });
        }
        component.set('v.wrapperLeadFields', wrapperLeadFields);
        
    },
    // Set Contact felds data
    setContactFieldsList:function(component, event, helper){
        var contactFieldList = component.get("v.contactFieldList");
        var wrapperContactFields = component.get("v.wrapperContactFields");
        for(var i in contactFieldList){
            var obj = contactFieldList[i];
            wrapperContactFields.push({
                'sobjectType': 'wrapperContactFields',
                'dataType': obj.fieldDataType,
                'apiName' : obj.fieldName,
                'key': obj.fieldLabel,
                'value': obj.fieldLabel,
                'listPicklistValues' :obj.listPicklistValues
            });
        }
        component.set('v.wrapperContactFields', wrapperContactFields);
    },
    // Validate sub component - CriterionComponent
    validateCriterion : function(component, event, helper) {
        var entryCriterion = component.find('actionCriterionComponent');
        if(entryCriterion === undefined) {
            return false;
        }
        var isValid = entryCriterion.validateCriterion();
        return isValid;
    },
    
    createListForInput : function (component){
        var fieldList = component.get("c.createListForUIInput");      
        component.set('v.spinner', true);
		fieldList.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var result = response.getReturnValue();
                var pList = result.pList;
				component.set('v.pList', pList);
                //component.get(pList[1]).set(selected,true);
                component.set('v.spinner', true);                
                window.setTimeout(
                    $A.getCallback(function() {
                       
                        try {
                            var cAct = component.get('v.cadenceAction');
                            if(cAct != undefined || cAct != ''){
                                if ( cAct.priority == undefined ||cAct.priority == '' ){
                                    cAct.priority = pList[1]; 
                                    cAct.priorityNumber = 2;
                                    
                                }
                                component.set('v.cadenceAction', cAct); 
                            }
                        }
                        catch(err) {
                            console.log('error to set priority');
                        } 
                        /*if ( cAct.RDNACadence__Priority__c == undefined ||cAct.RDNACadence__Priority__c == '' ){
                            cAct.RDNACadence__Priority__c = pList[1]; 
                            cAct.RDNACadence__Priority_number__c = 2;
                        }*/
                        
                        //component.set('v.cadenceAction', cAct);                       
                        component.set('v.spinner', false);
                    }), 500
                );
               
			}else{
				console.log('failed with status:',response);
			}
		});
		$A.enqueueAction(fieldList);
    },
})