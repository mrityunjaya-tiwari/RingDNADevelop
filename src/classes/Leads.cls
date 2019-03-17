public class Leads  extends SObjectDomain {
    
    List<Lead> leadsWithCadence;
    List<Lead> leadsWithoutCadence;
    Map<Id, Cadence__c> cadMap;
    List<Lead> records;
    public static Integer flag = 0;
    
    public Leads(List<Lead> sObjectList) { 
        super(sObjectList);
        records = (List<Lead>)sObjectList;
        Map<String, List<Lead>> leadList = CadenceService.processObjectList(sObjectList);
        leadsWithCadence = leadList.get('leadListWithCadenceIds');
        leadsWithoutCadence = leadList.get('leadListWithoutCadenceIds');
        cadMap = CadenceSelector.getActiveCadencesByRecordType(new List<String>{CadenceConstants.LEAD_OBJECT_NAME});
        CadenceService.processParticipantActivation(cadMap, leadsWithCadence, CadenceConstants.LEAD_OBJECT_NAME);
    }
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
        	return new Leads(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        Map<Id, SObject> parentMap = CadenceService.getParentObject(leadsWithoutCadence, CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME, CadenceConstants.DB_OBJECT_NAME); 
        for(Lead leadObj: (List<Lead>) leadsWithoutCadence) {
            SObject parentObj;
			
			if(leadObj.ringdna100__Call_Attempts__c == null){
                leadObj.ringdna100__Call_Attempts__c=0;
            }
            if(leadObj.ringdna100__Email_Attempts__c == null){
                leadObj.ringdna100__Email_Attempts__c=0;
            }
            
            if(leadObj.ringdna100__Message_Attempts__c == null){
                leadObj.ringdna100__Message_Attempts__c=0;
            }
            if(leadObj.RDNACadence__NumberofLocations__c == null){
                leadObj.RDNACadence__NumberofLocations__c=0;
            }
            if(leadObj.NumberOfEmployees == null){
                leadObj.NumberOfEmployees=0;
            }
            if(leadObj.AnnualRevenue == null){
                leadObj.AnnualRevenue=0;
            }
            
			
            if(!parentMap.isEmpty() && leadObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME) != null) {
	            parentObj = parentMap.get((Id)leadObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME));
            }
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, leadObj, parentObj, CadenceConstants.LEAD_OBJECT_NAME);
        } 
    }
    
    public override void onAfterInsert() {
		Map<Id, List<CadenceAction__c>> leadIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
		Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();
        
		//Creating action on participants 
		for(Lead lObj : leadsWithCadence) {
            if(lObj.isActivated__c) {
				leadIdToAllCadActListMap.put(lObj.Id, cadMap.get(lObj.Cadence_Id__c).CadenceActions__r);
            }
		}
		Map<Id, Lead> leadMap = new Map<Id, Lead>(leadsWithCadence);
        CadenceService.createActionParticipants(leadIdToAllCadActListMap, leadMap, CadenceConstants.LEAD_OBJECT_NAME); 

        Map<Id, SObject> parentMap = CadenceService.getParentObject(leadsWithoutCadence, CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME, CadenceConstants.DB_OBJECT_NAME);
        
		//Getting non performed participant actions 
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantAction(leadMap.keySet(), CadenceConstants.LEAD_OBJECT_NAME);
		
		//Getting participant action to perform 
		for(Lead lObj : leadMap.values()) {
            if(partActionsMap.get(lObj.Id) == null) {
                continue;
            }
            Sequence_Action__c sa = partActionsMap.get(lObj.Id).get(0);
			if(lObj.isActivated__c && sa.Show_on_Target_List__c == false) {
				SObject parentObj;
        	    if(!parentMap.isEmpty() && lObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME) != null) {
		            parentObj = parentMap.get((Id)lObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME));
	            }
                List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get(lObj.Cadence_Id__c), lObj, parentObj, new List<Sequence_Action__c>{sa}, CadenceConstants.LEAD_OBJECT_NAME);
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
        
        //Updating dates on remaining participant objects
        List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
        for(Id objId : performedPartAct.keySet()) {
            for(Sequence_Action__c sa : performedPartAct.get(objId)) {
                System.debug('SA:'+sa);
                //if(sa.Actual_Execution_Date__c != null){
                	saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, partActionsMap.get(sa.Lead_Id__c)));    
                //}
            }
        }
        
		if(leadsToUpdate != null && !leadsToUpdate.isEmpty()) {
        	update leadsToUpdate; 
        }
        
        if(!saToUpdate.isEmpty()) {
            update saToUpdate;
        }
	}
    
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
		if(flag==1) {
			return;
		}
        Map<Id, SObject> objIdToParentMap = new Map<Id, SObject>();
        Map<Id, SObject> parentMap = CadenceService.getParentObject(leadsWithoutCadence, CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME, CadenceConstants.DB_OBJECT_NAME);
        for(Lead leadObj: (List<Lead>) records) {
            if(!parentMap.isEmpty() && leadObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME) != null) {
                objIdToParentMap.put(leadObj.Id, parentMap.get((Id)leadObj.get(CadenceConstants.LEAD_DB_OBJECT_FIELD_NAME)));
            }	             
        }
        CadenceService.processParticipantsWithCadences(records, parentMap, CadenceConstants.LEAD_OBJECT_NAME, true);
    }
    
    public override void onafterUpdate(Map<Id,SObject> existingRecords){

    }
    
    

  
}