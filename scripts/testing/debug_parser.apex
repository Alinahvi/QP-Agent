System.debug('=== Testing ANAgentFilterParser ===');

// Test 1: Simple country filter
ANAgentFilterParser.ParsedFilter result1 = ANAgentFilterParser.parse('country="US"');
System.debug('Test 1 - country="US": ' + result1.soqlWhere);
System.debug('  Valid: ' + result1.isValid + ', Display: ' + result1.display);

// Test 2: IN clause with aliases
ANAgentFilterParser.ParsedFilter result2 = ANAgentFilterParser.parse('country IN ("USA","Brasil","UK")');
System.debug('Test 2 - country IN ("USA","Brasil","UK"): ' + result2.soqlWhere);
System.debug('  Valid: ' + result2.isValid + ', Display: ' + result2.display);

// Test 3: Complex filter with AND
ANAgentFilterParser.ParsedFilter result3 = ANAgentFilterParser.parse('acv < 5000 AND tenure_months >= 6');
System.debug('Test 3 - acv < 5000 AND tenure_months >= 6: ' + result3.soqlWhere);
System.debug('  Valid: ' + result3.isValid + ', Display: ' + result3.display);

// Test 4: OR clause
ANAgentFilterParser.ParsedFilter result4 = ANAgentFilterParser.parse('ou = \'AMER ICE\' OR industry = "HLS"');
System.debug('Test 4 - ou = \'AMER ICE\' OR industry = "HLS": ' + result4.soqlWhere);
System.debug('  Valid: ' + result4.isValid + ', Display: ' + result4.display);

System.debug('=== Parser Test Complete ==='); 