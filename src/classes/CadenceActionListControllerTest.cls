@isTest
public class CadenceActionListControllerTest { 
    public static Final String ACTION_TYPE_CALL = 'Call';
    
    //Test data
    @testSetup public static void initialize(){
        
        List<Action__c> actions=new List<Action__c>();
        for(Integer actionCount=0;actionCount<3;actionCount++){
            //Create 3 actions of type Call
            actions.add(TestDataFactory.createAction(ACTION_TYPE_CALL));
        }
        insert actions;
        
        //Create cadence object of object type Lead
        Cadence__c cadenceObjLead= TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        
        List<Criterion> entryCriterionListLead = new List<Criterion>(); //Entry criteria
        entryCriterionListLead.add(TestDataFactory.createCriterion(1, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
        entryCriterionListLead.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'contains', 'Test'));
        String entryCriterionLead = TestDataFactory.createCadenceJSON(entryCriterionListLead, CadenceConstants.CONDITION_OR, '');
        
        List<Criterion> exitCriterionListLead = new List<Criterion>(); //Exit criteria
        exitCriterionListLead.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
        exitCriterionListLead.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Lead'));
        String exitCriterionLead = TestDataFactory.createCadenceJSON(exitCriterionListLead, CadenceConstants.CONDITION_AND, ''); 
        
        cadenceObjLead.Entrance_Criteria__c= entryCriterionLead;
        cadenceObjLead.Exit_Criteria__c=exitCriterionLead;
        cadenceObjLead.matching_priority__c='P1';
        cadenceObjLead.Participent_Activation__c='Automatic';
        
        insert cadenceObjLead;
        
        
        //Create 3 lead objects which match entrance criteria of cadenceObjectLead
        List<Lead> leads=new List<Lead>();
        for(Integer leadCount=0;leadCount<2;leadCount++){
            leads.add(TestDataFactory.createLead(cadenceObjLead.id));
        }
        insert leads;
        
        //Create a cadence object of object type Contact and no participant will be assigned
        Cadence__c cadenceObjContact= TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
        
        List<Criterion> entryCriterionListContact = new List<Criterion>(); //Entry criteria
        entryCriterionListContact.add(TestDataFactory.createCriterion(1, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
        entryCriterionListContact.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Test'));
        String entryCriterionContact = TestDataFactory.createCadenceJSON(entryCriterionListContact, CadenceConstants.CONDITION_OR, '');
        
        List<Criterion> exitCriterionListContact = new List<Criterion>(); //Exit criteria
        exitCriterionListContact.add(TestDataFactory.createCriterion(1, 'Department', 'STRING', 'equals', 'IT'));
        exitCriterionListContact.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Test Contact'));
        String exitCriterionContact = TestDataFactory.createCadenceJSON(exitCriterionListContact, CadenceConstants.CONDITION_OR, ''); 
        
        cadenceObjContact.Entrance_Criteria__c= entryCriterionContact;
        cadenceObjContact.Exit_Criteria__c=exitCriterionContact;
        cadenceObjContact.matching_priority__c='P2';
        cadenceObjContact.Participent_Activation__c='Automatic';
        
        insert cadenceObjContact;
        
        //Create a time based cadence action for cadenceObjLead and associate 1st action 
        CadenceAction__c cadenceAction1=TestDataFactory.createCadenceAction(cadenceObjLead.Id, actions[0].Id);
        cadenceAction1.Trigger_Type__c = 'Time Based';
        cadenceAction1.Day__c=0;
        cadenceAction1.Hour__c=1;
        insert cadenceAction1;
        
        //Create immediate cadence action for cadenceObjLead and associate 2nd action 
        CadenceAction__c cadenceAction2=TestDataFactory.createCadenceAction(cadenceObjLead.Id, actions[1].Id);
        cadenceAction2.Trigger_Type__c = 'Immediate';
        insert cadenceAction2;
        
        //Create sequence actions to associate participants with cadence actions
        Sequence_Action__c sequenceAction1=new Sequence_Action__c(CadenceAction_Id__c=cadenceAction1.Id,Lead_Id__c=leads[0].Id); //for lead 1
        insert sequenceAction1;
        Sequence_Action__c sequenceAction2=new Sequence_Action__c(CadenceAction_Id__c=cadenceAction2.Id,Lead_Id__c=leads[0].Id); //for lead 1
        insert sequenceAction2;
        Sequence_Action__c sequenceAction3=new Sequence_Action__c(CadenceAction_Id__c=cadenceAction1.Id,Lead_Id__c=leads[1].Id); //for lead 2
        insert sequenceAction3;
        Sequence_Action__c sequenceAction4=new Sequence_Action__c(CadenceAction_Id__c=cadenceAction2.Id,Lead_Id__c=leads[1].Id); //for lead 2
        insert sequenceAction4;
        
    }
    
    @isTest
    public static void fetchCadenceActionsTest(){   
        
        Test.startTest();
        List<CadenceActionListController.ActionWrapper> actions=CadenceActionListController.fetchCadenceActions();
        Test.stopTest();
        System.assertEquals(3, actions.size());
        System.assertEquals(1, actions[0].cadences,'1st action is associated with 1 cadence');
        System.assertEquals(0, actions[2].cadences,'3rd action is not associated with any cadence');
        System.assertEquals(2, actions[0].participants,'1st sequence satisfies entry criteria for 2 leads created');
    }
    
    @isTest
    public static void getCadenceDataTest(){
        Test.startTest();
        List<CadenceActionListController.CadenceWrapper> cadences=CadenceActionListController.getCadenceData();
        Test.stopTest();
        System.assertEquals(2, cadences.size());
        if(cadences[0].objType=='Contact'){
            System.assertEquals(0, cadences[0].participants,'No contact is participant of any cadence');
            System.assertEquals(2, cadences[1].participants,'2 leads are associated with 1 cadence');
        }else if(cadences[0].objType=='Lead'){
            System.assertEquals(2, cadences[0].participants,'2 leads are associated with 1 cadence');
            System.assertEquals(0, cadences[1].participants,'No contact is participant of any cadence');
        }
        
    } 
    @isTest
    public static void excludedDeleteActionsTest(){
        //fetch all actions
        List<Action__c> actions=[SELECT Id FROM Action__c];
        List<Id> actionIds=new List<Id>();
        //assign action ids to list of ids
        for(Action__c action:actions){
            actionIds.add(action.Id);
        }
        Test.startTest();
        CadenceActionListController.ActionDeleteMessageWrapper deleteMessage=CadenceActionListController.ExcludedDeleteActions(actionIds);
        Test.stopTest();
        System.assertEquals(1, deleteMessage.deletedCount,'3rd action has no participants so it can be deleted');
    }
    
    @isTest
    public static void deleteActionsTest(){
        //fetch actions before deletion
        List<Action__c> actionsBeforeDelete=[SELECT Id From Action__c];
        List<Id> actionIds=new List<Id>();
        //assign action ids to list of ids
        for(Action__c action:actionsBeforeDelete){
            actionIds.add(action.Id);
        }
        Test.startTest();
        CadenceActionListController.ActionDeleteMessageWrapper deleteMessage=CadenceActionListController.deleteActions(actionIds);
        Test.stopTest();
        //fetch reamining actions
        List<Action__c> actions=[SELECT Id From Action__c];
        System.assertEquals(2, actions.size(),'1 action is deleted which does not have any participant');
    }
    
    @isTest
    public static void deleteActionOnParticipantsTest(){
        //fetch one cadence
        Cadence__c cadence=[SELECT Id From Cadence__c LIMIT 1];
        List<Id> ids=new List<Id>();
        //assign cadence id to lidt of ids
        ids.add(cadence.Id);
        Test.startTest();
        CadenceActionListController.deleteActionOnpartcipants(ids);
        Test.stopTest();
        //fetch participant by cadence id
        List<Sequence_Action__c> participants=[SELECT Id From Sequence_Action__c WHERE CadenceAction_Id__r.Cadence_Id__c=:cadence.Id];
        System.assertEquals(0, participants.size(),'All participants are deleted');
    }
    
    @isTest
    public static void deleteCadencesTest(){
        //fetch all cadences
        List<Cadence__c> cadences=[SELECT Id From Cadence__c];
        List<Id> ids=new List<Id>();
        //assign cadence ids to list of Id
        for(Cadence__c cadence:cadences){
            ids.add(cadence.Id);
        }
        Test.startTest();
        CadenceActionListController.deleteCadences(ids);
        Test.stopTest();
        //fetch remaining cadence
        List<Cadence__c> cadencesAfterDeletion=[SELECT Id From Cadence__c];
        System.assertEquals(0, cadencesAfterDeletion.size(),'All cadences are deleted');
    }
}