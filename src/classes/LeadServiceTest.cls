@isTest
public class LeadServiceTest {
	
	public static String cadJsonobj;
	public static CadenceAction__c cadenceActionobj;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;
    
    @testSetup
	static void testSetupData() {
		List<Cadence__c> sequenceListToInsert = createSequence();
		createSequenceAction(sequenceListToInsert);
		createLead();
	}
	
	private static List<Cadence__c> createSequence() {
		List<Criterion> entryCriterionList = new List<Criterion>();
		entryCriterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		String entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
		
		List<Criterion> exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		String exitCriterionJson = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 
		
        List<Cadence__c> sequenceListToInsert = new List<Cadence__c>();
		Cadence__c leadSeqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		leadSeqRec.Name = 'Cadence New';
		leadSeqRec.Entrance_Criteria__c = entryCriterionJson;
		leadSeqRec.Exit_Criteria__c=  exitCriterionJson;
		leadSeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		leadSeqRec.matching_priority__c = 'P1';
		leadSeqRec.Participent_Activation__c = 'Automatic';
		leadSeqRec.Status__c = false;
        sequenceListToInsert.add(leadSeqRec);
        
		insert sequenceListToInsert;
		return sequenceListToInsert;
	}
	
	private static void createSequenceAction(List<Cadence__c> sequenceList) {
		Action__c action = createAction();
		
        List<CadenceAction__C> seqActionListToInsert = new List<CadenceAction__C>();
        for(Cadence__c sequence : sequenceList) {
            CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(sequence.id, action.Id);
            seqActionRec.Day__c = 2;
            seqActionRec.Hour__c = 2;
            seqActionRec.Trigger_Type__c = 'Time Based';
            seqActionListToInsert.add(seqActionRec);
        }
		insert seqActionListToInsert;
	}
	 
	private static Action__c createAction() {
		Action__c action = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action.Activation_Type__c = 'Automatic';
		insert action;
		return action;
	}
	
	private static void createLead() {
		Lead leadRec = TestDataFactory.createLead(); 
		leadRec.Email = 'Test12@gmail.com';
		insert leadRec;
	}
	
    static testMethod void getSequenceHistoryTest() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Test.startTest();
    	List<Lead> leadList = [SELECT Id FROM Lead];
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new LeadService().getSequenceHistory();
    	Test.stopTest();
    	
    	System.assertEquals(true, participantIdToSequenceIdHistorySetMap.get(leadList[0].Id).contains(seqRecList[0].Id));
    }
    
    static testMethod void checkExitCriteriaTest() {
		Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Leads.fireTrigger = false;
    	String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME);
    	List<Lead> leadList = Database.query(query);
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	Leads.fireTrigger = true;
    	
    	Test.startTest();
    	SequenceEngineWrapper sequenceEngineWrapper = new LeadService().checkExitCriteria(CadenceConstants.LEAD_OBJECT_NAME, leadList, null, seqIdToSequneceRecMap);
    	Test.stopTest();
    	
    	System.assertEquals(1, sequenceEngineWrapper.participantList.size());
    }
    
    static testMethod void unAssociateParticipantsTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Leads.fireTrigger = false;
    	String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME);
    	List<Lead> leadList = Database.query(query);
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	Leads.fireTrigger = true;
    	
    	SequenceEngineWrapper sequenceEngineWrapper = new LeadService().checkExitCriteria(CadenceConstants.LEAD_OBJECT_NAME, leadList, null, seqIdToSequneceRecMap);
    	
    	Test.startTest();
    	List<SObject> unAssociatedParticipantList  = new LeadService().unAssociateParticipants(sequenceEngineWrapper, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest(); 
    	
    	System.assertEquals(1, unAssociatedParticipantList.size());
    }
    
    static testMethod void checkEntryCriteriaTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	activateSequences(seqIdToSequneceRecMap.values());
    	
    	String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME);
    	List<Lead> leadList = Database.query(query);
    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new LeadService().getSequenceHistory();
    	
    	Test.startTest();
    	Map<Id, List<SObject>> sequenceIdToParticipationListMap = new LeadService().checkEntryCriteria(leadList, null, seqIdToSequneceRecMap, participantIdToSequenceIdHistorySetMap);
    	Test.stopTest();
    	
    	system.assert(false, sequenceIdToParticipationListMap);
    	System.assertEquals(1, sequenceIdToParticipationListMap.get(seqIdToSequneceRecMap.values()[0].Id).size());
    }
    
	    
    static testMethod void associateParticipantTest() {
    	Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
    	
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
    	Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
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
		List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	
    	CadenceController.activateSequences(sequenceIdList); 
    	
    	List<Sobject> participantList = [SELECT Id, Name, Email, OwnerId, Cadence_Id__c FROM Lead];
    	
		new LeadService().createParticipantActions(participantList, new Map<Id, Cadence__c>(seqRecList));
		
		List<Sequence_Action__c> unperformedParticipantActionList = [SELECT Name, Lead_Id__c, CadenceAction_ID__c, isActionPerformed__c, 
																		CadenceAction_Id__r.Action_Id__r.Type__c, Show_on_Target_List__c, 
																		CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Action_Id__r.Email_Type__c,
																		CadenceAction_Id__r.Action_Id__r.Template_Id__c, CadenceAction_Id__r.Index__c
																		FROM Sequence_Action__c];
		
		
		Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>();
		participantIdToUnperformedParticipantActionsMap.put(participantList[0].Id, unperformedParticipantActionList);
		
		Test.startTest();
    	Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap = new LeadService().performParticipantActions(participantList, participantIdToUnperformedParticipantActionsMap, new Map<Id, Cadence__c>(seqRecList), CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	
    	system.assertEquals(1, participantIdToPerformedParticipantActionsMap.get(participantList[0].Id).size());
    }
    
    private static void activateSequences(List<Cadence__c> seqRecList) {
		for(Cadence__c sequence : seqRecList) {
			sequence.Status__c = true;
		}
		update seqRecList;
	}
}