@isTest
public class LeadServiceTest {
    
    static testMethod void getParticipantIdToParentRecordMapTest() {
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
    	new LeadService().getParticipantIdToParentRecordMap(participantList);
    	Test.stopTest();
    }
    
    static testMethod void getActiveSequencesTest() {
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		seqRec.Status__c = false;
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(contRec.Id, seqActionRec.Id,CadenceConstants.CONTACT_OBJECT_NAME);
		insert participantAction;
		
		Account accountRec1 = TestDataFactory.createAccount();
		insert accountRec1;
		Action__c actionRec1 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		insert actionRec1;
		Cadence__c seqRec1 = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		seqRec1.Name = 'Sequence Rec';
		insert seqRec1;
		CadenceAction__C seqActionRec1 = TestDataFactory.createCadenceAction(seqRec1.Id, actionRec1.Id);
		insert seqActionRec1;
		Contact contRec1 = TestDataFactory.createContact(accountRec1.Id, seqRec1.Id);
		insert contRec1; 
		
		participantList.add(contRec1);
		Sequence_Action__c participantAction1 = TestDataFactory.createParticipantAction(contRec1.Id, seqActionRec1.Id,CadenceConstants.CONTACT_OBJECT_NAME);
		insert participantAction1;
		
		Test.startTest();
    	Map<Id, Cadence__c> activeSequenceIdToSequenceMap = new LeadService().getActiveSequences(CadenceConstants.CONTACT_OBJECT_NAME, participantList );
    	Test.stopTest();
    	List<Cadence__c> seqList = new List<Cadence__c>();
    	for(Id seqId :  activeSequenceIdToSequenceMap.keySet()) {
    		Cadence__c sequenceRec = activeSequenceIdToSequenceMap.get(seqId);
    		seqList.add(sequenceRec);
    	}
    	system.assertEquals(seqList[0].Name,'Sequence Rec');
    }
    
    static testMethod void unAssociateParticipantsTest() {
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
		
		Test.startTest();
    	List<Lead> unAssociateLeadList = LeadService.unAssociateParticipants(participantList, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(unAssociateLeadList[0].Cadence_ID__c,null);
    	system.assertEquals(unAssociateLeadList[0].isActivated__c, false);
    }
    
    static testMethod void associateParticipantTest() {
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		List<Sequence_Action__c> seqActRec = new List<Sequence_Action__c>();
		insert actionRec;
		Map<Id, List<SObject>> sequenceIdToParticipantListMap = new Map<Id, List<SObject>>();
		Map<Id, Set<Id>> participantIdToSequenceIdSetMap = new Map<Id, Set<Id>>();
		List<SObject> participantList = new List<SObject>();
		List<Cadence__c> seqRecList = new List<Cadence__c>();
		List<CadenceAction__C> seqActionRecList = new List<CadenceAction__C>();
		Set<Id> sequenceIdSet = new Set<Id>();
		for(Integer i=0; i<5; i++) {
			Cadence__c seqRec = new Cadence__c();
			seqRec.Name = 'Test Cadence' + i;
			seqRec.Record_Type__c = CadenceConstants.LEAD_OBJECT_NAME;
			seqRec.Status__c = true;
			seqRec.Participent_Activation__c = 'Automatic'; 
			seqRecList.add(seqRec);
			sequenceIdSet.add(seqRec.Id);
		}
		
		insert seqRecList;
		
		for(Integer i=0; i<5; i++) {
			CadenceAction__C seqActionRec = new CadenceAction__C();
			seqActionRec.Cadence_Id__c = seqRecList[i].Id;
			seqActionRec.Action_Id__c = actionRec.Id;
			seqActionRec.Name = 'Test Cadence Action' + i;
			seqActionRec.Trigger_Type__c = 'Immediate';
			seqActionRecList.add(seqActionRec);
		}
		
		insert seqActionRecList;
		
		for(Integer i=0; i<5; i++) {
			Lead leadRec = new Lead();
			leadRec.LastName = 'Test Lead' + i;
			leadRec.Company = 'Test Company' + i;
			leadRec.Cadence_Id__c = seqRecList[i].Id;
			leadRec.Priority__C = i;
			participantList.add(leadRec);
		}
		
		insert participantList; 
		
		for(Cadence__c sequenceRec : seqRecList) {
			sequenceIdToParticipantListMap.put(sequenceRec.Id, participantList);
		}
		
		for(SObject participantRec : participantList) {
			participantIdToSequenceIdSetMap.put(participantRec.Id, sequenceIdToParticipantListMap.keySet());
		}
		
		Test.startTest();
    	List<Lead> unAssociateLeadList = new LeadService().associateParticipant(sequenceIdToParticipantListMap, participantIdToSequenceIdSetMap);
    	Test.stopTest();
    }
}