public class RingDNAHost {

    private static Map<String, String> baseUriMap = new Map<String, String>{
        'local' => 'https://<development.host>',
        'qa' => 'https://qa.ringdna.com',
        'production' => 'https://app.ringdna.com'
    };
    
    public static String getBaseUri() {
        String baseUri = '';
        
        RingDNAEnvironment__c[] environments = [SELECT value__c From RingDNAEnvironment__c];
        
        // There should only be one of these..
        if(! environments.isEmpty()){ 
            RingDNAEnvironment__c environment = environments[0];
            String environmentString = environment.value__c;
            
            baseUri = baseUriMap.get(environmentString);
        }
        
        
        return baseUri;
    }
    
}