public with sharing class CriterionEvaluatorFactory {

    private static Map<String, ICriterionEvaluator> evaluatorInstanceMap = new Map<String, ICriterionEvaluator>();
    static {
        ICriterionEvaluator eval;

        //evaluatorInstanceMap.put('DATETIME', new DatetimeCriterionEvaluator());

        //evaluatorInstanceMap.put('DATE', new DateCriterionEvaluator());

        //evaluatorInstanceMap.put('MULTIPICKLIST', new MultipicklistCriterionEvaluator());

        evaluatorInstanceMap.put('PICKLIST', new PicklistCriterionEvaluator());

        evaluatorInstanceMap.put('BOOLEAN', new BooleanCriterionEvaluator());

        //evaluatorInstanceMap.put('REFERENCE', new PicklistCriterionEvaluator());

        evaluatorInstanceMap.put('ID',  new PicklistCriterionEvaluator());

        eval = new NumericCriterionEvaluator();
        evaluatorInstanceMap.put('DOUBLE', eval);
        evaluatorInstanceMap.put('CURRENCY', eval);
        evaluatorInstanceMap.put('INTEGER', eval);
        evaluatorInstanceMap.put('PERCENT', eval);
        evaluatorInstanceMap.put('NUMBER', eval);

        eval = new StringCriterionEvaluator();
        evaluatorInstanceMap.put('STRING', eval);
        evaluatorInstanceMap.put('TEXTAREA', eval);
        evaluatorInstanceMap.put('EMAIL', eval);
        evaluatorInstanceMap.put('PHONE', eval);
        evaluatorInstanceMap.put('URL', eval);
        evaluatorInstanceMap.put('ADDRESS', eval);
        evaluatorInstanceMap.put('COMBOBOX', eval);
    }
    public static ICriterionEvaluator createNew(String fieldType) {
        ICriterionEvaluator evaluator = evaluatorInstanceMap.get(fieldType);
        System.debug('Evaluator: ' + evaluator);
        return evaluator;
    }
}