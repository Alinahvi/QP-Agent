public with sharing class FRAgentAPMNominationService {
    /**
     * Creates a new APM Nomination record
     */
    public static Map<String, Object> create(Map<String, Object> params) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            apm_nomination__c nom = new apm_nomination__c();
            // Validate Asset_Id_c__c
            if (params.containsKey('Asset_Id_c__c')) {
                String assetId = String.valueOf(params.get('Asset_Id_c__c'));
                if (String.isBlank(assetId) || assetId.length() < 15) {
                    result.put('success', false);
                    result.put('message', 'Asset_Id_c__c must be a valid Salesforce Id.');
                    return result;
                }
                nom.Asset_Id_c__c = assetId;
            }
            // Validate Nominator_c__c
            if (params.containsKey('Nominator_c__c')) {
                String nominatorId = String.valueOf(params.get('Nominator_c__c'));
                if (String.isBlank(nominatorId) || nominatorId.length() < 15 || !nominatorId.startsWith('005')) {
                    result.put('success', false);
                    result.put('message', 'Nominator_c__c must be a valid Salesforce User Id.');
                    return result;
                }
                nom.Nominator_c__c = nominatorId;
            }
            if (params.containsKey('Asset_Name_c__c')) nom.Asset_Name_c__c = (String)params.get('Asset_Name_c__c');
            if (params.containsKey('Asset_Type_c__c')) nom.Asset_Type_c__c = (String)params.get('Asset_Type_c__c');
            if (params.containsKey('Date_Nominated_c__c')) nom.Date_Nominated_c__c = (Date)params.get('Date_Nominated_c__c');
            if (params.containsKey('Status_c__c')) nom.Status_c__c = (String)params.get('Status_c__c');
            if (params.containsKey('Comments_c__c')) nom.Comments_c__c = (String)params.get('Comments_c__c');
            insert nom;
            result.put('success', true);
            result.put('message', 'Nomination created successfully.');
            result.put('record', nom);
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Sorry, something went wrong while creating the nomination. Please check your input or contact support.');
        }
        return result;
    }

    /**
     * Retrieves a nomination by Id
     */
    public static Map<String, Object> retrieve(Id nominationId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            apm_nomination__c nom = [SELECT Id, Name, Asset_Id_c__c, Asset_Name_c__c, Asset_Type_c__c, Nominator_c__c, Status_c__c, Comments_c__c, Date_Nominated_c__c, Name__c FROM apm_nomination__c WHERE Id = :nominationId LIMIT 1];
            result.put('success', true);
            result.put('record', nom);
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Sorry, something went wrong while retrieving the nomination. Please try again or contact support.');
        }
        return result;
    }

    /**
     * Searches for nominations by asset name, type, or nominator
     */
    public static Map<String, Object> search(Map<String, Object> params) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            String soql = 'SELECT Id, Name, Asset_Id_c__c, Asset_Name_c__c, Asset_Type_c__c, Nominator_c__c, Status_c__c, Comments_c__c, Date_Nominated_c__c, Name__c FROM apm_nomination__c WHERE Id != null';
            if (params.containsKey('Asset_Name_c__c') && String.isNotBlank((String)params.get('Asset_Name_c__c'))) {
                soql += ' AND Asset_Name_c__c LIKE :nameParam';
            }
            if (params.containsKey('Asset_Type_c__c') && String.isNotBlank((String)params.get('Asset_Type_c__c'))) {
                soql += ' AND Asset_Type_c__c = :typeParam';
            }
            if (params.containsKey('Nominator_c__c') && String.isNotBlank((String)params.get('Nominator_c__c'))) {
                soql += ' AND Nominator_c__c = :nominatorParam';
            }
            soql += ' ORDER BY CreatedDate DESC LIMIT 20';
            List<apm_nomination__c> noms;
            if (soql.contains(':nameParam') || soql.contains(':typeParam') || soql.contains(':nominatorParam')) {
                String nameParam = (String)params.get('Asset_Name_c__c');
                String typeParam = (String)params.get('Asset_Type_c__c');
                String nominatorParam = (String)params.get('Nominator_c__c');
                noms = Database.query(soql);
            } else {
                noms = [SELECT Id, Name, Asset_Id_c__c, Asset_Name_c__c, Asset_Type_c__c, Nominator_c__c, Status_c__c, Comments_c__c, Date_Nominated_c__c, Name__c FROM apm_nomination__c ORDER BY CreatedDate DESC LIMIT 20];
            }
            result.put('success', true);
            result.put('records', noms);
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Sorry, something went wrong while searching nominations. Please try again or contact support.');
        }
        return result;
    }

    public class NominationInput {
        @InvocableVariable(label='Asset_Id_c__c') public String assetId;
        @InvocableVariable(label='Asset_Name_c__c') public String assetName;
        @InvocableVariable(label='Asset_Type_c__c') public String assetType;
        @InvocableVariable(label='Nominator_c__c') public String nominator;
        @InvocableVariable(label='Status_c__c') public String status;
        @InvocableVariable(label='Comments_c__c') public String comments;
        @InvocableVariable(label='Date_Nominated_c__c') public Date dateNominated;
        @InvocableVariable(label='Name__c') public String name;
    }
    public class NominationOutput {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }
    @InvocableMethod(label='Create APM Nomination' description='Creates an APM nomination for agent')
    public static List<NominationOutput> invocableCreate(List<NominationInput> inputs) {
        List<NominationOutput> results = new List<NominationOutput>();
        for (NominationInput input : inputs) {
            Map<String, Object> params = new Map<String, Object>{
                'Asset_Id_c__c' => input.assetId,
                'Asset_Name_c__c' => input.assetName,
                'Asset_Type_c__c' => input.assetType,
                'Nominator_c__c' => input.nominator,
                'Status_c__c' => input.status,
                'Comments_c__c' => input.comments,
                'Date_Nominated_c__c' => input.dateNominated,
                'Name__c' => input.name
            };
            Map<String, Object> result = create(params);
            NominationOutput out = new NominationOutput();
            out.success = (Boolean)result.get('success');
            out.message = (String)result.get('message');
            results.add(out);
        }
        return results;
    }
}