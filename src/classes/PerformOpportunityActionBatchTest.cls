@isTest
public class PerformOpportunityActionBatchTest {
	
    static testMethod void PerformOpportunityActionBatch() {
    	Contacts.fireTrigger = false;
    	Opportunity opp = TestDataFactory.createOpp('Test');
    	insert opp;
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		insert seqRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec;
    	OpportunityContactRole oppRol = TestDataFactory.createOpportunityRole(opp.Id,contRec.Id);
    	Test.startTest();
        DataBase.executeBatch(new PerformOpportunityActionBatch());
        Test.stopTest();
    }
}