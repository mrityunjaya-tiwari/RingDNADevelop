public class PerformOpportunityActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {

	public PerformOpportunityActionBatch() {  
	} 

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.OPPORTUNITY_OBJECT_NAME) ;
		return Database.getQueryLocator(query);
	} 
 
	public void execute(Database.BatchableContext bc, List<SObject> participantList) {
		PerformCadenceActionBatchService.runSequenceEngine(CadenceConstants.OPPORTUNITY_OBJECT_NAME, participantList);
	}

	public void finish(Database.BatchableContext bc) {
	}
}