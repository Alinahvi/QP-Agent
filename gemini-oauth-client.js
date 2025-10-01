const { GoogleAuth } = require('google-auth-library');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const readline = require('readline');

class GeminiOAuthClient {
  constructor() {
    this.auth = new GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/cloud-platform']
    });
    this.genAI = null;
    this.model = null;
  }

  async initialize() {
    try {
      console.log('🔐 Authenticating with Google OAuth...');
      
      // Get access token
      const authClient = await this.auth.getClient();
      const accessToken = await authClient.getAccessToken();
      
      console.log('✅ OAuth authentication successful!');
      
      // Initialize Gemini with OAuth
      this.genAI = new GoogleGenerativeAI(accessToken.token);
      this.model = this.genAI.getGenerativeModel({ 
        model: "gemini-2.5-pro",
        generationConfig: {
          maxOutputTokens: 8192,
          temperature: 0.7,
        }
      });
      
      console.log('🚀 Gemini Pro initialized with OAuth!');
      return true;
      
    } catch (error) {
      console.error('❌ OAuth authentication failed:', error.message);
      console.log('\nTroubleshooting:');
      console.log('1. Run: gcloud auth application-default login');
      console.log('2. Make sure you\'re signed in with your company Google account');
      console.log('3. Check if your account has access to Gemini Pro');
      return false;
    }
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

  async startInteractiveMode() {
    console.log('🚀 Cursor + Gemini Pro (OAuth)');
    console.log('================================');
    console.log('Authenticated with your company Google account');
    console.log('Type your questions and get AI-powered responses!');
    console.log('Commands:');
    console.log('  - Ask anything (just type your question)');
    console.log('  - /clear - Clear conversation');
    console.log('  - /status - Check authentication status');
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
            console.log('🧹 Conversation cleared');
            askQuestion();
            return;
          }

          if (command === '/status') {
            console.log('📋 Authentication Status:');
            console.log(`- OAuth: ✅ Authenticated`);
            console.log(`- Model: Gemini 2.5 Pro`);
            console.log(`- Project: ${process.env.GOOGLE_CLOUD_PROJECT || 'Not set'}`);
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
  const client = new GeminiOAuthClient();
  
  const initialized = await client.initialize();
  if (initialized) {
    await client.startInteractiveMode();
  } else {
    process.exit(1);
  }
}

main().catch(console.error);


