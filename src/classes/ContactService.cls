public class ContactService  { 
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    /**public Map<Id, SObject> getParticipantIdToParentRecordMap(List<SObject> participantList)
    {
    	Map<Id, SObject> participantIdToParentRecordMap = PerformCadenceActionBatchHelper.getObjectIdToParentRecordMap(participantList, 'AccountId', CadenceConstants.ACCOUNT_OBJECT_NAME); //--to do    	
    	return participantIdToParentRecordMap;
    }*/
    
    public Map<Id, Cadence__c> getActiveSequences(String objectType, List<SObject> participantList)
    {
    	Map<Id, Cadence__c> mapActiveSequences;
    	// to do
    	return mapActiveSequences;
    }
    
    public Map<Id, Set<Id>> getSequenceHistory()
    {
    	Map<Id, Set<Id>> contactIdToSequenceActionsIdSetMap = new Map<Id, Set<Id>>();
        Set<Id> sequenceIds;        
        List<Sequence_Action__c> sequenceActionAllContacts = [select Id, Contact_Id__c from Sequence_Action__c 
                                                                         where Contact_Id__c != null];    
                                                                         
        for(Sequence_Action__c sequenceAction : sequenceActionAllContacts){
           
           if(!contactIdToSequenceActionsIdSetMap.containsKey(sequenceAction.Contact_Id__c))
           {
           	  contactIdToSequenceActionsIdSetMap.put(sequenceAction.Lead_Id__c, new Set<Id>());
           }                       
           contactIdToSequenceActionsIdSetMap.get(sequenceAction.Lead_Id__c).add(sequenceAction.Id);             
        }  
        
    	return contactIdToSequenceActionsIdSetMap;
    }
			
	public List<SObject> checkExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceMap, List<string> participantTypeAndParantGroupsList)
	{
		List<SObject> lstParticipants;		
		// to do 
		return lstParticipants;		
	}	
		
	public static List<SObject> unAssociateParticipants(List<SObject> participantList, string participantType)
    {
    	for(SObject participant : participantList)
    	{
    		participant.put(nameSpace+'Cadence_Id__c', null);
			participant.put(nameSpace+'isActivated__c', false);
			participant.put(nameSpace+'EntranceCriteria_Matched_Date__c', null);
			if(participantType == CadenceConstants.CONTACT_OBJECT_NAME){
				participant.put(nameSpace+'Opportunity_Id__c', null);
			}
    	}
    	return participantList;
    }
		
	public Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap, Map<Id, SObject> participantIdToParentRecordMap, Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap)
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