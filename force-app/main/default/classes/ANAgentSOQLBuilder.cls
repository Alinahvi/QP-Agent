public with sharing class ANAgentSOQLBuilder {

    public class BuiltQuery {
        public String soql;
        public String alias;
        public String groupAlias;
    }

    public static BuiltQuery build(ANAgentAggregationSpec spec) {
        if (spec == null) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Spec cannot be null');
        }
        if (String.isBlank(spec.metricFieldApi) || String.isBlank(spec.aggFn)) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Spec missing metricFieldApi or aggFn');
        }

        BuiltQuery out = new BuiltQuery();
        out.alias = 'aggV';
        out.groupAlias = 'g';

        String metric = spec.metricFieldApi;

        // Build WHERE clause
        String whereClause = ' FROM AGENT_OU_PIPELINE_V2__c WHERE IsDeleted = false';
        if (spec.requireNonNullMetric == true) {
            whereClause += ' AND ' + metric + ' != null';
        }
        if (!String.isBlank(spec.filterWhere)) {
            // spec.filterWhere must already be safe/escaped by the filter parser
            whereClause += ' AND (' + spec.filterWhere + ')';
        }

        String soql = '';

        // No group-by: single aggregate
        if (String.isBlank(spec.groupByFieldApi)) {
            soql = 'SELECT ' + spec.aggFn + '(' + metric + ') ' + out.alias + whereClause;
        } else {
            // Grouped aggregate
            soql = 'SELECT ' + spec.groupByFieldApi + ' ' + out.groupAlias + ', ' + spec.aggFn + '(' + metric + ') ' + out.alias;

            if (spec.perAENormalize == true) {
                soql += ', COUNT_DISTINCT(EMP_ID__c) nPeople';
            }

            soql += whereClause;

            // Restrict to a fixed set of group values, if provided
            if (spec.restrictInValues != null && !spec.restrictInValues.isEmpty()) {
                List<String> escapedValues = new List<String>();
                for (String v : spec.restrictInValues) {
                    escapedValues.add('\'' + String.escapeSingleQuotes(v) + '\'');
                }
                soql += ' AND ' + spec.groupByFieldApi + ' IN (' + String.join(escapedValues, ',') + ')';
            }

            soql += ' GROUP BY ' + spec.groupByFieldApi;
        }

        if (spec.limitN != null && spec.limitN > 0) {
            soql += ' LIMIT ' + spec.limitN;
        }

        out.soql = soql;
        return out;
    }
    
    public static String buildNonAggregate(ANAgentAggregationSpec spec) {
        if (spec == null) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Spec cannot be null');
        }
        if (String.isBlank(spec.metricFieldApi)) {
            throw new ANAgentErrors.InvalidAggregationSpecException('Spec missing metricFieldApi');
        }

        String soql = 'SELECT Id, ' + spec.metricFieldApi;
        
        if (String.isNotBlank(spec.groupByFieldApi)) {
            soql += ', ' + spec.groupByFieldApi;
        }
        if (spec.perAENormalize == true) {
            soql += ', EMP_ID__c';
        }
        
        soql += ' FROM AGENT_OU_PIPELINE_V2__c WHERE IsDeleted = false';
        
        if (spec.requireNonNullMetric == true) {
            soql += ' AND ' + spec.metricFieldApi + ' != null';
        }
        
        if (!String.isBlank(spec.filterWhere)) {
            soql += ' AND (' + spec.filterWhere + ')';
        }
        
        if (spec.restrictInValues != null && !spec.restrictInValues.isEmpty() && String.isNotBlank(spec.groupByFieldApi)) {
            List<String> escapedValues = new List<String>();
            for (String v : spec.restrictInValues) {
                escapedValues.add('\'' + String.escapeSingleQuotes(v) + '\'');
            }
            soql += ' AND ' + spec.groupByFieldApi + ' IN (' + String.join(escapedValues, ',') + ')';
        }
        
        return soql;
    }
    
    public static String avg(String field, String alias) {
        return 'AVG(' + field + ') ' + alias;
    }
    
    public static String sum(String field, String alias) {
        return 'SUM(' + field + ') ' + alias;
    }
    
    public static String countDistinct(String field, String alias) {
        return 'COUNT_DISTINCT(' + field + ') ' + alias;
    }
} 