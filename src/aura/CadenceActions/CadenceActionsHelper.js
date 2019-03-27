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
        var action = component.get("c.getActionList");
        var cadence = component.get("v.newCadence");
        action.setParams({type: cadence.recordType});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionWrapper = response.getReturnValue();
                component.set('v.actionList', actionWrapper.actionClsList);
                component.set('v.actionTypeList', actionWrapper.actionTypeList); 
                //Data Sorting
                for(var i=0;actionWrapper.fieldList.length > i;i++){
                    //actionWrapper.fieldList[i]["fieldsDetail"].sort((a, b) => a['fieldLabel'].localeCompare(b['fieldLabel']));
                    actionWrapper.fieldList[i]["fieldsDetail"].sort((a, b) => a.fieldLabel.localeCompare(b.fieldLabel));
                }
                
                component.set('v.UpdateFieldList', actionWrapper.fieldList[0]);
                //console.log('actionWrapper.fieldList[0]:'+ JSON.stringify(actionWrapper.fieldList[0]));
                helper.setDataToEdit(component, event, helper);
                //component.set('v.spinner',false);
            } else{
                //component.set('v.spinner',false);
            }
            
            component.set('v.ISLoad', true);
            component.set('v.spinner',false);
        });
        //Sprint198-What is the use of this: newCadence
        //var newCadence = component.get("v.newCadence");
        $A.enqueueAction(action)
    }
    
})