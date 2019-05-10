public class SequenceEngine {
	
	public static void processSequences(string participantType, List<string> participantTypeAndParantGroupsList, List<SObject> participantList, boolean isTrigger)
	{
		//Created a factory map using all participant types.
		Map<String, Type> sequenceEngineFactory = new Map<String, Type> {'Contact' => ContactService.class, 'Lead' => LeadService.class };
			
		//Initiation of service class	
		IPatricipant participantService = (IPatricipant)sequenceEngineFactory.get(participantType).newInstance();
		
		//Fetch all the Active sequences 
		Map<Id, Cadence__c> activeSequencesMap  = participantService.getActiveSequences(participantType);
		
		//Fetch participant list which have exit criteria matched in sequence(further those participant will be unassociated.)
		List<SObject> participantListWithMatchedCriteria = participantService.checkExitCriteria(participantType, participantList, activeSequencesMap, participantTypeAndParantGroupsList);
		
		
		List<SObject> unAssociatedParticipantList = SequenceEngineHelper.unAssociateParticipants(participantListWithMatchedCriteria);
				
		SequenceEngineHelper.deleteUnPerformedParticipantActions(unAssociatedParticipantList);
		
		List<SObject> participantListToCreateParticipantActions = new List<SObject>();
		List<SObject> participantListToPerformParticipantAction = new List<SObject>();
		
		if (isTrigger) {
			 Map<Id, Set<Id>> participantIdToSequenceIdSetMap = SequenceEngineHelper.getSequenceHistory();
			 
			 Map<Id, List<SObject>> sequenceIdToParticipantListMap =  participantService.checkEntryCriteria(participantList, activeSequencesMap);
			 
			 participantListToCreateParticipantActions = participantService.associateParticipant(sequenceIdToParticipantListMap, participantIdToSequenceIdSetMap);
			 participantListToPerformParticipantAction = participantList;			  			 
		}
		else {
		   participantListToPerformParticipantAction = SequenceEngineHelper.removeChildListItemsFromParentList(participantList, unAssociatedParticipantList);
		   
		   participantListToCreateParticipantActions = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantListToPerformParticipantAction, activeSequencesMap, participantType);		   
		}	
			
		participantService.createParticipantActions(participantListToCreateParticipantActions, activeSequencesMap);
		
		Map<Id, List<Sequence_Action__c>> participantIdToParticipantActionsMap = SequenceEngineHelper.getRemainingParticipantAction(participantListToPerformParticipantAction, participantType);
		
		Map<Id, List<Sequence_Action__c>> mapParticipantIdToPerformedParticipantActions = participantService.performParticipantActions(participantListToPerformParticipantAction, participantIdToParticipantActionsMap);
		
		participantService.updateSObjectFields(participantListToPerformParticipantAction, mapParticipantIdToPerformedParticipantActions, participantType, isTrigger);
		
	}    
}