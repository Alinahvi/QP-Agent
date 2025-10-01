const { GoogleGenerativeAI } = require('@google/generative-ai');
const readline = require('readline');

class CursorGeminiBridge {
  constructor(apiKey) {
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({ 
      model: "gemini-2.5-pro",
      generationConfig: {
        maxOutputTokens: 8192,
        temperature: 0.7,
      }
    });
    this.conversationHistory = [];
  }

  async askGemini(prompt, context = '') {
    try {
      // Add context to the prompt
      const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
      
      // Add to conversation history
      this.conversationHistory.push({ role: 'user', content: fullPrompt });
      
      const result = await this.model.generateContent(fullPrompt);
      const response = await result.response;
      const text = response.text();
      
      // Add response to history
      this.conversationHistory.push({ role: 'assistant', content: text });
      
      return text;
    } catch (error) {
      throw new Error(`Gemini error: ${error.message}`);
    }
  }

  async startInteractiveMode() {
    console.log('🚀 Cursor + Company Gemini Pro Bridge');
    console.log('=====================================');
    console.log('This connects Cursor interface to your company\'s Gemini Pro');
    console.log('Type your questions and get AI-powered responses!');
    console.log('Commands:');
    console.log('  - Ask anything (just type your question)');
    console.log('  - /clear - Clear conversation history');
    console.log('  - /context - Show current context');
    console.log('  - /exit - Quit');
    console.log('');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const askQuestion = () => {
      rl.question('💬 You: ', async (input) => {
        const command = input.trim();

        try {
          if (command === '/exit') {
            console.log('👋 Goodbye!');
            rl.close();
            return;
          }

          if (command === '/clear') {
            this.conversationHistory = [];
            console.log('🧹 Conversation history cleared');
            askQuestion();
            return;
          }

          if (command === '/context') {
            console.log('📋 Current context:');
            console.log(`- Model: Gemini 2.5 Pro`);
            console.log(`- History length: ${this.conversationHistory.length} messages`);
            console.log(`- API Key: ${process.env.GEMINI_API_KEY ? 'Set' : 'Not set'}`);
            askQuestion();
            return;
          }

          if (command) {
            console.log('\n🤖 Gemini Pro:');
            const response = await this.askGemini(command);
            console.log(response);
            console.log('');
          }
        } catch (error) {
          console.error('❌ Error:', error.message);
          console.log('');
        }

        askQuestion();
      });
    };

    askQuestion();
  }
}

async function main() {
  const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
  
  if (!apiKey) {
    console.log('❌ No API key found!');
    console.log('Please set your company\'s Gemini API key:');
    console.log('export GEMINI_API_KEY=your_company_api_key_here');
    console.log('or');
    console.log('export GOOGLE_API_KEY=your_company_api_key_here');
    process.exit(1);
  }

  const bridge = new CursorGeminiBridge(apiKey);
  await bridge.startInteractiveMode();
}

main().catch(console.error);


