@isTest
public class PerformCadenceActionBatchServiceTest {
	
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	
    @testSetup
	static void testSetupData() {
		List<Cadence__c> sequenceListToInsert = createSequences();
		createSequenceAction(sequenceListToInsert);
		createLead();
	}
	
	private static List<Cadence__c> createSequences() {
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
        sequenceListToInsert.add(leadSeqRec);
        
        entryCriterionList = new List<Criterion>();
        entryCriterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Contact'));
		entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
        Cadence__c contactSeqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		contactSeqRec.Name = 'Cadence New';
		contactSeqRec.Entrance_Criteria__c = entryCriterionJson;
		contactSeqRec.Exit_Criteria__c=  exitCriterionJson;
		contactSeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		contactSeqRec.matching_priority__c = 'P1';
		contactSeqRec.Participent_Activation__c = 'Automatic';
        sequenceListToInsert.add(contactSeqRec);
        
        
        exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'Name', 'STRING', 'equals', 'Exit'));
		exitCriterionJson = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, '');
        entryCriterionList = new List<Criterion>();
        entryCriterionList.add(TestDataFactory.createCriterion(1, 'Name', 'STRING', 'equals', 'Test Opportunity'));
		entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
        Cadence__c opportunitySeqRec = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		opportunitySeqRec.Name = 'Cadence New';
		opportunitySeqRec.Entrance_Criteria__c = entryCriterionJson;
		opportunitySeqRec.Exit_Criteria__c=  exitCriterionJson;
		opportunitySeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		opportunitySeqRec.matching_priority__c = 'P1';
		opportunitySeqRec.Participent_Activation__c = 'Automatic';
        sequenceListToInsert.add(opportunitySeqRec);
        
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
		leadRec.Email = 'Test@gmail.com';
		insert leadRec;
	}
	
	static testMethod void runSequenceEngineTest () {
		Leads.fireTrigger = false;
		
		List<Lead> participantList = [SELECT Id, Cadence_Id__c FROM Lead];
    	PerformCadenceActionBatchService.runSequenceEngine(CadenceConstants.LEAD_OBJECT_NAME, participantList, null);
    }
}