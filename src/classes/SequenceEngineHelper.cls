public class SequenceEngineHelper {
    
    public static Map<Id, Set<Id>> getSequenceHistory()
    {
    	Map<Id, Set<Id>> participantIdToSequenceIdSetMap;
    	
    	return participantIdToSequenceIdSetMap;
    } 
    
    public static List<SObject> unAssociateParticipants(List<SObject> participantList)
    {
    	return participantList;
    }
    
    public static void deleteUnPerformedParticipantActions(List<SObject> participantList)
    {
    	 
    }
    
    public static List<SObject> removeChildListItemsFromParentList(List<SObject> parentList, List<Sobject> childList)
    {    	
    	for(Integer index = 0; index < childList.size(); index++)
    	{
		   if(parentList.contains(childList.get(index)))
    		{
    		   parentList.remove(index);
    		}
    	}    	
    	return parentList; 	
    }    
    
    public static Map<Id, Cadence__c> getSequenceMap(List<string> participantType)
    {
    	return new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c WHERE Status__c = true AND Record_Type__c in : participantType]);
    }
    
    /**
    * Name: getParticipantListToCreateParticipantActions
    * Desc: Method to get participant list for which Participant Actions are not created 
    * @param:  (1) participantList - List<SObject> - List of Contact or Lead records
    * 		   (2) sequenceIdToSequenceMap - Map<Id, Cadence__c> - sequence Id to Sequence record (with sequence actions) list map
    * 		   (3) participantType - String - object Type (Lead/Contact)
    * @return: List<SObject> - participant list for which Participant Actions are not created
    **/
    public static List<SObject> getParticipantListToCreateParticipantActions(List<SObject> participantList, Map<Id, Cadence__c> sequenceIdToSequenceMap, 
    																					String participantType) {
	   	Map<Id,Set<Id>> participantIdToSequenceActionIdSetMap = getParticipantIdToSequenceActionIdSetMap(participantList);
	   	Map<Id, Set<Id>> sequenceIdToSequenceActionIdSetMap = new Map<Id, Set<Id>>();
	   	for(Id sequenceId : sequenceIdToSequenceMap.keySet()) {
	   		if(sequenceIdToSequenceMap.get(sequenceId).CadenceActions__r != null) {
	   			sequenceIdToSequenceActionIdSetMap.put(sequenceId, new Set<Id>());
	   			for(CadenceAction__c sequenceAction : sequenceIdToSequenceMap.get(sequenceId).CadenceActions__r) {
	   				sequenceIdToSequenceActionIdSetMap.get(sequenceId).add(sequenceAction.Id);
	   			}
	   		}
	   	}
	   	
	   	List<SObject> requiredParticipantList = new List<SObject>();
	   	for(SObject participant: participantList) {
	   		Set<Id> participantSequenceActionIdSet = participantIdToSequenceActionIdSetMap.containsKey(participant.Id) ? participantIdToSequenceActionIdSetMap.get(participant.Id) 
	   												: new Set<Id>();
	   		Set<Id> SequenceActionIdSet;
	   		 
	   		if(participantType == 'Contact') {
	   			Contact contactRecord = (Contact)participant;
	   			SequenceActionIdSet = sequenceIdToSequenceActionIdSetMap.containsKey(contactRecord.Cadence_ID__c) ? sequenceIdToSequenceActionIdSetMap.get(contactRecord.Cadence_ID__c)
	   									: new Set<Id>(); 
	   		} else {
	   			Lead leadRecord = (Lead)participant;
	   			SequenceActionIdSet = sequenceIdToSequenceActionIdSetMap.containsKey(leadRecord.Cadence_ID__c) ? sequenceIdToSequenceActionIdSetMap.get(leadRecord.Cadence_ID__c)
	   									: new Set<Id>(); 
	   		}
	   		
   			if(!participantSequenceActionIdSet.equals(SequenceActionIdSet)) {
   				requiredParticipantList.add(participant);
   			}
	   	}
	   	return requiredParticipantList;
	}
	
	
    /**
    * Name: getParticipantIdToSequenceActionIdSetMap
    * Desc: Method to get participant id and related Participant action's parent sequence action's id set 
    * @param:  (1) participantList - List<SObject> - List of Contact or Lead records
    * @return: Map<Id,Set<Id>> - participant Id To Participant action's parent sequence action's id set Map
    **/
    private static Map<Id,Set<Id>> getParticipantIdToSequenceActionIdSetMap(List<SObject> participantList) {
	   	Map<Id,Set<Id>> participantIdToSequenceActionIdSetMap = new Map<Id,Set<Id>>();
	   	List<Sequence_Action__c> participantActions = [SELECT Contact_Id__c, Lead_Id__c, CadenceAction_ID__c FROM Sequence_Action__c 
	   										WHERE Contact_Id__c IN: participantList OR Lead_Id__c IN: participantList];
	   	
	   	Id participantId = null;
	   	
	   	for(Sequence_Action__c participantAction :participantActions) {
	   		participantId = (String.isNotBlank(participantAction.Contact_Id__c)) ? participantAction.Contact_Id__c : 
	   							(String.isNotBlank(participantAction.Lead_Id__c) ? participantAction.Lead_Id__c : null); 
	   	
		    if(participantId != null ) {
		    	if(!participantIdToSequenceActionIdSetMap.containsKey(participantId)) {
			    	participantIdToSequenceActionIdSetMap.put(participantId, new Set<Id>());
			   	} 
		    	participantIdToSequenceActionIdSetMap.get(participantId).add(participantAction.CadenceAction_ID__c);
		    }
	   	}
	   	return participantIdToSequenceActionIdSetMap;
	}
	
	public static Map<Id, List<Sequence_Action__c>> getRemainingParticipantAction(List<SObject> participantList, String participantType) 
	{	    
	    Map<Id, SObject> participantMap = new Map<Id, SObject>(participantList);
	    
	    Set<Id> participantIds = participantMap.keySet();
	    
	    Map<Id, List<Sequence_Action__c>> participantIdToSequenceActionsList = new Map<Id, List<Sequence_Action__c>>();
        
        //Getting all the available and unperformed action for object
        List<Sequence_Action__c> participantActions = new List<Sequence_Action__c>();            
        
        participantActions = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c,Opportunity_Id__c,Cadence_Type__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c, CadenceAction_Id__r.Action_Id__r.Email_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                  CadenceAction_Id__r.Index__c, Expected_Execution_Date__c, Actual_Execution_Date__c From Sequence_Action__c 
                                  where (Lead_Id__c IN :participantIds OR Contact_Id__c IN : participantIds) AND CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = : participantType AND isActionPerformed__c = false AND isDeferred__c = false 
                                  order by CadenceAction_Id__r.Index__c];
       
        for(Sequence_Action__c participantAction : participantActions) {
            if(participantAction.Lead_Id__c == null && participantAction.Contact_Id__c == null) {
                continue;
            }
			
            if(participantAction.Lead_Id__c == null) {
                if(!participantIdToSequenceActionsList.containsKey(participantAction.Contact_Id__c)) {
                    participantIdToSequenceActionsList.put(participantAction.Contact_Id__c, new List<Sequence_Action__c>{participantAction});	    
                } else {
                    participantIdToSequenceActionsList.get(participantAction.Contact_Id__c).add(participantAction);
                }	    
            } else {
                if(!participantIdToSequenceActionsList.containsKey(participantAction.Lead_Id__c)) {
                    participantIdToSequenceActionsList.put(participantAction.Lead_Id__c, new List<Sequence_Action__c>{participantAction});    
                } else {
                    participantIdToSequenceActionsList.get(participantAction.Lead_Id__c).add(participantAction);
                }
            }
        }
        return participantIdToSequenceActionsList;
	}
}