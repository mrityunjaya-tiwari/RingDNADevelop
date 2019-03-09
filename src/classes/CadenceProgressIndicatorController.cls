public class CadenceProgressIndicatorController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    @AuraEnabled
    public static String saveCadence(Cadence__c cadenceObj, List<CadenceAction__c> listCadenceAction, List<String> caIdsList){
    	try{
        	populatePostFixExpressions(cadenceObj);          
        	upsert cadenceObj;
            deleteCadenceAction(cadenceObj, caIdsList);
        
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
        	Map<Id, CadenceAction__c> caToInsertMap = new Map<Id, CadenceAction__c>();
        	for(Integer index = 0, size = results.size(); index < size; index++) {
            	if(results[index].isSuccess()) {
                	if(results[index].isCreated()) {
                    	caToInsertMap.put(caListToInsert[index].Id, caListToInsert[index]);
                    	caIdsToCreatePa.put(caListToInsert[index].Id, caListToInsert[index].Name);
                	} 
            	}
        	}
            addActionOnParticipant(cadenceObj, caToInsertMap);
        }
        catch(Exception e){
        }
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
    /*********************Updated logic for delete AOP*******************/
    public static void deleteCadenceAction(Cadence__c cadence, List<Id> caIdList){
        List<CadenceAction__c> ListOfCadenceActionToDelete = [Select id from CadenceAction__c where Id in :caIdList];
        system.debug('ListOfCadenceActionToDelete ' + ListOfCadenceActionToDelete.size());
        if (ListOfCadenceActionToDelete.size() > 0){
            updateCadenceActionAndDelete(cadence, caIdList);
            delete ListOfCadenceActionToDelete;
            // deleteParticipantActionsByCadenceActions(caIdList);
        }
    }
    
    public static List<Sequence_Action__c> getParticipantActionsByCadenceActionsIds(List<Id> caIdList){
        List<Id> caIds = caIdList;
        String query = CadenceSelector.getQueryForObject(nameSpace+'Sequence_Action__c');
        query += ' WHERE '+nameSpace+'isActionPerformed__c = false AND ' +nameSpace+'CadenceAction_ID__c=:caIds';
        return Database.query(query); 
    } 
    
    public static void updateCadenceActionAndDelete(Cadence__c cadence, List<Id> caIdsToDelete){
        Set<Id> participantIdsList = New Set<Id>();
        Set<Id> deletedAOPIds = New Set<Id>();
        List<Sequence_Action__c> aopToUpdateList = New List<Sequence_Action__c>();
        List<Sequence_Action__c> aopToDeleteRelatedToCadence = new List<Sequence_Action__c>();
        
        List<Sequence_Action__c> aopToDeleteList = getParticipantActionsByCadenceActionsIds(caIdsToDelete);
        Map<Id, Sequence_Action__c> aopToDeleteMap = New Map<Id, Sequence_Action__c>(aopToDeleteList);
        deletedAOPIds = aopToDeleteMap.keySet();
        
        
        list<SObject> participantList = CadenceSelector.getParticipantsOfCadence(cadence.Id, cadence.Record_Type__c); 
        Map<Id, SObject> participantMap = New Map<Id, SObject>(participantList);
        participantIdsList = participantMap.keySet();
        
        Map<Id, List<Sequence_Action__c>>  participantSequenceActionMap = CadenceService.getRemainingParticipantAction(participantIdsList, cadence.Record_Type__c);
        
        
        for (Id sobjID : participantIdsList ){
            List<Sequence_Action__c> saList = participantSequenceActionMap.get(sobjID);
            Integer day = 0, hour = 0;
            DateTime entranceDate;  
            system.debug('saList ' + saList.size());
            for (Sequence_Action__c sa : saList){
                if (deletedAOPIds.contains(sa.Id)){ 
                    aopToDeleteRelatedToCadence.add(sa);
                    if (entranceDate == null && sa.Expected_Execution_Date__c != null){
                        if (sa.Expected_Execution_Date__c <  system.now()){
                            entranceDate = system.now();
                            system.debug('Deleted Before date');
                        }else{
                            system.debug('Deleted After date');
                            day = sa.CadenceAction_Id__r.Day__c != null ? -(Integer)sa.CadenceAction_Id__r.Day__c : 0;
                            hour = sa.CadenceAction_Id__r.Hour__c != null ? -(Integer)sa.CadenceAction_Id__r.Hour__c : 0;
                            entranceDate = sa.Expected_Execution_Date__c;
                            system.debug('day hour ' + day + ' ' + hour);
                            system.debug('before entranceDate ' + entranceDate);
                            entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                            system.debug('after entranceDate ' + entranceDate);
                            if (entranceDate < system.now()){
                                entranceDate = system.now();
                            }
                        }
                    }
                }else if (entranceDate != null){
                    system.debug('Updating aop');
                    day = sa.CadenceAction_Id__r.Day__c != null ? (Integer)sa.CadenceAction_Id__r.Day__c : 0;
                    hour = sa.CadenceAction_Id__r.Hour__c != null ? (Integer)sa.CadenceAction_Id__r.Hour__c : 0;
                    entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                    system.debug('sa FOR before UPDATE ' + sa.Expected_Execution_Date__c);
                    sa.Expected_Execution_Date__c = entranceDate;
                    system.debug('sa FOR after UPDATE ' + sa.Expected_Execution_Date__c);
                    aopToUpdateList.add(sa);
                }
            }
            system.debug('aopToUpdateList size ' + aopToUpdateList.size());
            if (aopToUpdateList.size() > 0 ){
                system.debug('aopToUpdateList size ' + aopToUpdateList.size());
                update aopToUpdateList; 
            }
            
            if (aopToDeleteRelatedToCadence.size() > 0 ){
                system.debug('aopToDeleteList size ' + aopToDeleteRelatedToCadence.size());
                delete aopToDeleteRelatedToCadence;
            }
            
        }
    }
    /*********************Updated logic for add  AOP*******************/
    public static void addActionOnParticipant(Cadence__c cadence, Map<Id, CadenceAction__c> caToInsertMap){
        List<Sequence_Action__c> saToInsert = New List<Sequence_Action__c>();
        Set<Id> participantIdsList = New Set<Id>();
        list<SObject> participantList = CadenceSelector.getParticipantsOfCadence(cadence.Id, cadence.Record_Type__c); 
        Map<Id, SObject> participantMap = New Map<Id, SObject>(participantList);
        participantIdsList = participantMap.keySet();
        Map<Id, List<Sequence_Action__c>> participantSequenceActionMap = New Map<Id, List<Sequence_Action__c>>();

        participantSequenceActionMap = CadenceService.getRemainingParticipantActions(participantIdsList, cadence.Record_Type__c);
        
        for (Id sobjID : participantIdsList ){
            List<Sequence_Action__c> saList = new List<Sequence_Action__c>();
            saList = participantSequenceActionMap.get(sobjID);
            Integer lastIndex = 0;
            if (saList != null){
                lastIndex = saList.size() - 1;
                Sequence_Action__c sa = saList.get(lastIndex);
                DateTime entranceDate =  sa.Expected_Execution_Date__c ;
                for (Id caId : caToInsertMap.keySet()){
                    CadenceAction__c ca = caToInsertMap.get(caId);
                    Sequence_Action__c newSA = New Sequence_Action__c();
                    newSA.CadenceAction_ID__c = caId;
                    newSA.Name = ca.Name;
                    if (cadence.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME){
                        newSA.Lead_Id__c = (String)sobjID;
                    } else {
                        newSA.Contact_Id__c = (String)sobjID;
                    }
                    Integer day = 0, hour = 0;
                    day = sa.CadenceAction_Id__r.Day__c != null ? (Integer)ca.Day__c : 0;
                    hour = sa.CadenceAction_Id__r.Hour__c != null ? (Integer)ca.Hour__c : 0;
                    
                    entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                    newSA.Expected_Execution_Date__c =  entranceDate;
                    saToInsert.add(newSA);
                }
            }else{ 
                DateTime entranceDate =  system.now() ;
                for (Id caId : caToInsertMap.keySet()){
                    CadenceAction__c ca = caToInsertMap.get(caId);
                    Sequence_Action__c newSA = New Sequence_Action__c();
                    newSA.CadenceAction_ID__c = caId;
                    newSA.Name = ca.Name;
                    if (cadence.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME){
                        newSA.Lead_Id__c = (String)sobjID;
                    } else {
                        newSA.Contact_Id__c = (String)sobjID;
                    }
                    Integer day = 0, hour = 0;
                    day = ca.Day__c != null ? (Integer)ca.Day__c : 0;
                    hour = ca.Hour__c != null ? (Integer)ca.Hour__c : 0;
                    
                    entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                    newSA.Expected_Execution_Date__c =  entranceDate;
                    saToInsert.add(newSA);
                }
            }
        }

        if (saToInsert.size() > 0){
            insert saToInsert;
        }
    }
}