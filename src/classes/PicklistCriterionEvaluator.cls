public with sharing class PicklistCriterionEvaluator implements ICriterionEvaluator{
    private static final String VALUE_SEPARATOR = '%&%';

    public PicklistCriterionEvaluator() {

    }

    public Boolean equals(Object a, Object b) {
        if (a == null || b == null) { return false; }
        Set<String> patternValues = this.prepareValueSet((String) b);
        return patternValues.contains((String) a);
    }

    public Boolean notEquals(Object a, Object b) {
        if (a == null || b == null) { return false; }
        Set<String> patternValues = this.prepareValueSet((String) b);
        return !patternValues.contains((String) a);
    }

    public Boolean greater(Object a, Object b) {
        return false;
    }

    public Boolean lessThan(Object a, Object b) {
        return false;
    }

    public Boolean lessOrEquals(Object a, Object b) {
        return false;
    }

    public Boolean greaterOrEquals(Object a, Object b) {
        return false;
    }

    public Boolean contains(Object a, Object b) {
        return false;
    }

    public Boolean startWith(Object a, Object b) {
        return false;
    }

    public Boolean notContains(Object a, Object b) {
        return false;
    }

    private Set<String> prepareValueSet(String val) {
        List<String> patValues = val.split(VALUE_SEPARATOR);
        for(Integer i = 0; i < patValues.size(); i++) {
            patValues[i] = patValues[i].trim();
        }
        return new Set<String> (patValues);
    }
}