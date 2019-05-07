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
        var actionWrapper = JSON.stringify(newAct); 
        action.setParams({ 
            "actWra": actionWrapper,
            "taskObj":newTask
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionId  = response.getReturnValue();                	
                helper.addNewActionList(component, event, actionId);                 
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
        var action = component.get('c.getActionById');
            action.setParams({
                actionId : id
            });
             action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {    
                    var object = response.getReturnValue();
                    object.sobjectType = 'Action';
                    if(  !actionTypeList.includes(object.type )   ){                        
                       actionTypeList.push(object.type); 
                       component.set('v.actionTypeList', actionTypeList);
                    }
                    var actionlst = component.get("v.actionList");
                    actionlst.push(object);
                    component.set('v.actionList',actionlst);
                    component.set('v.isEnabled', true);
                    component.set('v.createAction', false);
                }                
            });            
            $A.enqueueAction(action);
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
            component.set('v.disableActivationType', true);
            component.set('v.newAction.activationType','Manual');
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.type == 'Call+Voicemail'){
            component.set('v.listToShowInTemplateType', component.get("v.listVMTemplate"));
            component.set('v.disableActivationType', true);
            component.set('v.newAction.activationType','Manual');
            component.set("v.isActionTypeRequired", false);
        }else if (newAct.type == 'Task'){
            component.set('v.newAction.activationType','Manual');
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
    handleCadDynamicRowEvent: function(component, event, helper){
        var ronIndex = event.getParam("ronIndex");
        var rowList = component.get("v.listTask");
        rowList.splice(ronIndex, 1);
        component.set("v.listTask", rowList);
    },
    
    onCancel: function(component, event){
        component.set('v.isEnabled', false);
        component.set('v.createAction', false);
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