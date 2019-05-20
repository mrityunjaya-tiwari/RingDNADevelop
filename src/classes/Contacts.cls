public class Contacts  extends SObjectDomain {

	List<Contact> contsWithCadence;
	List<Contact> contsWithoutCadence;
	List<Contact> records;
	public static boolean flag = true;
	Map<Id, Cadence__c> cadMap;
	map<string,List<String>> mapOfOpportunityContactIds= new map<String,List<string>>();

	public Contacts(List<Contact> sObjectList) {
		super(sObjectList);
		records = (List<Contact>)sObjectList;
		Map<String, List<Contact>> contList = CadenceService.processObjectList(sObjectList);
		contsWithCadence = contList.get('contactListWithCadenceIds');
		contsWithoutCadence = contList.get('contactListWithoutCadenceIds');
		cadMap = CadenceSelector.getActiveCadencesByRecordType(New List<String>{CadenceConstants.CONTACT_OBJECT_NAME,CadenceConstants.OPPORTUNITY_OBJECT_NAME});
		CadenceService.processParticipantActivation(cadMap, contsWithCadence, CadenceConstants.CONTACT_OBJECT_NAME);
		mapOfOpportunityContactIds = CadenceService.getOpportunityOrContactMap(records);
	}

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> sObjectList) {
			return new Contacts(sObjectList);
		}
	}
    public override void onBeforeInsert() {        
        Set<Id> accountIds = new Set<Id>();
        for(Contact contObj : (List<Contact>)contsWithoutCadence) {
            if(contObj.AccountId != null) {
                accountIds.add(contObj.AccountId);
            }
        }       
        String query = CadenceUtil.getSObjectQuery(CadenceConstants.ACCOUNT_OBJECT_NAME);
        query = query + 'Where Id in : accountIds';        
		List<Account> accList = Database.query(query);
        Map<Id, Account> accMap = new Map<Id, Account>(accList);        
    	Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(New List<String>{CadenceConstants.CONTACT_OBJECT_NAME,'Opportunity'});
        for(Contact contObj: (List<Contact>)contsWithoutCadence) {
			Account parentObj;
            if(contObj.AccountId != null) {
	            parentObj = accMap.get(contObj.AccountId);
            }
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, contObj, parentObj, CadenceConstants.CONTACT_OBJECT_NAME);
        }
    }
	public override void onAfterInsert() {
		Set<Id> accountIds = new Set<Id>();
		Map<Id, List<CadenceAction__c>> contIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();

		//Creating action on participants 
		for(Contact cObj : contsWithCadence) {
			if(cObj.isActivated__c) {
				if(cadMap.containsKey(cObj.Cadence_Id__c)) {
					contIdToAllCadActListMap.put(cObj.Id, cadMap.get(cObj.Cadence_Id__c).CadenceActions__r);
				}
			}
			if(cObj.AccountId != null) {
				accountIds.add(cObj.AccountId);
			}

			if( cObj.Sequence_Type__c == CadenceConstants.OPPORTUNITY_OBJECT_NAME && (cObj.Opportunity_Id__c == null ||  String.isBlank(cObj.Opportunity_Id__c))){
				cObj.Opportunity_Id__c = CadenceService.GetOpportunityIdByContactId(mapOfOpportunityContactIds,cObj.Id);
			}
		}

		String query = CadenceUtil.getSObjectQuery(CadenceConstants.ACCOUNT_OBJECT_NAME);
		query = query + 'Where Id in : accountIds';

		List<Account> accList = Database.query(query);
		Map<Id, Account> accMap = new Map<Id, Account>(accList);

		Map<Id, Contact> contMap = new Map<Id, Contact>(contsWithCadence);

		CadenceService.createActionParticipants(contIdToAllCadActListMap, new Map<Id, SObject>(contsWithCadence), CadenceConstants.CONTACT_OBJECT_NAME); 

		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantAction(contMap.keySet(), CadenceConstants.CONTACT_OBJECT_NAME);

		//Getting participant action to perform 
		for(Contact cObj : contMap.values()) {
			if(partActionsMap.get(cObj.Id) == null) {
				continue;
			}
			Sequence_Action__c sa = partActionsMap.get(cObj.Id).get(0);
			if(cObj.isActivated__c && sa.Show_on_Target_List__c == false) {
				Account parentObj;
				if(cObj.AccountId != null) {
					parentObj = accMap.get(cObj.AccountId);
				}
				List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(cObj.Cadence_Id__c), cObj, parentObj, new List<Sequence_Action__c>{sa}, CadenceConstants.CONTACT_OBJECT_NAME);
				if(!partActList.isEmpty()) {
					partActToPerform.put(cObj.Id, partActList);		
				}
			} 		
		}

		//perform participant actions 
		Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(contMap.values(), partActToPerform);

		//perform participant field update
		flag = false;
		List<Contact> contsToUpdate = (List<Contact>)CadenceService.updateSObjectFields(contMap.values(), performedPartAct, CadenceConstants.CONTACT_OBJECT_NAME, true);

		//Updating dates on remaining participant objects
		List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
		for(Id objId : performedPartAct.keySet()) {
			for(Sequence_Action__c sa : performedPartAct.get(objId)) {
				saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, partActionsMap.get(sa.Lead_Id__c)));
			}
		}

		if(!saToUpdate.isEmpty()) {
			update saToUpdate;
		}

		if(contsToUpdate != null && !contsToUpdate.isEmpty()) {
			Database.SaveResult[] results = Database.update(contsToUpdate, false);
		}

	}

	public override void onbeforeUpdate(Map<Id,SObject> existingRecords){

		if(!flag) {
			return;
		}
		Map<Id, Id> contIdToAccIdMap = new Map<Id, Id>();
		Map<Id, Account> parentMap = new Map<Id, Account>();
		Boolean IsOpportunity = false;
		for(Contact cObj: (List<Contact>) records) {
			if(cObj.AccountId != null) {
				contIdToAccIdMap.put(cObj.Id, cObj.AccountId);
			}
			if(cObj.Opportunity_Id__c != null && !String.isBlank(cObj.Opportunity_Id__c)) {
				IsOpportunity = true;
			}
		}

		List<Id> accountIds = contIdToAccIdMap.values();
		String query = CadenceUtil.getSObjectQuery(CadenceConstants.ACCOUNT_OBJECT_NAME);
		query = query + 'Where Id in : accountIds';
		List<Account> accList = Database.query(query);
		Map<Id, Account> accMap = new Map<Id, Account>(accList);
		for(Contact cObj: (List<Contact>) records) {
			if(cObj.AccountId != null) {
				parentMap.put(cObj.Id, accMap.get(cObj.AccountId));
			}	             
		}
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();

		//Getting leadList to process
		ParticipantsToProcess participantsToProcess = CadenceService.getSObjectsToProcess(records, parentMap, cadMap, CadenceConstants.CONTACT_OBJECT_NAME);
        Map<Id, Contact> contMap = new Map<Id, Contact>((List<Contact>)participantsToProcess.allParticipantsToProcess);

		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap;
		if(IsOpportunity == true){
			partActionsMap = CadenceService.getRemainingParticipantAction(contMap.keySet(), CadenceConstants.OPPORTUNITY_OBJECT_NAME);    
		}else{
			partActionsMap = CadenceService.getRemainingParticipantAction(contMap.keySet(), CadenceConstants.CONTACT_OBJECT_NAME);
		}

		//Getting participant action to perform 
		for(Contact cObj : contMap.values()) {
			if(partActionsMap.get(cObj.Id) == null) {
				continue;
			}
			Sequence_Action__c sa = partActionsMap.get(cObj.Id).get(0);
			if(cObj.isActivated__c) {
				Account parentObj;
				if(cObj.AccountId != null) {
					parentObj = accMap.get(cObj.AccountId);
				}
				List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(cObj.Cadence_Id__c), cObj, parentMap.get((Id)cObj.get('Id')), new List<Sequence_Action__c>{sa}, CadenceConstants.CONTACT_OBJECT_NAME);
				if(!partActList.isEmpty()) {
					partActToPerform.put(cObj.Id, partActList) ;		
				} 
			} 		
		}

		//perform participant actions 
		Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(contMap.values(), partActToPerform);

		//Updating dates on remaining participant objects
		List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
		for(Id objId : performedPartAct.keySet()) {
			for(Sequence_Action__c sa : performedPartAct.get(objId)) {
				saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, partActionsMap.get(sa.Lead_Id__c)));
			}
		}

		if(!saToUpdate.isEmpty()) {
			update saToUpdate;
		}

		//perform participant field update
		CadenceService.updateSObjectFields(contMap.values(), performedPartAct, CadenceConstants.CONTACT_OBJECT_NAME, false);

	}
}