@isTest
public class ActionDetailControllerTest {
    public static Action actionEmailManual; 
    public static Action actionEmailAuto;
    public static Action actionCallManual;
    public static Action actionVMManual;
    public static Action actionSMSManual;
    public static Action actionTaskManual;
    
    public static Task task;
    Public static Final String ACTION_TYPE_Email = 'Email';
    Public static Final String ACTION_TYPE_Call = 'Call';
    Public static Final String ACTION_TYPE_SMS = 'SMS';
    Public static Final String ACTION_TYPE_Task = 'Task';
    Public static Final String ACTION_TYPE_Voicemail = 'Call+Voicemail';
    public static EmailTemplate validEmailTemplate;
    static {
        validEmailTemplate=[select Id, isActive, Name, DeveloperName, TemplateType, FolderId, Subject from EmailTemplate LIMIT 1][0];
        
        //Mannual activation email action
        actionEmailManual = new Action();
        actionEmailManual.Name = 'testMannualEmail';
        actionEmailManual.Type = ACTION_TYPE_Email;
        actionEmailManual.TemplateId=validEmailTemplate.Id;
        actionEmailManual.ActivationType = 'Manual';
        
        //Automatic activation email action
        actionEmailAuto = new Action();
        actionEmailAuto.Name = 'testAutomaticEmail';
        actionEmailAuto.Type = ACTION_TYPE_Email;
        actionEmailAuto.TemplateId=validEmailTemplate.Id;
        actionEmailAuto.ActivationType = 'Automatic';
        
        //Manual activation Call action
        actionCallManual = new Action();
        actionCallManual.Name = 'testMannualCall';
        actionCallManual.Type = ACTION_TYPE_Call;
        actionCallManual.ActivationType = 'Manual';
        
        //Manual activation SMS action
        actionSMSManual = new Action();
        actionSMSManual.Name = 'testMannualSMS';
        actionSMSManual.Type = ACTION_TYPE_SMS;
        actionSMSManual.ActivationType = 'Manual';
        
        //Manual activation Call+VM action
        actionVMManual = new Action();
        actionVMManual.Name = 'testMannualVM';
        actionVMManual.Type = ACTION_TYPE_Voicemail;
        actionVMManual.ActivationType = 'Manual';
        
        //Manual activation Task action
        actionTaskManual = new Action();
        actionTaskManual.Name = 'testMannualTask';
        actionTaskManual.Type = ACTION_TYPE_Task;
        actionTaskManual.activationType = 'Manual';
        
        //Task object
        task=new Task();
        task.subject = 'Description';
        task.Description = 'testDesc';
        
    }
    @isTest
    public static void testInitCadenceActionData(){
        
        //Fetch email templates
        Test.startTest();
        ActionDetailController.ActionWrapper initActionObj = ActionDetailController.getActionWrapper();
        system.assertEquals(true,initActionObj.listEmailTemplate.size()>0);
        system.assertEquals(true, initActionObj.wrapperTaskFields.size()>0);
        Test.stopTest();
    }
    @isTest
    public static void testsaveAction(){
        
        insert task;
        
        //Conversion from wrapper to actual Action object and insertion into database
        Test.startTest();        
        Id actionIdEmailManual = ActionDetailController.saveAction(system.JSON.serialize(actionEmailManual),null); 
        Id actionIdEmailAuto = ActionDetailController.saveAction(system.JSON.serialize(actionEmailAuto),null);
        Id actionIdCallManual = ActionDetailController.saveAction(system.JSON.serialize(actionCallManual),null);
        Id actionIdSMSManual = ActionDetailController.saveAction(system.JSON.serialize(actionSMSManual),null);
        Id actionIdVMManual = ActionDetailController.saveAction(system.JSON.serialize(actionVMManual),null);
        Id actionIdTaskManual = ActionDetailController.saveAction(system.JSON.serialize(actionTaskManual),task);
        System.assertNotEquals(null, actionIdEmailManual);
        System.assertNotEquals(null, actionIdEmailAuto);
        System.assertNotEquals(null, actionIdCallManual);
        System.assertNotEquals(null, actionIdSMSManual);
        System.assertNotEquals(null, actionIdTaskManual);
        System.assertNotEquals(null, actionIdVMManual);
        Test.stopTest();
    }
    
    @isTest
    public static void getFieldsWithLabelsTest() {
        List<CriterionWrapper> fieldsWithLabels;
        List<String> objectList = new List<String>();
        objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME,CadenceConstants.DB_OBJECT_NAME };
            
            Test.startTest();
        fieldsWithLabels = CadenceService.getFieldsWithLabels(objectList);
        Test.stopTest();
        
        System.assertEquals(true, fieldsWithLabels[0].fieldsDetail!=null);
        System.assertEquals(true, fieldsWithLabels!=null);
        System.assertEquals(true, fieldsWithLabels.size()>0);
    } 
    
    @isTest
    static void getActionDataTest() {
        
        insert task;
        ActionDetailController.ActionDataWrapper actionWrapEmailManual, actionWrapTask, actionWrapEmailAuto,
            actionWrapCall, actionWrapSMS, actionWrapVM;
        
        Test.startTest();
        //insert actions
        Id actionIdEmailManual = ActionDetailController.saveAction(system.JSON.serialize(actionEmailManual),null); 
        Id actionIdEmailAuto = ActionDetailController.saveAction(system.JSON.serialize(actionEmailAuto),null);
        Id actionIdCallManual = ActionDetailController.saveAction(system.JSON.serialize(actionCallManual),null);
        Id actionIdSMSManual = ActionDetailController.saveAction(system.JSON.serialize(actionSMSManual),null);
        Id actionIdVMManual = ActionDetailController.saveAction(system.JSON.serialize(actionVMManual),null);
        Id actionIdTaskManual = ActionDetailController.saveAction(system.JSON.serialize(actionTaskManual),task);
        
        //Actual action to ActionDataWrapper
        actionWrapEmailAuto = ActionDetailController.getActionData(actionIdEmailAuto);
        actionWrapEmailManual = ActionDetailController.getActionData(actionIdEmailManual);
        actionWrapCall = ActionDetailController.getActionData(actionIdCallManual);
        actionWrapSMS = ActionDetailController.getActionData(actionIdSMSManual);
        actionWrapVM = ActionDetailController.getActionData(actionIdVMManual);
        actionWrapTask = ActionDetailController.getActionData(actionIdTaskManual);
        Test.stopTest();
        
        //Check for Automatic Email
        Action actionEmailAuto=actionWrapEmailAuto.actionCls;
        System.assertEquals(true, actionWrapEmailAuto!=null);
        System.assertEquals('testAutomaticEmail', actionEmailAuto.name);
        System.assertEquals(ACTION_TYPE_Email, actionEmailAuto.type);
        System.assertEquals(validEmailTemplate.Id, actionEmailAuto.TemplateId);
        System.assertEquals(true, actionWrapEmailAuto.taskList==null);
        
        //Check for Manual Email
        Action actionEmailManual=actionWrapEmailManual.actionCls;
        System.assertEquals(true, actionWrapEmailManual!=null);
        System.assertEquals('testMannualEmail', actionEmailManual.name);
        System.assertEquals(ACTION_TYPE_Email, actionEmailManual.type);
        System.assertEquals(validEmailTemplate.Id, actionEmailManual.TemplateId);
        System.assertEquals(true, actionWrapEmailManual.taskList==null);
        
        //Check for Call
        Action actionCall=actionWrapCall.actionCls;
        System.assertEquals(true, actionWrapCall!=null);
        System.assertEquals('testMannualCall', actionCall.name);
        System.assertEquals(ACTION_TYPE_Call, actionCall.type);
        System.assertEquals(null, actionCall.TemplateId);
        System.assertEquals(true, actionWrapCall.taskList==null);
        
        //Check for SMS
        Action actionSMS=actionWrapSMS.actionCls;
        System.assertEquals(true, actionWrapSMS!=null);
        System.assertEquals('testMannualSMS', actionSMS.name);
        System.assertEquals(ACTION_TYPE_SMS, actionSMS.type);
        System.assertEquals(null, actionSMS.TemplateId);
        System.assertEquals(true, actionWrapSMS.taskList==null);
        
        //Check for Call+Voicemail
        Action actionVM=actionWrapVM.actionCls;
        System.assertEquals(true, actionWrapVM!=null);
        System.assertEquals('testMannualVM', actionVM.name);
        System.assertEquals(ACTION_TYPE_Voicemail, actionVM.type);
        System.assertEquals(null, actionVM.TemplateId);
        System.assertEquals(true, actionWrapVM.taskList==null);
        
        //Check for Task
        Action actionTask=actionWrapTask.actionCls;
        System.assertEquals(true, actionWrapTask!=null);
        System.assertEquals('testMannualTask', actionTask.name);
        System.assertEquals(ACTION_TYPE_Task, actionTask.type);
        System.assertEquals(null, actionTask.TemplateId);
        System.assertEquals(true, actionWrapTask.taskList!=null);
    }
    
    @isTest
    static void updateFieldValueTest() {
        
        Account account = new Account();  
        Contact contact= new Contact();
        
        Test.startTest();
        ActionDetailController.updateFieldValue(account, 'Name', 'Test', '');
        ActionDetailController.updateFieldValue(account,'AnnualRevenue','1500', 'currency');
        ActionDetailController.updateFieldValue(account, 'SLAExpirationDate__c', '2018-08-13', 'Date');
        ActionDetailController.updateFieldValue(account, 'NumberOfEmployees', '20', 'Number');
        insert account;
        ActionDetailController.updateFieldValue(contact, 'EntranceCriteria_Matched_Date__c', '2018-08-13 02:22:26' ,'datetime');
        ActionDetailController.updateFieldValue(contact, 'AccountId', account.Id, 'reference');
        ActionDetailController.updateFieldValue(contact, 'isActivated__c', 'true', 'boolean');
        Test.stopTest();
        
        System.assertEquals(true, account.AnnualRevenue != null);
        System.assertEquals(true, account.SLAExpirationDate__c != null);
        System.assertEquals(true, account.NumberOfEmployees != null);
        System.assertEquals(true, contact.EntranceCriteria_Matched_Date__c != null);
        System.assertEquals(true, contact.isActivated__c);
        System.assertEquals(true, contact.AccountId != null);
        System.assertEquals('Test', account.Name);
    }
    
    @isTest
    static void getActionByIdTest() {
        
        insert task;
        
        Test.startTest();
        //insert actions
        Id actionIdEmailManual = ActionDetailController.saveAction(system.JSON.serialize(actionEmailManual),null); 
        Id actionIdEmailAuto = ActionDetailController.saveAction(system.JSON.serialize(actionEmailAuto),null);
        Id actionIdCallManual = ActionDetailController.saveAction(system.JSON.serialize(actionCallManual),null);
        Id actionIdSMSManual = ActionDetailController.saveAction(system.JSON.serialize(actionSMSManual),null);
        Id actionIdVMManual = ActionDetailController.saveAction(system.JSON.serialize(actionVMManual),null);
        Id actionIdTaskManual = ActionDetailController.saveAction(system.JSON.serialize(actionTaskManual),task);
        
        //Conversion from action object to Action wrapper
        Action actionEmailAuto=ActionDetailController.getActionById(actionIdEmailAuto);
        Action actionTask=ActionDetailController.getActionById(actionIdTaskManual);
        Action actionEmailManual=ActionDetailController.getActionById(actionIdEmailManual);
        Action actionCall=ActionDetailController.getActionById(actionIdCallManual);
        Action actionSMS=ActionDetailController.getActionById(actionIdSMSManual);
        Action actionVM=ActionDetailController.getActionById(actionIdVMManual);
        Test.stopTest();
        
        System.assertEquals('testAutomaticEmail',actionEmailAuto.name);
        System.assertEquals('testMannualEmail',actionEmailManual.name);
        System.assertEquals('testMannualCall',actionCall.name);
        System.assertEquals('testMannualSMS',actionSMS.name);
        System.assertEquals('testMannualVM',actionVM.name);
        System.assertEquals('testMannualTask',actionTask.name);
    }
}