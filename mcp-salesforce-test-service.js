const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { CallToolRequestSchema, ListToolsRequestSchema } = require('@modelcontextprotocol/sdk/types.js');

class SalesforceTestService {
  constructor() {
    this.server = new Server(
      {
        name: "salesforce-test-service",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.setupToolHandlers();
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "execute_apex",
          description: "Execute Apex code in Salesforce org",
          inputSchema: {
            type: "object",
            properties: {
              code: {
                type: "string",
                description: "Apex code to execute"
              },
              description: {
                type: "string",
                description: "Description of what this code does"
              }
            },
            required: ["code"]
          }
        },
        {
          name: "query_soql",
          description: "Execute SOQL query",
          inputSchema: {
            type: "object",
            properties: {
              query: {
                type: "string",
                description: "SOQL query to execute"
              },
              limit: {
                type: "number",
                description: "Maximum number of records to return (default: 10)"
              }
            },
            required: ["query"]
          }
        },
        {
          name: "test_class_method",
          description: "Test a specific class method",
          inputSchema: {
            type: "object",
            properties: {
              className: {
                type: "string",
                description: "Name of the Apex class"
              },
              methodName: {
                type: "string",
                description: "Name of the method to test"
              },
              parameters: {
                type: "array",
                description: "Parameters to pass to the method",
                items: {
                  type: "string"
                }
              }
            },
            required: ["className", "methodName"]
          }
        },
        {
          name: "check_data_quality",
          description: "Check data quality for specific objects and fields",
          inputSchema: {
            type: "object",
            properties: {
              objectName: {
                type: "string",
                description: "API name of the object"
              },
              fields: {
                type: "array",
                description: "Fields to check",
                items: {
                  type: "string"
                }
              },
              conditions: {
                type: "string",
                description: "WHERE conditions for the query"
              }
            },
            required: ["objectName"]
          }
        },
        {
          name: "deploy_metadata",
          description: "Deploy metadata to Salesforce org",
          inputSchema: {
            type: "object",
            properties: {
              metadataType: {
                type: "string",
                description: "Type of metadata to deploy (e.g., ApexClass, CustomObject)"
              },
              metadataName: {
                type: "string",
                description: "Name of the metadata component"
              }
            },
            required: ["metadataType", "metadataName"]
          }
        }
      ]
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case "execute_apex":
          return await this.executeApex(args.code, args.description);
        
        case "query_soql":
          return await this.executeSOQL(args.query, args.limit || 10);
        
        case "test_class_method":
          return await this.testClassMethod(args.className, args.methodName, args.parameters || []);
        
        case "check_data_quality":
          return await this.checkDataQuality(args.objectName, args.fields, args.conditions);
        
        case "deploy_metadata":
          return await this.deployMetadata(args.metadataType, args.metadataName);
        
        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  async executeApex(code, description) {
    try {
      const { exec } = require('child_process');
      const fs = require('fs');
      
      // Write code to temporary file
      const tempFile = `temp_apex_${Date.now()}.apex`;
      fs.writeFileSync(tempFile, code);
      
      return new Promise((resolve, reject) => {
        exec(`sfdx force:apex:execute -f ${tempFile}`, (error, stdout, stderr) => {
          // Clean up temp file
          fs.unlinkSync(tempFile);
          
          if (error) {
            reject(new Error(`Apex execution failed: ${error.message}`));
            return;
          }
          
          resolve({
            content: [
              {
                type: "text",
                text: '**Apex Execution Results' + (description ? ' - ' + description : '') + '**\n\n```\n' + stdout + '\n```'
              }
            ]
          });
        });
      });
      
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: 'Error executing Apex: ' + error.message
          }
        ]
      };
    }
  }

  async executeSOQL(query, limit) {
    const apexCode = `
// SOQL Query: ${query}
System.debug('=== SOQL QUERY RESULTS ===');
System.debug('Query: ${query}');
System.debug('Limit: ${limit}');

try {
    List<SObject> records = Database.query('${query.replace(/'/g, "\\'")} LIMIT ${limit}');
    System.debug('Records found: ' + records.size());
    
    for (SObject record : records) {
        System.debug('=== RECORD ===');
        System.debug('Id: ' + record.Id);
        System.debug('Type: ' + record.getSObjectType().getDescribe().getName());
        
        // Show all field values
        Map<String, Object> fieldMap = record.getPopulatedFieldsAsMap();
        for (String fieldName : fieldMap.keySet()) {
            System.debug(fieldName + ': ' + fieldMap.get(fieldName));
        }
    }
    
} catch (Exception e) {
    System.debug('SOQL ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}`;

    return await this.executeApex(apexCode, `SOQL Query: ${query}`);
  }

  async testClassMethod(className, methodName, parameters) {
    const paramString = parameters.map(p => `'${p.replace(/'/g, "\\'")}'`).join(', ');
    const apexCode = `
// Testing ${className}.${methodName}(${paramString})
System.debug('=== TESTING CLASS METHOD ===');
System.debug('Class: ${className}');
System.debug('Method: ${methodName}');
System.debug('Parameters: ${paramString}');

try {
    Type classType = Type.forName('${className}');
    if (classType == null) {
        System.debug('ERROR: Class ${className} not found');
        return;
    }
    
    // Call the method
    Object result = classType.newInstance();
    System.debug('Method result: ' + result);
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}`;

    return await this.executeApex(apexCode, `Testing ${className}.${methodName}`);
  }

  async checkDataQuality(objectName, fields, conditions) {
    const fieldList = fields ? fields.join(', ') : 'Id, Name';
    const whereClause = conditions ? `WHERE ${conditions.replace(/'/g, "\\'")}` : '';
    
    const apexCode = `
// Data Quality Check for ${objectName}
System.debug('=== DATA QUALITY CHECK ===');
System.debug('Object: ${objectName}');
System.debug('Fields: ${fieldList}');
System.debug('Conditions: ${whereClause}');

try {
    String query = 'SELECT ${fieldList} FROM ${objectName} ${whereClause} LIMIT 100';
    List<SObject> records = Database.query(query);
    
    System.debug('Total records: ' + records.size());
    
    // Check for null values
    Integer nullCount = 0;
    for (SObject record : records) {
        Map<String, Object> fieldMap = record.getPopulatedFieldsAsMap();
        for (String fieldName : fieldMap.keySet()) {
            if (fieldMap.get(fieldName) == null) {
                nullCount++;
            }
        }
    }
    
    System.debug('Records with null values: ' + nullCount);
    System.debug('Data completeness: ' + ((records.size() - nullCount) / records.size() * 100) + '%');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}`;

    return await this.executeApex(apexCode, `Data Quality Check for ${objectName}`);
  }

  async deployMetadata(metadataType, metadataName) {
    const { exec } = require('child_process');
    
    return new Promise((resolve, reject) => {
      exec(`sfdx force:source:deploy -m ${metadataType}:${metadataName}`, (error, stdout, stderr) => {
        if (error) {
          reject(new Error(`Deployment failed: ${error.message}`));
          return;
        }
        
        resolve({
          content: [
            {
              type: "text",
              text: '**Deployment Results for ' + metadataType + ':' + metadataName + '**\n\n```\n' + stdout + '\n```'
            }
          ]
        });
      });
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Salesforce Test Service running on stdio");
  }
}

// Start the service
const service = new SalesforceTestService();
service.run().catch(console.error);