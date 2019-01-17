public with sharing class CadenceController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    @AuraEnabled
    public static cadenceDataWrapper getCadenceData(Id cadenceId){
        cadenceDataWrapper adWObj = new cadenceDataWrapper();
        adWObj.cObj  = CadenceController.getCadenceDetail(cadenceId);
        adWObj.conCriList = CadenceController.getFields(CadenceConstants.CONTACT_OBJECT_NAME);
        adWObj.ldCriList = CadenceController.getFields(CadenceConstants.LEAD_OBJECT_NAME);
        return adWObj;
    }
    @AuraEnabled
    public static cadenceDataWrapper getObjCriList(){
        cadenceDataWrapper adWObj = new cadenceDataWrapper();
        adWObj.conCriList = CadenceController.getFields(CadenceConstants.CONTACT_OBJECT_NAME);
        adWObj.ldCriList = CadenceController.getFields(CadenceConstants.LEAD_OBJECT_NAME);
        return adWObj;
    }
    
    public class cadenceDataWrapper{
        @AuraEnabled public Cadence__c cObj;
        @AuraEnabled public List<Criterion>  conCriList;
        @AuraEnabled public List<Criterion>  ldCriList;
    }
    
    
    @AuraEnabled
    public static Cadence__c getCadenceDetail(Id cadenceId){
    	List<Cadence__c> cadence = [Select Id, Name, Entrance_Criteria__c, Exit_Criteria__c, 
    	Participent_Activation__c, Record_Type__c, Matching_Priority__c ,
    	Status__c, Total_Participants__c,
    	(
    		Select id, name , Cadence_Id__c, Action_Id__c, Fields_To_Update_Action__c, Hour__c, Day__c, Trigger_Type__c, Action_Criterion__c from 
			CadenceActions__r order by Day__c, Hour__c
		)
    	from Cadence__c where Id=: cadenceId];
    	return cadence[0];								
    }
    
    @AuraEnabled
    public static List<Criterion> getFields(String objectStr){
    	List<Criterion> criterions = CadenceService.getFieldsWithLabels(objectStr);
    	return CadenceService.getFieldsWithLabels(objectStr);
    }
    
    @AuraEnabled
    public static void activateCadence(Id cadId) {
    	Cadence__c cad = new Cadence__c(Id=cadId, Status__c=true);
    	upsert cad;
    	updateParticipants(cadId); 
    	CadenceService.setParticipantsActivation(cadId, true);
    }
    
    @AuraEnabled
    public static void updateParticipants(Id cadId) {
    	/*CadenceBatch cadBatch = new CadenceBatch(cadId);
    	Database.executeBatch(cadBatch);  */
        Cadence__c cadence = CadenceSelector.getCadenceById(cadId);
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        String objName = cadence.Record_Type__c;
        String query2 = formQuery2(objName,cadence);
        System.debug('query2'+query2);
        List<SObject> sObjectListToUpdate = new List<SObject>();
        for(Sobject obj : Database.query(query2 + ' limit 2000')){
            
            obj.put(nameSpace+'Cadence_Id__c', cadence.Id);
			if(cadence.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
				obj.put(nameSpace+'isActivated__c', true);
			} else {
				obj.put(nameSpace+'isActivated__c', false);
			}
			obj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());

            sObjectListToUpdate.add(obj);
            objIdToAllCadActListMap.put((Id)obj.get('Id'), cadence.CadenceActions__r);
        }

        if(!objIdToAllCadActListMap.isEmpty()) {
            CadenceService.createActionParticipants(objIdToAllCadActListMap, objName);
        }
         
        if(sObjectListToUpdate !=  null && sObjectListToUpdate.size() > 0) {
            update sObjectListToUpdate; 
        }
    }
    
    @AuraEnabled
    public static void deactivateCadence(Id cadId) {
    	Cadence__c cad = new Cadence__c(Id=cadId, Status__c=false);
    	upsert cad;
    	CadenceService.setParticipantsActivation(cadId, false);
    }
    
     public Static String formQuery2(String objName,Cadence__c cadence){
   		String query = 'Select Cadence_ID__c,isActivated__c,EntranceCriteria_Matched_Date__c from '+ objName +' Where (Cadence_ID__c = null) AND ';
   		Set<String> allowedFields = new Set<String>();
        Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions =  new Map<Id, CriterionSet>();
        Map<Id, CriterionSet> mapofCadenceWiseExitCriterions =  new Map<Id, CriterionSet>();
	    Map<Id, CriterionSet> mapofCadenceActionCriterions =  new Map<Id, CriterionSet>();
		list<Cadence__c> listOfcadence =  new List<Cadence__c>();
		if(cadence != null){
			listOfcadence.add(cadence);
			mapofCadenceWiseEntryCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_ENTRY);
            //System.debug(' this for entry criteria  :'+mapofCadenceWiseEntryCriterions);
			mapofCadenceWiseExitCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_EXIT);
            //System.debug(' this for exit criteria  :'+mapofCadenceWiseExitCriterions);
			if(cadence.CadenceActions__r != null && cadence.CadenceActions__r.size() >0)
			mapofCadenceActionCriterions = RuleCriterionMatcherHelper.getActionWiseCriterions(cadence.CadenceActions__r);	
            
            // Filter condition for entry criteria 
            if(mapofCadenceWiseEntryCriterions.keyset().size() > 0)
            query = query+ '(('+criteriaFilters(mapofCadenceWiseEntryCriterions,cadence)+')';
            //System.debug('Filter  query for entry'+query);
            
            // Filter condition for exit criteria  
            if(mapofCadenceWiseExitCriterions.keyset().size() > 0)
            query = query+ +' AND (NOT('+criteriaFilters(mapofCadenceWiseExitCriterions,cadence) +')))';
            //System.debug('Filter  query for exit'+query);
            
		}
        system.debug('query  in batch@@@@'+query);
		system.debug('mapofCadenceWiseCriterions  in batch'+mapofCadenceWiseEntryCriterions );
		system.debug('mapofCadenceActionCriterions   in batch'+mapofCadenceActionCriterions);
   		return query;
   	}
    
 	 public static String criteriaFilters( Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions,Cadence__c cadence){
        string query ='';
        if(mapofCadenceWiseEntryCriterions.keySet().size() > 0){
            if(mapofCadenceWiseEntryCriterions.containskey(cadence.id) && mapofCadenceWiseEntryCriterions.get(cadence.id).criterions != null){
                if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition != null ){
                    map<integer,Criterion> mapofCriterion = new map<integer,Criterion>();
                    mapofCriterion = mapofCadenceWiseEntryCriterions.get(cadence.id).criterions;
                    integer listcount=0;
                    system.debug('Test#### '+mapofCadenceWiseEntryCriterions.get(cadence.id).condition);
                    String conditionforAll='';
                    if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('conditions are met'))
                    conditionforAll = mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('AND') ? ' AND':(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('OR')?' OR':'');  
                    else
                    conditionforAll =mapofCadenceWiseEntryCriterions.get(cadence.id).condition;
                    
                    System.debug('conditionforAll@@@@'+conditionforAll);  
                    System.debug('mapofCriterion.keyset() Size @@@@'+mapofCriterion.keyset());
                    List<Integer> listOfMapKey =new List<Integer>();
                    listOfMapKey.addAll(mapofCriterion.keyset());
                    listOfMapKey.sort();
                    System.debug('listOfMapKey@@@@@@@@@@'+listOfMapKey);
                    for( Integer num : listOfMapKey){
                        if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.containsIgnoreCase('Custom logic') && num ==1 && mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula.startswith('('))
                        query = query +'(';
                        query = query + mapofCriterion.get(num).fieldName;
                        System.debug('num@@@@@@@@@@'+num);
                        System.debug('operation'+mapofCriterion.get(num).operation);
                      
                        if(mapofCriterion.get(num).operation == 'contains'){
                             if(mapofCriterion.get(num).fieldDataType =='picklist' )
                             query =query+' LIKE  \'%' +mapofCriterion.get(num).value + '%\'';
                             else if (mapofCriterion.get(num).fieldDataType =='multipicklist')
                             query =query+' INCLUDES ( \''+mapofCriterion.get(num).value+ '\' )';
                             else
                             query =query+' LIKE  \'%' +mapofCriterion.get(num).value + '%\'';
                        } 
                        else if(mapofCriterion.get(num).operation =='not_equals'){
                             system.debug('Does Not equal');
                             if(mapofCriterion.get(num).fieldDataType =='Number')
                             query =query+' !='+  decimal.valueOf(mapofCriterion.get(num).value);
                             else if(mapofCriterion.get(num).fieldDataType =='Boolean')
                             query =query+' !='+  mapofCriterion.get(num).value; 
                             else 
                             query =query+' !=\''+  mapofCriterion.get(num).value +'\''; 
                        }
                        else if(mapofCriterion.get(num).operation =='equals'){
                            if(mapofCriterion.get(num).fieldDataType =='Number')
                            query =query+' ='+  decimal.valueOf(mapofCriterion.get(num).value);
                            else if(mapofCriterion.get(num).fieldDataType =='Boolean')
                            query =query+' ='+  mapofCriterion.get(num).value; 
                            else 
                            query =query+' =\''+  mapofCriterion.get(num).value +'\'';  
                        }
                        else if(mapofCriterion.get(num).fieldDataType =='Number'){ 
                            if(mapofCriterion.get(num).operation =='greater'){ 
                                 query =query+' >'+  decimal.valueOf(mapofCriterion.get(num).value);
                            }
                            else  if(mapofCriterion.get(num).operation =='greater_or_equals'){ 
                                 query =query+' >='+  decimal.valueOf(mapofCriterion.get(num).value);
                            }
                            else if(mapofCriterion.get(num).operation =='less_or_equals'){ 
                                 query =query+' <='+  decimal.valueOf(mapofCriterion.get(num).value);
                            }
                            else  if(mapofCriterion.get(num).operation =='less_than'){ 
                                 query =query+' <'+  decimal.valueOf(mapofCriterion.get(num).value);
                            }
                            
                        }
                        else
                            query =query+' LIKE  \'%' +mapofCriterion.get(num).value +'\''; 
                        listcount++;
                        System.debug('Num@@'+num + 'listcount'+listcount);
                        if(listcount <= mapofCriterion.keyset().size()){
                            if(!conditionforAll.containsIgnoreCase('Custom logic') && num != mapofCriterion.keyset().size()){
                                 System.debug('Test custom logic in if '+mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula +'conditionforAll'+conditionforAll);
                                 query = query + conditionforAll +' ';
                            }
                           
                            else{
                              System.debug('Test custom logic'+mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula);
                              String conditionLogic = mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula != null ? mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula.trim():'';
                              String temp ='';
                             
                              System.debug('num+1###'+String.valueof(num+1));
                                if(conditionLogic.containsIgnoreCase(String.valueof(num+1))){
                                    temp = conditionLogic.substringBetween(String.valueof(num)+'',String.valueof(num+1)); 
                                }
                              
                              else{
                                    /*if(mapofCriterion.keyset().size() <num+1 ){
                                        //temp = mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula.substringBetween(String.valueof(num)+' ',' ') +')';
                                        //if(!mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('conditions are met'))
                                        //temp=')';
                                      
                                    }
                                    else*/ 
                                  	  System.debug('Test End' +conditionLogic.substringAfter(String.valueof(num)));
                                        temp = conditionLogic.substringAfter(String.valueof(num));    
                              }
                              query = query + ' '+temp +' ';
                            }
                        } 
                    }   
                }
            }        
        }
    	return query;
    } 
    
}