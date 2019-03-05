public class LookupFieldController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    public class UserListWrapper{
        @AuraEnabled public String userName;
        @AuraEnabled public String userId;
    } 
    @AuraEnabled
    public static List<LookupFieldController.UserListWrapper> getUserWrapper(){
        return CadenceService.getUserWrapperList();
    }
}