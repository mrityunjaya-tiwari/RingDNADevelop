@isTest
public class LoggerTest {
	@isTest
    public static void testCreate(){
        //EnableLogger__c enableLoggerSettings =new EnableLogger__c(IsEnabled__c=true);
        //insert enableLoggerSettings;
        Logger.create('Test title', 'Test description');
    }
}
