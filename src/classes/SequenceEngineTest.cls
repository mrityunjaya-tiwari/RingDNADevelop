@isTest
public class SequenceEngineTest {
	
	static testMethod void processSequencesForContactTest() {
		Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		List<String> participantTypeAndParantGroupsList = new List<String> {'Contact'};
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.CONTACT_OBJECT_NAME,participantTypeAndParantGroupsList,participantList,false);
		Test.stopTest();
	}
	
	static testMethod void processSequencesForLeadTest() {
		
		List<String> participantTypeAndParantGroupsList = new List<String> {'Lead'};
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
		
		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.LEAD_OBJECT_NAME,participantTypeAndParantGroupsList,participantList,false);
		Test.stopTest();
		
		
	}   
}