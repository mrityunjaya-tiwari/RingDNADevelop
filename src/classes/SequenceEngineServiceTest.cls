@isTest
public class SequenceEngineServiceTest {
	
	public static String cadJsonobj;
	public static CadenceAction__c cadenceActionobj;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;
	
    static testMethod void activateSequencesTest1() {
    	
    	List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		List<Id> seqIdList = new List<Id>(); 
		
		criterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		 
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec.Name = 'Cadence New';
		seqRec.Entrance_Criteria__c = cadJsonobj;
		seqRec.Exit_Criteria__c=  exitCriterion;
		seqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		seqRec.matching_priority__c='P1';
		seqRec.Participent_Activation__c='Automatic';
		insert seqRec;
		seqIdList.add(seqRec.Id);
		
		
		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(seqIdList[0], action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();
		
		Lead leadRec = TestDataFactory.createLead(); 
		leadRec.Email = 'Test@gmail.com';
		insert leadRec;
		
		Test.startTest();
    	CadenceController.activateSequences(seqIdList);
    	Test.stopTest();
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    
    static testMethod void activateSequencesTest2() {
    	
    	List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		List<Id> seqIdList = new List<Id>(); 
		
		criterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		 
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec.Name = 'Cadence New';
		seqRec.Entrance_Criteria__c = cadJsonobj;
		seqRec.Exit_Criteria__c=  exitCriterion;
		seqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		seqRec.matching_priority__c='P1';
		seqRec.Participent_Activation__c='Automatic';
		insert seqRec;
		seqIdList.add(seqRec.Id);
		
		
		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(seqIdList[0], action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();
		
		Test.startTest();
		List<Lead> leadList = new List<Lead>();
		
		for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList.add(leadRec);
		}
		insert leadList;
		activateSequencesTest2Helper();
		CadenceController.activateSequences(seqIdList);
    	Test.stopTest();
    	List<Lead> leadListUpdated = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadListUpdated[0].Cadence_Id__c != null));
    }
    
    @future
    public static void activateSequencesTest2Helper() {
    	List<Lead> leadList1 = new List<Lead>();
    	for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList1.add(leadRec);  
		}
		insert leadList1;
    }
}