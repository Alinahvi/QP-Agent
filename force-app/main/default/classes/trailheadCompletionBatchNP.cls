global with sharing class trailheadCompletionBatchNP implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global Map<String, String> emailToUserId = new Map<String, String>(); //no usage, but cna't be removed due to package
    global String accessToken;
    global Boolean refreshTokenValid = true;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()) {
            return Database.getQueryLocator([SELECT Id, Name, Email FROM User WHERE IsActive = true AND LastName = 'User 1']);
        } else {
            return Database.getQueryLocator([SELECT Id, Name, Email
                                             FROM User
                                             WHERE id = '0052E00000L4Q7tQAF' ]);

//  0052E00000LlrSkQAJ  

        }
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {
        if(!refreshTokenValid) {
            return;
        } else if(accessToken == null) {
            String newAccessToken = utilitiesNP.getAccessTokenFromRefresh();

            if(newAccessToken == null) {
                refreshTokenValid = false;
                return;
            } else {
                accessToken = newAccessToken;
            }
        }

        trailheadCompletionBatchHelperNP.checkTrailheadCompletion(scope, accessToken);
    }

    global void finish(Database.BatchableContext BC) {

    }
}