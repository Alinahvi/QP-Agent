# 🎯 **Enhanced Agent Test Utterances - Coaching Focus**

## 📊 **Key Improvements Based on Feedback**

### **✅ Focus on Average Scores per AE**
- **Previous**: Individual deal scores (many 0.00 scores)
- **Enhanced**: Average performance scores per AE for coaching opportunities

### **✅ Specific Coaching Topics**
- **Product-based coaching**: Based on products in their pipeline
- **Future pipe-gen opportunities**: Best products for future pipeline generation
- **Stage-based coaching**: Based on deal stages and bottlenecks

### **✅ Actionable Coaching Recommendations**
- **High Performers**: Mentoring opportunities and advanced topics
- **Mid-Range Performers**: Targeted skill development
- **Low Performers**: Urgent coaching and basic skill building

---

## 🚀 **Enhanced Agent Test Utterances**

### **1. Average Score-Based Coaching (10 utterances)**

1. **"Show me AE coaching opportunities based on average scores in EMEA SMB"**
   - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Average scores per AE, not individual deal scores

2. **"What are the coaching priorities for AEs with low average scores in AMER ACC?"**
   - **Expected**: Tool: open_pipe_analyze, OU: AMER ACC, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Low performers need urgent coaching

3. **"Find high-performing AEs who can mentor others in APAC"**
   - **Expected**: Tool: open_pipe_analyze, OU: APAC, Intelligence: AE Performance + Coaching Topics
   - **Focus**: High performers (4.0+ average scores) for mentoring

4. **"Show me mid-range AEs who need targeted coaching in UKI"**
   - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Mid-range performers (1.0-3.0 average scores)

5. **"What coaching topics are needed for AEs with declining average scores in EMEA?"**
   - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Declining performance trends

6. **"Generate coaching recommendations based on average performance in AMER"**
   - **Expected**: Tool: open_pipe_analyze, OU: AMER, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Performance-based coaching recommendations

7. **"Show me AEs who need urgent coaching support in EMEA SMB"**
   - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Urgent coaching needs (very low average scores)

8. **"What are the coaching opportunities for AEs with inconsistent performance in APAC?"**
   - **Expected**: Tool: open_pipe_analyze, OU: APAC, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Inconsistent performance patterns

9. **"Find AEs who need advanced coaching topics in UKI"**
   - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: AE Performance + Coaching Topics
   - **Focus**: Advanced coaching for high performers

10. **"Show me coaching priorities based on average scores and performance trends in EMEA"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: AE Performance + Coaching Topics
    - **Focus**: Score-based and trend-based coaching priorities

---

### **2. Product-Based Coaching Topics (10 utterances)**

11. **"What coaching topics are needed for AEs working with Data Cloud in AMER ACC?"**
    - **Expected**: Tool: open_pipe_analyze, OU: AMER ACC, Product: Data Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Data Cloud-specific coaching topics

12. **"Show me coaching recommendations for AEs with Tableau deals in EMEA SMB"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Product: Tableau, Intelligence: AE Performance + Product Coaching
    - **Focus**: Tableau-specific coaching topics

13. **"Find AEs who need Sales Cloud coaching in APAC"**
    - **Expected**: Tool: open_pipe_analyze, OU: APAC, Product: Sales Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Sales Cloud-specific coaching topics

14. **"What coaching topics are best for AEs with Marketing Cloud pipeline in UKI?"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Product: Marketing Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Marketing Cloud-specific coaching topics

15. **"Show me Service Cloud coaching opportunities for AEs in EMEA"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Product: Service Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Service Cloud-specific coaching topics

16. **"What coaching topics are needed for AEs working with Platform Cloud in AMER?"**
    - **Expected**: Tool: open_pipe_analyze, OU: AMER, Product: Platform Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Platform Cloud-specific coaching topics

17. **"Find AEs who need Analytics Cloud coaching in EMEA SMB"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Product: Analytics Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Analytics Cloud-specific coaching topics

18. **"Show me Commerce Cloud coaching recommendations for AEs in APAC"**
    - **Expected**: Tool: open_pipe_analyze, OU: APAC, Product: Commerce Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Commerce Cloud-specific coaching topics

19. **"What coaching topics are best for AEs with Health Cloud deals in UKI?"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Product: Health Cloud, Intelligence: AE Performance + Product Coaching
    - **Focus**: Health Cloud-specific coaching topics

20. **"Find AEs who need Einstein Analytics coaching in EMEA"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Product: Einstein Analytics, Intelligence: AE Performance + Product Coaching
    - **Focus**: Einstein Analytics-specific coaching topics

---

### **3. Future Pipe-Gen Coaching (10 utterances)**

21. **"What are the best coaching topics for future pipe-gen opportunities in AMER ACC?"**
    - **Expected**: Tool: future_pipeline, OU: AMER ACC, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline generation coaching topics

22. **"Show me coaching recommendations for AEs to improve future pipe-gen in EMEA SMB"**
    - **Expected**: Tool: future_pipeline, OU: EMEA SMB, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline generation coaching

23. **"Find AEs who need coaching on best products for future pipe-gen in APAC"**
    - **Expected**: Tool: future_pipeline, OU: APAC, Intelligence: PMF + Coaching Topics
    - **Focus**: Product-Market Fit coaching for future pipeline

24. **"What coaching topics are needed for future pipe-gen success in UKI?"**
    - **Expected**: Tool: future_pipeline, OU: UKI, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline generation success coaching

25. **"Show me coaching priorities for AEs to improve future pipe-gen performance in EMEA"**
    - **Expected**: Tool: future_pipeline, OU: EMEA ENTR, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline performance coaching

26. **"What are the coaching opportunities for future pipe-gen in AMER?"**
    - **Expected**: Tool: future_pipeline, OU: AMER, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline generation opportunities

27. **"Find AEs who need coaching on product-market fit for future pipe-gen in EMEA SMB"**
    - **Expected**: Tool: future_pipeline, OU: EMEA SMB, Intelligence: PMF + Coaching Topics
    - **Focus**: PMF coaching for future pipeline

28. **"Show me coaching recommendations for AEs to improve future pipe-gen in APAC"**
    - **Expected**: Tool: future_pipeline, OU: APAC, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline generation improvement

29. **"What coaching topics are best for future pipe-gen success in UKI?"**
    - **Expected**: Tool: future_pipeline, OU: UKI, Intelligence: PMF + Coaching Topics
    - **Focus**: Future pipeline success coaching

30. **"Find AEs who need coaching on best products for future pipe-gen in EMEA"**
    - **Expected**: Tool: future_pipeline, OU: EMEA ENTR, Intelligence: PMF + Coaching Topics
    - **Focus**: Best products for future pipeline coaching

---

### **4. Stage-Based Coaching (10 utterances)**

31. **"What coaching topics are needed for AEs with deals stuck in Discovery stage in AMER ACC?"**
    - **Expected**: Tool: open_pipe_analyze, OU: AMER ACC, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Discovery stage coaching topics

32. **"Show me coaching recommendations for AEs with deals stuck in Qualification stage in EMEA SMB"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Qualification stage coaching topics

33. **"Find AEs who need coaching on Proposal stage deals in APAC"**
    - **Expected**: Tool: open_pipe_analyze, OU: APAC, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Proposal stage coaching topics

34. **"What coaching topics are best for AEs with deals stuck in Negotiation stage in UKI?"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Negotiation stage coaching topics

35. **"Show me coaching opportunities for AEs with deals stuck in Closing stage in EMEA"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Closing stage coaching topics

36. **"What coaching topics are needed for AEs with long dwell times in Discovery stage in AMER?"**
    - **Expected**: Tool: open_pipe_analyze, OU: AMER, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Long dwell time coaching topics

37. **"Find AEs who need coaching on stage progression in EMEA SMB"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Stage progression coaching topics

38. **"Show me coaching recommendations for AEs with stage bottlenecks in APAC"**
    - **Expected**: Tool: open_pipe_analyze, OU: APAC, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Stage bottleneck coaching topics

39. **"What coaching topics are best for AEs with deals stuck in multiple stages in UKI?"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Multi-stage coaching topics

40. **"Find AEs who need coaching on stage-specific skills in EMEA"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: Stage Bottlenecks + Coaching Topics
    - **Focus**: Stage-specific skill coaching topics

---

### **5. Comprehensive Coaching Analysis (10 utterances)**

41. **"Show me comprehensive coaching analysis for AEs in EMEA SMB with average scores and product focus"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: AE Performance + Coaching Topics + Product Coaching
    - **Focus**: Comprehensive coaching analysis

42. **"What are the coaching priorities for AEs in AMER ACC based on average scores, products, and stages?"**
    - **Expected**: Tool: open_pipe_analyze, OU: AMER ACC, Intelligence: AE Performance + Coaching Topics + Product Coaching + Stage Coaching
    - **Focus**: Multi-dimensional coaching priorities

43. **"Find AEs who need urgent coaching in APAC based on performance, products, and future pipe-gen"**
    - **Expected**: Tool: open_pipe_analyze, OU: APAC, Intelligence: AE Performance + Coaching Topics + Product Coaching + PMF
    - **Focus**: Urgent coaching needs

44. **"Show me coaching recommendations for AEs in UKI with focus on average scores and stage bottlenecks"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: AE Performance + Coaching Topics + Stage Coaching
    - **Focus**: Score and stage-based coaching

45. **"What coaching topics are needed for AEs in EMEA based on performance trends and product mix?"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: AE Performance + Coaching Topics + Product Coaching
    - **Focus**: Performance trend and product-based coaching

46. **"Find AEs who need coaching on future pipe-gen opportunities in AMER based on current performance"**
    - **Expected**: Tool: future_pipeline, OU: AMER, Intelligence: PMF + Coaching Topics + AE Performance
    - **Focus**: Future pipeline coaching based on current performance

47. **"Show me coaching priorities for AEs in EMEA SMB with focus on average scores and stage progression"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA SMB, Intelligence: AE Performance + Coaching Topics + Stage Coaching
    - **Focus**: Score and stage progression coaching

48. **"What are the coaching opportunities for AEs in APAC based on product expertise and future pipe-gen?"**
    - **Expected**: Tool: future_pipeline, OU: APAC, Intelligence: PMF + Coaching Topics + Product Coaching
    - **Focus**: Product expertise and future pipeline coaching

49. **"Find AEs who need comprehensive coaching in UKI based on all performance factors"**
    - **Expected**: Tool: open_pipe_analyze, OU: UKI, Intelligence: AE Performance + Coaching Topics + Product Coaching + Stage Coaching
    - **Focus**: Comprehensive coaching analysis

50. **"Show me coaching recommendations for AEs in EMEA with focus on average scores, products, stages, and future pipe-gen"**
    - **Expected**: Tool: open_pipe_analyze, OU: EMEA ENTR, Intelligence: AE Performance + Coaching Topics + Product Coaching + Stage Coaching + PMF
    - **Focus**: Complete coaching analysis

---

## 🎯 **Expected Coaching Output Format**

### **For Each AE, the system should provide:**

1. **Average Score**: Overall performance score (not individual deal scores)
2. **Performance Category**: High (4.0+), Mid-Range (1.0-3.0), Low (0.0-1.0)
3. **Coaching Priority**: Urgent, High, Medium, Low
4. **Product-Based Coaching Topics**: Based on products in their pipeline
5. **Stage-Based Coaching Topics**: Based on deal stages and bottlenecks
6. **Future Pipe-Gen Coaching**: Best products for future pipeline generation
7. **Specific Recommendations**: Actionable coaching topics and next steps

### **Example Output Format:**
```
AE: John Smith
Average Score: 2.3 (Mid-Range Performer)
Coaching Priority: High
Products in Pipeline: Data Cloud, Sales Cloud
Stage Bottlenecks: Discovery, Qualification
Future Pipe-Gen Opportunities: Marketing Cloud, Service Cloud

Coaching Topics:
1. Data Cloud Product Expertise
2. Discovery Stage Skills
3. Qualification Techniques
4. Future Pipeline Generation
5. Cross-Sell Opportunities
```

---

## 📈 **Success Criteria**

- **Average Score Focus**: 100% of coaching analysis based on average scores per AE
- **Product-Based Coaching**: 80%+ of recommendations include product-specific topics
- **Stage-Based Coaching**: 70%+ of recommendations include stage-specific topics
- **Future Pipe-Gen Coaching**: 60%+ of recommendations include future pipeline topics
- **Actionable Recommendations**: 90%+ of coaching topics are specific and actionable

---

## 🚀 **Ready for Testing**

These enhanced utterances focus on:
- **Average scores per AE** (not individual deal scores)
- **Product-specific coaching topics** based on pipeline products
- **Stage-based coaching topics** based on deal stages and bottlenecks
- **Future pipe-gen coaching** based on best products for future pipeline
- **Comprehensive coaching analysis** combining all factors

**Test these utterances with your agent to validate the enhanced coaching capabilities!** 🎯
