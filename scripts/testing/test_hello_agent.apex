// Test the Hello Agent handler to verify basic Agent framework works
System.debug('=== Testing Hello Agent Handler ===');

// Test with a name
HelloAgentRequest req = new HelloAgentRequest();
req.name = 'Anahvi';

List<HelloAgentResponse> resp = HelloAgentHandler.run(new List<HelloAgentRequest>{ req });

System.debug('Response: ' + resp);
System.debug('JSON: ' + JSON.serializePretty(resp));

// Test with empty request
List<HelloAgentResponse> emptyResp = HelloAgentHandler.run(new List<HelloAgentRequest>());

System.debug('Empty Response: ' + emptyResp);
System.debug('Empty JSON: ' + JSON.serializePretty(emptyResp));

System.debug('=== Hello Agent Test Complete ==='); 