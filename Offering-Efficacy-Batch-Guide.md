# Offering Efficacy Batch Processing Quick Reference

## Overview

The **ANAgentOfferingEfficacyBatchService** provides efficient processing of large datasets (millions of records) using Salesforce Batch Apex. It automatically handles governor limits and provides comprehensive aggregation across batches.

## When to Use Batch Processing

### **Automatic Detection**
The system automatically detects when batch processing is needed:
- **No specific filters** (broad search across all data)
- **Expected dataset > 10,000 records**
- **Complex multi-dimensional analysis**

### **Manual Trigger**
You can also manually trigger batch processing for specific use cases:
```apex
Id batchJobId = ANAgentOfferingEfficacyBatchService.executeBatchAnalysis(
    offeringLabel, programType, region, macroSegment, 
    fiscalQuarter, kpiName, product, analysisType
);
```

## Batch Processing Features

### **1. Intelligent Batch Sizing**
- **Default**: 1,000 records per batch
- **Customizable**: 100, 200, 400, 800, 1,000
- **Optimized**: Factors of 2,000 for best performance

### **2. Stateful Processing**
- **Maintains state** across all batches
- **Aggregates results** progressively
- **Tracks top performers** throughout processing

### **3. Comprehensive Aggregation**
- **Total counts**: Records, effectiveness, lift, ACV, learners
- **Breakdowns**: Regional, segment, KPI, program
- **Top performers**: Maintains top 10 throughout processing

## Usage Examples

### **Example 1: Basic Batch Analysis**
```apex
// Start batch analysis for all Fast Start programs
Id jobId = ANAgentOfferingEfficacyBatchService.executeBatchAnalysis(
    null,           // offeringLabel
    'Fast Start',   // programType
    null,           // region
    null,           // macroSegment
    null,           // fiscalQuarter
    null,           // kpiName
    null,           // product
    'analyze'       // analysisType
);
```

### **Example 2: Custom Batch Size**
```apex
// Use smaller batch size for complex processing
Id jobId = ANAgentOfferingEfficacyBatchService.executeBatchAnalysis(
    'Einstein', 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL', 'analyze', 200
);
```

### **Example 3: Monitor Batch Progress**
```apex
// Check batch job status
AsyncApexJob batchJob = [
    SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
    FROM AsyncApexJob 
    WHERE Id = :batchJobId
];

System.debug('Status: ' + batchJob.Status);
System.debug('Progress: ' + batchJob.JobItemsProcessed + '/' + batchJob.TotalJobItems);
System.debug('Errors: ' + batchJob.NumberOfErrors);
```

## Batch Job Statuses

| Status | Description |
|--------|-------------|
| **Holding** | Job in Apex Flex Queue (up to 100 jobs) |
| **Queued** | Job waiting for execution |
| **Preparing** | Start method executing |
| **Processing** | Execute method running |
| **Completed** | All batches processed successfully |
| **Failed** | System failure occurred |
| **Aborted** | Job manually stopped |

## Performance Considerations

### **Optimal Batch Sizes**
- **100**: Complex processing per record
- **200**: Standard processing (default)
- **400**: Light processing
- **800**: Very light processing
- **1,000**: Minimal processing (recommended for large datasets)

### **Memory Management**
- **Stateful variables** persist across batches
- **Large collections** are processed incrementally
- **Top performers** list is maintained efficiently

## Integration with Regular Service

### **Automatic Fallback**
The main service automatically detects when to use batch processing:
```apex
// This automatically uses batch if dataset is large
EfficacySearchResult result = ANAgentOfferingEfficacyService.searchEfficacyData(
    null, null, null, null, null, null, null, null
);

if (result.batchJobId != null) {
    System.debug('Batch processing started: ' + result.batchJobId);
}
```

### **Seamless Experience**
- **Same API** for both regular and batch processing
- **Automatic detection** of processing method
- **Consistent response format**

## Monitoring and Debugging

### **Debug Logs**
```apex
// Enable debug logging for batch jobs
System.debug('Batch job started: ' + bc.getJobId());
System.debug('Processing batch of ' + scope.size() + ' records');
System.debug('Total records processed: ' + totalRecordsProcessed);
```

### **Progress Tracking**
- **Real-time updates** in debug logs
- **Batch-level progress** tracking
- **Final summary** with complete results

## Error Handling

### **Batch-Level Errors**
- **Individual batch failures** don't stop the job
- **Error logging** for each failed batch
- **Continue processing** remaining batches

### **Job-Level Errors**
- **System failures** mark entire job as failed
- **Partial results** may be available
- **Manual restart** required for failed jobs

## Best Practices

### **1. Batch Size Selection**
- Start with **1,000** for large datasets
- Use **200** for complex processing
- Monitor **execution time** and adjust

### **2. Filter Usage**
- **Specific filters** reduce dataset size
- **Broad searches** automatically use batch
- **Combine filters** for targeted analysis

### **3. Monitoring**
- **Check job status** regularly
- **Monitor debug logs** for progress
- **Handle errors** gracefully

### **4. Resource Management**
- **Limit concurrent jobs** (max 5 active)
- **Use flex queue** for job prioritization
- **Schedule during off-peak** hours

## Limitations

### **Salesforce Limits**
- **Max 5 concurrent** batch jobs
- **Max 100 holding** jobs in flex queue
- **Max 50 million** records in QueryLocator
- **Max 2,000** records per batch (enforced)

### **Processing Time**
- **No guaranteed** execution time
- **Depends on** system resources
- **Flex queue** prioritization available

---

**Note**: Batch processing is ideal for large-scale efficacy analysis, providing comprehensive insights across millions of records while respecting Salesforce governor limits. 