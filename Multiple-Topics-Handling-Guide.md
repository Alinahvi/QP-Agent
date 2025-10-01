# Multiple Topics Handling Guide

## Quick Reference for Agents

### When Knowledge Search Returns Multiple Articles

**ALWAYS analyze the user's specific question and provide only relevant information.**

## Step-by-Step Process

1. **Read the user's query carefully**
   - What specific topic are they asking about?
   - What information do they need?

2. **Review search results**
   - Look at the article titles returned
   - Identify which ones directly answer the user's question

3. **Prioritize relevant articles**
   - Focus on articles that match the user's specific topic
   - Ignore articles that are tangentially related

4. **Extract relevant information only**
   - Use information from the most relevant articles
   - Don't include details from irrelevant topics

## Common Scenarios

### Scenario 1: Specific Topic Query
**User asks:** "Tell me about AE Academy"

**Search returns:** 
- AE Academy Table Documentation
- Subject-Matter-Expert (SME) Finder Topic  
- Agentforce Badge Completion

**Correct response:** Focus ONLY on "AE Academy Table Documentation" content

**Incorrect response:** Including SME Finder or Agentforce Badge information

### Scenario 2: Process Query
**User asks:** "How do I log a case for ACT?"

**Search returns:**
- ACT: How to Log a Support Case
- Session: Registration
- Profile: Timezone / Language

**Correct response:** Focus ONLY on "ACT: How to Log a Support Case" content

**Incorrect response:** Including session registration or profile information

### Scenario 3: General Query
**User asks:** "What are the SME identification criteria?"

**Search returns:**
- SME Finder Documentation
- Subject-Matter-Expert (SME) Finder Topic
- AE Academy Table Documentation

**Correct response:** Use information from SME-related articles only

**Incorrect response:** Including AE Academy information

## Key Principles

### ✅ DO:
- Focus on the user's specific question
- Prioritize exact topic matches
- Provide relevant, focused information
- Use the most appropriate articles from the results

### ❌ DON'T:
- Include irrelevant topics just because they appear in results
- Provide information from all returned articles
- Mix unrelated topics in your response
- Assume all search results are equally relevant

## Response Templates

### For Specific Topic Queries:
"Based on your question about [specific topic], here's the relevant information from the knowledge base:

[Include only information from the most relevant article(s)]"

### For Process Queries:
"Here's how to [specific process] based on the knowledge base:

[Include only process-specific information]"

### For General Queries:
"Here's what I found about [topic] in the knowledge base:

[Include only relevant information from appropriate articles]"

## Quality Checklist

Before providing a response, ask:
- [ ] Does this directly answer the user's question?
- [ ] Am I focusing on the most relevant topic?
- [ ] Am I excluding irrelevant information?
- [ ] Is the information from the appropriate articles?
- [ ] Would this response be helpful to the user?

## Remember

**Relevance over completeness** - It's better to provide focused, relevant information than to include everything from all search results.

**User intent matters** - Understand what they're really asking for and provide that specific information.

**Quality over quantity** - A focused, accurate response is better than a comprehensive but irrelevant one. 