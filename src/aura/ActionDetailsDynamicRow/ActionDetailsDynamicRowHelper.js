({
	helperMethod : function() {
		
	},
    updateTaskField : function(component, event, helper){
        var UpdateFieldList = component.get("v.UpdateFieldList");
        var taskObj = component.get("v.taskObj");
        for(var i=0;UpdateFieldList.length > i;i++){
            var fields = UpdateFieldList[i]["fieldsDetail"];
            for(var fieldObj in fields){
                var field = fields[fieldObj];
                if (field.fieldName == taskObj.key){
                    fields.splice(fieldObj,1);
                    var FieldList = component.get("v.FieldList");
                    var fieldswqewq = FieldList[i]["fieldsDetail"];
                    if(FieldList.includes(field.fieldName)){
                        FieldList.indexOf(field.fieldName);
                    }
                    
                    component.set("v.listPicklistValues", field.listPicklistValues);
                    component.set("v.dataType", field.fieldDataType);
                    component.set("v.fieldName", field.fieldName);
                }
                
            }
        }
    },
})