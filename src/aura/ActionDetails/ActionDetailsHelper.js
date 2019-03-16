({
    createAction : function(component, event,helper) {
        var newAct = helper.selectTemplateName(component, event,helper); 
        //newAct.sobjectType = 'ActionWrapper';
        
        var action = component.get("c.saveAction");
        var listTask = component.get("v.listTask");
        var wrapperTaskFields = component.get("v.wrapperTaskFields");
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
    
    updateActionType: function (component, event, helper) {
        var newAct = component.get("v.newAction");
        var container = component.find("InputSelectTemplate");
        var createTaskdiv = component.find("createTaskdiv");
        $A.util.addClass(createTaskdiv, 'slds-hide');
        $A.util.removeClass(container, 'slds-hide');
        
        if (newAct.type == 'Email'){
            component.set('v.listToShowInTemplateType', component.get("v.listEmailTemplate"));
            component.set("v.isActionTypeRequired", true);
            component.set('v.disableActivationType', false);
            if(component.get('v.isNew')){
               component.set('v.newAction.activationType','Select Activation Type');
               component.set('v.disableActivationType', false);
            }
        }else if (newAct.type == 'SMS'){
            component.set('v.listToShowInTemplateType', component.get("v.listSmsTemplate"));
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.type == 'Call'){
            component.set('v.listToShowInTemplateType', component.get("v.listCallTemplate"));
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.type == 'Call+Voicemail'){
            component.set('v.listToShowInTemplateType', component.get("v.listVMTemplate"));
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.type == 'Task'){
            var container = component.find("InputSelectTemplate");
            $A.util.addClass(container, 'slds-hide');
            var createTaskdiv = component.find("createTaskdiv");
            $A.util.removeClass(createTaskdiv, 'slds-hide');
            
            component.set('v.newAction.activationType','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
            var wrapperTaskFields = component.get("v.wrapperTaskFields");
        }else{
            component.set('v.listToShowInTemplateType','');
            component.set('v.isActionTypeRequired',false);
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
    removeDeletedRow: function(component, event, helper) {
        var rowList = component.get("v.listTask");
        var listSize = rowList.length;
        rowList.splice([listSize-1], 1);
        component.set("v.listTask", rowList);
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
               
                //component.set('v.newAction', obj.actionWrapper);
                var object = obj.actionCls;
                object.sobjectType = 'ActionWrapper';

                if (object.type != 'Task' ){
                    var listOfTemplate = component.get("v.listEmailTemplate");
                    if (object.type == 'SMS'){
                        listOfTemplate = component.get("v.listSmsTemplate");;
                    }else if(object.type == 'Call'){
                        listOfTemplate = component.get("v.listCallTemplate");;
                    }else if(object.type == 'Call+Voicemail'){
                        listOfTemplate = component.get("v.listVMTemplate");;
                    }
                    
                    for(var index in listOfTemplate){
                        if(listOfTemplate[index].Name == object.templateName){
                            object.templateId = index;
                        }
                    }
                }
                
                component.set('v.newAction', object); 
                component.set('v.recordName', object.Name);
                helper.updateActionType(component, event, helper);
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
    handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowList = component.get("v.listTask");
        rowList.splice(ronIndex, 1);
        component.set("v.listTask", rowList);
    },
    
    onCancel: function(component, event){
        var myUserContext = component.get("v.themeName"); 
        
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.history.go(-1);
            /*window.location = '/apex/CadenceActionList';*/
        } else if(myUserContext == undefined) {
            window.history.go(-1);
            /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "RDNACadence4:CadenceActionList" ,
                componentAttributes : {
                }
            });
            evt.fire()  */
        }
    },
    
    viewDetails : function(cmp, event, id) {
        
        var myUserContext = cmp.get("v.themeName");
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.location = '/apex/ActionDetailView?id='+id;
        } 
        else if(myUserContext == undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "RDNACadence4:ActionDetailView" ,
                componentAttributes : {
                    "recordId" : id
                }
            });
            evt.fire()  
        }
    },
    selectTemplateName: function(component, event, helper){
        var newAct = component.get("v.newAction");
        if (newAct.type != 'Task' && component.get("v.listToShowInTemplateType").length > 0 && newAct.templateId){
            var index = newAct.templateId;
            var obj= component.get("v.listToShowInTemplateType")[index];
            newAct.templateId = obj.Id;
            newAct.templateName = obj.Name;
        }else{
            newAct.templateId = "";
            newAct.templateName = "";
        }
        return newAct;
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
