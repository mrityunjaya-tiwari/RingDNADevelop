public class TargetListController {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    @AuraEnabled
    public static List<TargetListWrapper> getTargetList(String pgId){
        
        List<TargetListWrapper> tlList = New List<TargetListWrapper>();
        tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.LEAD_OBJECT_NAME, pgId));
        tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.CONTACT_OBJECT_NAME, pgId));
        system.debug('tlList ' + tlList.size());
        TargetListInit tlObj = New TargetListInit();
        //tlObj.pgList = CadenceSelector.getAllPublicGroup();
        tlObj.tlWList = tlList;                      
        return tlList;
        
    } 
    
    @AuraEnabled 
    public static TargetListInit getTargetListInitData(String pgId){
        
        List<TargetListWrapper> tlList = New List<TargetListWrapper>();
        // if (pgId == UserInfo.getUserID()){
        tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.LEAD_OBJECT_NAME, pgId));
        tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.CONTACT_OBJECT_NAME, pgId));
        
        //system.debug('tlList ' + tlList.size());
        TargetListInit tlObj = New TargetListInit();
        List<Group> gList =  CadenceSelector.getAllPublicGroup(); 
        List<GrouplistWrapper> pgList = new List<GrouplistWrapper>();
        GrouplistWrapper glwObj = new GrouplistWrapper();
        glwObj.Id = String.ValueOf(UserInfo.getUserID());
        glwObj.Name = 'Record Owner';
        pgList.add(glwObj);
        for (Group gObj : gList){
            GrouplistWrapper obj = new GrouplistWrapper(); 
            obj.Id = String.ValueOf(gObj.Id);
            obj.Name = gObj.Name;
            pgList.add(obj);
        }
        tlObj.pgList = pgList;
        tlObj.tlWList = tlList;
        tlObj.selectedGroup = pgId;
        return tlObj;
    }
    
    public class TargetListInit{
        @AuraEnabled public List<GrouplistWrapper> pgList;
        @AuraEnabled public List<TargetListWrapper> tlWList;
        @AuraEnabled public String selectedGroup;
    }
    public class GrouplistWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
    }
    public class TargetListWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String linkActionName;
        @AuraEnabled public Integer priority;
        @AuraEnabled public String company;
        @AuraEnabled public String companyId;
        @AuraEnabled public String type;
        @AuraEnabled public String actionType;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String nextAction;
        @AuraEnabled public String actionPerformDay;
        @AuraEnabled public String participantId;
        @AuraEnabled public String participantActionsId;        
        @AuraEnabled public String emailTempId;
        @AuraEnabled public String cadenceId;
        @AuraEnabled public String cadenceName;
    }
    
    @AuraEnabled
    public static void deletePA(List<Id> ids){
        Delete [Select Id from Action_on_Participants__c where Id IN :ids];
        
    }
    
    public static void createTask(List<Id> ids){
        TargetListController.TargetListWrapper twrap;
        Action_on_Participants__c ap=[Select Id, Name from Action_on_Participants__c where Id IN :ids];
        Task t= new Task();
        t.Description= ap.Name;
        t.Status='Deferred';
        t.WhoId= twrap.participantId;
        insert t;
    }
    
    /**
* @description - created target list for SObject(lead/Contact)
* @param objType - sObject name string
* @return - List of TargetList(Wrapper class) 
*/
    public static List<TargetListWrapper> getTargetListforSObject(String objectType, String pgId){
        system.debug('pgId ' + pgId);
        List<TargetListWrapper> tlList = New List<TargetListWrapper>();
        // SObject list with related participentActions
        List<SObject> soList;
        if (pgId == '' ||  pgId == String.ValueOf(UserInfo.getUserID())){
            soList =  CadenceSelector.getParticipantsWithCadenceActionsOfUser(objectType);
        }else{
            soList =  CadenceSelector.getParticipantsWithCadenceActionsOfPublicGroup(objectType, Id.valueOf(pgId));
        }
        
        List<Id> paIdsList = New List<Id>();
        // Created list of cadenceAction ids
        for (SObject sObj : soList){
            for (Action_on_Participants__c paObj :  getAPOfSObject(sObj, objectType)){
                if (paObj.CadenceAction_ID__c != null){
                    paIdsList.Add(paObj.CadenceAction_ID__c);
                    
                }
            }
        }
        // Created list of cadenceActions 
        list<CadenceAction__c> caList= CadenceSelector.getCadenceActionsByIds(paIdsList);
        Map<Id, CadenceAction__c> caMap = New Map<Id, CadenceAction__c>(caList);
        // Itrate SObject list to create list of Wrapper 
        for (SObject sObj : soList){
            for (Action_on_Participants__c paObj :  getAPOfSObject(sObj, objectType)){
                TargetListWrapper tlObj = New TargetListWrapper();
                String caId= (String)paObj.get(nameSpace+'CadenceAction_ID__c');
                CadenceAction__c caObj = caMap.get(caId);
                if (caObj != null && caObj.Action_Id__r.Activation_Type__c == CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL  && (getDaysToPerformAction(sObj, caObj) < 1)){
                    
                    tlObj.participantId = (String)sObj.get('Id');
                    tlObj.cadenceId = (String)sObj.get(nameSpace+'Cadence_ID__c');
                    setCadenceDetails(tlObj, sObj, objectType);
                    tlObj.participantActionsId = paObj.Id;
                    
                    tlObj.linkActionName =  caObj.Name;             
                    
                    tlObj.actionType = caObj.Action_Id__r.Type__c;
                    tlObj.emailTempId = caObj.Action_Id__r.Template_Id__c;
                    tlObj.type = objectType;
                    tlObj.name = (String)sObj.get('Name');
                    if(sObj.get(nameSpace+'Priority__c') != null) {
                        tlObj.priority = Integer.valueOf(sObj.get(nameSpace+'Priority__c')); 
                    }
                    
                    if (objectType == CadenceConstants.LEAD_OBJECT_NAME){
                        tlObj.company = (String)sObj.get('Company');
                    }else {
                        setContactCompanyDetail(tlObj, sObj);
                    }
                    
                    tlObj.email = (String)sObj.get('Email');
                    tlObj.phone = (String)sObj.get('Phone');
                    
                    if (getDaysToPerformAction(sObj, caObj) < 0){
                        tlObj.actionPerformDay = 'Previous';
                        tlObj.nextAction = caObj.Action_Id__r.Id;
                    } else {
                        tlObj.actionPerformDay = 'Today';
                        tlObj.nextAction = caObj.Action_Id__r.Id;
                    }
                    
                    tlList.Add(tlObj);
                }
            }
        }
        
        return tlList;
    }
    
    
    /**
* @description - to get list of Action on Participants from SObject(lead/Contact)
* @param objType - sObject name string
* @param sObj - object to get apList
* @return - List of Action_on_Participants__c
*/
    public static  List<Action_on_Participants__c> getAPOfSObject(SObject sObj, String objType){
        List<Action_on_Participants__c> apList;
        if (objType == CadenceConstants.LEAD_OBJECT_NAME){
            Lead lObj = (Lead)sObj;
            apList =  lObj.Action_on_Participants__r;
        } else {
            Contact cObj = (Contact)sObj;
            apList =  cObj.Action_on_Participants__r;
        }
        return apList;
    }
    
    
    /**
	 * @description - Used to get company name of contact
	 * @param sObj - contact object
	 * @return - String  - company name
	 */
    public static void setContactCompanyDetail(TargetListWrapper tlObj, SObject sObj){
        Contact cObj = (Contact)sObj;
        tlObj.company = cObj.Account.Name;
        tlObj.companyId = cObj.Account.Id;
    }
    /**
	 * @description - Used to get cadenceDetails
	 */
    public static void setCadenceDetails(TargetListWrapper tlObj, SObject sObj, String objectType){
        if (objectType == CadenceConstants.LEAD_OBJECT_NAME){
            Lead lObj = (Lead)sObj;
            tlObj.cadenceId = lObj.Cadence_ID__c;
            tlObj.cadenceName = lObj.RDNACadence__Cadence_ID__r.name;
        }else {
            Contact cObj = (Contact)sObj;
            tlObj.cadenceId = cObj.Cadence_ID__c;
            tlObj.cadenceName = cObj.RDNACadence__Cadence_ID__r.name;
        }
    }
    
    /**
* @description - Method is used to find days to perform cadence Action
* @param sObj - sObject (Lead/Contact)
* @param caObj - CadenceAction object
* @return - Integer - days to perform
*/
    public static Integer getDaysToPerformAction(SObject sObj, CadenceAction__c caObj){
        DateTime dt = (DateTime)sObj.get(nameSpace+'EntranceCriteria_Matched_Date__c');
        Map<String, String> dtMap = CadenceUtil.getTimeDiff(system.now(), dt);
        Integer dayToPerform;
        Integer hourToPerform;
        if (caObj.Day__c != null) {
            dayToPerform = Integer.valueOf(caObj.Day__c);
        }else {
            dayToPerform = 0;
        }
        if (caObj.Hour__c != null) {
            hourToPerform = Integer.valueOf(caObj.Hour__c);
        } else {
            hourToPerform = 0;
        }
        
        Integer dayFromMatchedDate = Integer.valueOf(dtMap.get('day'));
        Integer hourFromMatchedDate = Integer.valueOf(dtMap.get('hour'));
        Integer hour = (dayToPerform * 24 + hourToPerform ) - (dayFromMatchedDate * 24 + hourFromMatchedDate );
        return hour/24;
    }
}