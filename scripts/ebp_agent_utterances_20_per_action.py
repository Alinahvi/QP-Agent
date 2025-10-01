#!/usr/bin/env python3
"""
EBP Agent POC - 20 Utterances Per Action
Generated with diverse parameters: management, vertical, country, OU, etc.
"""

def generate_ebp_utterances():
    """Generate 20 utterances per action for EBP Agent POC"""
    
    # KPI Analysis Utterances (20)
    kpi_utterances = [
        # Basic KPI queries with different countries and OUs
        "Show me avg calls in Germany for EMEA ENTR",
        "What's the average ACV for AMER ACC this quarter?",
        "Compare coverage rates between US and UK for this month",
        "Find meeting statistics for APAC region",
        "Show me call connections in LATAM OU",
        
        # Ramp status analysis
        "Break down meetings by slow ramping vs fast ramping AEs in EMEA ENTR",
        "Compare ACV performance between ramped and ramping AEs in AMER ACC",
        "Show me coverage by ramp status in UKI OU",
        "What's the pipeline generation difference between ramped and ramping AEs in APAC?",
        "Analyze call connections by ramp status in LATAM",
        
        # Quarter comparisons
        "Compare this quarter vs last quarter ACV in Germany",
        "Show me meeting trends: current vs previous quarter in EMEA ENTR",
        "What's the ACV growth from last quarter to this quarter in AMER ACC?",
        "Compare call connection improvement in UKI this quarter vs last quarter",
        "Show me coverage changes from last quarter in APAC",
        
        # Management and vertical analysis
        "Show me performance metrics by management level in EMEA ENTR",
        "Compare ACV by vertical industry in AMER ACC",
        "What's the meeting performance by management tier in UKI?",
        "Show me call connections by vertical in APAC",
        "Analyze coverage rates by management level in LATAM"
    ]
    
    # Content Search Utterances (20)
    content_utterances = [
        # ACT articles and courses
        "Show me ACT articles on AI and machine learning for EMEA ENTR",
        "Find ACT courses on Data Cloud implementation in AMER ACC",
        "Search for ACT content about Service Cloud best practices in UKI",
        "Look for ACT articles on Marketing Cloud automation in APAC",
        "Get ACT courses on Platform development for LATAM",
        
        # Documentation and guides
        "Find documentation about Sales Cloud configuration in EMEA ENTR",
        "Look for guides on Einstein Analytics setup in AMER ACC",
        "Search for documentation on Lightning Web Components in UKI",
        "Get guides on Apex programming best practices in APAC",
        "Find documentation about Flow automation in LATAM",
        
        # Vertical-specific content
        "Show me content about healthcare industry solutions in EMEA ENTR",
        "Find articles on financial services implementations in AMER ACC",
        "Search for manufacturing industry content in UKI",
        "Look for retail industry solutions in APAC",
        "Get content about government sector implementations in LATAM",
        
        # Management and training content
        "Find management training content for EMEA ENTR leaders",
        "Search for executive-level Salesforce content in AMER ACC",
        "Look for team management guides in UKI",
        "Get leadership development content in APAC",
        "Find strategic planning resources for LATAM management"
    ]
    
    # SME Search Utterances (20)
    sme_utterances = [
        # Regional experts
        "Search for experts on Salesforce CRM in EMEA ENTR",
        "Find SMEs for Data Cloud in AMER ACC region",
        "Who are the Service Cloud experts in UKI?",
        "Look for Marketing Cloud specialists in APAC",
        "Find Platform development experts in LATAM",
        
        # Vertical expertise
        "Who knows about healthcare industry solutions in EMEA ENTR?",
        "Find experts on financial services implementations in AMER ACC",
        "Search for manufacturing industry specialists in UKI",
        "Look for retail industry experts in APAC",
        "Who are the government sector specialists in LATAM?",
        
        # Technical expertise
        "Find Apex programming experts in EMEA ENTR",
        "Who knows about Lightning Web Components in AMER ACC?",
        "Search for Flow automation specialists in UKI",
        "Look for Einstein Analytics experts in APAC",
        "Find Integration specialists in LATAM",
        
        # Management and leadership
        "Who are the management consultants in EMEA ENTR?",
        "Find executive advisors in AMER ACC",
        "Search for leadership coaches in UKI",
        "Look for strategic advisors in APAC",
        "Who are the change management experts in LATAM?"
    ]
    
    # Future Pipeline Utterances (20) - WITH OU/COUNTRY
    future_pipeline_utterances = [
        # Renewal opportunities
        "What are the top renewal products for UKI OU?",
        "Show me renewal opportunities for EMEA ENTR",
        "Generate renewal pipeline for AMER ACC",
        "Find renewal opportunities in APAC region",
        "What are the best renewal products for LATAM?",
        
        # Cross-sell opportunities
        "Show me cross-sell opportunities for Data Cloud in EMEA ENTR",
        "Generate cross-sell pipeline for Service Cloud in AMER ACC",
        "Find cross-sell opportunities for Marketing Cloud in UKI",
        "What are the top cross-sell products for APAC?",
        "Create cross-sell opportunities for Platform in LATAM",
        
        # Upsell opportunities
        "Show me upsell potential for Einstein Analytics in EMEA ENTR",
        "Generate upsell pipeline for Lightning Web Components in AMER ACC",
        "Find upsell opportunities for Apex in UKI",
        "What are the highest value upsell products for APAC?",
        "Create upsell opportunities for Flow in LATAM",
        
        # Vertical and management opportunities
        "What are the top products for healthcare industry in EMEA ENTR?",
        "Show me opportunities for financial services in AMER ACC",
        "Generate pipeline for manufacturing industry in UKI",
        "Find opportunities for retail sector in APAC",
        "What are the best products for government sector in LATAM?"
    ]
    
    # Open Pipe Analysis Utterances (20) - WITH OU/COUNTRY
    open_pipe_utterances = [
        # Stage analysis
        "Show me open pipe analysis for EMEA ENTR by stage",
        "What products are in the passed stage for AMER ACC?",
        "Analyze open pipe by stage for UKI OU",
        "Show me stage breakdown for APAC region",
        "What's the open pipe analysis for LATAM by stage?",
        
        # Product analysis
        "Show me Data Cloud products in open pipe for EMEA ENTR",
        "What Service Cloud opportunities are in open pipe for AMER ACC?",
        "Analyze Marketing Cloud open pipe for UKI",
        "Show me Platform products in open pipe for APAC",
        "What Einstein Analytics opportunities are open for LATAM?",
        
        # Vertical analysis
        "Show me healthcare industry open pipe for EMEA ENTR",
        "What financial services opportunities are open for AMER ACC?",
        "Analyze manufacturing industry open pipe for UKI",
        "Show me retail sector open pipe for APAC",
        "What government sector opportunities are open for LATAM?",
        
        # Management and value analysis
        "Show me high-value open pipe opportunities for EMEA ENTR",
        "What are the largest open pipe deals for AMER ACC?",
        "Analyze open pipe by deal size for UKI",
        "Show me strategic open pipe opportunities for APAC",
        "What are the priority open pipe deals for LATAM?"
    ]
    
    # Workflow Utterances (20)
    workflow_utterances = [
        # Process workflows
        "Show me the workflow for lead qualification in EMEA ENTR",
        "What's the process for opportunity management in AMER ACC?",
        "Guide me through the sales process workflow in UKI",
        "Show me the customer onboarding workflow in APAC",
        "What's the process for contract renewal in LATAM?",
        
        # Management workflows
        "Show me the management approval workflow in EMEA ENTR",
        "What's the process for budget approval in AMER ACC?",
        "Guide me through the performance review workflow in UKI",
        "Show me the strategic planning workflow in APAC",
        "What's the process for team management in LATAM?",
        
        # Technical workflows
        "Show me the deployment workflow for EMEA ENTR",
        "What's the process for code review in AMER ACC?",
        "Guide me through the testing workflow in UKI",
        "Show me the release management workflow in APAC",
        "What's the process for system maintenance in LATAM?",
        
        # Vertical-specific workflows
        "Show me the healthcare compliance workflow in EMEA ENTR",
        "What's the process for financial services approval in AMER ACC?",
        "Guide me through the manufacturing quality workflow in UKI",
        "Show me the retail inventory workflow in APAC",
        "What's the process for government procurement in LATAM?"
    ]
    
    return {
        'kpi_analyze': kpi_utterances,
        'content_search': content_utterances,
        'sme_search': sme_utterances,
        'future_pipeline': future_pipeline_utterances,
        'open_pipe_analyze': open_pipe_utterances,
        'workflow': workflow_utterances
    }

def print_utterances_by_action(utterances_dict):
    """Print utterances organized by action"""
    
    print("🚀 EBP Agent POC - 20 Utterances Per Action")
    print("=" * 80)
    
    for action, utterances in utterances_dict.items():
        print(f"\n📊 {action.upper().replace('_', ' ')} ({len(utterances)} utterances)")
        print("-" * 60)
        
        for i, utterance in enumerate(utterances, 1):
            print(f"{i:2d}. {utterance}")
    
    print("\n" + "=" * 80)
    print(f"Total utterances: {sum(len(utterances) for utterances in utterances_dict.values())}")

def save_utterances_to_file(utterances_dict, filename):
    """Save utterances to a text file"""
    
    with open(filename, 'w') as f:
        f.write("EBP Agent POC - 20 Utterances Per Action\n")
        f.write("=" * 80 + "\n\n")
        
        for action, utterances in utterances_dict.items():
            f.write(f"{action.upper().replace('_', ' ')} ({len(utterances)} utterances)\n")
            f.write("-" * 60 + "\n")
            
            for i, utterance in enumerate(utterances, 1):
                f.write(f"{i:2d}. {utterance}\n")
            
            f.write("\n")
        
        f.write("=" * 80 + "\n")
        f.write(f"Total utterances: {sum(len(utterances) for utterances in utterances_dict.values())}\n")

if __name__ == "__main__":
    # Generate utterances
    utterances = generate_ebp_utterances()
    
    # Print to console
    print_utterances_by_action(utterances)
    
    # Save to file
    filename = "ebp_agent_utterances_20_per_action.txt"
    save_utterances_to_file(utterances, filename)
    
    print(f"\n💾 Utterances saved to: {filename}")
    
    # Summary
    total_utterances = sum(len(utterances_list) for utterances_list in utterances.values())
    print(f"\n📈 Summary:")
    print(f"   Actions: {len(utterances)}")
    print(f"   Total utterances: {total_utterances}")
    print(f"   Utterances per action: 20")
    
    # Parameter diversity summary
    print(f"\n🎯 Parameter Diversity:")
    print(f"   OUs: EMEA ENTR, AMER ACC, UKI, APAC, LATAM")
    print(f"   Countries: Germany, US, UK, APAC, LATAM")
    print(f"   Verticals: Healthcare, Financial Services, Manufacturing, Retail, Government")
    print(f"   Management: Leadership, Executive, Team Management, Strategic Planning")
    print(f"   Products: Data Cloud, Service Cloud, Marketing Cloud, Platform, Einstein Analytics")
    print(f"   Timeframes: This quarter, Last quarter, This month, Current vs Previous")
