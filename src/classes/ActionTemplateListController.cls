public class ActionTemplateListController {
    
    @AuraEnabled
    public static List <ActionTemplate> fetchActionTemplates() {
        List<ActionTemplate> actionTemplateList = New List<ActionTemplate>();
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts(); 
        List<Object> jsonList;
        if(test.isRunningTest()){
            jsonList = (List<Object>)JSON.deserializeUntyped(ActionTemplateListControllerTest.jsonStrForOneRecord);
        }else{
            jsonList = ringdnaAPI.getSMSTemplatesUpdated();
        }
        
        for (Object obj : jsonList) {
            Map<String, Object> objMap = (Map<String, Object>)obj;
            if((Boolean)objMap.get('enabled')) {
                actionTemplateList.add(New ActionTemplate(String.valueOf(objMap.get('name')),String.valueOf(objMap.get('id')), String.valueOf(objMap.get('teams')), String.valueOf(objMap.get('template'))));
            } 
        }
        return actionTemplateList;
    }
    
    public class ActionTemplate {
        @AuraEnabled String name {get;set;}
        @AuraEnabled String id {get;set;}
        @AuraEnabled String type {get;set;}
        @AuraEnabled String teams {get;set;}
        @AuraEnabled String template {get;set;}
        @AuraEnabled String selectButtonLabel {get;set;}
        @AuraEnabled String disableselectButton {get;set;}
        public ActionTemplate(String templateName, String templateId, String templateTeam, String templateType){
            name = templateName;
            id = templateId;
            teams = templateTeam;
            template = templateType;
            selectButtonLabel =  'Select'; 
            // disableselectButton = 'false';
        }
    }
}