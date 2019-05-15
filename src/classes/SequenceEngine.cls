public class SequenceEngine {
	
	public static void processSequences(string participantType, List<SObject> participantList, boolean isTrigger)
	{
		List<string> participantTypeAndParantGroupsList;
		Map<Id, SObject> participantIdToParentRecordMap;
		
		//Created a factory map using all participant types.
		Map<String, Type> sequenceEngineFactory = new Map<String, Type> {CadenceConstants.CONTACT_OBJECT_NAME => ContactService.class, CadenceConstants.LEAD_OBJECT_NAME => LeadService.class };
		
		//Initiation of service class	
		IParticipant participantService = (IParticipant)sequenceEngineFactory.get(participantType).newInstance();
		 
		//Fetch all the Active sequences 
		Map<Id, Cadence__c> activeSequenceIdToSequenceMap  = SequenceEngineHelper.getActiveSequenceIdToSequenceMap(new List<String> {participantType}); 
		for(SObject obj : participantList)
				{
					System.Debug('perform1'  + obj.get(CadenceConstants.NAMESPACE + 'Cadence_Id__c'));
				}
		//Fetch participant list which have exit criteria matched in sequence(further those participant will be unassociated.)
		List<SObject> participantListWithMatchedCriteria = participantService.checkExitCriteria(participantType, participantList, activeSequenceIdToSequenceMap); 
		for(SObject obj : participantList)
				{
					System.Debug('perform2'  + obj.get(CadenceConstants.NAMESPACE + 'Cadence_Id__c'));
				}
		List<SObject> unAssociatedParticipantList = new List<SObject>();
			
		If(participantListWithMatchedCriteria != null && participantListWithMatchedCriteria.size() > 0)	
		{ 
			unAssociatedParticipantList = participantService.unAssociateParticipants(participantListWithMatchedCriteria, participantType);					
			SequenceEngineHelper.deleteUnPerformedParticipantActions(unAssociatedParticipantList);
		}
		
		List<SObject> participantListToCreateParticipantActions = new List<SObject>();
		List<SObject> participantListToPerformParticipantAction = new List<SObject>();
		
		if (isTrigger) {
			 Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = participantService.getSequenceHistory(); 			 
			 Map<Id, List<SObject>> sequenceIdToParticipantListMap =  participantService.checkEntryCriteria(participantList, activeSequenceIdToSequenceMap, participantIdToSequenceIdHistorySetMap);
			 
			 participantListToCreateParticipantActions = participantService.associateParticipant(sequenceIdToParticipantListMap);
			 participantListToPerformParticipantAction = participantList; 	 		  			 
		}
		else {
		   participantListToPerformParticipantAction = SequenceEngineHelper.removeChildListItemsFromParentList(participantList, unAssociatedParticipantList);
		   participantListToCreateParticipantActions = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantListToPerformParticipantAction, activeSequenceIdToSequenceMap, participantType);	   
		}
			
		participantService.createParticipantActions(participantListToCreateParticipantActions, activeSequenceIdToSequenceMap);
		
		Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = SequenceEngineHelper.getUnPerformedParticipantActions(participantListToPerformParticipantAction, participantType);
				
		Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap = participantService.performParticipantActions(participantListToPerformParticipantAction, participantIdToUnperformedParticipantActionsMap, activeSequenceIdToSequenceMap, participantType);
		
		List<SObject> participantListToUpdateFields = participantService.getParticipantListForFieldsUpdate(participantListToPerformParticipantAction, participantIdToPerformedParticipantActionsMap, participantType, isTrigger);
		
		participantService.updateParticipantFields(participantListToPerformParticipantAction, participantListToUpdateFields, isTrigger);
	}     
}