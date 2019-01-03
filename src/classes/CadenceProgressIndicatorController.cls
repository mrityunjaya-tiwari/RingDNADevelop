public class CadenceProgressIndicatorController {
    
    @AuraEnabled
    public static String saveCadence(Cadence__c cadenceObj, List<CadenceAction__c> listCadenceAction, List<String> caIdsList){
        
        populatePostFixExpressions(cadenceObj);
        upsert cadenceObj;
        
        List<CadenceAction__c> ListOfCadenceActionToDelete = [Select id from CadenceAction__c where Id in :caIdsList];
        
        if (ListOfCadenceActionToDelete.size() > 0){
            deleteParticipantActionsByCadenceActions(caIdsList);
            delete ListOfCadenceActionToDelete;
        }
        List<CadenceAction__c> caListToInsert = new List<CadenceAction__c>();
        for (CadenceAction__c caObj : listCadenceAction){
            if (caObj.Cadence_Id__c == null){
                caObj.Cadence_Id__c = cadenceObj.Id;
            }
            populateCadActionPostFixExpression(caObj);
            caListToInsert.add(caObj);
        }
        //upsert caListToInsert;
        Database.UpsertResult[] results = Database.upsert(caListToInsert);
        Map<Id, String> caIdsToCreatePa = new Map<Id, String>();
        for(Integer index = 0, size = results.size(); index < size; index++) {
            if(results[index].isSuccess()) {
                if(results[index].isCreated()) {
                    caIdsToCreatePa.put(caListToInsert[index].Id, caListToInsert[index].Name);
                } 
            }
        }
        createParticipantActionsByCadenceActions(cadenceObj, caIdsToCreatePa);
        return String.valueOf(cadenceObj.Id);
    }
    
    
    public static void populatePostFixExpressions(Cadence__c cadenceObj) {
        String entryCriterion = cadenceObj.Entrance_Criteria__c;
        CriterionSet ecs = CriterionSet.parse(entryCriterion);
        if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
            cadenceObj.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
        }
        
        String exitCriterion = cadenceObj.Exit_Criteria__c;
        ecs = CriterionSet.parse(exitCriterion);
        if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
            cadenceObj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
        }
    }
    
    public static void populateCadActionPostFixExpression(CadenceAction__c cadAction) {
        String actionCriterion = cadAction.Action_Criterion__c;
        if(actionCriterion != null && !actionCriterion.equals('')) {
            CriterionSet ecs = CriterionSet.parse(actionCriterion);
            if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
                cadAction.Action_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
            }	
        }
    }
    /**
* @description - Used to create ParticipantActions by CadenceActions.
* @param cadenceObj - cadence object , caIds - CadenceActions id list
*/
    public static void createParticipantActionsByCadenceActions(Cadence__c cadenceObj, Map<Id, String> caIds){
        List<SObject> soList = CadenceSelector.getParticipantsOfCadence(cadenceObj.Id , cadenceObj.Record_Type__c);
        List<Sequence_Action__c> paList = New List<Sequence_Action__c>();
        for (SObject sObj : soList){
            for(Id caId : caIds.keySet()){
                Sequence_Action__c paObj = New Sequence_Action__c();
                paObj.CadenceAction_ID__c = caId;
                paObj.Name = caIds.get(caId);
                if (cadenceObj.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME){
                    paObj.Lead_Id__c = (String)sObj.get('Id');
                    paList.add(paObj);
                } else {
                    paObj.Contact_Id__c = (String)sObj.get('Id');
                    paList.add(paObj);
                } 
            }
        }
        insert paList;
    }
    
    public static void deleteParticipantActionsByCadenceActions(List<Id> caIds){
        List<Sequence_Action__c> paList = CadenceSelector.getParticipantActionsByCadenceActionsIds(caIds);
        if (paList.size() > 0){
            delete paList;
        }
    }
    
}