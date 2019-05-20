@isTest
public class sequenceHistoryCheckTest {
    
    public static Integer size = 0;
	
    @testSetup
	static void testSetupData() {
		List<Participant_Sequence_History__c> lstSequenceHistory = createSequenceHistory();
        size = lstSequenceHistory.size();
	}
    
    public static List<Participant_Sequence_History__c> createSequenceHistory()
    {        
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = new List<Contact>();
        
        Lead lead = new Lead(LastName='TestLead1', Company = 'TestCompany1', Status ='TestStatus1');
        leadList.add(lead);
        lead = new Lead(LastName='TestLead2', Company = 'TestCompany2', Status ='TestStatus2');
        leadList.add(lead);
        lead = new Lead(LastName='TestLead3', Company = 'TestCompany3', Status ='TestStatus3');
        leadList.add(lead);
        lead = new Lead(LastName='TestLead4', Company = 'TestCompany4', Status ='TestStatus4');
        leadList.add(lead);
        
        Contact contact = new Contact(LastName='TestContact1');
        contactList.add(contact);
        contact = new Contact(LastName='TestContact2');
        contactList.add(contact);
        
        List<Participant_Sequence_History__c> participantSequenceHistory = new List<Participant_Sequence_History__c>();
        
        Integer count =0;
        for(Lead lead1 : leadList)
        {
            participantSequenceHistory.add(new Participant_Sequence_History__c(Lead_Id__c = lead1.Id, Contact_Id__c = contactList[count].Id));
        }       
        system.debug(participantSequenceHistory);
        return participantSequenceHistory;
    }
    
    @isTest static void testHistory() {
		test.startTest();
		LeadService testLeadService = new LeadService();
        Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = testLeadService.getSequenceHistory();
        system.debug(participantIdToSequenceIdHistorySetMap);
        System.assertEquals(size, participantIdToSequenceIdHistorySetMap.size());
        test.stopTest();
	}
}