// Debug CSV Export
System.debug('=== DEBUG CSV EXPORT ===');

// Test the CSV export
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request.operatingUnit = 'UKI';

String csvData = ANAgentOpenPipeAnalysisService.exportOpenPipeToCSV_AELevel(request);

System.debug('CSV Data length: ' + csvData.length());
System.debug('CSV contains newlines: ' + csvData.contains('\n'));

// Count commas in first line manually
Integer firstLineEnd = csvData.indexOf('\n');
if (firstLineEnd > 0) {
    String firstLine = csvData.substring(0, firstLineEnd);
    System.debug('First line: ' + firstLine);
    
    Integer commaCount = 0;
    for (Integer i = 0; i < firstLine.length(); i++) {
        if (firstLine.substring(i, i + 1) == ',') {
            commaCount++;
        }
    }
    System.debug('First line field count: ' + (commaCount + 1));
}

System.debug('=== END DEBUG ==='); 