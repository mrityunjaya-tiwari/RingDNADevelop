@isTest
public class TestDataFactory {

    public static Account createAccount() {
    	Account acc = new Account();
        acc.Name = 'Test Account';
        return acc;
    }
    
    public static Contact createContact(Id accId, Id cadenceId) {
        Contact cont = new Contact();
        cont.LastName = 'Test Contact';
        cont.AccountId = accId;
        cont.Cadence_ID__c = cadenceId;
        return cont;
    }
     
    public static Lead createLead(Id cadenceId) {
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'Test Company';
        l.Cadence_Id__c = cadenceId;
        l.Priority__C = 12;
        return l;
    }
    
    public static Lead createLead() { 
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'Test Company';
        l.Priority__C = 12;
        return l;
    }
    
    public static Action__c createAction(String actionType) {
        Action__c action = new Action__c();
        action.Name = 'Test Action';
        action.Type__c = actionType;
        action.Activation_Type__c = 'Automatic';
        return action;
    }
    
    public static Cadence__c createCadence(String recordType) {
    	Cadence__c cad = new Cadence__c();
        cad.Name = 'Test Cadence';
        cad.Record_Type__c = recordType;
        cad.Status__c = true;
        cad.Participent_Activation__c = 'Automatic'; 
        return cad;
    } 
    
    public static CadenceAction__c createCadenceAction(Id cadId, Id actionId) {
        CadenceAction__c cadAction = new CadenceAction__c();
        cadAction.Cadence_Id__c = cadId;
        cadAction.Action_Id__c = actionId;
        cadAction.Name = 'Test Cadence Action';
        cadAction.Trigger_Type__c = 'Immediate';
        return cadAction;
    }
    
	public static String createCadenceJSON(List<Criterion> criterionList, String condition, String priorityFormula) {
		
		Map<Integer, Criterion> criterionMap = new Map<Integer, Criterion>();
		for(Criterion crit : criterionList) {
			criterionMap.put(crit.Id, crit);
		}
		
		CriterionSet cs= new CriterionSet();
		cs.criterionPriorityFormula='';
		if(condition.containsIgnoreCase('AND')) {
			cs.condition = CadenceConstants.CONDITION_AND;
		} else if(condition.containsIgnoreCase('OR')) {
			cs.condition = CadenceConstants.CONDITION_OR;
		} else {
			cs.condition = CadenceConstants.CONDITION_CUSTOM;
			cs.criterionPriorityFormula = priorityFormula;
		}
		
		cs.executionCriterion = 'Conditions are met';
		cs.criterions = criterionMap;
		
		String criterionJSON = JSON.serialize(cs);
		system.debug('serialize json = '+ criterionJSON);
		return criterionJSON;
		
	}

    public static Criterion createCriterion(Integer id, String fieldName, String fieldDataType, String operation, String value){
		Criterion c = new Criterion();
		c.id = id;
		c.fieldName = fieldName;
		c.fieldDataType = fieldDataType;
		c.operation = operation;
		c.value = value;
		return c;
	}
    
    public static String createCadJsonWithNameCriterions(String firstName, String lastName, String condition, String priorityFormula) {
        
        List<Criterion> criterionList = new List<Criterion>();
        Criterion c1 = TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', firstName);
        Criterion c2 = TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', lastName);
        Criterion c3 = TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Rest');
        criterionList.add(c1);
        criterionList.add(c2);
        criterionList.add(c3);
        
        return createCadenceJSON(criterionList, condition, priorityFormula);

    }
    
}