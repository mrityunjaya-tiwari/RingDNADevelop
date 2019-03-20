public class CadenceProgressIndicatorController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    @AuraEnabled
    public static String saveCadence(string cadenceObjString,  string listCadenceActionString, List<String> caIdsList){
        Cadence__c cadenceObj ;
        List<CadenceAction__c> listCadenceAction = New  List<CadenceAction__c>();
        try{
            Sequence sequence = (Sequence)System.JSON.deserialize(cadenceObjString, Sequence.class); 
            List<SequenceAction> sequenceActionList = (List<SequenceAction>)System.JSON.deserialize(listCadenceActionString, List<SequenceAction>.class); 
            for (SequenceAction sequenceAction : sequenceActionList){
                listCadenceAction.add(getCadenceAction(sequenceAction));
            }
            cadenceObj = getCadence(sequence);
            if (sequence.id != null && string.valueOf(sequence.id) != '' ){
                cadenceObj.Id = Id.valueOf(sequence.id);
            }
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
    
    public static CadenceAction__c getCadenceAction(SequenceAction sequenceAction){
        CadenceAction__c cadenceAction = new CadenceAction__c();
        cadenceAction.Name = sequenceAction.name;
        if (sequenceAction.cadenceId != null && sequenceAction.cadenceId != ''){
            cadenceAction.Cadence_Id__c = Id.valueOf(sequenceAction.cadenceId);
        }
        if (sequenceAction.id != null && string.valueOf(sequenceAction.id) != '' ){
            cadenceAction.Id = ID.valueOf(sequenceAction.id);
        }
        //cadenceAction.Id = sequenceAction.id;
        cadenceAction.Action_Criterion__c = sequenceAction.actionCriterion;
        cadenceAction.Action_Id__c = Id.valueOf(sequenceAction.actionId);
        if (sequenceAction.day != null && sequenceAction.day != '')
        cadenceAction.Day__c = Integer.valueOf(sequenceAction.day);
        cadenceAction.Fields_To_Update_Action__c = sequenceAction.fieldsToUpdateAction;
        if (sequenceAction.hour != null && sequenceAction.hour != '')
        cadenceAction.Hour__c = Integer.valueOf(sequenceAction.hour);
        if (sequenceAction.index != null && sequenceAction.index != '')
        cadenceAction.Index__c = Integer.valueOf(sequenceAction.index);
        cadenceAction.Priority__c = sequenceAction.priority;
        if (sequenceAction.priorityNumber != null && sequenceAction.priorityNumber != '')
        cadenceAction.Priority_number__c = Integer.valueOf(sequenceAction.priorityNumber);
        cadenceAction.Trigger_Type__c = sequenceAction.triggerType;
        return cadenceAction;
    }
    public static Cadence__c getCadence(Sequence sequence){
        Cadence__c cadence = new Cadence__c();
        cadence.Name = sequence.name;
        cadence.Entrance_Criteria__c = sequence.entranceCriteria;
        cadence.Exit_Criteria__c = sequence.exitCriteria;
        cadence.matching_priority__c = sequence.matchingPriority;
        cadence.Participent_Activation__c = sequence.participentActivation;
        cadence.Record_Type__c = sequence.recordType;
        //cadence.Status__c = Boolean.valueOf(sequence.status);
        //cadence.Total_Participants__c = Integer.valueOf(sequence.totalParticipants);
        return cadence;
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
            for (Sequence_Action__c sa : saList){
                if (deletedAOPIds.contains(sa.Id)){ 
                    aopToDeleteRelatedToCadence.add(sa);
                    if (entranceDate == null && sa.Expected_Execution_Date__c != null){
                        if (sa.Expected_Execution_Date__c <  system.now()){
                            entranceDate = system.now();
                        }else{
                            day = sa.CadenceAction_Id__r.Day__c != null ? -(Integer)sa.CadenceAction_Id__r.Day__c : 0;
                            hour = sa.CadenceAction_Id__r.Hour__c != null ? -(Integer)sa.CadenceAction_Id__r.Hour__c : 0;
                            entranceDate = sa.Expected_Execution_Date__c;
                            entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                            if (entranceDate < system.now()){
                                entranceDate = system.now();
                            }
                        }
                    }
                }else if (entranceDate != null){
                    day = sa.CadenceAction_Id__r.Day__c != null ? (Integer)sa.CadenceAction_Id__r.Day__c : 0;
                    hour = sa.CadenceAction_Id__r.Hour__c != null ? (Integer)sa.CadenceAction_Id__r.Hour__c : 0;
                    entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                    sa.Expected_Execution_Date__c = entranceDate;
                    aopToUpdateList.add(sa);
                }
            }
            if (aopToUpdateList.size() > 0 ){
                update aopToUpdateList; 
            }
            
            if (aopToDeleteRelatedToCadence.size() > 0 ){
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