({
	helperMethod : function() {
		
	},
    updateTaskField : function(component, event, helper){
        var wrapperTaskFields = component.get("v.wrapperTaskFields");
        var newTask = component.get("v.taskObj");
        for(var taskFieldObjIndex in wrapperTaskFields){
            var taskFieldObj = wrapperTaskFields[taskFieldObjIndex];
            if (taskFieldObj.key == newTask.key){
                component.set("v.dataType", taskFieldObj.dataType);
                component.set("v.listPicklistValues", taskFieldObj.listPicklistValues);
            }
        }
    },
})