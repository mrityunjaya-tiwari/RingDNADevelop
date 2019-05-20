public class opportunities extends SObjectDomain {
    List<Opportunity> records = new List<Opportunity>();
	public static boolean fireTrigger = true;

	public opportunities(List<Opportunity> sObjectList) {
		super(sObjectList);
		records = (List<Opportunity>)sObjectList;
	}

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> sObjectList) {
			return new opportunities(sObjectList);
		}
	}
    
    public override void onAfterInsert(){
        if (shouldTriggerFire()){
            startSequenceEngine();
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if (shouldTriggerFire()){
            startSequenceEngine();
        }        
    }
    
    boolean shouldTriggerFire(){
        return fireTrigger;
    }
    
    private void startSequenceEngine(){
        Map<Id, SObject> contactIdopportunityMap = New Map<Id, SObject>(records);
        Set<Id> opportunityIdSet = contactIdopportunityMap.keyset();
        String query = formOpportunityContactSelectQuery(opportunityIdSet) ;
        List<Opportunity> opportunityList = Database.query(query);
        List<SObject> participantList = getContactsRelatedToOpportunities(opportunityList);
        system.debug('participantList ' + participantList);
        system.debug('opportunityList ' + opportunityList);
        SequenceEngine.processSequences(CadenceConstants.OPPORTUNITY_OBJECT_NAME, participantList, opportunityList, true);
    }
    
    private static String formOpportunityContactSelectQuery(Set<Id> opportunityIdSet) {
		List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
        String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> opportunityFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Opportunity');
		
		query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, opportunityFieldList, participantTypeToParentObjectList);
		
		query += ' (Select ContactId, OpportunityId, Role From OpportunityContactRoles)';
		query += ' From Opportunity WHERE Id IN :opportunityIdSet' ;
		return query;
	}
    
    Private static List<Contact> getContactsRelatedToOpportunities(List<Opportunity> opportunityList) {
		List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.CONTACT_OBJECT_NAME);
		
		Set<Id> contactIdSet = new Set<Id>();
		for(Opportunity opportunity : opportunityList) {
			if(opportunity.OpportunityContactRoles != null) {
				for(OpportunityContactRole opportunityContactRole : opportunity.OpportunityContactRoles) {
					contactIdSet.add(opportunityContactRole.ContactId);
				}
			}
		}
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE ID IN: contactIdSet Limit ' + SequenceEngineHelper.getAvailableQueryRowsLimit();
		return DataBase.query(query);
	}
}