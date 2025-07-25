/**
 * @description A fluent builder for creating dynamic, secure SOQL queries.
 * It enforces security by using bind variables and running queries in User Mode. 
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingQueryBuilder {

    private TrainingQueryRequest request;
    private List<String> selectFields;
    private String fromObject;
    private List<String> whereConditions;
    private List<String> orderByFields;
    private Integer limitResults;
    private Integer offsetResults;
    private Map<String, Object> bindVars;

    public TrainingQueryBuilder(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.selectFields = new List<String>();
        this.whereConditions = new List<String>();
        this.orderByFields = new List<String>();
        this.bindVars = new Map<String, Object>();
        this.offsetResults = 0;
    }

    public TrainingQueryBuilder selectFrom(String objectApiName) {
        // ... (Logic from source document) 
        this.fromObject = objectApiName;
        return this;
    }

    public TrainingQueryBuilder addSelectField(String fieldPath) {
        // ... (Logic from source document) 
        this.selectFields.add(fieldPath);
        return this;
    }
    
    public TrainingQueryBuilder clearSelectFields() {
        this.selectFields.clear();
        return this;
    }

    public TrainingQueryBuilder addWhereCondition(String conditionFragment, String bindKey, Object value) {
        // ... (Logic from source document) 
        this.whereConditions.add(conditionFragment);
        this.bindVars.put(bindKey, value);
        return this;
    }

    public TrainingQueryBuilder addWhereConditionRaw(String rawConditionFragment) {
        this.whereConditions.add(rawConditionFragment);
        return this;
    }

    public TrainingQueryBuilder orderBy(String field, String direction) {
        // ... (Logic from source document) 
        this.orderByFields.add(field + ' ' + direction.toUpperCase());
        return this;
    }

    public TrainingQueryBuilder setLimit(Integer count) {
        this.limitResults = count;
        return this;
    }

    public TrainingQueryBuilder setOffset(Integer offset) {
        this.offsetResults = offset;
        return this;
    }

    public String buildSOQLString() {
        // ... (Logic from source document) 
        String soql = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + fromObject;
        if (!whereConditions.isEmpty()) {
            soql += ' WHERE ' + String.join(whereConditions, ' AND ');
        }
        if (!orderByFields.isEmpty()) {
            soql += ' ORDER BY ' + String.join(orderByFields, ', ');
        }
        if (limitResults != null && limitResults > 0) {
            soql += ' LIMIT ' + limitResults;
        }
        if (offsetResults != null && offsetResults > 0) {
            soql += ' OFFSET ' + offsetResults;
        }
        return soql;
    }

    public List<SObject> executeQuery() {
        String queryString = buildSOQLString();
        System.debug(LoggingLevel.INFO, 'Executing Query: ' + queryString);
        // Executes the query in user context with safe bind variables 
        return Database.queryWithBinds(queryString, this.bindVars, AccessLevel.USER_MODE);
    }

    public Integer executeCountQuery() {
        // ... (Logic from source document) 
        String queryString = buildSOQLString();
        // Executes the query in user context with safe bind variables 
        return Database.countQueryWithBinds(queryString, this.bindVars, AccessLevel.USER_MODE);
    }

    public class TrainingQueryException extends Exception {}
}