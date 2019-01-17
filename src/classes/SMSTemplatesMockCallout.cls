@isTest
global class SMSTemplatesMockCallout implements HttpCalloutMock{
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        system.debug('request'+request);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        string str ='[{"enabled": true,"groups": [], "id": 30, "name": "Sumit SMS Template","template": "Implemented for cadence"}]' ;
        response.setBody(str);
        response.setStatusCode(200);
        return response; 
    }
}