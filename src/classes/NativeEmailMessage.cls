public class NativeEmailMessage { 
    @AuraEnabled public string MailTo {get; set;}
    @AuraEnabled public string MailCc {get; set;}
    @AuraEnabled public string MailBcc {get; set;}
    @AuraEnabled public string Subject {get; set;}
    @AuraEnabled public string Body {get; set;}
    @AuraEnabled public Id TemplateId {get; set;}
    
    public NativeEmailMessage (){
        
    }
    
    public NativeEmailMessage ( string nativeMailTo, string nativeMailCc, 
                               string nativeMailBcc, string nativeSubject, string nativeBody, Id nativeTemplateId){
                                   MailTo = nativeMailTo;
                                   MailCc = nativeMailCc;
                                   MailBcc = nativeMailBcc;
                                   Subject = nativeSubject;
                                   Body = nativeBody;
                                   TemplateId = nativeTemplateId;
                               }
}