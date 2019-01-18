public class Leads  extends SObjectDomain {
    
    List<Lead> leadsWithCadence;
    List<Lead> leadsWithoutCadence;
    List<Lead> records;
    public static Integer flag = 0;
    
    public Leads(List<Lead> sObjectList) { 
        super(sObjectList);
        records = (List<Lead>)sObjectList;
        Map<String, List<Lead>> leadList = CadenceService.processObjectList(sObjectList);
        leadsWithCadence = leadList.get('leadListWithCadenceIds');
        leadsWithoutCadence = leadList.get('leadListWithoutCadenceIds');
    }
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new Leads(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
    	Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(CadenceConstants.LEAD_OBJECT_NAME);
        for(Lead leadObj: (List<Lead>) leadsWithoutCadence) {
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, leadObj, CadenceConstants.LEAD_OBJECT_NAME);
        } 
    }
    
    public override void onAfterInsert() {

    	Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(CadenceConstants.LEAD_OBJECT_NAME);
    	Map<Id, List<CadenceAction__c>> leadIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();
    	
		//Creating action on participants 
		for(Lead lObj : leadsWithCadence) {
			leadIdToAllCadActListMap.put(lObj.Id, cadMap.get(lObj.Cadence_Id__c).CadenceActions__r);
		}
		Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithCadence);
        CadenceService.createActionParticipants(leadIdToAllCadActListMap, CadenceConstants.LEAD_OBJECT_NAME); 

		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantActions(leadMap.keySet(), CadenceConstants.LEAD_OBJECT_NAME);
		
		//Getting participant action to perform 
		for(Lead lObj : leadMap.values()) {
			if(lObj.isActivated__c) {
				List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(lObj.Cadence_Id__c), lObj, partActionsMap.get(lObj.Id), CadenceConstants.LEAD_OBJECT_NAME);
				if(!partActList.isEmpty()) {
					partActToPerform.put(lObj.Id, partActList);		
				}
			} 		
		}

		//perform participant actions 
		Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(leadMap.values(), partActToPerform);
		
		//perform participant field update
		List<Lead> leadsToUpdate = (List<Lead>)CadenceService.updateSObjectFields(leadMap.values(), performedPartAct, CadenceConstants.LEAD_OBJECT_NAME, true);
		flag = 1;
        
		if(leadsToUpdate != null && !leadsToUpdate.isEmpty()) {
        	update leadsToUpdate; 
        }
	
    }
    
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
		if(flag==1) {
			return;
		}
		CadenceService.processParticipantsWithCadences(records, CadenceConstants.LEAD_OBJECT_NAME, true);
    }
    
    public override void onafterUpdate(Map<Id,SObject> existingRecords){

    }
  
}