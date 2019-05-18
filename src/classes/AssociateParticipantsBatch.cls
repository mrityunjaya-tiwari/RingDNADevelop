/**
 * Author: Pooja Khandelwal
 * Since: May. 15, 2019
 * Name: AssociateParticipantsBatch
 * Description: Batch for Associate participants to any sequnce - In case if (total number participants to be associated to sequence > max size)
**/
public class AssociateParticipantsBatch implements Database.Batchable<SObject>, Database.stateful {
	Id sequenceIdToAssociateParticipants;
	Map<Id, Cadence__c> sequenceIdToSequenceMap;
	public List<SObject> participantListToUpdate; 
	
	public AssociateParticipantsBatch(Id sequenceId) {  
		sequenceIdToAssociateParticipants = sequenceId;
		sequenceIdToSequenceMap = SequenceEngineHelper.getActiveSequenceIdToSequenceMapByFieldValue(new Map<String, Set<String>>{'Id' => new Set<String>{sequenceId}});
		participantListToUpdate = new List<SObject>();
	} 
	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String sequenceRecordType = sequenceIdToSequenceMap.containsKey(sequenceIdToAssociateParticipants) ? sequenceIdToSequenceMap.get(sequenceIdToAssociateParticipants).Record_Type__c : null;
		String query; 
		
		if(!sequenceRecordType.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME))
			query = SequenceEngineService.formParticipantSelectQuery(sequenceRecordType, sequenceIdToSequenceMap.get(sequenceIdToAssociateParticipants));
		else{
			//query = formQueryOpportunity(objName,cadence);
		}
		query += ' order by lastmodifieddate';
		return Database.getQueryLocator(query); // Max available query row limit - 50 million (Record limit)
	}
  
	public void execute(Database.BatchableContext bc, List<SObject> participantList) {
		if(sequenceIdToSequenceMap.containsKey(sequenceIdToAssociateParticipants) && participantList.size() > 0) {
			AssociateParticipantsBatchService.associateParticipantsToSequence(sequenceIdToAssociateParticipants, sequenceIdToSequenceMap, participantList, participantListToUpdate);
		}
	}

	public void finish(Database.BatchableContext bc) {
		Database.update(participantListToUpdate, false);
	}
}