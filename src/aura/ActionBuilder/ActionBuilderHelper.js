({
    createAction : function(component, event,helper) {       
        component.set('v.spinner', true);
        var newAct = component.get("v.newAction");
        newAct.sobjectType = 'ActionWrapper';
        var action = component.get("c.saveAction");
        var listTask = component.get("v.listTask");
        var newTask = component.get("v.taskObj");
        for(var index in listTask){
            var wrapperTOCreateTask = listTask[index];
            var key = wrapperTOCreateTask.key;
            var value = wrapperTOCreateTask.value;
            newTask[key] =  value;
        }
        var actionWrapper = JSON.stringify(newAct);  
        action.setParams({ 
            "actWra": actionWrapper,
            "taskObj":newTask
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var actionId  = response.getReturnValue();
                helper.viewDetails(component, event, actionId);	
            }
            component.set('v.spinner', false);
        });
        if (component.get('v.isValid') == true){
            $A.enqueueAction(action)
        }
    },    
    getData : function(component, event, helper, id) {
        component.set('v.spinner', true);
        var action = component.get('c.getActionData');
        action.setParams({
            actionId : id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();               
                var object = obj.actionCls;
                object.sobjectType = 'ActionWrapper';
                component.set('v.newAction', object); 
                component.set('v.recordName', object.name);
                if(obj.taskList != null) {
                    var taskList = [];
                    for(var i=0; i<obj.taskList.length; i++) {
                        obj.taskList[i].sobjectType = 'wrapperTaskField';
                        taskList.push(obj.taskList[i]);
                    }                    
                    component.set('v.listTask', taskList);
                }
                component.set('v.spinner', false);
            }else{
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    viewDetails : function(cmp, event, id) {        
        var myUserContext = cmp.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/ActionDetailView?id='+id;
        } 
        else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ActionDetailView" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire()  
        }
    },
    onCancel: function(component, event){
        var myUserContext = component.get("v.themeName");        
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/CadenceActionList';
        } else if(myUserContext == undefined) {
             var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CadenceActionList" ,
                componentAttributes : {
                }
            });
            evt.fire();
        }
    },
    createObjectData: function(component, event) {
        var rowList = component.get("v.listTask");
        rowList.push({
            'sobjectType': 'wrapperTaskField',
            'key': '',
            'value': ''
        });
        component.set("v.listTask", rowList);
    },
    validateEmailActionBuilder: function(component, event, helper){ 
        var newAct = component.get("v.newAction");
        if(newAct.emailType == '' || newAct.emailType == null){
            component.set('v.ValidationError' , 'Select Required Field');
            return false;
        }else if(newAct.activationType == '' || newAct.activationType == null){
            component.set('v.ValidationError' , 'Select Required Field');
            return false;
        }else if(newAct.activationType == 'Automatic' && (newAct.deliveryPreference == '' || newAct.deliveryPreference == null)){
            component.set('v.ValidationError' , 'Select Required Field');
            return false;
        }else{
                return true;
            }
    },  
})