public class LeadService implements IPatricipant {
    
    public Map<Id, Cadence__c> getActiveSequences(String objectType)
    {
    	Map<Id, Cadence__c> activeSequencesMap = SequenceEngineHelper.getSequenceMap(New List<String> {objectType});    	
    	return activeSequencesMap;
    }
			
	//return participant with matching criteria
	public List<SObject> checkExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceMap, List<string> participantTypeAndParantGroupsList)
	{
		List<SObject> lstParticipants;	
		lstParticipants = LeadSelector.getLeadsWithMatchingExitCriteria(participantType, participnatList, sequenceMap, participantTypeAndParantGroupsList);		
		return lstParticipants;		
	}	
		
	public Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap)
	{
		Map<Id, List<SObject>> mapSequenceToParticipationList;
		// to do 
		return mapSequenceToParticipationList;
	}
	
	public List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap, Map<Id, Set<Id>> participantIdToSequenceIdSetMap)
	{
		List<SObject> lstParticipant;
		// to do
		return lstParticipant;
	}
	
	public void createParticipantActions(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap)
	{
		// to do
	}
	
	public Map<Id, List<Sequence_Action__c>> performParticipantActions(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToParticipantActionsMap)
	{
		Map<Id, List<Sequence_Action__c>> mapParticipantIdToPerformedParticipantActions;
		//to do
		return mapParticipantIdToPerformedParticipantActions;
	}
	
	public void updateSObjectFields(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, string participantType, boolean isTrigger)
	{
		
	}	
}