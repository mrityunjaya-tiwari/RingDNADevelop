public class RingDNAApiCallouts {

    private String sessionId;
    private String accountId;
    private String userId;
    private String host; 
    private final String HTTP_METHOD = 'GET';
    private final String BASE_URL = 'api/v2/app';
    private final String ACCOUNT_DETAILS_PATH = 'salesforce/verify';
    private final String CALL_NOTE_TEMPLATES_PATH = 'callNoteTemplates';
    private final String SMS_TEMPLATES_PATH = 'smsTemplates';
    private final String VOICEMAIL_DROPS_PATH = 'voicemailDrops';
    
    public RingDNAApiCallouts() {
        host = RingDNAHost.getBaseUri();
        Map<String, Object> accountDetails = getAccountDetails();
        if(accountDetails != null && !accountDetails.isEmpty()) {
        	sessionId = String.valueOf(accountDetails.get('sessionId'));
    	    accountId = String.valueOf(accountDetails.get('accountId'));
	        userId = String.valueOf(accountDetails.get('userId'));
        }	
    } 
    
    public Map<String, Object> getAccountDetails() {
        String uri = host + '/' + ACCOUNT_DETAILS_PATH;
        String endpoint = uri +
            '?' + 'sfUserId=' + UserInfo.getUserId() +
            '&' + 'sfSessionId=' + getSessionIdFrmVFPg(Page.SessionIdVfPage);
        
        if(test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new AccountDetailsMockClass());
        HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, null);
        if(httpResponse == null) {
            return null;
        }
        else{
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            return jsonMap;
        }
    }
    
    public Map<String, String> getCallNoteTemplates() {
        String uri = host + '/' + BASE_URL + '/' + CALL_NOTE_TEMPLATES_PATH;
        String endpoint = uri + '?' + 'accountId=' + accountId;
        if(sessionId == null || host == '') {
            return New Map<String, String>();
        }
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
        
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> callTemplatesData = new Map<String, String>();	
        for (Object obj : jsonList) {
            Map<String, Object> objMap = (Map<String, Object>)obj;
            if((Boolean)objMap.get('enabled')) {
            	callTemplatesData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('name'))); 	   
            }
        }
        return callTemplatesData;
    }
    
    public Map<String, String> getSMSTemplates() {
        String uri = host + '/' + BASE_URL + '/' + SMS_TEMPLATES_PATH;
        String endpoint = uri + '?' + 'sessionId='+ sessionid + '&' +'accountId=' + accountId;
        
        if(sessionId == null || host == '') {
            return New Map<String, String>();
        }
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
        
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> smsTemplatesData = new Map<String, String>();	
        for (Object obj : jsonList) {
            Map<String, Object> objMap = (Map<String, Object>)obj;
            if((Boolean)objMap.get('enabled')) {
            	smsTemplatesData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('name'))); 	   
            } 
        }
        return smsTemplatesData;
    } 
    public List<Object> getSMSTemplatesUpdated() {
        String uri = host + '/' + BASE_URL + '/' + SMS_TEMPLATES_PATH;
        String endpoint = uri + '?' + 'sessionId='+ sessionid + '&' +'accountId=' + accountId;
        system.debug('endpoint ' + endpoint);
        if(sessionId == null || host == '') {
            return New List<Object>();
        }
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
        return jsonList;
    } 
    
    public Map<String, String> getVoicemailDrops() {
        
        String uri = host + '/' + BASE_URL + '/' + VOICEMAIL_DROPS_PATH;
        String endpoint = uri + '?' +'accountId=' + accountId;
        if(sessionId == null || host == '') {
            return New Map<String, String>();
        } 
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> voicemailDropsData = new Map<String, String>();	
        for (Object obj : jsonList) {
            Map<String, Object> objMap = (Map<String, Object>)obj;
            voicemailDropsData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('label'))); 	   
        }
        return voicemailDropsData;
    }
    
    public HTTPResponse getResponse(String requestType, String endpoint, String sessionId) {
        try {
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(requestType);
            httpRequest.setEndpoint(endpoint);
            if(sessionId != null) {
                httpRequest.setHeader('sessionId', sessionId);    
            }
            return http.send(httpRequest);
        }  catch(Exception e) {
            return null;
        }
    }
    
    public String getSessionIdFrmVFPg(PageReference vfPageContainSessionId){
        String data ='';
            //String data= vfPageContainSessionId.getContent().toString();
        if(!test.isRunningTest()){
            data= vfPageContainSessionId.getContent().toString();
          }else{
            data =  'Session_Id_Start_Here'+userinfo.getSessionId()+'Session_Id_End_Here';
          }
        return data.substring(data.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), data.indexOf('Session_Id_End_Here'));
	}

}