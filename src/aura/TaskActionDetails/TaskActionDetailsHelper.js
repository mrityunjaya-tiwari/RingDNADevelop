({
	createObjectData: function(component, event) {
        var rowList = component.get("v.listTask");
        rowList.push({
            'sobjectType': 'wrapperTaskField',
            'key': '',
            'value': ''
        });
        component.set("v.listTask", rowList);
    },
    removeDeletedRow: function(component, event, helper) {
        var rowList = component.get("v.listTask");
        var listSize = rowList.length;
        rowList.splice([listSize-1], 1);
        component.set("v.listTask", rowList);
    },
    handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowList = component.get("v.listTask");
        rowList.splice(ronIndex, 1);
        component.set("v.listTask", rowList);
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
})