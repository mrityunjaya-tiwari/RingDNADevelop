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
            component.set('v.ValidationError', 'Please Add Cadence Actions');
        }
        return isValid;
    },
    // Used to edit cadence
    setDataToEdit:function(component, event, helper){
        var cadenceActionList = component.get("v.cadenceActionList");
        if (cadenceActionList.length > 0){
            var actionTypeListForCadenceAction = component.get("v.actionTypeListForCadenceAction");
            for (var index in cadenceActionList){
                var cadenceActionObj = cadenceActionList[index];
                var actionId = cadenceActionObj.RDNACadence__Action_Id__c;
                var actionList =  component.get('v.actionList');
                for(var index in actionList){
                    if(actionList[index].Id == actionId){
                        component.set("v.actionType", actionList[index].RDNACadence__Type__c);
                        actionTypeListForCadenceAction.push(actionList[index].RDNACadence__Type__c);
                    }
                }
            }
            component.set("v.actionTypeListForCadenceAction",actionTypeListForCadenceAction);
        }
    }
})