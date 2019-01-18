public with sharing class Tasks extends SObjectDomain {
 
    List<Task> records;
    
    public Tasks(List<Task> sObjectList)
    {
        super(sObjectList);
        records = sObjectList;
    } 
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new Tasks(sObjectList);
        }
    }
     
    public override void onBeforeInsert() {
    	
        Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
    	List<Sequence_Action__c> actionToUpdate = new List<Sequence_Action__c>();
    	Map<Id, List<CadenceAction__c>> objToCadActListMap = new Map<Id, List<CadenceAction__c>>();
    	
		objToPartActMap = getAllParticipantActionsForTaskOwner((List<Task>)records);
		if(objToPartActMap == null || objToPartActMap.isEmpty()) {
			return;
		}

		//Updating performed actions
		for(Task t : (List<Task>)records) {
			
            if(t.WhoId == null || t.Subject == null || t.Sequence_Action__c != null) {
     			continue;
     		}

            String taskType = t.TaskSubtype;
			String taskSubject = t.Subject;
			if(objToPartActMap.containsKey(t.WhoId)) {
				CadenceAction__c cadAct = new CadenceAction__c();
				for(Sequence_Action__c action : objToPartActMap.get(t.WhoId)) {
                    if(action == null || action.isActionPerformed__c == true || action.Show_on_Target_List__c == false) {
						continue;
					}
					
                    String actionType = action.CadenceAction_Id__r.Action_Id__r.Type__c;
					if(taskType!=null && (actionType.equals(CadenceConstants.ACTION_TYPE_CALL) || actionType.equals(CadenceConstants.ACTION_TYPE_CALL_VOICEMAIL)) 
                       && taskType.equals(CadenceConstants.ACTION_TYPE_CALL)) {
						action.isActionPerformed__c = true;
                        t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;
					}
					
                    if(actionType.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                        if(taskType == null) {
                            if(taskSubject.containsIgnoreCase('Email')) {
                            	action.isActionPerformed__c = true;	
                		        t.Sequence_Action__c = action.Id;   
								actionToUpdate.add(action);
								break;    
                            }
                        } else {
                            if(taskType.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                                action.isActionPerformed__c = true;	
		                        t.Sequence_Action__c = action.Id;   
								actionToUpdate.add(action);
								break; 
                            }
                        }
                    }
                    
					if(actionType.equals(CadenceConstants.ACTION_TYPE_SMS) && taskSubject.containsIgnoreCase('Outbound Message')) {
						action.isActionPerformed__c = true;	
                        t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;
					}
				}
			}
		}
		
		if(!actionToUpdate.isEmpty()) {
			update actionToUpdate;
			updateObjectFields(actionToUpdate);
		}

    }

	public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {

	   	Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
    	List<Sequence_Action__c> actionToUpdate = new List<Sequence_Action__c>();
    	Map<Id, List<CadenceAction__c>> objToCadActListMap = new Map<Id, List<CadenceAction__c>>();
    	List<Task> tasksToProcess = new List<Task>();
  	
		for(Task t : (List<Task>)records) {
			if(existingRecords.get(t.Id).get('WhoId') == null && t.WhoId != null) {
				tasksToProcess.add(t);
			}
		}
	
		objToPartActMap = getAllParticipantActionsForTaskOwner(tasksToProcess);
		if(objToPartActMap == null || objToPartActMap.isEmpty()) {
			return;
		}

		//Updating performed actions
		for(Task t : tasksToProcess) {

            if(t.WhoId == null || t.Subject == null || t.Sequence_Action__c != null) {
     			continue;
     		}
			String taskType = t.TaskSubtype;
			String taskSubject = t.Subject;
			
			if(objToPartActMap.containsKey(t.WhoId)) {
				CadenceAction__c cadAct = new CadenceAction__c();
				for(Sequence_Action__c action : objToPartActMap.get(t.WhoId)) {
					
                    if(action == null || action.isActionPerformed__c == true || action.Show_on_Target_List__c == false) {
						continue;
					}
					
                    String actionType = action.CadenceAction_Id__r.Action_Id__r.Type__c;
					if(taskType!=null && (actionType.equals(CadenceConstants.ACTION_TYPE_CALL) || actionType.equals(CadenceConstants.ACTION_TYPE_CALL_VOICEMAIL)) 
                       && taskType.equals(CadenceConstants.ACTION_TYPE_CALL)) {
						action.isActionPerformed__c = true;
                        t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;
					}
					
					if(actionType.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                        if(taskType == null) {
                            if(taskSubject.containsIgnoreCase('Email')) {
                            	action.isActionPerformed__c = true;	
                		        t.Sequence_Action__c = action.Id;   
								actionToUpdate.add(action);
								break;    
                            }
                        } else {
                            if(taskType.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                                action.isActionPerformed__c = true;	
		                        t.Sequence_Action__c = action.Id;   
								actionToUpdate.add(action);
								break; 
                            }
                        }
                    }
                    
					if(actionType.equals(CadenceConstants.ACTION_TYPE_SMS) && taskSubject.containsIgnoreCase('Outbound Message')) {
						action.isActionPerformed__c = true;	
                        t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;
					}
				}
			}
		}
		
		if(!actionToUpdate.isEmpty()) {
			update actionToUpdate;
			updateObjectFields(actionToUpdate);
		}
										
	}
		
    public static void updateObjectFields(List<Sequence_Action__c> actPartList) {

		//Returning if list is empty		
		if(actPartList == null || actPartList.isEmpty()) {
			return;
		}
		
		//Updating the fields
		List<SObject> sObjListToUpdate = new List<SObject>();
		Map<String, List<String>> leadfieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.LEAD_OBJECT_NAME);
		Map<String, List<String>> contactfieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.CONTACT_OBJECT_NAME);
	
		for(Sequence_Action__c partAct : actPartList) {
			SObject sObj;
			if(partAct.Lead_Id__c == null) { 
				sObj = new Contact();
				sObj.put('Id', partAct.Contact_Id__c);
			} else {
				sObj = new Lead();
				sObj.put('Id', partAct.Lead_Id__c);
			}
			String fieldsToUpdate = partAct.CadenceAction_Id__r.Fields_To_Update_Action__c;
			if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
				Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
				fieldMap.remove('sobjectType');
				for(String fieldName : fieldMap.keySet()) {
					List<String> apiList;
					if(partAct.Lead_Id__c == null) {
						apiList = contactfieldDataTypeMap.get(fieldName);
					} else {
						apiList = leadfieldDataTypeMap.get(fieldName);
					}
				    
                    String fieldApiName = apiList[0];
                    String fieldApiType = apiList[1];
                    CadenceUtil.updateFieldValue(sObj, fieldApiName, fieldMap.get(fieldName), fieldApiType);
				}
				sObjListToUpdate.add(sObj);					
			}
		}
		if(!sObjListToUpdate.isEmpty()) {
			update sObjListToUpdate;		
		}
		
    }
    
    
    public static Map<Id, List<Sequence_Action__c>> getAllParticipantActionsForTaskOwner(List<Task> tasks) {

		Map<Id, List<Task>> contToTasksMap = new Map<Id, List<Task>>();
    	Map<Id, List<Task>> leadToTasksMap = new Map<Id, List<Task>>();
    	Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
		
    	//Separating tasks for lead and contact
     	for(Task t : tasks) {
     		if(t.WhoId == null) {
     			continue;
     		}
     		if((t.WhoId).getSObjectType().getDescribe().getName().equals(CadenceConstants.CONTACT_OBJECT_NAME)) {
    			if(contToTasksMap.containsKey(t.WhoId)) {
	    			contToTasksMap.get(t.WhoId).add(t);
	    		} else {
	    			contToTasksMap.put(t.WhoId, new List<Task>{t});
	    		}
    		} else {
	    		if(leadToTasksMap.containsKey(t.WhoId)) {
	    			leadToTasksMap.get(t.WhoId).add(t);
	    		} else {
	    			leadToTasksMap.put(t.WhoId, new List<Task>{t});
	    		}
    		}
    	}
    	
    	//Getting unperformed participants actions for contacts 
    	if(!contToTasksMap.isEmpty()) {
    		objToPartActMap = CadenceService.getRemainingParticipantActions(contToTasksMap.keySet(), CadenceConstants.CONTACT_OBJECT_NAME);    	
    	}
    	
    	//Getting unperformed participants actions for leads 
    	if(!leadToTasksMap.isEmpty()) {
    		objToPartActMap.putAll(CadenceService.getRemainingParticipantActions(leadToTasksMap.keySet(), CadenceConstants.LEAD_OBJECT_NAME));    	
    	}
    	
    	return objToPartActMap;
    	
    }
    
}