@isTest
public class SequenceEngineTest {
	
	static testMethod void processSequencesForContactTest() {
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
		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.CONTACT_OBJECT_NAME,participantList,false);
		Test.stopTest();
	}
	
	static testMethod void processSequencesForLeadTest() {
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		List<Sequence_Action__c> seqActRec = new List<Sequence_Action__c>();
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		participantList.add(leadRec);
		
		Action__c actionRec1 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		insert actionRec1;
		Cadence__c seqRec1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec1.Name = 'Cadence New 1';
		seqRec1.Status__c = false;
		insert seqRec1;
		CadenceAction__C seqActionRec1 = TestDataFactory.createCadenceAction(seqRec1.Id, actionRec1.Id);
		insert seqActionRec1;
		Lead leadRec1 = TestDataFactory.createLead(seqRec1.Id);
		leadRec1.LastName = 'Lead New 1';
		leadRec1.Company = 'Company New 1';
		insert leadRec1; 
		Sequence_Action__c participantAction1 = TestDataFactory.createParticipantAction(leadRec1.Id, seqActionRec1.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction1;
		participantList.add(leadRec1);
		
		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.LEAD_OBJECT_NAME,participantList,true);
		Test.stopTest();
	}   
}