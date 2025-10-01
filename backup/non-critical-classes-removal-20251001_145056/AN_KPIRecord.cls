public with sharing class AN_KPIRecord {
    // Expose fields to Flow/Agentforce
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String empId { get; set; }
    @AuraEnabled public String fullName { get; set; }
    @AuraEnabled public String empEmailAddr { get; set; }
    @AuraEnabled public String workLocationCountry { get; set; }
    @AuraEnabled public String ouName { get; set; }
    @AuraEnabled public String empMgrNm { get; set; }
    @AuraEnabled public String primaryIndustry { get; set; }
    @AuraEnabled public String learnerProfileId { get; set; }

    @AuraEnabled public Decimal valQuota { get; set; }
    @AuraEnabled public Decimal coverage { get; set; }
    @AuraEnabled public String rampStatus { get; set; }
    @AuraEnabled public Decimal timeSinceOnboarding { get; set; }
    @AuraEnabled public Decimal fullTotalAcvQuotaUsd { get; set; }
    @AuraEnabled public Decimal acvThreshold { get; set; }
    @AuraEnabled public Decimal daysToProductivity { get; set; }

    @AuraEnabled public Decimal cqCustomerMeeting { get; set; }
    @AuraEnabled public Decimal cqPg { get; set; }
    @AuraEnabled public Decimal cqAcv { get; set; }
    @AuraEnabled public Decimal cqCallConnect { get; set; }
    @AuraEnabled public Decimal cqCcAcv { get; set; }
    @AuraEnabled public Decimal cqDaysAcv { get; set; }
    @AuraEnabled public Decimal cqDaysAcvPart { get; set; }
    @AuraEnabled public Decimal cqDaysPgPart { get; set; }
    @AuraEnabled public Decimal cqDaysPg { get; set; }

    @AuraEnabled public Decimal pqCustomerMeeting { get; set; }
    @AuraEnabled public Decimal pqPg { get; set; }
    @AuraEnabled public Decimal pqAcv { get; set; }
    @AuraEnabled public Decimal pqCallConnect { get; set; }
    @AuraEnabled public Decimal pqCcAcv { get; set; }
    @AuraEnabled public Decimal pqDaysAcv { get; set; }
    @AuraEnabled public Decimal pqDaysAcvPart { get; set; }
    @AuraEnabled public Decimal pqDaysPgPart { get; set; }
    @AuraEnabled public Decimal pqDaysPg { get; set; }

    @AuraEnabled public Decimal aov { get; set; }
    @AuraEnabled public String definition { get; set; }
    @AuraEnabled public String description { get; set; }
    @AuraEnabled public Decimal callAiMention { get; set; }

    @AuraEnabled public Integer distance { get; set; }
} 