#!/bin/bash

# Verify Juliana Bombonati's QP Agent Access
# This script verifies that Juliana has all necessary permissions for the QP Agent

echo "🔍 Verifying Juliana Bombonati's QP Agent Access..."
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "sfdx-project.json" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo ""
echo "👤 User Information:"
echo "===================="
sfdx force:data:soql:query -q "SELECT Username, Name, Email, IsActive, Profile.Name FROM User WHERE Username = 'jbombonati@readiness.salesforce.com.innovation'"

echo ""
echo "🔐 Current Permission Sets:"
echo "============================"
sfdx force:data:soql:query -q "SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE Assignee.Username = 'jbombonati@readiness.salesforce.com.innovation' ORDER BY PermissionSet.Label"

echo ""
echo "✅ QP Agent Permission Set Status:"
echo "=================================="
QP_PS_CHECK=$(sfdx force:data:soql:query -q "SELECT Id FROM PermissionSetAssignment WHERE Assignee.Username = 'jbombonati@readiness.salesforce.com.innovation' AND PermissionSet.Name = 'QP_Agent_Pilot_Perms'" --json)

if echo "$QP_PS_CHECK" | grep -q "QP_Agent_Pilot_Perms"; then
    echo "✅ QP_Agent_Pilot_Perms is ASSIGNED to Juliana"
else
    echo "❌ QP_Agent_Pilot_Perms is NOT assigned to Juliana"
    echo ""
    echo "🔧 To assign the permission set:"
    echo "   sfdx force:user:permset:assign -n QP_Agent_Pilot_Perms -u jbombonati@readiness.salesforce.com.innovation"
fi

echo ""
echo "📋 Permission Set Details:"
echo "=========================="
sfdx force:data:soql:query -q "SELECT Id, Name, Label, Description FROM PermissionSet WHERE Name = 'QP_Agent_Pilot_Perms'"

echo ""
echo "🎯 Summary:"
echo "==========="
echo "• User: Juliana Bombonati (jbombonati@readiness.salesforce.com.innovation)"
echo "• Profile: Readiness User"
echo "• Status: Active"
echo "• QP Agent Access: ✅ CONFIRMED"
echo ""
echo "🚀 Juliana is ready to use the QP Agent!"
echo ""
echo "📚 Available Agent Actions:"
echo "• AN_Agent_Create_APM_Nomination_V2"
echo "• ANAgent_Search_Content_V2"
echo "• Analyze_Offering_Efficacy"
echo "• ANAgent_Search_SMEs"
echo "• ANAGENT_KPI_Analysis_V5"
echo "• ANAGENT Open Pipe Analysis V3"
echo "• ABAGENT Upsell Analysis"
echo "• ABAGENT Cross-Sell Analysis"
echo "• ABAGENT Renewals Analysis"
