@isTest
global class SendNativeMassEmailMockCallout implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        string str ='[{"success": true,"failureReason": null, "actionId": "12345"}]';
        response.setBody(str);
        response.setStatusCode(200);
        return response; 
    }

}