public class Contacts  extends SObjectDomain {
    
    List<Contact> contsWithCadence;
    List<Contact> contsWithoutCadence;
    List<Contact> records;
    public static boolean flag = true;
    
    public Contacts(List<Contact> sObjectList) {
        super(sObjectList);
        records = (List<Contact>)sObjectList;
        Map<String, List<Contact>> contList = CadenceService.processObjectList(sObjectList);
        contsWithCadence = contList.get('contactListWithCadenceIds');
        contsWithoutCadence = contList.get('contactListWithoutCadenceIds');
    }
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new Contacts(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
    	Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(CadenceConstants.CONTACT_OBJECT_NAME);
        for(Contact contObj: (List<Contact>)contsWithoutCadence) {
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, contObj, CadenceConstants.CONTACT_OBJECT_NAME);
        }
    }
    
    public override void onAfterInsert() {
    	Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(CadenceConstants.CONTACT_OBJECT_NAME);
    	Map<Id, List<CadenceAction__c>> contIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();
    	
		//Creating action on participants 
		for(Contact cObj : contsWithCadence) {
			contIdToAllCadActListMap.put(cObj.Id, cadMap.get(cObj.Cadence_Id__c).CadenceActions__r);
		}
		Map<Id, Contact> contMap = new Map<Id, Contact>(contsWithCadence);
        CadenceService.createActionParticipants(contIdToAllCadActListMap, CadenceConstants.CONTACT_OBJECT_NAME); 

		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantActions(contMap.keySet(), CadenceConstants.CONTACT_OBJECT_NAME);
		
		//Getting participant action to perform 
		for(Contact cObj : contMap.values()) {
			if(cObj.isActivated__c) {
				List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(cObj.Cadence_Id__c), cObj, partActionsMap.get(cObj.Id), CadenceConstants.CONTACT_OBJECT_NAME);
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
		
		if(contsToUpdate != null && !contsToUpdate.isEmpty()) {
        	update contsToUpdate; 
        }

    }
    
    public override void onbeforeUpdate(Map<Id,SObject> existingRecords){
    	
		if(!flag) {
			return;
		}
		Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(CadenceConstants.CONTACT_OBJECT_NAME);
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();

		//Getting leadList to process
		Map<Id, Contact> contMap = new Map<Id, Contact>((List<Contact>)CadenceService.getSObjectsToProcess(records, cadMap, CadenceConstants.CONTACT_OBJECT_NAME));
		
		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantActions(contMap.keySet(), CadenceConstants.CONTACT_OBJECT_NAME);
		
		//Getting participant action to perform 
		for(Contact cObj : contMap.values()) {
			if(cObj.isActivated__c) {
				List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(cObj.Cadence_Id__c), cObj, partActionsMap.get(cObj.Id), CadenceConstants.CONTACT_OBJECT_NAME);
				if(!partActList.isEmpty()) {
					partActToPerform.put(cObj.Id, partActList);		
				}
			} 		
		}

		//perform participant actions 
		Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(contMap.values(), partActToPerform);
		
		//perform participant field update
		CadenceService.updateSObjectFields(contMap.values(), performedPartAct, CadenceConstants.CONTACT_OBJECT_NAME, false);
    	
     }
    
    public override void onafterUpdate(Map<Id,SObject> existingRecords){
  
    }
    
}