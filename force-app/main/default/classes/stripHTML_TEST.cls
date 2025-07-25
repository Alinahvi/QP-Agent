@isTest
public with sharing class stripHTML_TEST {

    @isTest
    static void stripHTMLTest() {
        Test.startTest();
        List<String> fakeData = new List<String>{'<p>This is a test run</p>'};
        List<String> plaintext = stripTags.removeHTMLTags(fakeData);
        Test.stopTest();
        System.assert(plaintext[0] == 'This is a test run', 'Did not strip HTML Properly');
    }
}