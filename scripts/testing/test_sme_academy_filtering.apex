// Comprehensive test script for SME Academy filtering capabilities
System.debug('🧪 Testing SME Academy Filtering Capabilities...');

// ========================================
// TEST 1: Basic Search with Academy Filtering (No Academy filter)
// ========================================

System.debug('=== TEST 1: Basic Search (No Academy Filter) ===');
try {
    ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();
    request.searchTerm = 'Service - Success Plans';
    request.searchType = 'Product';
    request.maxResults = 10;
    request.academyMembersOnly = false; // No Academy filter
    
    System.debug('🔍 Request Details:');
    System.debug('- Search Term: ' + request.searchTerm);
    System.debug('- Search Type: ' + request.searchType);
    System.debug('- Max Results: ' + request.maxResults);
    System.debug('- Academy Members Only: ' + request.academyMembersOnly);
    
    List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
        ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentSMESearchHandler.SMESearchResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Count: ' + response.totalCount);
        System.debug('- Academy Members Count: ' + response.academyMembersCount);
        System.debug('- Message: ' + response.message);
        
        if (response.success && response.totalCount > 0) {
            System.debug('🎉 SUCCESS: Basic search working! Found ' + response.totalCount + ' SMEs');
            System.debug('📊 Academy Members: ' + response.academyMembersCount + ' out of ' + response.totalCount);
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: Academy Members Only Search
// ========================================

System.debug('=== TEST 2: Academy Members Only Search ===');
try {
    ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();
    request.searchTerm = 'Service - Success Plans';
    request.searchType = 'Product';
    request.maxResults = 10;
    request.academyMembersOnly = true; // Academy members only
    
    System.debug('🔍 Request Details:');
    System.debug('- Search Term: ' + request.searchTerm);
    System.debug('- Search Type: ' + request.searchType);
    System.debug('- Max Results: ' + request.maxResults);
    System.debug('- Academy Members Only: ' + request.academyMembersOnly);
    
    List<ANAgentSMESearchHandler.SMESearchResponse> responses = 
        ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentSMESearchHandler.SMESearchResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Count: ' + response.totalCount);
        System.debug('- Academy Members Count: ' + response.academyMembersCount);
        System.debug('- Message: ' + response.message);
        
        if (response.success && response.totalCount > 0) {
            System.debug('🎉 SUCCESS: Academy-only search working! Found ' + response.totalCount + ' Academy members');
            if (response.academyMembersCount == response.totalCount) {
                System.debug('✅ All results are Academy members (filter working correctly)');
            } else {
                System.debug('⚠️ Filter issue: ' + response.academyMembersCount + ' Academy members out of ' + response.totalCount + ' total');
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 3: Direct Service Call - Top SMEs by Product with Academy Filter
// ========================================

System.debug('=== TEST 3: Direct Service Call - Top SMEs by Product with Academy Filter ===');
try {
    String productName = 'Service - Success Plans';
    Integer limitCount = 5;
    Boolean academyMembersOnly = true;
    
    System.debug('🔍 Service Call Details:');
    System.debug('- Product: ' + productName);
    System.debug('- Limit: ' + limitCount);
    System.debug('- Academy Only: ' + academyMembersOnly);
    
    List<ANAgentSMESearchService.SMEInfo> topSMEs = 
        ANAgentSMESearchService.getTopSMEsByProductWithAcademy(productName, limitCount, academyMembersOnly);
    
    System.debug('✅ Service Response:');
    System.debug('- Total SMEs Found: ' + topSMEs.size());
    
    if (!topSMEs.isEmpty()) {
        System.debug('📊 Top SMEs by ACV (Academy Members Only):');
        for (Integer i = 0; i < topSMEs.size(); i++) {
            ANAgentSMESearchService.SMEInfo sme = topSMEs[i];
            System.debug((i + 1) + '. ' + sme.aeName + ' - ACV: $' + sme.totalACV + 
                        ', Rank: ' + sme.aeRank + ', OU: ' + sme.organizationalUnit + 
                        ', Academy: ' + sme.isAcademyMember);
        }
        
        // Verify all are Academy members
        Boolean allAcademyMembers = true;
        for (ANAgentSMESearchService.SMEInfo sme : topSMEs) {
            if (sme.isAcademyMember != true) {
                allAcademyMembers = false;
                break;
            }
        }
        
        if (allAcademyMembers) {
            System.debug('✅ SUCCESS: All returned SMEs are Academy members');
        } else {
            System.debug('⚠️ ISSUE: Some returned SMEs are not Academy members');
        }
    }
} catch (Exception e) {
    System.debug('❌ Service Call Failed: ' + e.getMessage());
}

// ========================================
// TEST 4: Direct Service Call - Top SMEs by Product and OU with Academy Filter
// ========================================

System.debug('=== TEST 4: Direct Service Call - Top SMEs by Product and OU with Academy Filter ===');
try {
    String productName = 'Service - Success Plans';
    String ouName = 'UKI';
    Integer limitCount = 5;
    Boolean academyMembersOnly = true;
    
    System.debug('🔍 Service Call Details:');
    System.debug('- Product: ' + productName);
    System.debug('- OU: ' + ouName);
    System.debug('- Limit: ' + limitCount);
    System.debug('- Academy Only: ' + academyMembersOnly);
    
    List<ANAgentSMESearchService.SMEInfo> topSMEs = 
        ANAgentSMESearchService.getTopSMEsByProductAndOU(productName, ouName, limitCount, academyMembersOnly);
    
    System.debug('✅ Service Response:');
    System.debug('- Total SMEs Found: ' + topSMEs.size());
    
    if (!topSMEs.isEmpty()) {
        System.debug('📊 Top SMEs by ACV (UKI + Academy Members Only):');
        for (Integer i = 0; i < topSMEs.size(); i++) {
            ANAgentSMESearchService.SMEInfo sme = topSMEs[i];
            System.debug((i + 1) + '. ' + sme.aeName + ' - ACV: $' + sme.totalACV + 
                        ', Rank: ' + sme.aeRank + ', OU: ' + sme.organizationalUnit + 
                        ', Academy: ' + sme.isAcademyMember);
        }
        
        // Verify all are from UKI and Academy members
        Boolean allValid = true;
        for (ANAgentSMESearchService.SMEInfo sme : topSMEs) {
            if (sme.organizationalUnit != 'UKI' || sme.isAcademyMember != true) {
                allValid = false;
                System.debug('⚠️ Invalid SME: ' + sme.aeName + ' - OU: ' + sme.organizationalUnit + ', Academy: ' + sme.isAcademyMember);
                break;
            }
        }
        
        if (allValid) {
            System.debug('✅ SUCCESS: All returned SMEs are from UKI and Academy members');
        } else {
            System.debug('⚠️ ISSUE: Some returned SMEs do not meet criteria');
        }
    }
} catch (Exception e) {
    System.debug('❌ Service Call Failed: ' + e.getMessage());
}

// ========================================
// TEST 5: Convenience Method Test
// ========================================

System.debug('=== TEST 5: Convenience Method Test ===');
try {
    String searchTerm = 'Sales - Success Plans';
    
    System.debug('🔍 Testing convenience method: searchSMEs("' + searchTerm + '")');
    
    ANAgentSMESearchHandler.SMESearchResponse response = 
        ANAgentSMESearchHandler.searchSMEs(searchTerm);
    
    System.debug('✅ Convenience Method Response:');
    System.debug('- Success: ' + response.success);
    System.debug('- Total Count: ' + response.totalCount);
    System.debug('- Academy Members Count: ' + response.academyMembersCount);
    System.debug('- Message: ' + response.message);
    
    if (response.success) {
        System.debug('🎉 SUCCESS: Convenience method working!');
    }
} catch (Exception e) {
    System.debug('❌ Convenience Method Failed: ' + e.getMessage());
}

System.debug('🎯 SME Academy Filtering Test Complete!');
System.debug('📊 All tests should demonstrate the new Academy filtering capabilities!'); 