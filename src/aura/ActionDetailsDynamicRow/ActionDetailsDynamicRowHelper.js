({
	helperMethod : function() {
		
	},
    updateTaskField : function(component, event, helper){
        var UpdateFieldList = component.get("v.UpdateFieldList");
        var taskObj = component.get("v.taskObj");
        for(var i=0;UpdateFieldList.length > i;i++){
            var fields =UpdateFieldList[i]["fieldsDetail"];
            for(var fieldObj in fields){
                var field = fields[fieldObj];
                if (field.fieldName == taskObj.key){
                    component.set("v.listPicklistValues", field.listPicklistValues);
                    component.set("v.dataType", field.fieldDataType);
                    component.set("v.fieldName", field.fieldName);
                    // Delete row from UpdateFieldList
                    var isValidateUpdateFieldList = component.get('v.isValidateUpdateFieldList');
                    if (isValidateUpdateFieldList == true){
                        UpdateFieldList[i]["fieldsDetail"].splice(fieldObj, 1);
                    }
                }
            }
        }
     },
    addDeletedRowBackToUpdateFieldList : function(component){
        var UpdateFieldList = component.get("v.UpdateFieldList");
        var FieldList = component.get("v.FieldList");
        var taskObj = component.get("v.taskObj");
        for(var fieldObj in FieldList){
            var field = FieldList[fieldObj];
            if (field.fieldName == taskObj.key){
                UpdateFieldList[0]["fieldsDetail"].unshift(field);
            }
        }
    },
    removeAlreadySelectedRowFromUpdateFieldList : function(component){
        var taskObj = component.get("v.taskObj");
        if (taskObj.key == null || taskObj.key == ''  ){
            var listTask = component.get("v.listTask");
            var updateFieldList = component.get("v.UpdateFieldList");
            for (var listIndex = 0; listIndex < listTask.length; listIndex++){
                var taskObj = listTask[listIndex];
                for(var i=0; updateFieldList.length > i; i++){
                    for(var fieldObj in updateFieldList[i]["fieldsDetail"]){
                        var field = updateFieldList[i]["fieldsDetail"][fieldObj];
                        if (field.fieldName == taskObj.key){
                            updateFieldList[i]["fieldsDetail"].splice(fieldObj, 1);
                            break; 
                        }
                    }
                }
            }
        }
    }
})
