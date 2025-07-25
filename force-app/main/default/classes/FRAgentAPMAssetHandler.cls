public with sharing class FRAgentAPMAssetHandler {
    /**
     * Request wrapper for asset search
     */
    public class Request {
        @InvocableVariable(label='Keyword' description='Keyword to search in Name or Description')
        public String keyword;
        @InvocableVariable(label='Owner Id' description='Filter by OwnerId')
        public String ownerId;
        @InvocableVariable(label='Status' description='Filter by Status__c')
        public String status;
        @InvocableVariable(label='Created Date' description='Filter by CreatedDate (date literal or range)')
        public String createdDate;
        @InvocableVariable(label='Record Limit' description='Max number of records to return')
        public Integer recordLimit;
        @InvocableVariable(label='Offset' description='Offset for pagination')
        public Integer offset;
    }

    /**
     * Response wrapper for asset search
     */
    public class Response {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        @InvocableVariable(label='Message' description='Success or error message')
        public String message;
        @InvocableVariable(label='Assets' description='List of matching assets')
        public List<FRAgentAPMAssetWrapper> assets;
        @InvocableVariable(label='Summary' description='Formatted summary for agent display')
        public String summary;
        public Response() {
            this.success = false;
            this.message = '';
            this.assets = new List<FRAgentAPMAssetWrapper>();
            this.summary = '';
        }
    }

    /**
     * Invocable method for unified asset search
     */
    @InvocableMethod(label='FR Agent: Search Assets' description='Searches for Courses and Curriculums for nomination.')
    public static List<Response> searchAssets(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            Response errorResponse = new Response();
            errorResponse.success = false;
            errorResponse.message = 'No requests provided.';
            errorResponse.summary = 'No requests provided.';
            responses.add(errorResponse);
            return responses;
        }
        for (Request req : requests) {
            Response res = new Response();
            try {
                Map<String, Object> params = new Map<String, Object>();
                if (String.isNotBlank(req.keyword)) params.put('keyword', req.keyword);
                if (String.isNotBlank(req.ownerId)) params.put('ownerId', req.ownerId);
                if (String.isNotBlank(req.status)) params.put('status', req.status);
                if (String.isNotBlank(req.createdDate)) params.put('createdDate', req.createdDate);
                if (req.recordLimit != null) params.put('recordLimit', req.recordLimit);
                if (req.offset != null) params.put('offset', req.offset);
                Map<String, Object> result = FRAgentAPMAssetService.search(params);
                res.success = (Boolean)result.get('success');
                res.message = (String)result.get('message');
                res.summary = (String)result.get('summary');
                if (result.containsKey('records')) {
                    res.assets = (List<FRAgentAPMAssetWrapper>)result.get('records');
                }
            } catch (Exception e) {
                res.success = false;
                res.message = 'Sorry, something went wrong while searching for assets.';
                res.summary = 'Sorry, something went wrong while searching for assets.';
            }
            responses.add(res);
        }
        return responses;
    }

    public class RetrieveRequest {
        @InvocableVariable(label='Asset Id' description='The Id of the asset to retrieve')
        public String assetId;
        @InvocableVariable(label='Asset Type' description='Optional: Course or Curriculum')
        public String assetType;
    }
    public class RetrieveResponse {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        @InvocableVariable(label='Message' description='Success or error message')
        public String message;
        @InvocableVariable(label='Asset' description='The asset, if found and active')
        public FRAgentAPMAssetWrapper asset;
    }
    @InvocableMethod(label='FR Agent: Retrieve Asset By Id' description='Retrieves a Course or Curriculum by Id, with status checks.')
    public static List<RetrieveResponse> retrieveAssetById(List<RetrieveRequest> requests) {
        List<RetrieveResponse> responses = new List<RetrieveResponse>();
        if (requests == null || requests.isEmpty()) {
            RetrieveResponse errorResponse = new RetrieveResponse();
            errorResponse.success = false;
            errorResponse.message = 'No requests provided.';
            responses.add(errorResponse);
            return responses;
        }
        for (RetrieveRequest req : requests) {
            RetrieveResponse res = new RetrieveResponse();
            try {
                Map<String, Object> result = FRAgentAPMAssetService.retrieveById((Id)req.assetId, req.assetType);
                res.success = (Boolean)result.get('success');
                res.message = (String)result.get('message');
                if (result.containsKey('asset')) {
                    res.asset = (FRAgentAPMAssetWrapper)result.get('asset');
                }
            } catch (Exception e) {
                res.success = false;
                res.message = 'Sorry, something went wrong while retrieving the asset.';
            }
            responses.add(res);
        }
        return responses;
    }

    // Helper to generate nomination input from asset and nominator
    public static Map<String, Object> buildNominationInput(FRAgentAPMAssetWrapper asset, Id nominatorId) {
        if (asset == null || nominatorId == null) return new Map<String, Object>();
        return asset.toNominationInput(nominatorId);
    }
} 