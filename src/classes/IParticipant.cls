public interface IParticipant {
      
	List<SObject> checkExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceMap);
				 
	Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap,  Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap);
	 
	List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap); 
	
	List<SObject> unAssociateParticipants(List<SObject> participantList, string participantType);
	
	Map<Id, Set<Id>> getSequenceHistory(); 
	
	void createParticipantActions(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap);
	
	Map<Id, List<Sequence_Action__c>> performParticipantActions(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap, Map<Id, Cadence__c> activeSequenceIdToSequenceMap, string participantType);
	
	List<SObject> getParticipantListForFieldsUpdate(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, string participantType, boolean isTrigger);
	
	void updateParticipantFields(List<SObject> participantListToPerformParticipantAction, List<SObject> participantListToUpdateFields, boolean isTrigger);
	
}