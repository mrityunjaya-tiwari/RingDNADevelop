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
                helper.addNewActionList(component, event, actionObj.Id);                
            }
          
        });        
        
        if (component.get('v.isValid') == true){
            $A.enqueueAction(action)
        }       
         component.set('v.setActionTypeList', true);              
    },
    addNewActionList: function (component, event, id){      
        var setActionTypeList = component.get('v.setActionTypeList');
        if(setActionTypeList == true ){
        var actionTypeList = [];   
        actionTypeList = component.get("v.actionTypeList")  
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
                    if(  !actionTypeList.includes(object.RDNACadence2__Type__c )   ){                        
                       actionTypeList.push(object.RDNACadence2__Type__c); 
                       component.set('v.actionTypeList', actionTypeList);
                    }
                   
                    var actionlst = component.get("v.actionList");
                    actionlst.push(object);
                    component.set('v.actionList',actionlst);
                    component.set('v.createAction', false);
                    
                }                
            });            
            $A.enqueueAction(action);
      }         
    },
    validateActionForm: function (component, event){
        var newAct = component.get("v.newAction");
        component.set('v.isValid', true);
        component.set('v.isValidationError', false)
        if (newAct.RDNACadence2__Type__c == ''){
            component.set('v.isValid', false);
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Type');
        }else if (newAct.Name == ''){
            component.set('v.isValid', 'false');
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Name');
        } else if (newAct.RDNACadence2__Activation_Type__c == ''){
            component.set('v.isValid', 'false');
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Enter Activation Type');
        } else if (newAct.RDNACadence2__Template_Id__c == ''){
            if (newAct.RDNACadence2__Type__c == 'Email'){
                component.set('v.isValid', 'false');
                component.set('v.isValidationError', true);
                component.set('v.ValidationError', 'Please Select Template');
            } else if (newAct.RDNACadence2__Type__c == 'Task'){
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
        
        if (newAct.RDNACadence2__Type__c == 'Email'){
            component.set('v.listToShowInTemplateType', component.get("v.listEmailTemplate"));
            component.set("v.isActionTypeRequired", true);
            component.set('v.disableActivationType', false);
            if(component.get('v.isNew')){
               component.set('v.newAction.RDNACadence2__Activation_Type__c','Select Activation Type');
               component.set('v.disableActivationType', false);
            }
        }else if (newAct.RDNACadence2__Type__c == 'SMS'){
            component.set('v.listToShowInTemplateType', component.get("v.listSmsTemplate"));
            component.set('v.newAction.RDNACadence2__Activation_Type__c','Manual');
            component.set('v.disableActivationType', true);
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.RDNACadence2__Type__c == 'Call'){
            component.set('v.listToShowInTemplateType', component.get("v.listCallTemplate"));
            component.set('v.disableActivationType', true);
            component.set('v.newAction.RDNACadence2__Activation_Type__c','Manual');
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.RDNACadence2__Type__c == 'Call+Voicemail'){
            component.set('v.listToShowInTemplateType', component.get("v.listVMTemplate"));
            component.set('v.disableActivationType', true);
            component.set('v.newAction.RDNACadence2__Activation_Type__c','Manual');
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.RDNACadence2__Type__c == 'Task'){
            component.set('v.newAction.RDNACadence2__Activation_Type__c','Manual');
            var container = component.find("InputSelectTemplate");
            $A.util.addClass(container, 'slds-hide');
            var createTaskdiv = component.find("createTaskdiv");
            $A.util.removeClass(createTaskdiv, 'slds-hide');
            component.set('v.disableActivationType', true);
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
                if (object.RDNACadence2__Type__c != 'Task' ){
                    var listOfTemplate = component.get("v.listEmailTemplate");
                    if (object.RDNACadence2__Type__c == 'SMS'){
                        listOfTemplate = component.get("v.listSmsTemplate");;
                    }else if(object.RDNACadence2__Type__c == 'Call'){
                        listOfTemplate = component.get("v.listCallTemplate");;
                    }else if(object.RDNACadence2__Type__c == 'Call+Voicemail'){
                        listOfTemplate = component.get("v.listVMTemplate");;
                    }
                    for(var index in listOfTemplate){
                        if(listOfTemplate[index].Name == object.RDNACadence2__Template_Name__c){
                            object.RDNACadence2__Template_Id__c = index;
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
        component.set('v.createAction', false);
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
    selectTemplateName: function(component, event, helper){
        var newAct = component.get("v.newAction");
        if (newAct.RDNACadence2__Type__c != 'Task' && component.get("v.listToShowInTemplateType").length > 0 && newAct.RDNACadence2__Template_Id__c){
            var index = newAct.RDNACadence2__Template_Id__c;
            var obj= component.get("v.listToShowInTemplateType")[index];
            newAct.RDNACadence2__Template_Id__c = obj.Id;
            newAct.RDNACadence2__Template_Name__c = obj.Name;
        }else{
            newAct.RDNACadence2__Template_Id__c = "";
            newAct.RDNACadence2__Template_Name__c = "";
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