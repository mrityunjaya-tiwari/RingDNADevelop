({
    createAction : function(component, event,helper) {
        
        var newAct = helper.selectTemplateName(component, event,helper);
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
        action.setParams({ 
            "act": newAct,
            "taskObj":newTask
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionObj = response.getReturnValue();
                helper.viewDetails(component, event, actionObj.Id);	
            }else{
                console.log("Action Not Created");
                console.log(response.getError());
            }
        });
        
        //helper.validateActionForm(component, event);
        if (component.get('v.isValid') == true){
            $A.enqueueAction(action)
        }
    },
    
    validateActionForm: function (component, event){
        var newAct = component.get("v.newAction");
        component.set('v.isValid', true);
        component.set('v.isValidationError', false)
        if (newAct.RDNACadence__Type__c == ''){
            component.set('v.isValid', false);
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Type');
        }else if (newAct.Name == ''){
            component.set('v.isValid', 'false');
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Name');
        } else if (newAct.RDNACadence__Activation_Type__c == ''){
            component.set('v.isValid', 'false');
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Activation Type');
        } else if (newAct.RDNACadence__Template_Id__c == ''){
            if (newAct.RDNACadence__Type__c == 'Email'){
                component.set('v.isValid', 'false');
                component.set('v.isValidationError', true);
                component.set('v.ValidationError', 'Please Select Template');
            } else if (newAct.RDNACadence__Type__c == 'Task'){
                var listTask = component.get('v.listTask');
                for(var taskIndex in listTask){
                    var taskObj = listTask[taskIndex];
                    if(taskObj.key == '') {
                        component.set('v.isValid', false);
                        component.set('v.isValidationError', true);
                        component.set('v.ValidationError', 'Please Select Task Field');
                    } else if (taskObj.value == ''){
                        component.set('v.isValid', false);
                        component.set('v.isValidationError', true);
                        component.set('v.ValidationError', 'Please Select Task Fields Value For ' + taskObj.key );
                    }
                }
            }else {
                component.set('v.isValid', true);
            }
        }
    },
    updateActionType: function (component, event, helper) {
        var newAct = component.get("v.newAction");
        var container = component.find("InputSelectTemplate");
        var createTaskdiv = component.find("createTaskdiv");
        $A.util.addClass(createTaskdiv, 'slds-hide');
        $A.util.removeClass(container, 'slds-hide');
        if (newAct.RDNACadence__Type__c == 'Email'){
            component.set('v.listToShowInTemplateType', component.get("v.listEmailTemplate"));
            component.set("v.isActionTypeRequired", true);
        }else if (newAct.RDNACadence__Type__c == 'SMS'){
            component.set('v.listToShowInTemplateType', component.get("v.listSmsTemplate"));
        }else if (newAct.RDNACadence__Type__c == 'Call'){
            component.set('v.listToShowInTemplateType', component.get("v.listCallTemplate"));
        }else if (newAct.RDNACadence__Type__c == 'Call+Voicemail'){
            component.set('v.listToShowInTemplateType', component.get("v.listVMTemplate"));
        }else if (newAct.RDNACadence__Type__c == 'Task'){
            var container = component.find("InputSelectTemplate");
            $A.util.addClass(container, 'slds-hide');
            var createTaskdiv = component.find("createTaskdiv");
            $A.util.removeClass(createTaskdiv, 'slds-hide');
            component.set("v.isActionTypeRequired", false);
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
                var object = obj.action;
                object.sobjectType = 'Action__c';
                if (object.RDNACadence__Type__c != 'Task' ){
                    var listOfTemplate = component.get("v.listEmailTemplate");
                    if (object.RDNACadence__Type__c == 'SMS'){
                        listOfTemplate = component.get("v.listSmsTemplate");;
                    }else if(object.RDNACadence__Type__c == 'Call'){
                        listOfTemplate = component.get("v.listCallTemplate");;
                    }else if(object.RDNACadence__Type__c == 'Call+Voicemail'){
                        listOfTemplate = component.get("v.listVMTemplate");;
                    }
                    for(var index in listOfTemplate){
                        if(listOfTemplate[index].Name == object.RDNACadence__Template_Name__c){
                            object.RDNACadence__Template_Id__c = index;
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
        console.log('In Action details helper myUserContext',myUserContext);
        if(myUserContext == 'Theme3' || myUserContext == 'Theme4t' || myUserContext == 'Theme4d') {
            window.history.go(-1);
            /*window.location = '/apex/CadenceActionList';*/
        } else if(myUserContext == undefined) {
            window.history.go(-1);
           /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:CadenceActionList" ,
                componentAttributes : {
                }
            });
            evt.fire()  */
        }
    },
    
    viewDetails : function(cmp, event, id) {
        console.log('In view detail');
        console.log(id);
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
    selectTemplateName: function(component, event, helper){
        var newAct = component.get("v.newAction");
        if (newAct.RDNACadence__Type__c != 'Task'){
            var index = newAct.RDNACadence__Template_Id__c;
            var obj= component.get("v.listToShowInTemplateType")[index];
            newAct.RDNACadence__Template_Id__c = obj.Id;
            newAct.RDNACadence__Template_Name__c = obj.Name;
        }else{
            newAct.RDNACadence__Template_Id__c = "";
            newAct.RDNACadence__Template_Name__c = "";
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