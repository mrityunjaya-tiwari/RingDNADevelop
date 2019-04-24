({
    doInit: function(component, event, helper) {
       var UpdateFieldList = component.get("v.UpdateFieldList");
        var newAction  = component.get('v.newAction');
        var actionWrapper;    
        var action = component.get("c.getActionWrapper");
        component.set('v.spinner', true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {         
                actionWrapper= response.getReturnValue();
                component.set('v.UpdateFieldList', actionWrapper.wrapperTaskFields);
                var test = component.get('v.UpdateFieldList');
                var FieldList = [];
                for(var i=0; test.length > i;i++){
                    var fields = test[i]["fieldsDetail"];
                    for(var fieldObj in fields){
                        var field = fields[fieldObj];
                        FieldList.push(field);
                    }
                }
                component.set('v.FieldList', FieldList);
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set('v.listTask', component.get('v.listTask'));
                        component.set('v.newAction', component.get('v.newAction'));
                        component.set('v.spinner', false); 
                    }), 100
                ); 
                
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
    validationTask : function(component, event, helper){
        return helper.validateFieldsToUpdateComponent(component, event, helper); 
    },
    
})
