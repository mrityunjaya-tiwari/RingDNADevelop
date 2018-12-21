global class CadenceScheduler implements schedulable{
    // Next schedule time must be in minutes
    public static Integer nextScheduleTime  = 15;
    global void execute(SchedulableContext SC) {
        // Schedule batch for Contact
        PerformCadenceActionBatch con=new PerformCadenceActionBatch(CadenceConstants.CONTACT_OBJECT_NAME);
        Database.executeBatch(con,200);
        // Schedule batch for lead
        PerformCadenceActionBatch led=new PerformCadenceActionBatch(CadenceConstants.LEAD_OBJECT_NAME);
        Database.executeBatch(led,200);
        // Schedule next cadence scheduler
        CadenceUtil.scheduleNextCadenceScheduler(nextScheduleTime);
    }
}