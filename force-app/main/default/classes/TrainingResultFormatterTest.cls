@isTest
private class TrainingResultFormatterTest {

    @isTest
    static void testFormatAsList_Success() {
        // Arrange
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Name'};
        request.RESPONSE_CRITERIA.FORMAT = 'LIST';

        TrainingResultFormatter formatter = new TrainingResultFormatter(request);
        
        List<SObject> records = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };

        // Act
        String result = formatter.formatResults(records);

        // Assert
        System.assert(result.contains('Test Account 1, Test Account 2'), 'Should format names into a list.');
    }

    @isTest
    static void testFormatAsList_WithMoreThanMax() {
        // Arrange
        TrainingQueryRequest request = new TrainingQueryRequest();
        request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Name'};
        request.RESPONSE_CRITERIA.FORMAT = 'LIST';

        TrainingResultFormatter formatter = new TrainingResultFormatter(request);
        
        List<SObject> records = new List<Account>();
        for(Integer i=0; i<12; i++){
            records.add(new Account(Name='Account ' + i));
        }

        // Act
        String result = formatter.formatResults(records);

        // Assert
        System.assert(result.contains('and 2 more'), 'Should summarize results that exceed the max list size.');
    }
}