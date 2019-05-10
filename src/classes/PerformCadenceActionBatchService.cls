public class PerformCadenceActionBatchService {
    
    public static void runSequenceEngine(string participantType, List<string> participantTypeAndParentGroupsList, List<SObject> participantList)
    {
    	SequenceEngine.processSequences(participantType, participantTypeAndParentGroupsList, participantList, false);
    }
}