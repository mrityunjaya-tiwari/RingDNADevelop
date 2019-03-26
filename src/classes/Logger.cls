public class Logger {

    public static void create(String title, String description){
        /*
        EnableLogger__c enableLoggerSettings = [SELECT IsEnabled__c FROM EnableLogger__c LIMIT 1];
        if(enableLoggerSettings.IsEnabled__c==true){
            Logger__c loggerInstance = new Logger__c(Title__c=title, Description__c=description);
        	insert loggerInstance;
        }
		*/
        Logger__c loggerInstance = new Logger__c(Title__c=title, Description__c=description);
        insert loggerInstance;
    }
}