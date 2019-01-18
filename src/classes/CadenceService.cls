global class CadenceService {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    public static List<EmailTemplate> getEmailTemplates(){
        List<EmailTemplate> listEmailTemplate = [select id,name from EmailTemplate];
        return listEmailTemplate;
    } 
    
    public static List<ActionDetailController.WrapperTemplateObj> getSMSTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getSMSTemplates());
    } 
    
    public static List<ActionDetailController.WrapperTemplateObj> getCallTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getCallNoteTemplates());
    }
    
    public static List<ActionDetailController.WrapperTemplateObj> getVMTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getVoicemailDrops());
    }
    public static List<ActionDetailController.WrapperTemplateObj> mapToWrapperObj (Map<String, String> apiMap){
        List<ActionDetailController.WrapperTemplateObj> wtList = New List<ActionDetailController.WrapperTemplateObj>();
        for(String str : apiMap.keySet()){
            ActionDetailController.WrapperTemplateObj wtObj = New ActionDetailController.WrapperTemplateObj();
            wtObj.Id = str;
            wtObj.Name = apiMap.get(str);
            wtList.add(wtObj);
        } 
        return wtList; 
    }
    
    
    public static List<ActionDetailController.wrapperTaskField> getFields(String objectStr) {
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        List<ActionDetailController.wrapperTaskField> listWrapperTaskFields = new List<ActionDetailController.wrapperTaskField>();
        for (String field : fieldsMap.keySet()) {
            ActionDetailController.wrapperTaskField wrapperTaskFieldObj = new ActionDetailController.wrapperTaskField();
            Schema.sObjectField fieldAPIName = fieldsMap.get(field);
            Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();
            
            if (fieldDataType == Schema.DisplayType.Boolean || fieldDataType == Schema.DisplayType.Double 
                || fieldDataType == Schema.DisplayType.Integer 
                || fieldDataType == Schema.DisplayType.String 
                || fieldDataType == Schema.DisplayType.Picklist
                || fieldDataType == Schema.DisplayType.Combobox 
                || fieldDataType == Schema.DisplayType.MULTIPICKLIST
               ) {
                   if(!fieldAPIName.getDescribe().isCalculated() && fieldAPIName.getDescribe().isUpdateable()) {
                       wrapperTaskFieldObj.key = fieldAPIName.getDescribe().getName();
                       wrapperTaskFieldObj.value = fieldAPIName.getDescribe().getLabel();
                       wrapperTaskFieldObj.dataType = CadenceService.getDataType(objectStr, wrapperTaskFieldObj.key);
                       if (wrapperTaskFieldObj.dataType == 'Picklist' || wrapperTaskFieldObj.dataType == 'MultiPickList'){
                           wrapperTaskFieldObj.listPicklistValues = CadenceService.getPicklistValues(objectStr, wrapperTaskFieldObj.key);
                       }
                       listWrapperTaskFields.add(wrapperTaskFieldObj);
                   }
               }
        }
        return listWrapperTaskFields;
    }
    
    public static List<Criterion> getFieldsWithLabels(String objectStr){
        List<Criterion> fieldsWithLabels = new List<Criterion>();
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        for (String field : fieldsMap.keySet()) {
            Criterion c = new Criterion();
            Schema.sObjectField fieldAPIName = fieldsMap.get(field);
            Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();           
            Schema.DescribeFieldResult dfr = fieldAPIName.getDescribe();
            Integer LengthOfField = dfr.getLength();
            
         
            if (fieldDataType == Schema.DisplayType.Boolean 
                || fieldDataType == Schema.DisplayType.Double 
                || fieldDataType == Schema.DisplayType.Integer
                || fieldDataType == Schema.DisplayType.Email
                || (fieldDataType == Schema.DisplayType.String )
                || fieldDataType == Schema.DisplayType.Picklist
                || (fieldDataType == Schema.DisplayType.Textarea && (LengthOfField <= 255 && (fieldDataType != Schema.DisplayType.ENCRYPTEDSTRING)) )               
                || fieldDataType == Schema.DisplayType.Combobox
                || fieldDataType == Schema.DisplayType.MULTIPICKLIST
               ){
                   if(!fieldAPIName.getDescribe().isCalculated() && fieldAPIName.getDescribe().isUpdateable()) {
                       c.fieldName = fieldAPIName.getDescribe().getName();
                       c.fieldLabel = fieldAPIName.getDescribe().getLabel();
                       
                       c.fieldDataType = getDataType(objectStr, c.fieldName);
                       if (c.fieldDataType == 'Picklist' || c.fieldDataType == 'MultiPickList'){
                           c.listPicklistValues = getPicklistValues(objectStr, c.fieldName);
                       }
                       fieldsWithLabels.add(c);
                   }
               } 
        }
        
        return fieldsWithLabels;
    }
    
    public static String getDataType(String objectStr, String field) {
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        Schema.DisplayType fieldType = fieldsMap.get(field).getDescribe().getType();
        String dataType = 'String';
        if (fieldType == Schema.DisplayType.Boolean) {
            dataType = 'Boolean';
        } else if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Integer) {
            dataType = 'Number';
        } else if (fieldType == Schema.DisplayType.String) {
            dataType = 'String';
        } else if (fieldType == Schema.DisplayType.Picklist) {
            dataType = 'Picklist';
        }else if (fieldType == Schema.DisplayType.Email) {
            dataType = 'Email';
        }else if (fieldType == Schema.DisplayType.MULTIPICKLIST) {
            dataType = 'MultiPickList';
        }
        return dataType;
    }
    
    public static List<String> getPicklistValues(String objectStr, String field) {
        List<String> picklistValues = new List<String>();
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        Schema.sObjectField fieldAPIName = fieldsMap.get(field);
        Schema.DescribeFieldResult fieldResult = fieldAPIName.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : values) {
            picklistValues.add(picklistVal.getLabel());
        }     
        return picklistValues;
    }
    
    
    public static void setParticipantsActivation(Id cadId, Boolean active) {
        Cadence__c cad = [Select Id, Status__c, Participent_Activation__c, Record_Type__c from Cadence__c where Id = :cadId];
        if(cad.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL)) {
            return;
        }
        List<SObject> objList = getCadenceParticipants(cadId, cad.Record_Type__c);
        if(objList == null || objList.isEmpty()) {
            return;
        }
        for(SObject obj : objList) {
            if(active) {
                obj.put(nameSpace+'isActivated__c', true);
            } else {
                obj.put(nameSpace+'isActivated__c', false);
            }
        }
        update objList;
        
    }
    
    public static List<SObject> getCadenceParticipants(Id cadId, String objName) {
        String query = 'Select Id, Name, '+nameSpace+'Cadence_ID__c, '+nameSpace+'isActivated__c';
        query += ' FROM '+ objName +' WHERE '+nameSpace+'Cadence_Id__c = :cadId';
        return Database.query(query);
    }
    
    //This method is to create participant actions  
    public static List<Sequence_Action__c> createActionParticipants(Map<Id, List<CadenceAction__c>> objIdToActionMap, String objName) {
        
        List<Sequence_Action__c> partActionsToCreate = new List<Sequence_Action__c>(); 
        for(Id objId : objIdToActionMap.keySet()) {
            List<CadenceAction__c> cadActions = objIdToActionMap.get(objId);
            for(CadenceAction__c cadAct : cadActions) {
                Sequence_Action__c partAct = new Sequence_Action__c();
                partAct.Name = cadAct.Name;
                partAct.CadenceAction_ID__c = cadAct.Id;
                if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                    partAct.Lead_Id__c = objId;	
                } else {
                    partAct.Contact_Id__c = objId;
                }
                partActionsToCreate.add(partAct);
            }	
        }
        insert partActionsToCreate;	
        return partActionsToCreate;			
    }
    
    public Static Map<String, List<sObject>> processObjectList(List<Contact> contactList){
        List<Contact> contactListWithCadenceIds = new List<Contact>();
        List<Contact> contactListWithoutCadenceIds = new List<Contact>();
        for(Contact conObj : contactList){
            if (conObj.Cadence_ID__c == null || string.valueOf(conObj.Cadence_ID__c).trim() == ''){
                contactListWithoutCadenceIds.add(conObj);
            }else{
                contactListWithCadenceIds.add(conObj);
            }
        }
        Map<String, List<sObject>> MapOfSobjList = New Map<String, List<sObject>>();
        MapOfSobjList.put('contactListWithoutCadenceIds',contactListWithoutCadenceIds);
        MapOfSobjList.put('contactListWithCadenceIds',contactListWithCadenceIds);
        return MapOfSobjList;
    } 
    
    public Static Map<String, List<Lead>> processObjectList(List<Lead> leadList){
        List<Lead> leadListWithCadenceIds = new List<Lead>();
        List<Lead> leadListWithoutCadenceIds = new List<Lead>();
        for(Lead conObj : leadList){
            if (conObj.Cadence_ID__c == null || string.valueOf(conObj.Cadence_ID__c).trim() == ''){
                leadListWithoutCadenceIds.add(conObj);
            }else{
                leadListWithCadenceIds.add(conObj);
            }
        }
        Map<String, List<Lead>> MapOfSobjList = New Map<String, List<Lead>>();
        MapOfSobjList.put('leadListWithoutCadenceIds',leadListWithoutCadenceIds);
        MapOfSobjList.put('leadListWithCadenceIds',leadListWithCadenceIds);
        return MapOfSobjList;
    }
    
    /* Method to create email message
* @Param : sObjectId - List of sobject having email Ids,EmailTemplateId - Email Template Id
*/
    public static Messaging.MassEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId){
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectIds(new List<Id>{sObjectId});
        mail.setTemplateId(EmailTemplateId);
        return mail; 
    }
    
    public static Task getEmailTask(Id sequenceActionId, String actionName, Id sObjectId, Id templateId) {
        Task t = new Task();
        t.Subject = 'Emails: '+ actionName;
        t.Description = templateId;
        t.WhoId = sObjectId;
        t.TaskSubtype = 'Email'; 
        t.Sequence_Action__c = sequenceActionId; 
        return t;
    }
    
    /* 
* Method to perform Task Actions
* @Param : Id - Id of sobject (Lead/Contact),taskDescription - Json OfTaskObj
*/
    public static Task performTaskAction(Id sObjectId, String taskDescription){
        Task taskObj = (Task)JSON.deserialize(taskDescription, Task.class);
        taskObj.WhoId = sObjectId;
        return taskObj;
    }
    
    public static List<SObject> assignCadenceToParticipants(Map<Id, Cadence__c> cadMap, List<SObject> sObjectList, String objName) {
        List<SObject> objList = new List<SObject>();
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        for(SObject Obj : sObjectList) {
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, obj, objName);
            if(obj.get(nameSpace+'Cadence_Id__c') != null) {
                objIdToAllCadActListMap.put((Id)obj.get('Id'), cadMap.get((Id)obj.get(nameSpace+'Cadence_Id__c')).CadenceActions__r);
                objList.add(obj); 
            }
        }
        createActionParticipants(objIdToAllCadActListMap, objName);
        update objList; 
        return objList; 
    }
    
    public static Map<Id, List<Sequence_Action__c>> getRemainingParticipantActions(Set<Id> objIds, String objName) {
        Map<Id, List<Sequence_Action__c>> objToParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>(); 
        List<Sequence_Action__c> participantActions;
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            participantActions = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c From Sequence_Action__c 
                                  where Lead_Id__c IN :objIds AND isActionPerformed__c = false 
                                  order by CadenceAction_Id__r.Day__c, CadenceAction_Id__r.Hour__c];
        } else {  
            participantActions = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c From Sequence_Action__c 
                                  where Contact_Id__c IN :objIds AND isActionPerformed__c = false 
                                  order by CadenceAction_Id__r.Day__c, CadenceAction_Id__r.Hour__c];
        }
        for(Sequence_Action__c partAct : participantActions) {
            if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                if(objToParticipantActionsMap.containsKey(partAct.Lead_Id__c)) {
                    objToParticipantActionsMap.get(partAct.Lead_Id__c).add(partAct);
                } else {
                    objToParticipantActionsMap.put(partAct.Lead_Id__c, new List<Sequence_Action__c>{partAct});
                }
            } else {
                if(objToParticipantActionsMap.containsKey(partAct.Contact_Id__c)) {
                    objToParticipantActionsMap.get(partAct.Contact_Id__c).add(partAct);
                } else {
                    objToParticipantActionsMap.put(partAct.Contact_Id__c, new List<Sequence_Action__c>{partAct});
                }
            }	
        }
        return objToParticipantActionsMap;
    }
    
    public static void deleteSobjectsByIds(String ObjType, List<Id> ids){
        List<SObject> sObjList = CadenceSelector.getSobjectListByIds(ObjType, ids);
        delete sObjList;
    }
    
    public static void deleteUnperformedPartActions(Map<Id, Id> objIdToCadIdMap, String objName) {
        
        //Returning if nothing to remove
        if(objIdToCadIdMap.isEmpty()) {
            return;
        }
        
        //Deleting the part action object on changing the cadence  
        Set<Id> objIds = objIdToCadIdMap.keySet();
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            List<Sequence_Action__c> partsOfLead = [SELECT Id, Lead_Id__c, Contact_Id__c, CadenceAction_Id__c, CadenceAction_Id__r.Cadence_Id__c FROM Sequence_Action__c WHERE Lead_Id__c IN :objIds AND isActionPerformed__c=false];
            List<Sequence_Action__c> partsToDelete = new List<Sequence_Action__c>();
            for(Sequence_Action__c partAct : partsOflead) {
                if(objIdToCadIdMap.get(partAct.Lead_Id__c) == partAct.CadenceAction_Id__r.Cadence_Id__c) {
                    partsToDelete.add(partAct);
                }
            } 
            delete partsToDelete;
        } else {
            List<Sequence_Action__c> partsOfContact = [SELECT Id, Lead_Id__c, Contact_Id__c, CadenceAction_Id__c, CadenceAction_Id__r.Cadence_Id__c FROM Sequence_Action__c WHERE Contact_Id__c IN :objIds AND isActionPerformed__c=false];
            List<Sequence_Action__c> partsToDelete = new List<Sequence_Action__c>();
            for(Sequence_Action__c partAct : partsOfContact) {
                if(objIdToCadIdMap.get(partAct.Contact_Id__c) == partAct.CadenceAction_Id__r.Cadence_Id__c) {
                    partsToDelete.add(partAct);
                }
            } 
            delete partsToDelete;
        }	     
    }
    
    public static List<SObject> getSObjectsToProcess(List<SObject> objList, Map<Id, Cadence__c> cadMap, String objName) {
        
        //Initializing the soject list as per obj
        List<SObject> sObjectsToProcess;
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            sObjectsToProcess = new List<Lead>();
        } else {
            sObjectsToProcess = new List<Contact>();
        }   	 
        Map<Id, Id> oldPartActionToDelete = new Map<Id, Id>();
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        
        //Updating the obj list with cadences 
        for(SObject obj : objList) {
            if(obj.get(nameSpace+'Cadence_Id__c') == null) {
                Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, obj, objName);
                if(cad != null) {
                    sObjectsToProcess.add(obj);
                    objIdToAllCadActListMap.put((Id)obj.get('Id'), cad.CadenceActions__r);
                }				
            } else {
                Id cadId = (Id)obj.get(nameSpace+'Cadence_Id__c'); 
                SObject sObj = RuleCriterionMatcher.matchExitCriterion(cadMap.get((Id)obj.get(nameSpace+'Cadence_Id__c')), obj, objName);
                if(sObj != null) {
                    oldPartActionToDelete.put((Id)obj.get('Id'), cadId); 
                    Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, obj, objName);
                    if(cad != null) {
                        sObjectsToProcess.add(obj);
                        objIdToAllCadActListMap.put((Id)obj.get('Id'), cad.CadenceActions__r);
                    }				
                } else {
                    sObjectsToProcess.add(obj);
                }
            }
        }
        
        //Deleting old non performed participant actions 
        CadenceService.deleteUnperformedPartActions(oldPartActionToDelete, objName);
        //Creating new participant actions for new cadence  
        CadenceService.createActionParticipants(objIdToAllCadActListMap, objName); 
        
        return sObjectsToProcess;
        
    }    
    
    
    public static Map<Id, List<Sequence_Action__c>> performParticipantActions(List<SObject> objList, Map<Id, List<Sequence_Action__c>> partActionsMap) {
        
        Map<Id, List<Sequence_Action__c>> performedPartActions = new Map<Id, List<Sequence_Action__c>>();
        Map<Id, SObject> objMap = new Map<Id, SObject>(objList); 
        List<Sequence_Action__c> partActToUpdate = new List<Sequence_Action__c>();
        List<Task> tasksToCreate = new List<Task>();
        List<Messaging.MassEmailMessage> emailsToSend = new List<Messaging.MassEmailMessage>();
        
        //Return if no unperformed participant actions 
        if(partActionsMap == null || partActionsMap.isEmpty()) {
            return performedPartActions;
        } 
        
        //Processing the data to perform 
        for(Id objId : partActionsMap.keySet()) {
            for(Sequence_Action__c partAct : partActionsMap.get(objId)) {
                Boolean performed = false;
                if(partAct.CadenceAction_Id__r.Action_Id__r.Activation_Type__c.equals(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                    //Processing task type of participant action
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_TASK)) {
                        Task tsk = performTaskAction(objId, partAct.CadenceAction_Id__r.Action_Id__r.Task_Description__c);
                        tsk.Sequence_Action__c = partAct.Id;
                        tasksToCreate.add(tsk);
                        performed = true;
                    }
                    //Processing email type of participant action
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                        if(objMap.containsKey(objId) && objMap.get(objId).get('Email')!=null) {
                            emailsToSend.add(createEmailMessage(objId, partAct.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            tasksToCreate.add(getEmailTask(partAct.Id, partAct.Name, objId, partAct.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            performed = true;
                        } 
                    }
                } else { 
                    //Setting show on target list to true if it's a manual task
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Activation_Type__c.equals(CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL)) {
                        partAct.Show_on_Target_List__c = true;
                        partActToUpdate.add(partAct);
                    }
                }
                if(performed) {
                    partAct.isActionPerformed__c = true;
                    partActToUpdate.add(partAct);
                    if(performedPartActions.containsKey(objId)) {
                        performedPartActions.get(objId).add(partAct);
                    } else {
                        performedPartActions.put(objId, new List<Sequence_Action__c>{partAct});
                    }
                }
            } 
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
        }
        
        if(!tasksToCreate.isEmpty()) {
            if(System.isBatch()) {
                Database.SaveResult[] results = Database.insert(tasksToCreate, false);

            } else {
	            String tasksJson = JSON.serialize(tasksToCreate); 
    	        createTasks(tasksJson);
            }
        } 
        
        if(!partActToUpdate.isEmpty()) {
            Database.update(partActToUpdate, false);
        } 
        
        return performedPartActions;
         
    } 
    
    @future
    public static void createTasks(String tasksJson) {
        List<Task> tasks = (List<Task>)JSON.deserialize(tasksJson, List<Task>.class);
        //insert tasks; 
        Database.SaveResult[] results = Database.insert(tasks, false);
    }
    
    public static List<SObject> updateSObjectFields(List<SObject> objList, Map<Id, List<Sequence_Action__c>> partActionsMap, String objName, Boolean isAfter) {
        
        //Returning if list is empty		
        if(partActionsMap == null || partActionsMap.isEmpty()) {
            return null;
        }
        
        //Handling after update triggers 
        List<SObject> sObjectList = new List<SObject>();
        if (isAfter){
            for(SObject sObj : objList) {
                if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                    sObjectList.add(new Lead(Id=(Id)sObj.get('Id')));
                } else {
                    sObjectList.add(new Contact(Id=(Id)sObj.get('Id')));
                }
            }
            objList = sObjectList;
        }
        
        Map<Id, SObject> sObjsToUpdate = new Map<Id, SObject>();
        Map<Id, SObject> objMap = new Map<Id, SObject>(objList);
        List<Sequence_Action__c> partActList = new List<Sequence_Action__c>();
        
        //Getting fields map 
        Map<String, List<String>> objfieldDataTypeMap = CadenceUtil.getObjectFieldsType(objName);
        
        //Gettting participant action list 
        for(Id objId : partActionsMap.keySet()) {
            SObject sObj;
            partActList.addAll(partActionsMap.get(objId));
        } 		
        
        //Updating the obj fields 
        for(Sequence_Action__c partAct : partActList) {
            String fieldsToUpdate = partAct.CadenceAction_Id__r.Fields_To_Update_Action__c;
            if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
                Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
                fieldMap.remove('sobjectType');
                Id objId;
                if(partAct.Lead_Id__c == null) {
                    objId = partAct.Contact_Id__c;
                } else {
                    objId = partAct.Lead_Id__c;
                }
                for(String fieldName : fieldMap.keySet()) {
                    List<String> apiList;
                    apiList = objfieldDataTypeMap.get(fieldName);
                    CadenceUtil.updateFieldValue(objMap.get(objId), apiList[0], fieldMap.get(fieldName), apiList[1]);
                }
                sObjsToUpdate.put(objId, objMap.get(objId));					
            }
        }
        return sObjsToUpdate.values();
        
    }
    
    
    public static void processParticipantsWithCadences(List<SObject> objList, String objName, Boolean isTrigger) {
        
        Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(objName);
        Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();
        
        //Getting objList to process
        Map<Id, SObject> objMap = new Map<Id, SObject>(CadenceService.getSObjectsToProcess(objList, cadMap, objName));
        
        //Getting non performed participant actions 
        Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantActions(objMap.keySet(), objName);
        
        //Getting participant action to perform 
        for(SObject sObj : objMap.values()) {
            if((Boolean)sObj.get(nameSpace+'isActivated__c')) {
                List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get((Id)sObj.get(nameSpace+'Cadence_Id__c')), sObj, partActionsMap.get((Id)sObj.get('Id')), objName);
                if(!partActList.isEmpty()) {
                    partActToPerform.put((Id)sObj.get('Id'), partActList);		
                }
            } 		
        } 
        
        //perform participant actions  
        Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(objMap.values(), partActToPerform);
        
        //perform participant field update
        CadenceService.updateSObjectFields(objMap.values(), performedPartAct, objName, false);
        
        if(!isTrigger) {
            update objList;
        }
    }
    
}