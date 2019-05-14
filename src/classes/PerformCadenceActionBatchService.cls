public class PerformCadenceActionBatchService {
    
    public static void runSequenceEngine(string participantType, List<SObject> participantList) {	
    	SequenceEngine.processSequences(participantType, participantList, false);
    }
}