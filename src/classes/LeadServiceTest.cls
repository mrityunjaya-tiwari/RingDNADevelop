@isTest
public class LeadServiceTest {
    
    static testMethod void getSequenceHistoryTest() {
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		
		Test.startTest();
    	Map<Id, Set<Id>> leadIdToSequenceActionsIdSetMap = new LeadService().getSequenceHistory();
    	Test.stopTest();
    	system.assertEquals(leadIdToSequenceActionsIdSetMap.size(),1);
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
    	List<Lead> unAssociateLeadList = LeadService.unAssociateParticipants(participantList, null, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(unAssociateLeadList[0].Cadence_ID__c,null);
    	system.assertEquals(unAssociateLeadList[0].isActivated__c, false);
    }
    
    static testMethod void checkExitCriteriaTest() {
    	Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
    	List<SObject> participantList = new List<SObject>();
    	
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		List<Sequence_Action__c> seqActRec = new List<Sequence_Action__c>();
		insert actionRec;
		
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		participantList.add(leadRec);
		
		Action__c actionRec1 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec1;
		Cadence__c seqRec1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec1.Name = 'Cadence New 1';
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
		
		sequenceIdToSequenceMap.put(seqRec.Id, seqRec);
		sequenceIdToSequenceMap.put(seqRec1.Id, seqRec1);
		
		Test.startTest();
    	List<Lead> matchedParticipantList = new LeadService().checkExitCriteria(CadenceConstants.LEAD_OBJECT_NAME, participantList,null,sequenceIdToSequenceMap);
    	Test.stopTest();
    }
    
    static testMethod void associateParticipantTest() {
    	
		Map<Id, List<SObject>> sequenceIdToParticipantListMap = new Map<Id, List<SObject>>();
		List<Cadence__c> seqRecList = new List<Cadence__c>();
		List<Lead> participantList = new List<Lead>();
		List<Lead> participantList1 = new List<Lead>();
		
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec;
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		
		Action__c actionRec1 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
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
		
		Action__c actionRec2 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec2;
		Cadence__c seqRec2 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec2.Name = 'Cadence New 2';
		seqRec2.Status__c = false;
		insert seqRec2;
		CadenceAction__C seqActionRec2 = TestDataFactory.createCadenceAction(seqRec2.Id, actionRec2.Id);
		insert seqActionRec2;
		Lead leadRec2 = TestDataFactory.createLead(seqRec2.Id);
		leadRec2.LastName = 'Lead New 2';
		leadRec2.Company = 'Company New 2';
		insert leadRec2; 
		Sequence_Action__c participantAction2 = TestDataFactory.createParticipantAction(leadRec2.Id, seqActionRec2.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction2;
		
		Action__c actionRec3 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec3;
		Cadence__c seqRec3 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec3.Name = 'Cadence New 3';
		seqRec3.Status__c = false;
		insert seqRec3;
		CadenceAction__C seqActionRec3 = TestDataFactory.createCadenceAction(seqRec3.Id, actionRec3.Id);
		insert seqActionRec3;
		Lead leadRec3 = TestDataFactory.createLead(seqRec3.Id);
		leadRec3.LastName = 'Lead New 3';
		leadRec3.Company = 'Company New 3';
		insert leadRec3; 
		Sequence_Action__c participantAction3 = TestDataFactory.createParticipantAction(leadRec3.Id, seqActionRec3.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction3;
		
		participantList.add(leadRec);
		participantList.add(leadRec1);
		
		participantList1.add(leadRec2);
		participantList1.add(leadRec3);
		
		sequenceIdToParticipantListMap.put(seqRec.Id, participantList);
		sequenceIdToParticipantListMap.put(seqRec2.Id, participantList1);
		
		Test.startTest();
    	List<Lead> associateParticipantList = new LeadService().associateParticipant(sequenceIdToParticipantListMap);
    	Test.stopTest();
    	system.assertEquals(associateParticipantList.size(),4);
    }
    
    static testMethod void createParticipantActionsTest() {
    	Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
    	List<SObject> participantList = new List<SObject>();
    	
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		List<Sequence_Action__c> seqActRec = new List<Sequence_Action__c>();
		insert actionRec;
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		participantList.add(leadRec);
		
		Action__c actionRec1 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert actionRec1;
		Cadence__c seqRec1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec1.Name = 'Cadence New 1';
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
		
		Set<Id> seqIds = new Set<Id> {seqRec.Id,seqRec1.Id};
		List<Cadence__c> seqRecList =[Select Id,Name,Record_Type__c,Status__c,Participent_Activation__c, (Select Id,Cadence_Id__c,Action_Id__c,Name,Trigger_Type__c,Day__c,Hour__c from CadenceActions__r)  From Cadence__c WHERE Id IN: seqIds];
		for(Cadence__c seqActiveRec : seqRecList) {
			sequenceIdToSequenceMap.put(seqActiveRec.Id, seqActiveRec);
		}
		
		Test.startTest();
    	new LeadService().createParticipantActions(participantList,sequenceIdToSequenceMap);
    	Test.stopTest();
    }
    
	static testMethod void performParticipantActionsTest() {
    	Map<Id, Cadence__c> activeSequenceIdToSequenceMap = new Map<Id, Cadence__c>();
    	Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>();
		List<Cadence__c> seqRecList = new List<Cadence__c>();
		List<Lead> participantList = new List<Lead>();
		List<Lead> participantList1 = new List<Lead>();
		List<Sequence_Action__c> unperformedParticipantActionList = new List<Sequence_Action__c>();
		
    	Action__c actionRec = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		insert actionRec;
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Lead leadRec = TestDataFactory.createLead(seqRec.Id);
		insert leadRec; 
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		
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
		
		Action__c actionRec2 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		insert actionRec2;
		Cadence__c seqRec2 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec2.Name = 'Cadence New 2';
		insert seqRec2;
		CadenceAction__C seqActionRec2 = TestDataFactory.createCadenceAction(seqRec2.Id, actionRec2.Id);
		insert seqActionRec2;
		Lead leadRec2 = TestDataFactory.createLead(seqRec2.Id);
		leadRec2.LastName = 'Lead New 2';
		leadRec2.Company = 'Company New 2';
		insert leadRec2; 
		Sequence_Action__c participantAction2 = TestDataFactory.createParticipantAction(leadRec2.Id, seqActionRec2.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction2;
		
		Action__c actionRec3 = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		insert actionRec3;
		Cadence__c seqRec3 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec3.Name = 'Cadence New 3';
		seqRec3.Status__c = false;
		insert seqRec3;
		CadenceAction__C seqActionRec3 = TestDataFactory.createCadenceAction(seqRec3.Id, actionRec3.Id);
		insert seqActionRec3;
		Lead leadRec3 = TestDataFactory.createLead(seqRec3.Id);
		leadRec3.LastName = 'Lead New 3';
		leadRec3.Company = 'Company New 3';
		insert leadRec3; 
		Sequence_Action__c participantAction3 = TestDataFactory.createParticipantAction(leadRec3.Id, seqActionRec3.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction3;
		
		participantList.add(leadRec);
		participantList.add(leadRec1);
		participantList.add(leadRec2);
		participantList.add(leadRec3);
		
		unperformedParticipantActionList.add(participantAction);
		unperformedParticipantActionList.add(participantAction1);
		unperformedParticipantActionList.add(participantAction2);
		unperformedParticipantActionList.add(participantAction3);
		
		activeSequenceIdToSequenceMap.put(seqRec.Id,seqRec);
		activeSequenceIdToSequenceMap.put(seqRec2.Id,seqRec2);
		
		for(Lead unperformedParticipantRec : participantList) {
			participantIdToUnperformedParticipantActionsMap.put(unperformedParticipantRec.Id,unperformedParticipantActionList);
		}
		
		Test.startTest();
    	new LeadService().performParticipantActions(participantList,participantIdToUnperformedParticipantActionsMap,activeSequenceIdToSequenceMap,CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    }
    
    static testMethod void getParticipantListForFieldsUpdateTest() {
    	
    }
}