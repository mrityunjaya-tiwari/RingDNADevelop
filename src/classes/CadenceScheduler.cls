global class CadenceScheduler implements schedulable{
	// Next schedule time must be in minutes
	public static Integer nextScheduleTime  = 30;
	global void execute(SchedulableContext SC) {
		Integer runningBatch = CadenceUtil.getAllRunningBatch();
		if (runningBatch == 0){
			// Schedule batch for Contact
			PerformCadenceActionBatch con=new PerformCadenceActionBatch(new List<string>{CadenceConstants.CONTACT_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME});
			Database.executeBatch(con,100);

			// Schedule batch for lead
			PerformCadenceActionBatch led=new PerformCadenceActionBatch(new List<string>{CadenceConstants.LEAD_OBJECT_NAME, CadenceConstants.DB_OBJECT_NAME});
			Database.executeBatch(led,100);

			// Schedule batch for opportunity
			PerformCadenceActionBatch opportunity=new PerformCadenceActionBatch(new List<string>{CadenceConstants.OPPORTUNITY_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME,CadenceConstants.CONTRACT_OBJECT_NAME,CadenceConstants.PRICE_BOOK_OBJECT_NAME});
			Database.executeBatch(opportunity,100);
			// Schedule next cadence scheduler
		}
		CadenceUtil.scheduleNextCadenceScheduler(nextScheduleTime);
	}
}