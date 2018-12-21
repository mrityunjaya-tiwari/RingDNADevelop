public with sharing class RuleCriterionMatcherHelper {
    
    
    public static Map<Id, CriterionSet> getCadenceWiseCriterions(List<Cadence__c> cadences, String criterionType) {

    	Map<Id, CriterionSet> cadenceCriterions = new Map<Id, CriterionSet>();
		for(Cadence__c cad : cadences) {
			CriterionSet csObj;
			if(criterionType.equalsIgnoreCase(CadenceConstants.CRITERION_TYPE_ENTRY)) {
				csObj = CriterionSet.parse(cad.Entrance_Criteria__c);
				csObj.postFixExpression = cad.Entrance_Criteria_PE__c;
			} else {
				System.debug('Exit Criterion for cad= '+ cad);
				System.debug('Exit Criterion = '+ cad.Exit_Criteria__c);
				csObj = CriterionSet.parse(cad.Exit_Criteria__c);
				csObj.postFixExpression = cad.Exit_Criteria_PE__c;
			}  
			cadenceCriterions.put(cad.Id, csObj);
		}						
    	return cadenceCriterions;
    }
    
    public static Map<Id, CriterionSet> getActionWiseCriterions(List<CadenceAction__c> cadActions) {
    	Map<Id, CriterionSet> cadActionCriterions = new Map<Id, CriterionSet>();
		for(CadenceAction__c cadAction : cadActions) {
			if(cadAction == null) {
				continue;
			}
			System.debug('Cadence action = '+ cadAction);
			if(cadAction.Action_Criterion__c != null && !cadAction.Action_Criterion__c.equals('')) {
				CriterionSet csObj = CriterionSet.parse(cadAction.Action_Criterion__c);
				csObj.postFixExpression = cadAction.Action_Criteria_PE__c;
				cadActionCriterions.put(cadAction.Id, csObj);
			} else {
				cadActionCriterions.put(cadAction.Id, null);
			}
		}						
    	return cadActionCriterions;
    }

   public static Boolean cadenceCriterionMatches(SObject obj, CriterionSet cs) {

		Boolean cadCriteriaMatched = false;
		FormulaSObjectValue fsv = new FormulaSObjectValue(obj);
		if(cs==null) {
			return false; 
		}
		System.debug('cs is = '+ cs);
		if(!cs.executionCriterion.contains(CadenceConstants.EXECUTION_CRITERION_NO_CRITERION)){
			cadCriteriaMatched = matchEntryCriteria(cs,fsv);
		}else{
			cadCriteriaMatched = true;
		}
		return cadCriteriaMatched;
	}
	
	
	public static Boolean matchEntryCriteria(CriterionSet cs, FormulaSObjectValue fsv){
		Boolean isAllCriteriasMatched = false;
		if(cs.executionCriterion.contains(CadenceConstants.EXECUTION_CRITERION_NO_CRITERION)){
			isAllCriteriasMatched = true;
		}else{
			String operator = cs.condition.contains('OR')?'OR':'AND';
			if(cs.condition.contains('Custom')){ 
				isAllCriteriasMatched = matchCustomLogic(cs.criterions, cs.postFixExpression, fsv);
			}else if(operator.equals('AND')){
				isAllCriteriasMatched = matchANDOperatorCriterias(cs.criterions.values(), fsv);
				
			}else if(operator.equals('OR')){
				isAllCriteriasMatched = matchOROperatorCriterias(cs.criterions.values(), fsv);
			}
		}
		return isAllCriteriasMatched;
	}

	
	public static Boolean matchCustomLogic(Map<Integer, Criterion> criteriaMap, String postFixExp, FormulaSObjectValue fsv){
		System.debug('post fix expression is ='+ postFixExp);
		List<String> postFixExpression = (List<String>)System.JSON.deserialize(postFixExp, List<String>.class);
		return evalutePostfixExpression(criteriaMap, postFixExpression, fsv); 
	}
	
   
    public static Boolean evalutePostfixExpression(Map<Integer, Criterion> criteriaMap, List<String> postFixExpression, 
		FormulaSObjectValue fsv){
    	
    	Stack stack = new Stack();
    	Boolean result = false;
    	for(String s: postFixExpression){
    		if(s.isNumeric()) {
    			stack.push(Integer.valueOf(s));
    		} else {
    			if(stack.size()>=2) {
    				Object op1 = stack.pop();
    				Object op2 = stack.pop();
    				Boolean tempResult = calculateExpression(op1, op2, criteriaMap, fsv, s);
    				stack.push(tempResult);
    			} else {
    				System.debug('Invalid Expression.');
                    return false;
    			}
    		}
       	}
    	if(stack.size()==1 && (stack.peek() instanceOf Boolean)) {
    		result = Boolean.valueOf(stack.pop());
    	} else {
    		System.debug('Invalid Expression.');
            return false;
    	}
    	
    	return result;
    	
    }
    
    
    public static Boolean calculateExpression(Object op1, Object op2, 
    											Map<Integer, Criterion> criteriaMap, 
    											FormulaSObjectValue fsv, String operator){
    	Boolean result = false;
    	Boolean matchResult1 = getCriteriaMatchResult(op1, criteriaMap, fsv);
    	Boolean matchResult2 = getCriteriaMatchResult(op2, criteriaMap, fsv);
    	
    	if(operator.equalsIgnoreCase('AND')){
    		result=matchResult1 && matchResult2;
    	}else if(operator.equalsIgnoreCase('OR')){
    		result = matchResult1 || matchResult2;
    	}
    	return result;
    }
     
    
    public static Boolean getCriteriaMatchResult(Object op, Map<Integer, Criterion> criteriaMap,
													FormulaSObjectValue fsv){
		Boolean matchResult = false;
		if(op instanceOf Integer){
			Criterion c = criteriaMap.get(Integer.valueOf(op));
    		matchResult = c.matches(fsv)?true:false;
    	}else if(op instanceOf Boolean){
    		matchResult = Boolean.valueOf(op);
    	}
		return matchResult;												
	}
    
    public static Boolean matchANDOperatorCriterias(List<Criterion> criteriaList, FormulaSObjectValue fsv){
		Boolean isAllCriteriasMatched = true;
		for(Criterion c: criteriaList){
			if(c.matches(fsv)){
				isAllCriteriasMatched = isAllCriteriasMatched && true;
			} else {
				isAllCriteriasMatched = false;
			}
		}
		return isAllCriteriasMatched;
	}
	
	public static Boolean matchOROperatorCriterias(List<Criterion> criteriaList, FormulaSObjectValue fsv){
		Boolean isAllCriteriasMatched = false;
		for(Criterion c: criteriaList){
			if(c.matches(fsv)){
				isAllCriteriasMatched = true;
			}
		}
		return isAllCriteriasMatched;
	}
	
	public static Cadence__c getPriorityCadence(List<Cadence__c> cadList) {
		
		Cadence__c mostRecent = cadList.get(0);
		Map<String, List<Cadence__c>> cadMap = new Map<String, List<Cadence__c>>();
		for(Cadence__c cad : cadList) {
			if(cadMap.containsKey(cad.matching_priority__c)) {
				cadMap.get(cad.matching_priority__c).add(cad);
			} else {
				cadMap.put(cad.matching_priority__c, new List<Cadence__c>{cad});
			}
			if(mostRecent.CreatedDate < cad.CreatedDate) {
				mostRecent = cad;
			} 
		}
		
		for(Integer i=1 ; i<=5; i++) {
			String key = 'P'+i;
			if(cadMap.containsKey(key)) {
				if(cadMap.get(key).size() == 1) {
					return cadMap.get(key).get(0);
				} else {
					return mostRecent;
				}
			}
		}
		return null;
	}
    
}