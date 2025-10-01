const { GoogleGenerativeAI } = require('@google/generative-ai');

async function main() {
  // Initialize the Gemini API
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'your-api-key-here');
  const model = genAI.getGenerativeModel({ model: "gemini-pro" });

  console.log('Connected to Gemini Pro directly');

  try {
    // Example: Generate content
    const prompt = "Explain Salesforce Apex in simple terms";
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    
    console.log('Gemini Pro Response:');
    console.log(text);
    
  } catch (error) {
    console.error('Error calling Gemini Pro:', error);
  }
}

main().catch(console.error);


