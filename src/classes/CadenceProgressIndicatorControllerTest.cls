@isTest
public class CadenceProgressIndicatorControllerTest {
    Public static Final String ACTION_TYPE_CALL = 'Call';
    Public static Final String RECORD_TYPE_LEAD = 'Lead';
    public static String jsonString;
    public static final String CUSTOM_LOGIC = '1 AND (2 AND 3)';
    public static Action__c action1;
    public static Cadence__c cadence1;
    public static CadenceAction__c cadenceAction1;
    public static Sequence_Action__c actionOnParticipants;   
    Public static Final String ACTION_TYPE_Email = 'Email';
    @isTest
    public static void saveCadenceTest(){
        Action__c action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
        insert action1;
        
        List<Criterion> criterionList = new List<Criterion>();
        Cadence__c cadenceObj= TestDataFactory.createCadence(RECORD_TYPE_LEAD);
        Criterion c = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
        criterionList.add(c);
        jsonString = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, CUSTOM_LOGIC);
        cadenceobj.Entrance_Criteria__c = jsonString;
        cadenceobj.Exit_Criteria__c = jsonString;
        cadenceobj.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
        cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
        insert cadenceobj;
        CadenceAction__c cadenceActionobj= TestDataFactory.createCadenceAction(cadenceObj.Id, action1.Id);
        cadenceActionobj.Action_Criterion__c = jsonString;
        cadenceActionobj.Cadence_Id__c=cadenceobj.Id;
        insert cadenceActionobj;
        
        Test.startTest();
        CadenceProgressIndicatorController.saveCadence(cadenceObj, new List<CadenceAction__c> {cadenceActionobj}, New List<String>());
        Test.stopTest();
        List<CadenceAction__c> ListOfCadenceActionToDelete = [Select id from CadenceAction__c where Id =:cadenceActionobj.Id];
        System.assertEquals(1, ListOfCadenceActionToDelete.size(),  'cadenceAction size must be 1');             
        //List<CadenceAction__c> caListToInsert = new List<CadenceAction__c>();
       // caListToInsert.add(cadenceActionobj);
    }
    
    @isTest
    public static void populatePostFixExpressionsTest(){
        CriterionSet ecs= new CriterionSet();
        ecs.criterionPriorityFormula= 'CUSTOM_LOGIC';
        ecs.postFixExpression='CUSTOM_LOGIC';
        List<Criterion> criterionList = new List<Criterion>();
        Cadence__c cadenceObj= TestDataFactory.createCadence(RECORD_TYPE_LEAD);
        Criterion c = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
        criterionList.add(c);
        jsonString = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, CUSTOM_LOGIC);
        cadenceobj.Entrance_Criteria__c = jsonString;
        cadenceobj.Exit_Criteria__c = jsonString;
        cadenceobj.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);
        cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);
        insert cadenceobj;
        Test.startTest();
        CadenceProgressIndicatorController.populatePostFixExpressions(cadenceobj);
        Test.stopTest();
    }
    
    @isTest
    public static void populateCadActionPostFixExpressionTest(){
        
        List<Criterion> criterionList = new List<Criterion>();
        Cadence__c cadenceObj= TestDataFactory.createCadence(RECORD_TYPE_LEAD);
        Criterion c = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
        criterionList.add(c);
        jsonString = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, CUSTOM_LOGIC);
        cadenceobj.Entrance_Criteria__c = jsonString;
        cadenceobj.Exit_Criteria__c = jsonString;
        cadenceobj.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
        cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
        insert cadenceobj;
        Action__c action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
        insert action1;
        CadenceAction__c cadenceActionobj= TestDataFactory.createCadenceAction(cadenceObj.Id, action1.Id);
        cadenceActionobj.Action_Criterion__c = jsonString;
        cadenceActionobj.Trigger_Type__c= 'Immediate';
        insert cadenceActionobj;
        
        Test.startTest();
        CadenceProgressIndicatorController.populateCadActionPostFixExpression(cadenceActionobj);
        Test.stopTest();
    }
    
    @isTest
    public static void createParticipantActionsByCadenceActionsTest(){
        Cadence__c cadenceObj= TestDataFactory.createCadence(RECORD_TYPE_LEAD);
        insert cadenceobj;
        Action__c action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
        insert action1;
        CadenceAction__c cadenceActionobj= TestDataFactory.createCadenceAction(cadenceObj.Id, action1.Id);
        cadenceActionobj.Action_Criterion__c = jsonString;
        cadenceActionobj.Trigger_Type__c= 'Immediate';
        insert cadenceActionobj;
        Test.startTest();
        CadenceProgressIndicatorController.createParticipantActionsByCadenceActions(cadenceobj, new Map<Id, String>{cadenceActionobj.Id => cadenceActionobj.Name});
        Test.stopTest();
    }
    @isTest
    public static void deleteParticipantActionsByCadenceActionsTest(){
        action1= TestDataFactory.createAction(ACTION_TYPE_Email);
        insert action1;
        cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadence1.Participent_Activation__c='Automatic';
        cadence1.Status__c=true;
        cadence1.matching_priority__c= 'P1';
        cadence1.Record_Type__c='Lead';
        insert cadence1;        
        cadenceAction1=TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
        cadenceAction1.Name='democadenceaction';
        cadenceAction1.Trigger_Type__c= 'Immediate';       
        insert cadenceAction1;
        actionOnParticipants= new Sequence_Action__c();
        actionOnParticipants.CadenceAction_ID__c= cadenceAction1.Id;
        insert actionOnParticipants;
        Test.startTest();
        CadenceProgressIndicatorController.deleteParticipantActionsByCadenceActions(new list<Id>{cadenceAction1.Id});
        Test.stopTest();
        
    }
}