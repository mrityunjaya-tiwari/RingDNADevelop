public with sharing class CadenceController {
    
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
			CadenceActions__r
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
    	CadenceBatch cadBatch = new CadenceBatch(cadId);
    	Database.executeBatch(cadBatch);
    }
    
    @AuraEnabled
    public static void deactivateCadence(Id cadId) {
    	Cadence__c cad = new Cadence__c(Id=cadId, Status__c=false);
    	upsert cad;
    	CadenceService.setParticipantsActivation(cadId, false);
    }
    
}