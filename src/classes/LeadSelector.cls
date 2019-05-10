public class LeadSelector {
    
    public static List<SObject> getLeadsWithMatchingExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceMap, List<string> participantTypeAndParantGroupsList)
    {
    	List<SObject> ParticipantListWithMatchingCriteria = new List<SObject>();
    	
    	For(SObject participant : participnatList)
    	{
    		Lead objLead = (Lead)participant;
    		Cadence__c sequence =  sequenceMap.get(objLead.Cadence_Id__c);    		
    		//return SObject if exit criteria matches otherwise sends null
    		SObject matchedCriteria = RuleCriterionMatcher.matchExitCriterion(sequence, participant, participant, participantType); //--to do  //check how to convert the participantTypeAndParantGroupsList to SObject and pass as third argument
    		If(matchedCriteria != null)
    		{
    			ParticipantListWithMatchingCriteria.add(participant);
    		}    		
    	}    	
    	return ParticipantListWithMatchingCriteria; 
    }
}