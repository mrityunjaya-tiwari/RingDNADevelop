@isTest
public with sharing class CriterionEvaluatorTest {
    
    @isTest
    static void stringCriterionEvaluatorTest() {
    	
    	StringCriterionEvaluator strEvaluator = new StringCriterionEvaluator();
    	System.assertEquals(true, strEvaluator.equals('Test', 'Test'));
    	System.assertEquals(true, strEvaluator.notEquals('Test', 'Test1'));
    	System.assertEquals(false, strEvaluator.greater('Test', 'Test'));
    	System.assertEquals(false, strEvaluator.lessThan('', ''));
    	System.assertEquals(false, strEvaluator.lessOrEquals('', ''));
    	System.assertEquals(false, strEvaluator.greaterOrEquals('', ''));
    	System.assertEquals(true, strEvaluator.contains('Testing', 'Test'));
    	System.assertEquals(true, strEvaluator.startWith('Testing', 'Test'));
    	System.assertEquals(true, strEvaluator.notContains('Test', 'Work'));
    	
    }
    
    @isTest
    static void booleanCriterionEvaluatorTest() {
    	
    	BooleanCriterionEvaluator boolEvaluator = new BooleanCriterionEvaluator();
    	System.assertEquals(true, boolEvaluator.equals(true, true));
    	System.assertEquals(true, boolEvaluator.notEquals(true, false));
    	System.assertEquals(false, boolEvaluator.greater('Test', 'Test'));
    	System.assertEquals(false, boolEvaluator.lessThan('', ''));
    	System.assertEquals(false, boolEvaluator.lessOrEquals('', ''));
    	System.assertEquals(false, boolEvaluator.greaterOrEquals('', ''));
    	System.assertEquals(false, boolEvaluator.contains('Testing', 'Test'));
    	System.assertEquals(false, boolEvaluator.startWith('Testing', 'Test'));
    	System.assertEquals(false, boolEvaluator.notContains('Test', 'Work'));
    	
    }
    
    @isTest
    static void numericCriterionEvaluatorTest() {
    	
    	NumericCriterionEvaluator numEvaluator = new NumericCriterionEvaluator();
    	System.assertEquals(true, numEvaluator.equals(4, 4));
    	System.assertEquals(true, numEvaluator.notEquals(4, 3));
    	System.assertEquals(true, numEvaluator.greater(4, 3));
    	System.assertEquals(true, numEvaluator.lessThan(3, 4));
    	System.assertEquals(true, numEvaluator.lessOrEquals(4, 4));
    	System.assertEquals(true, numEvaluator.greaterOrEquals(4, 4));
    	System.assertEquals(false, numEvaluator.contains(1, 1));
    	System.assertEquals(false, numEvaluator.startWith(1, 1));
    	System.assertEquals(false, numEvaluator.notContains(1, 1));
    	
    }

	@isTest
    static void picklistCriterionEvaluatorTest() {
    	
    	PicklistCriterionEvaluator pickEvaluator = new PicklistCriterionEvaluator();
    	System.assertEquals(false, pickEvaluator.greater(4, 3));
    	System.assertEquals(false, pickEvaluator.lessThan(3, 4));
    	System.assertEquals(false, pickEvaluator.lessOrEquals(4, 4));
    	System.assertEquals(false, pickEvaluator.greaterOrEquals(4, 4));
    	System.assertEquals(false, pickEvaluator.contains(1, 1));
    	System.assertEquals(false, pickEvaluator.startWith(1, 1));
    	System.assertEquals(false, pickEvaluator.notContains(1, 1));
    	
    }    
    
    
}