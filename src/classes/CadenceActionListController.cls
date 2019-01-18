public class CadenceActionListController {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    public class ActionWrapper {
        @AuraEnabled public Id actionId;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public Integer cadences;
        @AuraEnabled public Integer participants;
        @AuraEnabled public Double effectivity;
    }
    
    public class CadenceWrapper {
        @AuraEnabled public Id cadId;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String objType;
        @AuraEnabled public String activation;
        @AuraEnabled public Integer participants;
        
        public CadenceWrapper(Id cadId, String name, Boolean status, String objType, String activation) {
            this.cadId = cadId;
            this.name = name;
            if(status) {
                this.status = 'Active';
            } else {
                this.status = 'Inactive';
            }
            this.objType = objType;
            this.activation = activation;
        }
    }
    
    @AuraEnabled
    public static List<ActionWrapper> fetchCadenceActions() {
        
        List<ActionWrapper> actionWrapperList = new List<ActionWrapper>();
        Map<Id, Integer> cadenceCount = new Map<Id, Integer>();
        
        //getting all the actions and their types
        List<Action__c> actionList = [SELECT Id, Name, Type__c FROM Action__c Order by CreatedDate desc];
        //Getting all the cadences count 
        List<AggregateResult> cadenceActions = [SELECT Action_Id__c, COUNT_DISTINCT(Cadence_Id__c) cadenceCount FROM CadenceAction__c GROUP BY Action_Id__c];
        for(AggregateResult result : cadenceActions) {
            cadenceCount.put((Id)result.get(nameSpace+'Action_Id__c'), (Integer)result.get('cadenceCount'));
        }
        
        //Getting all participants counts
        Map<Id, Integer> actionWiseParticipants = getActionWiseParticipants();
        
        for(Action__c action : actionList) {
            ActionWrapper actionWrap = new ActionWrapper();
            actionWrap.actionId = action.Id;
            actionWrap.name	= action.Name;
            actionWrap.type = action.Type__c;
            if(cadenceCount.containsKey(action.Id)) {
                actionWrap.cadences = cadenceCount.get(action.Id);
            } else {
                actionWrap.cadences = 0;  				             
            }
            if(actionWiseParticipants.containsKey(action.Id)) {
                actionWrap.participants = actionWiseParticipants.get(action.Id);
            } else { 
                actionWrap.participants = 0;
            }
            actionWrapperList.add(actionWrap);
        }
        return actionWrapperList;
    }
    
    @AuraEnabled 
    public static List<CadenceWrapper> getCadenceData() {
        // Start CadenceScheduler 
        CadenceUtil.startCadenceScheduler();
        //getting all the cadences and their types
        List<Cadence__c> cadenceList = [SELECT Id, Name, Status__c, Record_Type__c, Participent_Activation__c FROM Cadence__c Order by CreatedDate desc];
        
        //Getting cadence wise participants 
        Map<Id, Integer> cadWiseParts = getCadenceWiseParticipants();
        
        List<CadenceWrapper> cadWrapList = new List<CadenceWrapper>();
        for(Cadence__c cad : cadenceList) {
            CadenceWrapper cadWrap = new CadenceWrapper(cad.Id, cad.Name, cad.status__c, cad.Record_Type__c, cad.Participent_Activation__c);
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
    public static void deleteCadences(List<Id> cadIds) {
        if(!cadIds.isEmpty()) {
            List<Cadence__c> cadencesToDelete = new List<Cadence__c>();
            for(Id cadId: cadIds) {
                Cadence__c obj = new Cadence__c(Id = cadId);
                cadencesToDelete.add(obj);
            }
            deleteActionOnpartcipants(cadIds);
            delete cadencesToDelete;
        }    
    }
    
    
    @AuraEnabled
    public static void deleteActions(List<Id> actionIds) {
        if(!actionIds.isEmpty()) {
            List<Action__c> actionsToDelete = new List<Action__c>();
            for(Id actionId: actionIds) {
                Action__c obj = new Action__c(Id =actionId);
                actionsToDelete.add(obj);
            }
            delete actionsToDelete;
        }    
    }
    
    public static Map<Id, Integer> getCadenceWiseParticipants() {
        Map<Id, Integer> cadWiseParticipants = new Map<Id, Integer>();
        List<AggregateResult> cadParticipants = [Select Cadence_ID__c, count(Id) participants from Contact where Cadence_Id__c!=null group by Cadence_ID__c];
        cadParticipants.addAll([Select Cadence_ID__c, count(Id) participants from Lead where Cadence_Id__c!=null group by Cadence_ID__c]);
        
        if(!cadParticipants.isEmpty()) {
            for(AggregateResult result : cadParticipants) {
                if(cadWiseParticipants.containsKey((Id)result.get(nameSpace+'Cadence_ID__c'))) {
                    cadWiseParticipants.put((Id)result.get(nameSpace+'Cadence_ID__c'), (cadWiseParticipants.get((Id)result.get(nameSpace+'Cadence_ID__c')) + (Integer)result.get('participants')));
                } else {
                    cadWiseParticipants.put((Id)result.get(nameSpace+'Cadence_ID__c'), (Integer)result.get('participants'));
                }
            }
        }
        return cadWiseParticipants;
    }
    
    public static Map<Id, Integer> getActionWiseParticipants() {
        Map<Id, Integer> actionWiseParticipants = new Map<Id, Integer>();
        Map<Id, Integer> cadWiseParticipants = getCadenceWiseParticipants();
        Map<Id, Set<Id>> actionIdToCadencesIds = new Map<Id, Set<Id>>();
        List<CadenceAction__c> cadActions = [Select Id, Cadence_Id__c, Action_Id__c from CadenceAction__c];
        
        for(CadenceAction__c action : cadActions) {
            
            if(actionIdToCadencesIds.containsKey(action.Action_Id__c)) {
                actionIdToCadencesIds.get(action.Action_Id__c).add(action.Cadence_Id__c);
            } else {
                actionIdToCadencesIds.put(action.Action_Id__c, new Set<Id>{action.Cadence_Id__c});
            }
        }
        
        for(Id actId : actionIdToCadencesIds.keySet()) {
            for(Id cadId : actionIdToCadencesIds.get(actId)) {
                if(cadWiseParticipants.containsKey(cadId)) {
                    if(actionWiseParticipants.containsKey(actId)) {
                        actionWiseParticipants.put(actId, actionWiseParticipants.get(actId) + cadWiseParticipants.get(cadId));
                    } else {
                        actionWiseParticipants.put(actId, cadWiseParticipants.get(CadId));
                    }
                }
            }
        }
        return actionWiseParticipants;
    }
    
    public static void deleteActionOnpartcipants(List<Id> cadIds){      
        List<Sequence_Action__c> actionOnParticipants = [select Id from Sequence_Action__c where CadenceAction_ID__r.Cadence_Id__c  IN :cadIds and isActionPerformed__c=false];  
        if(!actionOnParticipants.isEmpty()) {
            delete actionOnParticipants;
        }
    }
}