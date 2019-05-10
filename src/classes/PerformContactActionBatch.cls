public class PerformContactActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {

	public String objType;
	public String parentObj;
	public list<string> listOfobjecttype;

	public PerformContactActionBatch(List<String> listOfObjTypeAndParent) { 
		this.listOfobjecttype = listOfObjTypeAndParent; 
		if(listOfObjTypeAndParent != null && listOfObjTypeAndParent.size() > 0) {
			this.objType=listOfObjTypeAndParent[0];
		}
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = PerformCadenceActionBatchHelper.formQuery(listOfobjecttype) ;
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<sObject> objList) {
		Map<Id, SObject> parentMap = new Map<Id, SObject>();
		PerformCadenceActionBatchService.runSequenceEngine(objType, listOfobjecttype, objList);
	}

	public void finish(Database.BatchableContext bc) {
	}
}