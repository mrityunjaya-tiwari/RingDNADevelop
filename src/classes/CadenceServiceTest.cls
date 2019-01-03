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
   
    @isTest
    public static void unMappedParticipateTest(){
        //List<Lead> leadlist= new List<Lead>();
        Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadence1.Participent_Activation__c='Automatic';
        cadence1.Status__c=true;
        cadence1.matching_priority__c= 'P1';
        cadence1.Record_Type__c='Lead';
        String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
        String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
    	cadence1.Entrance_Criteria__c = entryJson;
        cadence1.Exit_Criteria__c = exitJson;
        insert cadence1;
        
        action1= TestDataFactory.createAction('Email');
        action1.Template_Id__c= '00Xf4000001cPpjEAE';
        action1.Activation_Type__c = 'Automatic';
        insert action1;
        
        cadenceActionLeadAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
        cadenceActionLeadAND.Day__c= 2;
        cadenceActionLeadAND.Hour__c=2;
        cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
        insert cadenceActionLeadAND;
        
        Lead l1= TestDataFactory.createLead();
        l1.Company='COM';
        l1.FirstName='Test#11';
        l1.LastName='lname';
        l1.Status = 'Open - Not Contacted';
    	l1.LeadSource = 'Web';
    	l1.Title = 'Test';
    	insert l1;
        System.assertNotEquals(null, l1.id);
         
        Lead l2= TestDataFactory.createLead();
        l2.Company='COM2';
        l2.FirstName='Test#12';
        l2.LastName='lname2';
        l2.Status = 'Open - Not Contacted';
    	l2.LeadSource = 'Web';
    	l2.Title = 'Test';
    	insert l2;
        System.assertNotEquals(null, l2.id);
        
        
        Contact c1= new Contact();
        c1.FirstName='fname';
        c1.LastName='lname';
        c1.Department='IT';
        insert c1;
        System.assertNotEquals(null, c1.id);
        
        Contact c2= new Contact();
        c2.FirstName='fname2';
        c2.LastName='lname2';
        c2.Department='IT';
        insert c2;
        System.assertNotEquals(null, c2.id);
        
        Sequence_Action__c seqAction  =  new Sequence_Action__c();
        seqAction.CadenceAction_Id__c = cadenceActionLeadAND.id;
        seqAction.isActionPerformed__c =false;
        seqAction.Lead_Id__c =l1.id;
        insert seqAction;
        System.assertNotEquals(null, seqAction.id);
        
        Sequence_Action__c seqAction2  =  new Sequence_Action__c();
        seqAction2.CadenceAction_Id__c = cadenceActionLeadAND.id;
        seqAction2.isActionPerformed__c =false;
        seqAction2.Contact_Id__c =c1.id; 
        insert seqAction2;
        
        System.assertNotEquals(null, seqAction2.id);
        
        map<id,id > mapofleadCadence =  new map<id,id>{l2.id =>cadence1.id};
        map<id,id > mapofleadCadence2 =  new map<id,id>{c1.id =>cadence1.id};
        list<Lead> listoflead  = new list<Lead>();
        listoflead.add(l1); 
        
        list<contact> listofcon  = new list<contact>();
        listofcon.add(c1);    
        Test.startTest();
        CadenceService.processParticipantsWithCadences(listoflead,'Lead',false);
        CadenceService.deleteUnperformedPartActions(mapofleadCadence,'Lead');
        CadenceService.deleteUnperformedPartActions(mapofleadCadence2,'Contact');
        
        Test.stopTest();
    }
    
}