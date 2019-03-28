public class LookupFieldController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    public class UserListWrapper{
        @AuraEnabled public String userName;
        @AuraEnabled public String userId;
    } 
	
	public class DandBCompanyListWrapper{
        @AuraEnabled public String Name;
        @AuraEnabled public String Id;
    } 
	
    @AuraEnabled
    public static List<LookupFieldController.UserListWrapper> getUserWrapper(){
        return CadenceService.getUserWrapperList();
    }
	
	@AuraEnabled
    public static List<LookupFieldController.DandBCompanyListWrapper> getDandBCompanyWrapper(){
        return CadenceService.getDandBCompanyWrapperList();        
    }
}
