public with sharing class CadenceSelector {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
  
    public static Map<Id, Cadence__c> getActiveCadencesByRecordType(String recType) {
        
        return new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                        Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                        (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                         Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                         Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                         FROM CadenceActions__r order by Index__c) 
                                        FROM Cadence__c WHERE Status__c = true AND Record_Type__c = :recType]);
        
    }
    
    
    
    public static List<Sequence_Action__c> getParticipantActions() {
        return [Select Id, Name, CadenceAction_ID__c, Contact_Id__c, Lead_Id__c, isActionPerformed__c From Sequence_Action__c];
    }
    
    public static Cadence__c getCadenceById(Id cadId) { 
        
        return [SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                 Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                 Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                 FROM CadenceActions__r) 
                FROM Cadence__c WHERE Id = :cadId LIMIT 1];
        
    } 
    
    
    public static List<SObject> getSobjectListByIds(String ObjType, List<Id> Ids) {
        List<Id> soIds = Ids;
        String query = getQueryForObject(objType);
        query += ' WHERE Id In :soIds ';
        return Database.query(query);
    }
    
    /**
     * @description - Used to get ParticipantActions list by CadenceActionsIds.
     * @param caIds - CadenceActionsIds list.
     * @return - List<SObject> - list of SObject
     */
    public static List<Sequence_Action__c> getParticipantActionsByCadenceActionsIds(List<Id> caIdList){
        List<Id> caIds = caIdList;
        String query = getQueryForObject(nameSpace+'Sequence_Action__c');
        query += ' WHERE '+nameSpace+'CadenceAction_ID__c=:caIds';
        return Database.query(query); 
    }
    /**
     * @description - get all public group.
     * @return - List<Group> - list of Group
     */
    public static List<Group> getAllPublicGroup(){
        String gType = 'Regular';
        String query = 'Select Type, Name, Id From Group  where Type =: gType';
        return Database.query(query);
    }
    
    
    /**
     * @description - get all participents of current user.
     * @param objType - sObject name string
     * @return - List<SObject> - list of SObject
     */
    public static List<SObject> getParticipantsOfCadence(Id cadenceId, String objType){
        String cId = cadenceId;
        String query = getQueryForObject(objType);
        query += ' WHERE '+nameSpace+'Cadence_Id__c=:cId';
        return Database.query(query); 
    }
    
    
    /**
     * @description - get all participents of current user.
     * @param objType - sObject name string
     * @return - List<SObject> - list of SObject
     */
    public static List<SObject> getParticipantsOfUser(String objType){
        String userId = UserInfo.getUserID();
        String query = getQueryForObject(objType);
        query += ' WHERE OwnerId=:userId';
        return Database.query(query); 
    }
    /**
     * @description - get all participents with cadenceActions(Action_on_Participants) of public group.
     * @param objType - sObject name string , pgId - public group id
     * @return - List<SObject> - list of SObject
     */
    public static List<SObject> getParticipantsWithCadenceActionsOfPublicGroup(String objType, Id pgId){
        Id gId = pgId;
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String queryuser = 'SELECT UserOrGroupId FROM GroupMember WHERE GroupId  =: gId';
        List<GroupMember> gmList = Database.query(queryuser);
        List<Id> userIds = new List<Id>();
        for (GroupMember gmObj : gmList){
            if(((String)gmObj.UserOrGroupId).startsWith(userType))
            {
                userIds.add(gmObj.UserOrGroupId);
            }
        }
        Id cuId = UserInfo.getUserID();
        if (! userIds.contains(cuId)){
            userIds.add(cuId);
        }

        String query = getQueryForObject(objType);
        String subQuery = getQueryForObject(nameSpace+'Sequence_Action__c');
        subQuery = '( ' + subQuery.replace(nameSpace+'Sequence_Action__c', nameSpace+'Sequence_Actions__r') + ' WHERE '+nameSpace+'isActionPerformed__c = false AND '+nameSpace+'Show_on_Target_List__c = true AND ' + nameSpace+'isDeferred__c = false' +' ) ';
        String queryWithSubQuery = query.replace('Select', subQuery);
        if (objType == CadenceConstants.CONTACT_OBJECT_NAME){
            queryWithSubQuery = 'Select Account.Name, Account.Id,'+nameSpace+'Cadence_ID__r.name, ' + queryWithSubQuery ;
            queryWithSubQuery += ' WHERE '+nameSpace+'isActivated__c = true AND '+nameSpace+'Cadence_Id__c != null AND OwnerId in :userIds ';
        }else {
            queryWithSubQuery = 'Select '+nameSpace+'Cadence_ID__r.name, ' + queryWithSubQuery ;
            queryWithSubQuery += ' WHERE '+nameSpace+'isActivated__c = true AND IsConverted != true AND '+nameSpace+'Cadence_Id__c != null AND OwnerId in :userIds ';
        }
        return Database.query(queryWithSubQuery); 
    }
    
    /**
     * @description - get all participents with cadenceActions(Action_on_Participants) of current user.
     * @param objType - sObject name string
     * @return - List<SObject> - list of SObject
     */
    public static List<SObject> getParticipantsWithCadenceActionsOfUser(String objType){
        String userId = UserInfo.getUserID();
        String query = getQueryForObject(objType);
        String subQuery = getQueryForObject(nameSpace+'Sequence_Action__c');
        subQuery = '( ' + subQuery.replace(nameSpace+'Sequence_Action__c', nameSpace+'Sequence_Actions__r') + ' WHERE '+nameSpace+'isActionPerformed__c = false AND '+nameSpace+'Show_on_Target_List__c = true AND ' + nameSpace+'isDeferred__c = false' +' ) ';
        //subQuery = subQuery.replace('FROM', ','+nameSpace+'CadenceAction_ID__r.'+nameSpace+'Action_Id__r.'+nameSpace+'Type__c FROM');
        String queryWithSubQuery = query.replace('Select', subQuery);
        if (objType == CadenceConstants.CONTACT_OBJECT_NAME){
            queryWithSubQuery = 'Select Account.Name, Account.Id,'+nameSpace+'Cadence_ID__r.name, ' + queryWithSubQuery ;
            queryWithSubQuery += ' WHERE '+nameSpace+'isActivated__c = true AND '+nameSpace+'Cadence_Id__c != null AND OwnerId=:userId';
        }else {
            queryWithSubQuery = 'Select '+nameSpace+'Cadence_ID__r.name, ' + queryWithSubQuery ;
            queryWithSubQuery += ' WHERE '+nameSpace+'isActivated__c = true AND IsConverted != true  AND '+nameSpace+'Cadence_Id__c != null AND OwnerId=:userId';
        }
        System.debug('queryWithSubQuery:'+queryWithSubQuery);
        return Database.query(queryWithSubQuery); 
    }
    
    
    /**
     * @description - get all cadenceActions by ids.
     * @param Ids - cadenceActions ids list.
     * @return - List<SObject> - list of CadenceAction Object
     */
    public static List<CadenceAction__c> getCadenceActionsByIds(List<Id> Ids){
        List<Id> caIds = Ids;
        String objType = nameSpace+'CadenceAction__c';
        String parentFields = ' '+nameSpace+'Action_Id__r.'+nameSpace+'Type__c, '+nameSpace+'Action_Id__r.'+nameSpace+'Activation_Type__c, '+nameSpace+'Action_Id__r.'+nameSpace+'Template_Id__c, '+nameSpace+ 'Action_Id__r.'+nameSpace +'Task_Description__c, ';
        String query = getQueryForObject(objType);
        query = query.replace('Select ', parentFields);
        query = 'Select ' + query + ' WHERE Id In :caIds ';
        return Database.query(query); 
    }
    
    
    /**
     * @description - create soql querty for SObject.
     * @param objType - sObject name string
     * @return - String - SOQL query
     */
    public  static String getQueryForObject(String objType){
        Set<String> allowedFields = new Set<String>();
        String query = 'Select ';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                continue; 
            }
            String fieldName = fieldDescribe.getName();
            allowedFields.add(fieldName);
        }
        
        if(allowedFields.size() > 0){
            String apiNameWithNamespace;
            for(String fld : allowedFields){
            	apiNameWithNamespace = nameSpace + fld;
                if(allowedFields.contains(apiNameWithNamespace)){
                    allowedFields.remove(fld); 
                }
        	}
        }
        
        query += String.join(new List<String>(allowedFields), ',');
        query += ' FROM '+ objType + '';
        return query;
    } 
    
    public static List<User> getUserList(){
        return [select id, Name  from user where ReceivesAdminInfoEmails = true];
    }
    
     /**
     * @description - Get Task List with Action On Participant.
     * @param sequenceParticipantIds - List of Action On Participant Ids.
     * @return - List<Task> - Task List
     */
    public  static List<Task> getTasks(List<Id> sequenceParticipantIds){
       	return	[Select Id,Sequence_Action__c  from Task Where Sequence_Action__c in : sequenceParticipantIds ];
    } 
    
    /**
     * @description - Get Action On Participant Ids to update IsPerformed.
     * @param ids - List of Task Ids.
     * @return - List<Task> - Action On Participant Ids
     */
    public  static List<Task> getActionOnParticipantId(Set<Id> ids){
       	return	[Select Sequence_Action__c,WhoId	from Task 
				 Where Sequence_Action__r.CadenceAction_ID__r.Action_Id__r.Type__c = 'Task'
				 AND Sequence_Action__r.isActionPerformed__c = False
				 AND Status = 'Completed' AND Id in:ids];
    } 
    
    
    
    /**
     * @description - Get Action On Participant Ids to update IsPerformed.
     * @param ids - List of Task Ids.
     * @return - List<Task> - Action On Participant Ids
     */
   /* public  static List<Task> UpdateCallActionIsPerformed(Set<Id> ids){
       	return	[Select Sequence_Action__c	from Task 
				Where Sequence_Action__r.CadenceAction_ID__r.Action_Id__r.Type__c = 'Task'
				 AND Sequence_Action__r.isActionPerformed__c = False
				 AND Status = 'Completed' AND Id in:ids];
    }*/
    
    public static List<SObject> getParticipantsOfCadenceNew(Id cadenceId, String objType){
        String cId = cadenceId;
        String query = getQueryForObjectNew(objType);
        query += ' WHERE '+nameSpace+'Cadence_Id__c=:cId';
        return Database.query(query); 
    }
    public  static String getQueryForObjectNew(String objType){
        if(objType.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME))
        	objType = CadenceConstants.CONTACT_OBJECT_NAME;
        
        Set<String> allowedFields = new Set<String>();
        String query = 'Select ';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                continue; 
            }
            String fieldName = fieldDescribe.getName();
            allowedFields.add(fieldName);
        }
        
        if(allowedFields.size() > 0){
            String apiNameWithNamespace;
            for(String fld : allowedFields){
            	apiNameWithNamespace = nameSpace + fld;
                if(allowedFields.contains(apiNameWithNamespace)){
                    allowedFields.remove(fld); 
                }
        	}
        }
        
        query += String.join(new List<String>(allowedFields), ',');
        query += ' FROM '+ objType + '';
        return query;
    } 
    
    
}