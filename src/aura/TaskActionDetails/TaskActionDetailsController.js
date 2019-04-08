({
    doInit: function(component, event, helper) {
       var UpdateFieldList = component.get("v.UpdateFieldList");
        var newAction  = component.get('v.newAction');
        var actionWrapper;    
        var action = component.get("c.getActionWrapper");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {         
                actionWrapper= response.getReturnValue();
                component.set('v.UpdateFieldList', actionWrapper.wrapperTaskFields);
                var test = component.get('v.UpdateFieldList');
                console.log('test',test);
                var FieldList = component.get('v.FieldList');
                for(var i=0; test.length > i;i++){
                    console.log('for-loop');
                    var fields = test[i]["fieldsDetail"];
                        FieldList.push(test[i]);
                }
                component.set('v.FieldList', FieldList);
                //console.log('FieldList-task-init',JSON.stringify(component.get('v.FieldList')));

                component.set('v.spinner', false); 
                //helper.validateFieldsToUpdateComponent(component, event, helper);
            }
            else {
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);	
    },
    AddNewRow : function(component, event, helper){
        helper.createObjectData(component, event);    
    },
    removeRow : function(component, event, helper){
        helper.removeDeletedRow(component, event); 
    },
    handleCadDynamicRowEvent: function(component, event, helper){
        helper.handleCadDynamicRowEvent(component, event, helper);
    },
    
})