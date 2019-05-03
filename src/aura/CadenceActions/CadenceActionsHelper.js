({
    // validation(Cadence have at least one cadence Action) and sub component (validateCadenceActionComponent)
    validateCadenceActionComponent: function(component, event, helper){
        var  isValid = true;        
        var lstCadAction  = component.get("v.cadenceActionList");
        // For set fields to update Json on CadenceAction object and validate sub component
        if (lstCadAction.length > 0){
            var cadenceActionsDetailId = component.find('cadenceActionsDetailId');
            if (cadenceActionsDetailId.length){
                for (var index in cadenceActionsDetailId){
                    var obj = cadenceActionsDetailId[index];
                    var isValidRow = obj.getfieldsToUpdate();
                    if (!isValidRow){
                        isValid = isValidRow;
                    }
                }
            }else{
                isValid = cadenceActionsDetailId.getfieldsToUpdate();
            }
        }else{
            isValid = false;
            component.set('v.isValidationError', true);
            component.set('v.ValidationError', 'Please Add Sequence Actions');
        }
        return isValid;
    },
    updateCadenceActionIndex:function(component, event, helper){
        var lstCadAction  = component.get("v.cadenceActionList");
        // For set fields to update Json on CadenceAction object and validate sub component
        if (lstCadAction.length > 0){
            var cadenceActionsDetailId = component.find('cadenceActionsDetailId');
            if (cadenceActionsDetailId.length){
                for (var index in cadenceActionsDetailId){
                    var obj = cadenceActionsDetailId[index];
                    obj.updateCadenceActionIndex();
                } 
            }else{
                cadenceActionsDetailId.updateCadenceActionIndex();
            }
        }
    },
    addNewCadenceActions: function (component, event, helper, actionName, actionType) {        
        component.set('v.isValidationError', false);        
        var rowList = component.get("v.cadenceActionList");
        rowList.push({
            'sobjectType': 'SequenceAction'
        });       
        var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");
        var showDetail = component.get('v.showDetail');
        if(showDetail == true){            
            actionTypeListForCadenceAction.push(actionType);
            component.set('v.isNewAction', true);
            component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);           
            component.set("v.actionType", actionType);
            component.set("v.actionName", actionName);
            component.set("v.cadenceActionList", rowList);
        }
        else{component.set('v.isNewAction', false);
            var selectedActionType = event.getParam("value");
            actionTypeListForCadenceAction.push(selectedActionType);
            component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);
            component.set("v.actionType", selectedActionType);
            component.set("v.cadenceActionList", rowList);             
        }        
    },
    // Used to edit cadence
    setDataToEdit:function(component, event, helper){
        var cadenceActionList = component.get("v.cadenceActionList");    
        if (cadenceActionList.length > 0){
            var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");            
            for (var index in cadenceActionList){
                var cadenceActionObj = cadenceActionList[index];
                var actionId = cadenceActionObj.actionId;
                var actionList =  component.get('v.actionList');
                
                for(var index in actionList){
                    if(actionList[index].id == actionId){
                        component.set("v.actionType", actionList[index].type);
                        actionTypeListForCadenceAction.push(actionList[index].type);
                    }
                }
            }
            component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);            
        }
    },    
    getCadenceActionsData :  function(component, event, helper){
        component.set('v.spinner',true);
        component.set('v.SaveDisable', true);
        var action = component.get("c.getActionList");
        var cadence = component.get("v.newCadence");
        action.setParams({type: cadence.recordType});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionWrapper = response.getReturnValue();
                component.set('v.actionWrapper', actionWrapper);
                component.set('v.actionList', actionWrapper.actionClsList);
                component.set('v.actionTypeList', actionWrapper.actionTypeList); 
                //Data Sorting
                for(var i=0;actionWrapper.fieldList.length > i;i++){                   
                    actionWrapper.fieldList[i]["fieldsDetail"].sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                }                
                component.set('v.UpdateFieldList', actionWrapper.fieldList[0]);
                helper.setDataToEdit(component, event, helper);
            } else{
            }
            window.setTimeout(
                $A.getCallback(function() {
                    component.set('v.SaveDisable', false);
                }), 1000
            );
            component.set('v.ISLoad', true);
            component.set('v.spinner',false);
        });
        $A.enqueueAction(action)
    },
    oncreateActionAttributeChange : function(component, event, helper){    
        var currentValue = event.getParam("value");
        var isEnabled = component.get('v.isEnabled');                
        if (currentValue == false && isEnabled == true){
            var actionlist = component.get('v.actionList');
            var element = actionlist.slice(-1);            
            var actionName = element[0].name;
            var actionType = element[0].type;
            component.set('v.showDetail', true);           
            helper.addNewCadenceActions(component, event, helper, actionName, actionType);
        }
        component.set('v.showDetail', false);
    }    
})