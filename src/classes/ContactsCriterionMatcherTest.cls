@isTest
public class ContactsCriterionMatcherTest {
    
    public static final String CUSTOM_LOGIC = '1 AND (2 OR 3)';
    Public static Final String ACTION_TYPE_CALL = 'Call';
    Public static Final String ACTION_TYPE_Email = 'Email';
    public static final String CUSTOM_LOGIC1 = '1 AND (2 AND 3)';
    public static final String CUSTOM_LOGIC2 = '1 OR (2 OR 3)';
    
    public static Cadence__c cadContactAND;
    public static Cadence__c cadContactOR;
    public static Cadence__c cadContactOR2;
    public static Cadence__c cadContactCUSTOM;
   
    public static Action__c action1;
    public static Action__c action2;
    public static Action__c action3;
        
    public static CadenceAction__c cadenceActionContactAND;
    public static CadenceAction__c cadenceActionContactOR;
    public static CadenceAction__c cadenceActionCUSTOM;
    
    public static CadenceAction__c cadenceActionContactOR2;
    
    public static String cadJsonAND;
    public static String cadJsonAND2;
    
    public static String cadJsonOR;
    public static String cadJsonOR2;
    
    public static String cadJsonCUSTOM; 
    
    
    
    static {
        
        cadContactAND = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
        cadContactOR = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
        cadContactCUSTOM = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
        
        List<Criterion> criterionList = new List<Criterion>();
        Criterion c1 = TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'lname');
        Criterion c2 = TestDataFactory.createCriterion(2, 'FirstName', 'STRING', 'equals', 'fname');
        Criterion c3 = TestDataFactory.createCriterion(3, 'Department', 'STRING', 'equals', 'Sales');
        criterionList.add(c1);
        criterionList.add(c2);
        criterionList.add(c3);
        
        List<Criterion> criterionList2 = new List<Criterion>();
        Criterion c4 = TestDataFactory.createCriterion(1, 'Salutation', 'PICKLIST', 'equals', 'Mr.');
        Criterion c5 = TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'test');
        Criterion c6 = TestDataFactory.createCriterion(3, 'LeadSource', 'PICKLIST', 'equals', 'Partner Referral');
        criterionList2.add(c4);
        criterionList2.add(c5);
        criterionList2.add(c6);
        
        cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
        cadJsonAND2 = TestDataFactory.createCadenceJSON(criterionList2, CadenceConstants.CONDITION_AND, '');
        
        cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, '');
        cadJsonOR2= TestDataFactory.createCadenceJSON(criterionList2, CadenceConstants.CONDITION_OR, '');
        cadJsonCUSTOM = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);
        
        
        cadContactAND.Entrance_Criteria__c = cadJsonAND;
        cadContactAND.Exit_Criteria__c=cadJsonAND2;
        
        cadContactAND.matching_priority__c='P1';
        cadContactAND.Participent_Activation__c='Automatic';
        
        
        cadContactOR.Entrance_Criteria__c = cadJsonOR2;
        cadContactOR.Exit_Criteria__c =  cadJsonOR;
        cadContactOR.matching_priority__c='P2';
        cadContactOR.Participent_Activation__c = 'Automatic';
       
        cadContactOR.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadContactOR.Exit_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        
        cadContactCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;
        cadContactCUSTOM.Exit_Criteria__c = cadJsonCUSTOM;
        cadContactCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
        cadContactCUSTOM.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadContactCUSTOM.matching_priority__c='P3';
        cadContactCUSTOM.Participent_Activation__c='Automatic';
       
        
        insert cadContactAND;
        insert cadContactOR;
        insert cadContactCUSTOM;
        
        action1= TestDataFactory.createAction(ACTION_TYPE_Email);
        action2= TestDataFactory.createAction(ACTION_TYPE_Email);
        action3= TestDataFactory.createAction(ACTION_TYPE_Email);
        action1.Template_Name__c='Sales: New Customer Email';
        
        action1.Activation_Type__c = 'Automatic';
        action2.Activation_Type__c = 'Automatic';
        action3.Activation_Type__c = 'Automatic';
        action1.Template_Id__c= '00Xf4000001cPpjEAE';
        action2.Template_Id__c= '00Xf4000001cPpjEAE';
        action3.Template_Id__c= '00Xf4000001cPpjEAE';
       
        insert action1;
        insert action2;
        insert action3; 
        
        cadenceActionContactAND=TestDataFactory.createCadenceAction(cadContactAND.Id, action1.Id);
        cadenceActionContactOR=TestDataFactory.createCadenceAction(cadContactOR.Id, action2.Id);
        cadenceActionCUSTOM=TestDataFactory.createCadenceAction(cadContactCUSTOM.Id, action3.Id);
        
        cadenceActionContactAND.Trigger_Type__c = 'Immediate';
        cadenceActionContactOR.Trigger_Type__c = 'Immediate';
        cadenceActionCUSTOM.Trigger_Type__c = 'Immediate';
        insert cadenceActionContactAND;
        insert cadenceActionContactOR;
        insert cadenceActionCUSTOM;
      
    }
        
       
    @isTest 
       static void contactMatchesEntryCriterionTest() {
        Contact c1= new Contact();
        Contact c2 = new Contact();
        Contact c3 = new Contact();
        c1.FirstName='fname';
        c1.LastName='lname';
        c1.Department='Sales';
        insert c1;
        Test.startTest();
        c1.Salutation = 'Mr.';
        c1.Description = 'Hindi';
        c1.LeadSource = 'Partner Referral';
        update c1;
        Test.stopTest();
        // Activate cadence
        CadenceService.setParticipantsActivation(cadContactAND.Id,true);
        c2 = [Select Id, Cadence_Id__c, isActivated__c, EntranceCriteria_Matched_Date__c, CreatedDate from Contact where Id = :c1.Id];
        //System.assertEquals(c2.CreatedDate, c2.EntranceCriteria_Matched_Date__c, 'Entrance Criteria matches');
        System.assertEquals(true, c2.isActivated__c, 'contact activated through cadence');        
        //System.assertEquals(cadContactAND.Id, c2.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');
        //c3 = [Select Id, Cadence_Id__c, CadencePerformed__c from Contact where Id = :c2.Id];  
        //System.assertEquals(true, c3.CadencePerformed__c, 'Exit Criterias matches,CadencePerformed set to true ');
           
    }
    @isTest 
    static void contactNotMatchesCriterionTest() {
    	Contact c4= new Contact();
        c4.FirstName='name';
        c4.LastName='name';
        c4.Department='IT';
        insert c4;
     
    	Test.startTest();
    	CadenceController.updateParticipants(cadContactAND.Id);
    	Test.stopTest();
    	
    	c4 = [Select Id, Cadence_Id__c from Contact where Id = :c4.Id];
    	System.assertEquals(null, c4.Cadence_Id__c , 'Cadence lookup will not populate as its criterion not matches');
    } 
       

    @isTest 
    static void contactMatchesEntryCustomCriterionTest() {
		
    	Contact c5= new Contact();
    	c5.FirstName='fname';
        c5.LastName='lname';
        c5.Department='IT';
        insert c5;    
        Test.startTest();
        cadContactCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
    	update cadContactCUSTOM;
    	Test.stopTest();
 	
    	CadenceService.setParticipantsActivation(cadContactCUSTOM.Id,true); 
        c5= [Select Id, Cadence_Id__c, isActivated__c, EntranceCriteria_Matched_Date__c, CreatedDate from Contact where Id = :c5.Id];
        //System.assertEquals(true, c5.isActivated__c, 'contact activated through cadence');
        //System.assertEquals(c5.CreatedDate, c5.EntranceCriteria_Matched_Date__c, 'Entrance Criteria matches');    		
    	//System.assertEquals(cadContactCUSTOM.Id, c5.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');
       
	    }
    
          	

    
    @isTest 
    static void contactNotMatchesEntryCustomCriterionTest() {
		
    	Contact c6= new Contact();
    	c6.FirstName='demoname';
        c6.LastName='demoname';
        c6.Department='IT';
        insert c6;
        Test.startTest();
        cadContactCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
    	update cadContactCUSTOM;
    	Test.stopTest();
    	
    	CadenceService.setParticipantsActivation(cadContactCUSTOM.Id,true);  	
    	c6 = [Select Id, Cadence_Id__c from Contact where Id = :c6.Id];
    	System.assertEquals(null, c6.Cadence_Id__c, 'Cadence lookup will not populate as its criterion not matches');
        }
}