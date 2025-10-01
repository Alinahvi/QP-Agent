const { GoogleGenerativeAI } = require('@google/generative-ai');
const { exec } = require('child_process');

class GeminiSalesforceClient {
  constructor() {
    // Initialize Gemini Pro
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'your-api-key-here');
    this.model = this.genAI.getGenerativeModel({ model: "gemini-pro" });
  }

  async executeApex(apexCode) {
    return new Promise((resolve, reject) => {
      const fs = require('fs');
      const tempFile = `temp_apex_${Date.now()}.apex`;
      
      // Write code to temporary file
      fs.writeFileSync(tempFile, apexCode);
      
      exec(`sfdx force:apex:execute -f ${tempFile}`, (error, stdout, stderr) => {
        // Clean up temp file
        fs.unlinkSync(tempFile);
        
        if (error) {
          reject(new Error(`Apex execution failed: ${error.message}`));
          return;
        }
        
        resolve(stdout);
      });
    });
  }

  async querySOQL(query, limit = 10) {
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

    return await this.executeApex(apexCode);
  }

  async askGemini(prompt) {
    try {
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      return response.text();
    } catch (error) {
      throw new Error(`Gemini error: ${error.message}`);
    }
  }

  async interactiveMode() {
    console.log('🚀 Gemini Pro + Salesforce Direct Client');
    console.log('=====================================');
    console.log('Available commands:');
    console.log('  - ask "your question" - Ask Gemini Pro');
    console.log('  - apex "your apex code" - Execute Apex');
    console.log('  - soql "your query" - Execute SOQL');
    console.log('  - exit - Quit');
    console.log('');

    const readline = require('readline');
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const askQuestion = () => {
      rl.question('> ', async (input) => {
        const [command, ...args] = input.trim().split(' ');
        const fullInput = args.join(' ');

        try {
          switch (command.toLowerCase()) {
            case 'ask':
              console.log('\n🤖 Gemini Pro:');
              const geminiResponse = await this.askGemini(fullInput);
              console.log(geminiResponse);
              break;

            case 'apex':
              console.log('\n⚡ Executing Apex...');
              const apexResult = await this.executeApex(fullInput);
              console.log(apexResult);
              break;

            case 'soql':
              console.log('\n🔍 Executing SOQL...');
              const soqlResult = await this.querySOQL(fullInput);
              console.log(soqlResult);
              break;

            case 'exit':
              console.log('👋 Goodbye!');
              rl.close();
              return;

            default:
              console.log('❌ Unknown command. Use: ask, apex, soql, or exit');
          }
        } catch (error) {
          console.error('❌ Error:', error.message);
        }

        console.log('');
        askQuestion();
      });
    };

    askQuestion();
  }
}

async function main() {
  const client = new GeminiSalesforceClient();
  
  // Check if API key is set
  if (!process.env.GEMINI_API_KEY) {
    console.log('⚠️  GEMINI_API_KEY not set. Please run:');
    console.log('export GEMINI_API_KEY=your_actual_api_key');
    console.log('');
  }

  await client.interactiveMode();
}

main().catch(console.error);


