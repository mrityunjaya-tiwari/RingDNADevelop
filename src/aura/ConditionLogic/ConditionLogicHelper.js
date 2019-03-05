({
	valueChangeValidation : function(component, event, helper) {
        var listCount = component.get("v.criteriaListCount") ;
        if(listCount >= 3){
              
        	var inputField = component.find("formValidationId"); 
        	var val=inputField.get('v.value').toUpperCase();
            while(1){
                            val = val.replace("AND","+").replace("OR","+");
                            if(val.includes("AND")  || val.includes("OR")){
                                continue;
                            }
                            break;
                    }
            try {
          			var t = eval(val);
                    while(1){
                            val = val.replace("("," ").replace(")"," ").replace("+"," ");
                            if(val.includes("(")  || val.includes(")")  || val.includes("+")){
                                continue;
                            }
                            break;
                    }
                    var arr = val.split(" ");
                    var Max= 0,i=0;
                    for (i = 0; i < arr.length; i++) { 
                             if(Number(arr[i]) > Max){
                                Max = Number(arr[i]);
                            }
                        
                    }
                if(Number(Max) > Number(listCount) ){
                    inputField.setCustomValidity("Input condition number is not valid!");
                    inputField.reportValidity();
                }else{
                    inputField.setCustomValidity("");
                    inputField.reportValidity();
                    }
            	}
                catch(err) {
                   inputField.setCustomValidity("Input is not valid!");
                   inputField.reportValidity();
                }  
         }      
    },
     valueChangeCriteriaList : function(component, event, helper) {
       var criteriaListCount = component.get('v.criteriaListCount');
        var conditionsList = component.get('v.conditionsList');
        
        if (conditionsList.length == 2 && criteriaListCount >= 3) {
            conditionsList.push({'label':'Customize the logic', 'value':'Custom logic'});
        }
        else if (conditionsList.length == 3 && criteriaListCount == 2) {
            var listSize = conditionsList.length;
            conditionsList.splice([listSize-1], 1);
            var sc = component.get('v.selectedCondition');
            if (sc == 'Custom logic'){
                component.set('v.selectedCondition', "All of the conditions are met (AND)");
            }
        }
        component.set('v.conditionsList', conditionsList);
	}
})