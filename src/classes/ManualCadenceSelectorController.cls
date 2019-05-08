public class ManualCadenceSelectorController {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    private ApexPages.StandardSetController standardSetController;
    private ApexPages.StandardController standardController;
    public List<SObject> participants{get;set;}
    public SObject participant{get;set;}
    public String recordType{get;set;}
	
    public ManualCadenceSelectorController(ApexPages.StandardController standardController){
        this.standardController = standardController; 
        participant=(Contact)standardController.getRecord();
    }
	
    public ManualCadenceSelectorController(ApexPages.StandardSetController standardsetController){
        this.standardSetController = standardsetController;
        participants=standardsetController.getSelected();
        SObject obj;
        if(participants != null && participants.size()>0){
            obj=participants[0];
        	 
        }else{
            participants.add(standardsetController.getRecord());
            if(participants.size() > 0){
            	obj=participants[0];
            }   
        }
        if(obj != null){
            recordType=obj.getSObjectType().getDescribe().getName(); 
        }
    }
}