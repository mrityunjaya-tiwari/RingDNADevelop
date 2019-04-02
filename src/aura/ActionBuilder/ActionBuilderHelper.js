({
    createAction : function(component, event,helper) {
        
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
            }else{ 
            }
        });
        
        //helper.validateActionForm(component, event);
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
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set('v.newAction', component.get('v.newAction'));
                        component.set('v.spinner', false);
                    }), 500
                );
                
            }else{
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    createCallAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type','Call'); 
        component.set('v.newAction.activationType','Manual');
        component.set('v.disableActivationType', true);
        component.set("v.isActionTypeRequired", false);
        
        var myUserContext = component.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/CadenceActionList';
        } 
        else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CadenceActionList" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire()  
        }
    },
    createEmailAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'Email');
        component.set("v.isActionTypeRequired", true);
        component.set('v.disableActivationType', false);
        
    },
    createSMSAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'SMS');
        component.set('v.newAction.activationType','Manual');
        component.set('v.currentStep','2');
        // we don't add any thing to select activation type , its always manual type
        component.set('v.disableActivationType', true);
        // use to validate that template is required or not
        component.set("v.isActionTypeRequired", false);
    },
    createTaskAction : function(component, event, helper){
        helper.validateActionName(component, event,helper);
        component.set('v.newAction.type', 'Task');
        component.set('v.newAction.activationType','Manual');
        component.set('v.disableActivationType', true);
        component.set("v.isActionTypeRequired", false);
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
            window.history.go(-1);
        } else if(myUserContext == undefined) {
            window.history.go(-1);
        }
    },
    validateActionName: function(component, event, helper){
        var newAct = component.get("v.newAction");
        var name = newAct.name;
        if (name){
            newAct.name = name.trim();
        }
        component.set("v.newAction", newAct);
    },
    
})