public class PerformCadenceActionBatchHelper {
   public static String formQuery(String participantType){
		if(participantType == CadenceConstants.CONTACT_OBJECT_NAME) {
			return formContactSelectQuery(getParticipantTypeToParentObjectListMap().get(CadenceConstants.CONTACT_OBJECT_NAME));
		} else if(participantType == CadenceConstants.LEAD_OBJECT_NAME) {
			return formLeadSelectQuery(getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME));
		} else if(participantType == CadenceConstants.OPPORTUNITY_OBJECT_NAME) {
			return formOpportunityContactSelectQuery(new list<String>());
		}
		return '';
	} 
	
	private static String formContactSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		for(Schema.SObjectField contactField : contactFieldList) {
			query += contactField.getDescribe().getname() + ',';
		}
		
		List<Schema.SObjectField> parentObjectFieldList;
		for(String parentObjectName : participantTypeToParentObjectList) {
			parentObjectFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, parentObjectName);
		
			for(Schema.SObjectField parentObjectField : parentObjectFieldList) {
				query += parentObjectName + '.' + parentObjectField.getDescribe().getname() + ',';
			}
		}
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE Cadence_ID__c != null AND Opportunity_Id__c = null';
		return query;
	}
	
	private static String formLeadSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> leadFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
		
		for(Schema.SObjectField leadField : leadFieldList) {
			query += leadField.getDescribe().getname() + ',';
		}
		
		List<Schema.SObjectField> parentObjectFieldList;
		for(String parentObjectName : participantTypeToParentObjectList) {
			parentObjectFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, parentObjectName);
		
			for(Schema.SObjectField parentObjectField : parentObjectFieldList) {
				query += parentObjectName + '.' + parentObjectField.getDescribe().getname() + ',';
			}
		}
		
		query = query.subString(0, query.length() - 1);
		query += ' From Lead WHERE Cadence_ID__c != null';
		return query;
	}
	
	private static String formOpportunityContactSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		for(Schema.SObjectField contactField : contactFieldList) {
			query += contactField.getDescribe().getname() + ',';
		} 
		
		List<Schema.SObjectField> parentObjectFieldList;
		for(String parentObjectName : participantTypeToParentObjectList) {
			parentObjectFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, parentObjectName);
		
			for(Schema.SObjectField parentObjectField : parentObjectFieldList) {
				query += parentObjectName + '.' + parentObjectField.getDescribe().getname() + ',';
			}
		}
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE Cadence_ID__c != null AND Opportunity_Id__c != null';
		return query;
	}
	
	private static List<Schema.SObjectField> getFieldListFromGlobalDescribedSchemaMap(Map <String, Schema.SObjectType> globalDescribedSchemaMap, String objectName) {
		List<Schema.SObjectField> fieldList = globalDescribedSchemaMap.get(objectName).getDescribe().fields.getMap().values();
		return fieldList;
	}
	
	private static Map<String, list<String>> getParticipantTypeToParentObjectListMap() {
		Map<String, list<String>> participantTypeToParentGroupsListMap = new Map<String, list<String>>{
																										CadenceConstants.CONTACT_OBJECT_NAME => new list<String>(),
																										CadenceConstants.LEAD_OBJECT_NAME => new list<String>(),
																										 CadenceConstants.OPPORTUNITY_OBJECT_NAME => new list<String>()
																									  };
		
		participantTypeToParentGroupsListMap.get(CadenceConstants.CONTACT_OBJECT_NAME).add(CadenceConstants.ACCOUNT_OBJECT_NAME);
		participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.ACCOUNT_OBJECT_NAME);
		
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		if(globalDescribedSchemaMap.get(CadenceConstants.DB_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.LEAD_OBJECT_NAME).add(CadenceConstants.DB_OBJECT_NAME);
		} 
		
		if(globalDescribedSchemaMap.get(CadenceConstants.CONTRACT_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.CONTRACT_OBJECT_NAME);
		}
		
		if(globalDescribedSchemaMap.get(CadenceConstants.PRICE_BOOK_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.PRICE_BOOK_OBJECT_NAME);
		}	
		return participantTypeToParentGroupsListMap;
	}
}