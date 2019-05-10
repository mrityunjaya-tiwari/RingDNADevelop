public class PerformCadenceActionBatchHelper {
    public static String formQuery(List<String> listOfobjecttype){
		List<CriterionWrapper> criterionWrapperList =  CadenceService.getFieldsWithLabelsForBatch(listOfobjecttype);
		String objecttype;
		if(listOfobjecttype != null && listOfobjecttype.size() > 0)
			objecttype = listOfobjecttype[0];
		
		String query = 'Select ';
		Set<String> allowedFields = new Set<String>();
		for(CriterionWrapper wrapper : criterionWrapperList ){
			for(Criterion criteria : wrapper.fieldsDetail ){
				allowedFields.add(criteria.fieldName);
			}
		}
		if(CadenceConstants.NAMESPACE != ''  && allowedFields.size() > 0){
			String apiNameWithNamespace;
			for(String fld : allowedFields){
				apiNameWithNamespace = CadenceConstants.NAMESPACE + fld;
				if(allowedFields.contains(apiNameWithNamespace)){
					allowedFields.remove(fld); 
				}
			}
		}
		query += String.join(new List<String>(allowedFields), ',');
		query += ' FROM '+ objecttype + '';
		return query;
	}
}