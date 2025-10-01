#!/bin/bash

# Deploy QP Agent Permission Set
# This script deploys the QP_Agent_Pilot_Perms permission set to the Salesforce org

echo "🚀 Deploying QP Agent Permission Set..."

# Check if we're in the right directory
if [ ! -f "sfdx-project.json" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Deploy the permission set
echo "📦 Deploying QP_Agent_Pilot_Perms permission set..."
sfdx force:source:deploy -p force-app/main/default/permissionsets/QP_Agent_Pilot_Perms.permissionset-meta.xml

if [ $? -eq 0 ]; then
    echo "✅ Permission set deployed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Assign the 'QP_Agent_Pilot_Perms' permission set to pilot users"
    echo "2. Verify users can access the agent actions"
    echo "3. Test the QP Agent functionality"
    echo ""
    echo "🔧 To assign the permission set to a user:"
    echo "   sfdx force:user:permset:assign -n QP_Agent_Pilot_Perms -u USERNAME"
else
    echo "❌ Deployment failed. Please check the error messages above."
    exit 1
fi
