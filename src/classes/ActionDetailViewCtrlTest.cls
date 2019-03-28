@isTest
public class ActionDetailViewCtrlTest {
    
    public static Lead testLead;
    public static Contact testContact;
    public static Cadence__c cadenceLead;
    public static Cadence__c cadenceContact;
    public static Action__c action1;
    public static Action__c action2;
    public static CadenceAction__c cadenceActionLead;
    public static CadenceAction__c cadenceActionContact;
    public static Account testAccount;
    
    //Constants 
    Public static Final String ACTION_TYPE_CALL = 'Call';
    Public static Final String ACTION_TYPE_SMS = 'SMS';
    Public static Final String RECORD_TYPE_CONTACT = 'Contact';
    Public static Final String RECORD_TYPE_LEAD = 'Lead';
    
    static {
        
        //for cadence on object type Lead
        action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
        insert action1;
        cadenceLead = TestDataFactory.createCadence(RECORD_TYPE_LEAD);
        insert cadenceLead;
        cadenceActionLead = TestDataFactory.createCadenceAction(cadenceLead.Id, action1.Id);
        insert cadenceActionLead;
        testLead = TestDataFactory.createLead(cadenceLead.Id);
        testLead.isActivated__c=true; //to test toggle participant activation
        insert testLead;
        
        //for cadence on object type contact        
        cadenceContact = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
        insert cadenceContact;
        testAccount = TestDataFactory.createAccount();
        insert testAccount;
        testContact = TestDataFactory.createContact(testAccount.Id, cadenceContact.Id);
        testContact.Priority__c=5;
        insert testContact; 
        testContact.isActivated__c=false; //to test toggle participant activation
        action2 = TestDataFactory.createAction(ACTION_TYPE_SMS);
        insert action2;
        cadenceActionContact = TestDataFactory.createCadenceAction(cadenceContact.Id, action2.Id);
        insert cadenceActionContact; 
        
    }
    
    @isTest
    static void fetchCadenceActionsTest() {
        
        ActionDetailViewCtrl.ActionDetailWrapper actionWrapperLead, actionWrapperContact, actionWrapperInactive;
        
        //fetch action wrapper which will include action, its associated participants and cadence
        Test.startTest();
        
        actionWrapperLead = ActionDetailViewCtrl.getActionData(action1.Id);
        actionWrapperContact = ActionDetailViewCtrl.getActionData(action2.Id);
        
        Test.stopTest();    
        
        System.assertEquals(action1.Id, actionWrapperLead.action.Id);
        System.assertNotEquals(null, actionWrapperLead.participantList);
        System.assertEquals(1, actionWrapperLead.participantList.size());
        System.assertEquals(1, actionWrapperLead.cadWrapper.size());
        
        System.assertEquals(action2.Id, actionWrapperContact.action.Id);
        System.assertNotEquals(null, actionWrapperContact.participantList);
        System.assertEquals(1, actionWrapperContact.participantList.size());
        System.assertEquals(1, actionWrapperContact.cadWrapper.size());
        
    }
    
    
    
    @isTest
    static void getCadenceParticipantsDataTest() {
        
        //create new contact for cadenceContact to increase particiapnts
        Contact contact2 = TestDataFactory.createContact(testAccount.Id, cadenceContact.Id);
        insert contact2;
        List<ActionDetailViewCtrl.ParticipantWrapper> leadWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
        List<ActionDetailViewCtrl.ParticipantWrapper> contactWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
        List<ActionDetailViewCtrl.ParticipantWrapper> nullWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
        
        Test.startTest();
        //fetch participants for cadenceLead
        leadWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(cadenceLead.Id);
        //fetch participants for cadenceContact
        contactWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(cadenceContact.Id);
        //check for null cadence Id
        nullWrapper=ActionDetailViewCtrl.getCadenceParticipantsData(null);
        Test.stopTest();
        
        System.assertEquals(1, leadWrapper.size());
        System.assertEquals(2, contactWrapper.size());
        System.assertEquals(true,nullWrapper==null);
        
    }
    
    @isTest
    static void togglePartActivationTest() {
        
        List<ActionDetailViewCtrl.ParticipantWrapper> leadWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
        List<ActionDetailViewCtrl.ParticipantWrapper> contactWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
        
        Test.startTest();
        //fetch participants wrapper
        leadWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(cadenceLead.Id);
        contactWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(cadenceContact.Id);
        //toggle participants activation 
        ActionDetailViewCtrl.togglePartActivation(JSON.serialize(leadWrapper));
        ActionDetailViewCtrl.togglePartActivation(JSON.serialize(contactWrapper));
        
        Test.stopTest();
        
        //fetch updated data
        testLead=[SELECT isActivated__c FROM Lead WHERE Id = :testLead.Id];
        testContact=[SELECT isActivated__c FROM Contact WHERE Id = :testContact.Id];
        
        System.assertEquals(false, testLead.isActivated__c);
        System.assertEquals(true, testContact.isActivated__c);
    }
    
    
}