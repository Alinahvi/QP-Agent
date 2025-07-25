@isTest
private class TrainingNluServiceTest {

    @isTest
    static void testGetStructuredJson_Success() {
        String userInput = 'who completed compliance training';
        String expectedJson = '{"AGENT_ACTION":"GET_TRAINING_PARTICIPANTS"}';
        Test.setMock(HttpCalloutMock.class, new TrainingNluMock(200, expectedJson));

        String result = TrainingNluService.getStructuredJsonFromNlu(userInput);
        System.assertEquals(expectedJson, result, 'Should return the clean JSON.');
    }

    @isTest
    static void testCleanJsonResponse_HandlesSpecialWhitespace() {
        // Arrange
        // Create a string with a non-breaking space (char 160) before the first quote.
        String dirtyResponse = '{\u00A0"AGENT_ACTION":"TEST"}';
        String expected = '{"AGENT_ACTION":"TEST"}';

        // Act
        String result = TrainingNluService.cleanJsonResponse(dirtyResponse);

        // Assert
        System.assertEquals(expected, result.replace(' ', ''), 'Should replace special whitespace.');
    }

    // Mock for simulating the LLM API Callout
    private class TrainingNluMock implements HttpCalloutMock {
        protected Integer statusCode;
        protected String body;
        public TrainingNluMock(Integer code, String body) { this.statusCode = code; this.body = body; }
        public HTTPResponse respond(HTTPRequest req) {
            String responseBody = '{"generations":[{"text":"' + this.body.escapeJava() + '"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}