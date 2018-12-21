public with sharing class CadenceConstants {
    
    //Namespace for managed package
    public static final String NAMESPACE = 'RDNACadence__'; 
    
    // Object names
    public static final String CONTACT_OBJECT_NAME = 'Contact';
	public static final String LEAD_OBJECT_NAME = 'Lead';

	//cadence criterion types
    public static final String CRITERION_TYPE_ENTRY = 'Entry';
    public static final String CRITERION_TYPE_EXIT = 'Exit'; 
    
    //Cadence execution criterion 
    public static final String 	EXECUTION_CRITERION_NO_CRITERION = 'No Additional Criterion';
    public static final String 	EXECUTION_CRITERION_CONDITION_MATCHES = 'Conditions are met';

	//Cadence conditions for criterions 
	public static final String CONDITION_AND = 'All of the conditions are met (AND)';
	public static final String CONDITION_OR = 'Any of the conditions are met (OR)';
	public static final String CONDITION_CUSTOM = 'Custom Logic';
	
	//Cadence Participent Activation 
	public static final String PARTICIPANT_ACTIVATION_MANUAL = 'Manual';  
	public static final String PARTICIPANT_ACTIVATION_AUTOMATIC = 'Automatic';
	
	public static final String MULTIPLE_CADENCE_MATCHES_ERROR = 'Multiple cadence matches found for this record';
	
	//Cadence Action Trigger type - 
	public static final String CADENCE_ACTION_TRIGGER_TYPE_IMMEDIATE = 'Immediate';
	public static final String CADENCE_ACTION_TRIGGER_TYPE_TIME_BASED = 'Time Based';

	//Action types - 
	public static final String ACTION_TYPE_TASK = 'Task';
	public static final String ACTION_TYPE_EMAIL = 'Email';
	public static final String ACTION_TYPE_CALL = 'Call';
	public static final String ACTION_TYPE_CALL_VOICEMAIL = 'Call+Voicemail';
	public static final String ACTION_TYPE_SMS = 'SMS';
	
	//Task status 
	public static final String COMPLETED = 'Completed';
	public static final String MISSED = 'Missed';
	public static final String CONNECTED = 'Connected';
    
    public static string leadQueryString = 'Select Id,IsDeleted,MasterRecordId,LastName,FirstName,Salutation,Name,Title,Company,Street,City,State,PostalCode,Country,Latitude,Longitude,GeocodeAccuracy,Address,Phone,MobilePhone,Fax,Email,Website,PhotoUrl,Description,LeadSource,Status,Industry,Rating,AnnualRevenue,NumberOfEmployees,OwnerId,IsConverted,ConvertedDate,ConvertedAccountId,ConvertedContactId,ConvertedOpportunityId,IsUnreadByOwner,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastViewedDate,LastReferencedDate,Jigsaw,JigsawContactId,CleanStatus,CompanyDunsNumber,DandbCompanyId,EmailBouncedReason,EmailBouncedDate,RDNACadence__SICCode__c,RDNACadence__ProductInterest__c,RDNACadence__Primary__c,RDNACadence__CurrentGenerators__c,RDNACadence__NumberofLocations__c,RDNACadence__Cadence_Id__c,RDNACadence__EntranceCriteria_Matched_Date__c,RDNACadence__isActivated__c,RDNACadence__CadencePerformed__c,RDNACadence__CadenceAssignmentError__c,RDNACadence__Priority__c FROM Lead';
}