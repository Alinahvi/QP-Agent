// Test Naming Normalizer Only - Minimal Test
System.debug('🧪 TESTING NAMING NORMALIZER ONLY');
System.debug('=================================');

// Test OU Name Normalization
System.debug('Testing OU Name Normalization:');
String testOU1 = ANAgentNamingNormalizer.normalizeOUName('AMERACC');
String testOU2 = ANAgentNamingNormalizer.normalizeOUName('AMER_ACC');
String testOU3 = ANAgentNamingNormalizer.normalizeOUName('amer acc');
System.debug('AMERACC -> ' + testOU1);
System.debug('AMER_ACC -> ' + testOU2);
System.debug('amer acc -> ' + testOU3);

// Test Country Normalization
System.debug('');
System.debug('Testing Country Normalization:');
String testCountry1 = ANAgentNamingNormalizer.normalizeCountry('US');
String testCountry2 = ANAgentNamingNormalizer.normalizeCountry('United States');
String testCountry3 = ANAgentNamingNormalizer.normalizeCountry('u.s.a');
System.debug('US -> ' + testCountry1);
System.debug('United States -> ' + testCountry2);
System.debug('u.s.a -> ' + testCountry3);

// Test Segment Normalization
System.debug('');
System.debug('Testing Segment Normalization:');
String testSegment1 = ANAgentNamingNormalizer.normalizeMacroSegment('cmrcl');
String testSegment2 = ANAgentNamingNormalizer.normalizeMacroSegment('Commercial');
String testSegment3 = ANAgentNamingNormalizer.normalizeMacroSegment('commercial');
System.debug('cmrcl -> ' + testSegment1);
System.debug('Commercial -> ' + testSegment2);
System.debug('commercial -> ' + testSegment3);

System.debug('');
System.debug('✅ NAMING NORMALIZER TEST COMPLETED!');
