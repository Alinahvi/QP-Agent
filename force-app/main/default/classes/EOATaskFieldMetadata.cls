/**
 * EOATaskFieldMetadata: Invocable entry point to describe metadata and relationships for EOA-related objects.
 * Returns each object's fields' API names, labels, help texts, data types, lengths, picklist values, and object relationships.
 */
public with sharing class EOATaskFieldMetadata {

    public class DummyRequest {
        @InvocableVariable(required=false description='Returns metadata, relationships, special instructions, and the current user ID for each field across multiple EOA objects. Run first to ground agent.')
        public String dummyInput;
    }

    public class FieldInfo {
        @InvocableVariable(description='API name of the field')
        public String apiName;
        @InvocableVariable(description='Label of the field')
        public String label;
        @InvocableVariable(description='Help text or inline description')
        public String helpText;
        @InvocableVariable(description='Data type of the field')
        public String dataType;
        @InvocableVariable(description='Indicates if field is nillable')
        public Boolean isNillable;
        @InvocableVariable(description='Maximum length for text-based fields')
        public Integer length;
        @InvocableVariable(description='Picklist values, if applicable')
        public List<String> picklistValues;
    }

    public class RelationshipInfo {
        @InvocableVariable(description='Child object API name')
        public String childObject;
        @InvocableVariable(description='Parent object API name')
        public String parentObject;
        @InvocableVariable(description='Field used for relationship')
        public String relationshipField;
        @InvocableVariable(description='Relationship name used for queries')
        public String relationshipName;
    }

    public class ObjectMetadata {
        @InvocableVariable(description='API name of the object')
        public String objectApiName;
        @InvocableVariable(description='List of metadata for each field on the object')
        public List<FieldInfo> fields;
    }

    public class Response {
        @InvocableVariable(description='Current user ID for personalized searches')
        public String currentUserId;
        @InvocableVariable(description='Special instructions or notes for the agent')
        public List<String> specialInstructions;
        @InvocableVariable(description='List of object metadata including field info')
        public List<ObjectMetadata> objectsMetadata;
        @InvocableVariable(description='List of object relationship details')
        public List<RelationshipInfo> relationships;
    }

    @InvocableMethod(
        label='GA-EOA Describe All Objects and Relationships'
        description='Returns metadata, relationships, special instructions, and the current user ID for each field across multiple EOA objects. Run first to ground agent.'
    )
    public static List<Response> describeAndSample(List<DummyRequest> requests) {

        Response resp = new Response();
        resp.currentUserId = UserInfo.getUserId();
        resp.specialInstructions = new List<String>{
            'Search and retrieval operations require exact API field names.',
            'Translate user inputs to correct field names using provided metadata.'
        };

        List<String> objectNames = new List<String>{
            'agf__ADM_Task__c', 'agf__ADM_Work__c', 'agf__ADM_Epic__c',
            'agf__PPM_Project__c', 'agf__PPM_Program__c',
            'Decision_Log__c', 'Risk__c', 'Issue__c',
            'Health_Comments__c', 'driveconnect__File__c', 'User'
        };

        List<ObjectMetadata> allObjectMetadatas = new List<ObjectMetadata>();
        List<RelationshipInfo> relationshipInfos = new List<RelationshipInfo>();

        for (String objectName : objectNames) {
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
            Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
            List<FieldInfo> fieldInfos = new List<FieldInfo>();

            for (String fieldApi : fieldMap.keySet()) {
                Schema.DescribeFieldResult fDesc = fieldMap.get(fieldApi).getDescribe();
                FieldInfo fInfo = new FieldInfo();
                fInfo.apiName = fieldApi;
                fInfo.label = fDesc.getLabel();
                fInfo.helpText = fDesc.getInlineHelpText();
                fInfo.dataType = String.valueOf(fDesc.getType());
                fInfo.isNillable = fDesc.isNillable();

                if (fDesc.getType() == Schema.DisplayType.String ||
                    fDesc.getType() == Schema.DisplayType.Email ||
                    fDesc.getType() == Schema.DisplayType.Phone ||
                    fDesc.getType() == Schema.DisplayType.Url) {
                    fInfo.length = fDesc.getLength();
                }

                if (fDesc.getType() == Schema.DisplayType.Picklist ||
                    fDesc.getType() == Schema.DisplayType.Multipicklist) {
                    fInfo.picklistValues = new List<String>();
                    for (Schema.PicklistEntry pe : fDesc.getPicklistValues()) {
                        fInfo.picklistValues.add(pe.getValue());
                    }
                }

                if (fDesc.getType() == Schema.DisplayType.Reference) {
                    for (Schema.SObjectType ref : fDesc.getReferenceTo()) {
                        if (objectNames.contains(ref.getDescribe().getName())) {
                            RelationshipInfo rInfo = new RelationshipInfo();
                            rInfo.childObject = objectName;
                            rInfo.parentObject = ref.getDescribe().getName();
                            rInfo.relationshipField = fDesc.getName();
                            rInfo.relationshipName = fDesc.getRelationshipName();
                            relationshipInfos.add(rInfo);
                        }
                    }
                }
                fieldInfos.add(fInfo);
            }

            ObjectMetadata objMeta = new ObjectMetadata();
            objMeta.objectApiName = objectName;
            objMeta.fields = fieldInfos;
            allObjectMetadatas.add(objMeta);
        }

        resp.objectsMetadata = allObjectMetadatas;
        resp.relationships = relationshipInfos;

        return new List<Response>{ resp };
    }
}