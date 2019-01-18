public with sharing class FormulaSObjectValue {
	
	public class FormulaSObjectValueException extends Exception {

    }
    
	private SObject current ;
	
	public FormulaSObjectValue(SObject obj) {
        this(obj, null);
    }
    
    public FormulaSObjectValue(SObject obj, SObject old) {
        if (obj == null) {
            throw new FormulaSObjectValueException();
        }
        current = obj;
    }
    
    
    public Object get(String fieldName) {
        try {
            Object value = current.get(fieldName);
            return value;
        } catch (System.SObjectException exc) {
            return null;
        }
    }
}