public class ManualSequenceAssociateController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    private ApexPages.StandardSetController standardSetController;
    private ApexPages.StandardController standardController;
    public String lID{get;set;} 
    public String participantId{get;set;}
    public static String listViewReturnUrl{get;set;}
    public List<SObject> participants{get;set;}
    public String recordType{get;set;}
    public ManualSequenceAssociateController(ApexPages.StandardController standardController){       
        this.standardController = standardController;
        participantId = String.valueOf(standardController.getRecord().Id);
        if(participantId != null){
            recordType=standardController.getRecord().getSObjectType().getDescribe().getName(); 
        } 
    }
    public ManualSequenceAssociateController(ApexPages.StandardSetController standardsetController){
        participants=new List<SObject>();
        this.standardSetController = standardsetController;
        participants=standardsetController.getSelected();
        listViewReturnUrl=String.valueOf(standardsetController.cancel());
        listViewReturnUrl=listViewReturnUrl.substringBetween('[', ']');
        if(participants.size()>0){
            recordType=participants[0].getSObjectType().getDescribe().getName(); 
        }
    }
    @AuraEnabled 
    public static List<CadenceActionListController.CadenceWrapper> getCadenceDataByRecordType(String recordType) {
        //getting all the sequence of particular type
        Map<Id,Cadence__c> sequenceMap = CadenceSelector.getActiveCadencesByRecordType(new List<String>{recordType});
        List<Cadence__c> sequenceList=sequenceMap.values();
        //Getting cadence wise participants 
        Map<Id, Integer> cadWiseParts = CadenceActionListController.getCadenceWiseParticipants();
        List<CadenceActionListController.CadenceWrapper> cadWrapList = new List<CadenceActionListController.CadenceWrapper>();
        for(Cadence__c sequence : sequenceList) {
            CadenceActionListController.CadenceWrapper cadWrap = new CadenceActionListController.CadenceWrapper(sequence.Id, sequence.Name, sequence.status__c, sequence.Record_Type__c, sequence.Participent_Activation__c);
            if(cadWiseParts.containsKey(sequence.Id)) {
                cadWrap.participants = cadWiseParts.get(sequence.Id);
            } else {
                cadWrap.participants = 0;
            }
            cadWrapList.add(cadWrap);
        }
        return cadWrapList;    
    }
    @AuraEnabled
    public static List<Integer> saveParticipants(String sequenceId,String participantIds) {
        List<Integer> errorRecords=new List<Integer>();
        Cadence__c cadence = CadenceSelector.getCadenceById(sequenceId);
        Integer previouslyAssociated=0, samePastSequence=0;
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        String recordType = cadence.Record_Type__c;
        List<SObject> participantListToUpdate = new List<SObject>();
        participantIds=participantIds.remove(' ');
        participantIds=participantIds.remove('[');
        participantIds=participantIds.remove(']');
        List<String> listOfParticipantIds=participantIds.split(',');
        Set<Id> setOfParticipantIds=new Set<Id>();
        for(String participant : listOfParticipantIds){
            setOfParticipantIds.add(Id.valueOf(participant));
        }
        Map<Id,List<Id>> mapOfSequenceHistory=CadenceService.getParticipantSequenceHistory(setOfParticipantIds,recordType);
        List<SObject> participants=new List<SObject>();
        participants=CadenceSelector.getParticipantsByRecordType(recordType, listOfParticipantIds);
        for(Sobject participant : participants){            
            List<Id> previousSequences=new List<Id>();
            previousSequences=mapOfSequenceHistory.get((Id)participant.get('Id'));
            if(previousSequences!=null){
                if(previousSequences.contains(Id.valueOf(sequenceId))){
                    samePastSequence++;
                    continue;
                }
            }
            if(participant.get(nameSpace+'Cadence_Id__c') == null){
                participant.put(nameSpace+'Cadence_Id__c', cadence.Id);
                if(cadence.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                    participant.put(nameSpace+'isActivated__c', true);
                    participant.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
                    objIdToAllCadActListMap.put((Id)participant.get('Id'), cadence.CadenceActions__r);
                } else {
                    participant.put(nameSpace+'isActivated__c', false);
                }
                participantListToUpdate.add(participant);
            }else{
                previouslyAssociated++;
            }   
        }
        if(!objIdToAllCadActListMap.isEmpty()) {
            CadenceService.createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(participantListToUpdate), recordType);
        }
        if(participantListToUpdate !=  null && participantListToUpdate.size() > 0) {
            Database.SaveResult[] results = Database.update(participantListToUpdate, false);
        }
        errorRecords.add(previouslyAssociated);
        errorRecords.add(samePastSequence);
        return errorRecords;
    }
}