public with sharing class Lookup {
    @AuraEnabled
    public static String search(String searchTerm, String objName, List<Map<String, Object>> whereParams, List<String> additionalFields, List<String> searchFields){
        responseData rd = new responseData();

        try {
            String searchField = String.escapeSingleQuotes(searchFields[0]);
            objName = String.escapeSingleQuotes(objName);
            searchTerm = String.escapeSingleQuotes(searchTerm);
            String wildName = '%' + searchTerm + '%';
            String whereClause = ' WHERE (' + searchField + ' LIKE :wildName';
            Set<String> fieldsToQuery = new Set<String>{'Id', 'Name'};

            if (searchFields.size() > 1) {
                for (Integer i = 1; i < searchFields.size(); i++) {
                    whereClause += ' OR ' + String.escapeSingleQuotes(searchFields[i]) + ' LIKE :wildName';
                }
            }

            whereClause += ')';

            if(!additionalFields.isEmpty()){
                for(String field : additionalFields){
                    fieldsToQuery.add(String.escapeSingleQuotes(field));
                }
            }

            if(!whereParams.isEmpty()){
                for(Map<String, Object> param : whereParams){
                    String newClause = ' AND ' + String.escapeSingleQuotes((String)param.get('field')) + ' ' + String.escapeSingleQuotes((String)param.get('operator'));
                    Object values = param.get('values');

                    if(values instanceof String){
                        String stringValue = String.valueOf(values);
                        if(String.isEmpty(stringValue)){
                            continue;
                        }

                        stringValue = String.escapeSingleQuotes(stringValue);

                        whereClause += newClause + ' \'' + stringValue + '\'';
                    } else if(values instanceof List<Object>){
                        List<Object> listValues = (List<Object>)values;

                        if(listValues.isEmpty()){
                            continue;
                        }
                        //needs to be in ('id1', 'id2') format
                        String formattedValues = '(';

                        for(Object val : listValues){
                            String formattedVal = '\'' + String.escapeSingleQuotes((String)val) + '\'';
                            formattedValues += formattedVal + ',';
                        }

                        formattedValues = formattedValues.removeEnd(',');
                        formattedValues += ')';

                        whereClause += newClause + ' ' + formattedValues;
                    } else {
                        whereClause += newClause + ' ' + values;
                    }
                }
            }

            String query = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ', ') + ' FROM ' + objName + whereClause + ' WITH USER_MODE ORDER BY ' + searchField + ' ASC LIMIT 5';
            rd.put('searchResults', Database.query(query));
            rd.put('objLabel', Schema.getGlobalDescribe().get(objName.endsWith('__c') ? objName : objName).getDescribe().getLabel());//for opt groups
            rd.put('searchTerm', searchTerm);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }
}