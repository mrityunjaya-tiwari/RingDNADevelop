@isTest
public class PerformCadenceActionBatchTest {
    public static final String CUSTOM_LOGIC = '1 AND (2 OR 3)';
    Public static Final String ACTION_TYPE_CALL = 'Call';
    public static final String CUSTOM_LOGIC1 = '1 AND (2 AND 3)';
    public static final String CUSTOM_LOGIC2 = '1 OR (2 OR 3)';
     
    public static Cadence__c cadLeadAND;
    public static Cadence__c cadLeadOR;
    public static Cadence__c cadLeadCUSTOM;
    
    public static Cadence__c cadContactAND; 
    public static Cadence__c cadContactOR;
    
    public static Action__c action1;
    public static Action__c action2;
    public static Action__c action3;
    
    public static CadenceAction__c cadenceActionLeadAND;
    public static CadenceAction__c cadenceActionLeadOR;
    public static CadenceAction__c cadenceActionCUSTOM;
    
    public static String cadJsonAND;
    public static String cadJsonOR;
    public static String cadJsonCUSTOM; 
    
    static {
        
        cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadLeadOR = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadLeadCUSTOM = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        
        List<Criterion> criterionList = new List<Criterion>();
        Criterion c1 = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
        Criterion c2 = TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web');
        Criterion c3 = TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test');
        
        criterionList.add(c1);
        criterionList.add(c2);
        criterionList.add(c3);
        
        cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
        cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, '');
        cadJsonCUSTOM = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);
        
        
        cadLeadAND.Entrance_Criteria__c = cadJsonAND;
        cadLeadAND.Exit_Criteria__c=cadJsonAND;
        cadLeadAND.Participent_Activation__c='Automatic';
        cadLeadAND.matching_priority__c = 'P1';
        
        cadLeadOR.Entrance_Criteria__c = cadJsonOR;
        cadLeadOR.Exit_Criteria__c =  cadJsonOR;
        cadLeadOR.Participent_Activation__c = 'Automatic';
        cadLeadOR.matching_priority__c = 'P3';
        
        cadLeadOR.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadOR.Exit_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        
        cadLeadCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;
        cadLeadCUSTOM.Exit_Criteria__c = cadJsonCUSTOM;
        cadLeadCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadCUSTOM.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadCUSTOM.matching_priority__c = 'P2';
        
        cadLeadCUSTOM.Participent_Activation__c='Automatic';
        
        
        insert cadLeadAND;
        insert cadLeadOR;
        insert cadLeadCUSTOM;
        
        action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action2= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action3= TestDataFactory.createAction(ACTION_TYPE_CALL);
        
        action1.Activation_Type__c = 'Automatic';
        action2.Activation_Type__c = 'Automatic';
        action3.Activation_Type__c = 'Automatic';
        insert action1;
        insert action2;
        insert action3; 
        
        cadenceActionLeadAND=TestDataFactory.createCadenceAction(cadLeadAND.Id, action1.Id);
        cadenceActionLeadOR=TestDataFactory.createCadenceAction(cadLeadOR.Id, action2.Id);
        cadenceActionCUSTOM=TestDataFactory.createCadenceAction(cadLeadCUSTOM.Id, action3.Id);
        
        cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
        cadenceActionLeadOR.Trigger_Type__c = 'Immediate';
        cadenceActionCUSTOM.Trigger_Type__c = 'Immediate';
        
        
    }
    @isTest 
    static void leadMatchesCriterionTest() {
        Lead l1= new Lead();
        l1.Company='COM';
        l1.FirstName='fname';
        l1.LastName='lname';
        l1.Status = 'Open - Not Contacted';
        l1.LeadSource = 'Web';
        l1.Title = 'Test';
        insert l1;
        
        Lead l2 = TestDataFactory.createLead();
        l2.status = 'Open - Not Contacted';
        l2.LeadSource = 'Other';
        l2.Title = 'SecondTest';
        l1.Company='SecondCOM';
        l1.FirstName='fname2';
        l1.LastName='lname2';
        insert l2;
        
        Test.startTest();
        PerformCadenceActionBatch lead=new PerformCadenceActionBatch(new List<string>{CadenceConstants.LEAD_OBJECT_NAME, CadenceConstants.DB_OBJECT_NAME});
        PerformCadenceActionBatch contact=new PerformCadenceActionBatch(new List<string>{CadenceConstants.CONTACT_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME});
        Database.executeBatch(lead,200);
        Test.stopTest();
        
        l1 = [Select Id, Cadence_Id__c from Lead where Id = :l1.Id];
        l2 = [Select Id, Cadence_Id__c from Lead where Id = :l2.Id];
        
        //System.assertNotEquals(null, l1.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');
        //System.assertNotEquals(null, l2.Cadence_Id__c, 'Cadence lookup will not populate as its criterion not matches');
        
    }  
}