({
	helperMethod : function() {
		
	},
    updateTaskField : function(component, event, helper){
        var wrapperTaskFields = component.get("v.wrapperTaskFields");
        //console.log('wrapperTaskFields:',JSON.stringify(wrapperTaskFields));
        var newTask = component.get("v.taskObj");
        for(var taskFieldObjIndex in wrapperTaskFields){
            var taskFieldObj = wrapperTaskFields[taskFieldObjIndex];
            if (taskFieldObj.key == newTask.key){
                component.set("v.dataType", taskFieldObj.dataType);
                component.set("v.fieldName", taskFieldObj.apiName);
                component.set("v.listPicklistValues", taskFieldObj.listPicklistValues);
            }
        }
    },
    updateTaskFieldNew : function(component, event, helper){
        var UpdateFieldList = component.get("v.UpdateFieldList");
        var taskObj = component.get("v.taskObj");
        console.log('taskObj-Change:'+JSON.stringify(taskObj));
        for(var i=0;UpdateFieldList.length > i;i++){
            var fields =UpdateFieldList[i]["fieldsDetail"];
            for(var fieldObj in fields){
                var field = fields[fieldObj];
                if(field.fieldDataType == "String"){
                    component.set("v.objectInstanceNew.value", "");
                }
               
                if (field.fieldName == taskObj.key){
                    component.set("v.listPicklistValues", field.listPicklistValues);
                    component.set("v.dataType", field.fieldDataType);
                    component.set("v.fieldName", field.fieldName);
                }
            }
        }
     },
})