@isTest
public with sharing class TaskTriggerTest {
    
    @isTest
    static void createTask() {
    	
    	Task t = new Task();
    	t.Subject = 'Test';
    	insert t;
    } 
}