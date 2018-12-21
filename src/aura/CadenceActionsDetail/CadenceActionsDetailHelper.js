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
        if(rowList.length == 0) {
	        rowList.push({
	            'sobjectType': 'wrapperTaskField',
	            'key': 'Priority',
	            'value': ''
	        });
        } else {
	        rowList.push({
	            'sobjectType': 'wrapperTaskField',
	            'key': '',
	            'value': ''
	        });
        }
        component.set("v.rowToCreateFieldsToUpdate", rowList);
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
        
        if  (newCadence.RDNACadence__Record_Type__c =='Contact'){
            var newObject = component.get("v.ContactObj");
        }else {
            var newObject = component.get("v.LeadObj");
        }
        for(var index in wrapperFieldsData){
            var wrapperTOCreateObject= wrapperFieldsData[index];
            var key = wrapperTOCreateObject.key;
            var value = wrapperTOCreateObject.value;
            newObject[key] =  value;
        }
        cadenceAction.RDNACadence__Fields_To_Update_Action__c = JSON.stringify(newObject);
        component.set("v.cadenceAction", cadenceAction);
    },
    // Method is used to set 'Action_Criterion__c'
    setActionCriteria:function(component, event, helper){
        var cadenceAction= component.get("v.cadenceAction");
        cadenceAction.RDNACadence__Action_Criterion__c = JSON.stringify(component.get("v.entranceCriteriaSet"));
        component.set("v.cadenceAction", cadenceAction);
    },
    // Method is used to edit cadenceAction detail
    setDataForEdit:function(component, event, helper){
        var cadenceActionObj = component.get("v.cadenceAction");
        if (cadenceActionObj.RDNACadence__Fields_To_Update_Action__c && cadenceActionObj.RDNACadence__Fields_To_Update_Action__c != ''){
            component.set("v.fieldOptionsValue", "true"); 
            component.set("v.setFieldsToUpdate", "true"); 
            var obj = JSON.parse(cadenceActionObj.RDNACadence__Fields_To_Update_Action__c);
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
            console.log('cadenceActionObj.RDNACadence__Fields_To_Update_Action__c  ',obj.sobjectType);
        }
        if (cadenceActionObj.RDNACadence__Action_Criterion__c){
            component.set("v.criteriaOptionsValue", "true");
            var actionCriteriaSet = JSON.parse(cadenceActionObj.RDNACadence__Action_Criterion__c);
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
            if(actionList[index].RDNACadence__Type__c == actionType){
                actionListOfType.push(actionList[index]);
            }
        }
        component.set('v.actionList',actionListOfType);
        component.set('v.cadenceAction',component.get('v.cadenceAction'));
    },
    // Set action object according to cadenceAction object 
    setActionObject : function(component, event, helper){
        var cadenceActionObj = component.get("v.cadenceAction");
        var actionList = component.get("v.allActionsList");
        for(var index in actionList){
            var actionObj = actionList[index];
            var actionId = actionObj.Id;
            if (cadenceActionObj.RDNACadence__Action_Id__c == actionId){
                component.set("v.actionObject", actionObj);
                cadenceActionObj.Name = actionObj.Name;
            }
        }
    },
    // used to disable input for immediate cadence actions.
    disablUnitInput:function(component, event, helper){
        var cadObj = component.get("v.cadenceAction");
        if (cadObj.RDNACadence__Trigger_Type__c == 'Immediate'){
            component.set("v.disableInput",false);
            cadObj.RDNACadence__Day__c ='';
            cadObj.RDNACadence__Hour__c ='';
        }else if (cadObj.RDNACadence__Trigger_Type__c == 'Time Based'){
            component.set("v.disableInput",true);
            
            if (!cadObj.RDNACadence__Day__c){
                cadObj.RDNACadence__Day__c = 0;
            }
            if (!cadObj.RDNACadence__Hour__c){
                cadObj.RDNACadence__Hour__c = 0;
            }
        } else {
            component.set("v.disableInput",false);
            cadObj.RDNACadence__Day__c ='';
            cadObj.RDNACadence__Hour__c ='';
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
                'key': obj.fieldLabel,
                'value': obj.fieldName,
                'listPicklistValues' :obj.listPicklistValues
            });
        }
        component.set('v.wrapperLeadFields', wrapperLeadFields);
        console.log('leadFieldList ' , leadFieldList);
        console.log('wrapperLeadFields ' , wrapperLeadFields);
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
                'key': obj.fieldLabel,
                'value': obj.fieldName,
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
})