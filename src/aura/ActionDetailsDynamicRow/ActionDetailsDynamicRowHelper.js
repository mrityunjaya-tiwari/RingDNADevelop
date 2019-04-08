({
	helperMethod : function() {
		
	},
    updateTaskField : function(component, event, helper){
        var UpdateFieldList = component.get("v.UpdateFieldList");
        var taskObj = component.get("v.taskObj");
        console.log('taskObj-Change:'+JSON.stringify(taskObj));
        for(var i=0;UpdateFieldList.length > i;i++){
            var fields =UpdateFieldList[i]["fieldsDetail"];
            for(var fieldObj in fields){
                var field = fields[fieldObj];
                
                if (field.fieldName == taskObj.key){
                    component.set("v.listPicklistValues", field.listPicklistValues);
                    component.set("v.dataType", field.fieldDataType);
                    component.set("v.fieldName", field.fieldName);
                }
            }
        }
     },
})