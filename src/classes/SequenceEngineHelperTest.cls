@isTest
public class SequenceEngineHelperTest {
	//Constants 
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';
	Public static Final String ACTION_TYPE_CALL = 'Call';
	Public static Final String RECORD_TYPE_LEAD = 'Lead';
	
    static testMethod void getParticipantListForContactToCreateParticipantActionsTest() {
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(contRec.Id, seqActionRec.Id,RECORD_TYPE_CONTACT);
		insert participantAction;
		sequenceIdToSequenceMap.put(seqRec.Id,seqRec);
    	SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, RECORD_TYPE_CONTACT);
    }
    
    static testMethod void getParticipantListForLeadToCreateParticipantActionsTest() {
		Action__c actionRec = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_LEAD);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead();
		insert leadRec; 
		participantList.add(leadRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, RECORD_TYPE_LEAD);
		insert participantAction;
		sequenceIdToSequenceMap.put(seqRec.Id,seqRec);
    	SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, RECORD_TYPE_CONTACT);
    }
    
    static testMethod void getRemainingParticipantActionTest() {
		List<SObject> participantList = new List<SObject>();
		Lead leadRec = TestDataFactory.createLead();
		insert leadRec; 
		participantList.add(leadRec);
    	SequenceEngineHelper.getRemainingParticipantAction(participantList, RECORD_TYPE_LEAD);
    }
}