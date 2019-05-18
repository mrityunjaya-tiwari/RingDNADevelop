@isTest
public class SequenceEngineHelperTest {
	
    static testMethod void getParticipantListForContactToCreateParticipantActionsTest() {
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(contRec.Id, seqActionRec.Id,CadenceConstants.CONTACT_OBJECT_NAME);
		insert participantAction;
		sequenceIdToSequenceMap.put(seqRec.Id,seqRec);
		
		Test.startTest();
    	List<Contact> contactList = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, CadenceConstants.CONTACT_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(contactList.size(), 1);
    }
    
    static testMethod void getParticipantListForLeadToCreateParticipantActionsTest() {
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead();
		insert leadRec; 
		participantList.add(leadRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		sequenceIdToSequenceMap.put(seqRec.Id,seqRec);
		
		Test.startTest();
    	List<Lead> leadList = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(leadList.size(), 1);
    }
    
    /*static testMethod void getRemainingParticipantActionTest() {
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		List<Sequence_Action__c> seqActRec = new List<Sequence_Action__c>();
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead();
		insert leadRec; 
		participantList.add(leadRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		
		Test.startTest();
    	Map<Id, List<Sequence_Action__c>>  participantIdToSequenceActionsList = SequenceEngineHelper.getRemainingParticipantAction(participantList, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	for (Id participantId : participantIdToSequenceActionsList.keySet()) {
    		seqActRec = participantIdToSequenceActionsList.get(participantId);
    	}
    	system.assertEquals(seqActRec[0].Name, 'demoname');
    }*/
    
    static testMethod void deleteUnPerformedParticipantActionsTest() {
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(contRec.Id, seqActionRec.Id,CadenceConstants.CONTACT_OBJECT_NAME);
		insert participantAction;
		
		Test.startTest();
    	SequenceEngineHelper.deleteUnPerformedParticipantActions(participantList);
    	Test.stopTest();
    }
}