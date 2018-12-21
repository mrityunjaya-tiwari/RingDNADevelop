@isTest
public class CadenceServiceTest {
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
        
        cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, CUSTOM_LOGIC1);
        cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, CUSTOM_LOGIC2);
        cadJsonCUSTOM = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);
        
        
        cadLeadAND.Entrance_Criteria__c = cadJsonAND;
        
        cadLeadOR.Entrance_Criteria__c =  cadJsonOR;
        cadLeadOR.Exit_Criteria__c = cadLeadOR.Entrance_Criteria__c;
        //cadLeadOR.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        //cadLeadOR.Exit_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        
        cadLeadCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;
        
        //insert cadLeadAND;
        system.debug('cadLeadOR ' + cadLeadOR);
        cadLeadOR.Participent_Activation__c = 'Automatic';
       
        insert cadLeadOR;
        //insert cadLeadCUSTOM;
        
        action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action2= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action3= TestDataFactory.createAction(ACTION_TYPE_CALL);
        insert action1;
        action2.Activation_Type__c = 'Automatic';
        insert action2;
        insert action3; 
        
       // cadenceActionLeadAND=TestDataFactory.createCadenceAction(cadLeadAND.Id, action1.Id);
        cadenceActionLeadOR=TestDataFactory.createCadenceAction(cadLeadOR.Id, action2.Id);
        //cadenceActionCUSTOM=TestDataFactory.createCadenceAction(cadLeadCUSTOM.Id, action3.Id);
       // insert cadenceActionLeadAND;
        cadenceActionLeadOR.Trigger_Type__c = 'Immediate';
        insert cadenceActionLeadOR;
        //insert cadenceActionCUSTOM;
    }
    @isTest
    public static void testMethod1(){
        Lead l1= new Lead();
        l1.Company='Test#121';
        l1.FirstName='Test#121';
        l1.LastName='Test#121';
        l1.Status = 'Open - Not Contacted';
    	l1.LeadSource = 'Web';
    	l1.Title = 'Test';
    	insert l1;
       
    }
    
}