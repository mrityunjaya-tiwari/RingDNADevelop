public class ManualCadenceSelectorController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    private ApexPages.StandardSetController standardSetController;
    private ApexPages.StandardController standardController;
    public List<SObject> participants{get;set;}
    public SObject participant{get;set;}
    public String recordType{get;set;}
    
    public ManualCadenceSelectorController(ApexPages.StandardController standardController){
        this.standardController = standardController; 
        participant=(Contact)standardController.getRecord();
    }
    
    public ManualCadenceSelectorController(ApexPages.StandardSetController standardsetController){
        this.standardSetController = standardsetController;
        participants=standardsetController.getSelected();
        SObject obj;
        if(participants != null && participants.size()>0){
            obj=participants[0];
            
        }else{
            participants.add(standardsetController.getRecord());
            if(participants.size() > 0){
                obj=participants[0];
            }   
        }
        if(obj != null){
            recordType=obj.getSObjectType().getDescribe().getName(); 
        }
    }
    
    @AuraEnabled 
    public static List<CadenceActionListController.CadenceWrapper> getCadenceDataByRecordType(String recordType) {
        //getting all the cadences and their types
        
        List<Cadence__c> cadenceList = [SELECT Id, Name, Status__c, Record_Type__c, Participent_Activation__c FROM Cadence__c WHERE Record_Type__c=:recordType AND Status__c=true Order by CreatedDate desc];
        
        //Getting cadence wise participants 
        Map<Id, Integer> cadWiseParts = CadenceActionListController.getCadenceWiseParticipants();
        
        List<CadenceActionListController.CadenceWrapper> cadWrapList = new List<CadenceActionListController.CadenceWrapper>();
        for(Cadence__c cad : cadenceList) {
            CadenceActionListController.CadenceWrapper cadWrap = new CadenceActionListController.CadenceWrapper(cad.Id, cad.Name, cad.status__c, cad.Record_Type__c, cad.Participent_Activation__c);
            if(cadWiseParts.containsKey(cad.Id)) {
                cadWrap.participants = cadWiseParts.get(cad.Id);
            } else {
                cadWrap.participants = 0;
            }
            cadWrapList.add(cadWrap);
        }
        
        return cadWrapList;
        
    }
    @AuraEnabled
    public static Integer saveParticipants(Id cadId,List<Id> participantIds) {
        Cadence__c cadence = CadenceSelector.getCadenceById(cadId);
        Integer previouslyAssociated=0;
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        String objName = cadence.Record_Type__c;
        List<SObject> sObjectListToUpdate = new List<SObject>();
        List<SObject> participants;
        if(objName=='Contact'){
            participants=[SELECT Id, Cadence_Id__c,isActivated__c,EntranceCriteria_Matched_Date__c FROM Contact
                          WHERE Id IN :participantIds];
        }else if(objName=='Lead'){
            participants=[SELECT Id, Cadence_Id__c,isActivated__c,EntranceCriteria_Matched_Date__c FROM Lead
                          WHERE Id IN :participantIds];
        }
        for(Sobject obj : participants){
            if(obj.get(nameSpace+'Cadence_Id__c')!=null){
                obj.put(nameSpace+'Cadence_Id__c', cadence.Id);
                if(cadence.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                    obj.put(nameSpace+'isActivated__c', true);
                    obj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
                    objIdToAllCadActListMap.put((Id)obj.get('Id'), cadence.CadenceActions__r);
                } else {
                    obj.put(nameSpace+'isActivated__c', false);
                }
                sObjectListToUpdate.add(obj);
            }else{
                previouslyAssociated++;
            }   
        }
        if(!objIdToAllCadActListMap.isEmpty()) {
            List<Sequence_Action__c> testcreateActionParticipants =CadenceService.createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(sObjectListToUpdate), objName);
        }
        if(sObjectListToUpdate !=  null && sObjectListToUpdate.size() > 0) {
            Database.SaveResult[] results = Database.update(sObjectListToUpdate, false);
        }
        return previouslyAssociated;
    }
}