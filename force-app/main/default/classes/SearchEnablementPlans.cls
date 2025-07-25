public with sharing class SearchEnablementPlans {
    public class Request {
        @InvocableVariable(required=true)
        public String userQuery;
    }

    public class Response {
        @InvocableVariable public Id      recordId;
        @InvocableVariable public String  name;
        @InvocableVariable public String  ouSegment;
        @InvocableVariable public String  productL1;
        @InvocableVariable public String  productL2;
        @InvocableVariable public String  role;
        @InvocableVariable public String  status;
        @InvocableVariable public Date    deliveryDate;
        @InvocableVariable public String  summary;
    }

    @InvocableMethod(label='Find Enablement Solution by free-text')
    public static List<Response> find(List<Request> reqList) {
        List<Response> out = new List<Response>();

        for (Request req : reqList) {
            // Tokenize user query
            List<String> tokens = new List<String>();
            if (req.userQuery != null) {
                tokens = req.userQuery.toLowerCase().split('\\s+');
            }

            // Build dynamic WHERE clause
            String whereClause = '';
            if (tokens.contains('health'))    whereClause += ' AND Product_L1__c = \'Health Cloud\'';
            if (tokens.contains('sales'))     whereClause += ' AND Product_L1__c = \'Sales Cloud\'';
            if (tokens.contains('leader'))    whereClause += ' AND Role__c LIKE \'%Leader%\'';
            if (tokens.contains('ae'))        whereClause += ' AND Role__c LIKE \'%AE%\'';
            if (tokens.contains('smb'))       whereClause += ' AND Segment__c LIKE \'%SMB%\'';
            if (tokens.contains('enterprise'))whereClause += ' AND Segment__c LIKE \'%Enterprise%\'';
            if (tokens.contains('planned'))   whereClause += ' AND Status__c = \'Planned\'';

            // Compose full SOQL string
            String soql = 
                'SELECT Id, Name, Segment__c, Product_L1__c, Product_L2__c, '
              + 'Role__c, Status__c, Delivery_Date__c '
              + 'FROM Enablement_Solutions__c '
              + 'WHERE 1 = 1'
              + whereClause
              + ' ORDER BY LastModifiedDate DESC '
              + 'LIMIT 1';

            // Execute dynamic query
            List<Enablement_Solutions__c> plans = Database.query(soql);
            Enablement_Solutions__c plan = plans.isEmpty() ? null : plans[0];

            // Build response
            Response r = new Response();
            if (plan != null) {
                r.recordId     = plan.Id;
                r.name         = plan.Name;
                r.ouSegment    = plan.Segment__c;
                r.productL1    = plan.Product_L1__c;
                r.productL2    = plan.Product_L2__c;
                r.role         = plan.Role__c;
                r.status       = plan.Status__c;
                r.deliveryDate = plan.Delivery_Date__c;
                r.summary      = plan.Product_L1__c
                               + ' plan for ' + plan.Segment__c
                               + ' covering ' + plan.Role__c
                               + '. Status: ' + plan.Status__c
                               + '. Delivery: ' + plan.Delivery_Date__c.format()
                               + '.';
            }
            out.add(r);
        }

        return out;
    }
}