@isTest
public class SequenceEngineTest {
	//Constants 
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';
	Public static Final String ACTION_TYPE_CALL = 'Call';
	
	static testMethod void processSequencesTest() {
		Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionRec;
		List<String> participantTypeAndParantGroupsList = new List<String> {'Contact'};
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		SequenceEngine.processSequences(RECORD_TYPE_CONTACT,participantTypeAndParantGroupsList,participantList,false);
	}   
}