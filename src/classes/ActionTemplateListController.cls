public class ActionTemplateListController {   
    @AuraEnabled
    public static List <ActionTemplate> fetchActionTemplates(String type) {
        List<ActionTemplate> actionTemplateList = New List<ActionTemplate>();
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts(); 
        List<Object> jsonList;
        if(test.isRunningTest()){
            jsonList = (List<Object>)JSON.deserializeUntyped(ActionTemplateListControllerTest.jsonStrForOneRecord);
        }else{
            if(type == 'SMS'){
                jsonList = ringdnaAPI.getSMSTemplatesUpdated(); 
            }
            else if(type == 'Call'){
                jsonList = ringdnaAPI.getCallNoteTemplatesUpdated();  
            }                      
        }
        for (Object obj : jsonList) {
            Map<String, Object> objMap = (Map<String, Object>)obj;           
            if((Boolean)objMap.get('enabled')) {                                               
                String teamName = '';
                List<Object> teams = (List<Object>)objMap.get('teams');
                if (teams != null){
                    for(Object team : teams){
                        Map<String, Object> teamMap = (Map<String, Object>)team;
                        Object teamObj = teamMap.get('team');                    
                        Map<String, Object> teamObjMap = (Map<String, Object>)teamObj;                    
                        teamName = teamName + String.valueOf(teamObjMap.get('name')) + ', ';
                    }                  
                    if(teamName == '' || teamName == null){
                        teamName = 'All';
                    }
                }
                
                actionTemplateList.add(New ActionTemplate(String.valueOf(objMap.get('name')),String.valueOf(objMap.get('id')), teamName.removeEnd(', '), String.valueOf(objMap.get('template'))));
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