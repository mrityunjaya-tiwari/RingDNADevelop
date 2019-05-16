public class Contacts  extends SObjectDomain {

	List<Contact> records = new List<Contact>();
	public static boolean fireTrigger = false;
	
	//Need to remove
	public static boolean flag = false;

	public Contacts(List<Contact> sObjectList) {
		super(sObjectList);
		records = (List<Contact>)sObjectList;
	}

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> sObjectList) {
			return new Contacts(sObjectList);
		}
	}


	/*public override void onBeforeInsert() {        
		
	}*/

	public override void onAfterInsert() {
		if(shouldTriggerFire()) {
			SequenceEngine.processSequences(CadenceConstants.CONTACT_OBJECT_NAME, records, New List<SObject>(), true);
		}
		
	}

	/*public override void onbeforeUpdate(Map<Id,SObject> existingRecords){
	
	}*/
	
	public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
	 	if(shouldTriggerFire()) {
			SequenceEngine.processSequences(CadenceConstants.CONTACT_OBJECT_NAME, records, New List<SObject>(), true);
		}
 	}
	 
	 boolean shouldTriggerFire(){
	 	return (System.isBatch() == false|| (System.isBatch() && fireTrigger == true));
	 }
}