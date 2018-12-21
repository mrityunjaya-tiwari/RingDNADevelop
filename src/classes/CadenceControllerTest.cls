@isTest
private class CadenceControllerTest {
    
    public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
    
    public static testMethod void testCadenceQuery(){
    	Cadence__c cadenceRecord = TestDataFactory.createCadence('Lead');
        Test.startTest();
    	insert cadenceRecord;
    	CadenceController.getCadenceDetail(cadenceRecord.Id);
        Test.stopTest();
      
    }
    @isTest
    public static void getFieldsTest(){
        Contact c1= new Contact();
        c1.FirstName='fname';
        c1.LastName='lname';
        c1.Department='IT';
        insert c1;
        Test.startTest();
        CadenceController.getFields('Contact');
        Test.stopTest();       
    }
   @isTest
    public static void activateCadenceTest(){
      Cadence__c cadenceobj = TestDataFactory.createCadence('Lead');
    	insert cadenceobj;  
        cadenceobj.Status__c=true;
        upsert cadenceobj;
        Test.startTest();
        CadenceController.activateCadence(cadenceobj.Id);
        CadenceController.updateParticipants(cadenceobj.Id);
        Test.stopTest();
        cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
        System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
    } 
    @isTest
    public static void deactivateCadenceTest(){
        Cadence__c cadenceobj2 = TestDataFactory.createCadence('Lead');
    	insert cadenceobj2;  
        cadenceobj2.Status__c=false;
        upsert cadenceobj2;
        Test.startTest();
        CadenceController.deactivateCadence(cadenceobj2.Id);
        Test.stopTest();
        cadenceobj2=[select Id, Status__c from Cadence__c where id =: cadenceobj2.Id];
        System.assertEquals(False, cadenceobj2.Status__c, 'Cadence deactivated');
    }
    
    @isTest
    static void getCadenceDataTest() {
        Cadence__c cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
        String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
    	cadLeadAND.Entrance_Criteria__c = entryJson;
        cadLeadAND.Exit_Criteria__c = exitJson;
        insert cadLeadAND;
		
        Test.startTest();
        CadenceController.getCadenceData(cadLeadAND.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getObjCriListTest() {
        
        Test.startTest();
        CadenceController.getObjCriList();
        Test.stopTest();
    }
    
    
}