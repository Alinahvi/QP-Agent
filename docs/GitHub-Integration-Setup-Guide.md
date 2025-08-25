# GitHub Integration Setup Guide

## Overview
This guide will help you set up a secure GitHub integration with your Salesforce org. The integration allows you to interact with GitHub repositories directly from Salesforce using the GitHub API.

## Prerequisites
- Salesforce org with API access
- SFDX CLI installed
- GitHub personal access token
- Access to your Salesforce project

## Security Notice ⚠️
**IMPORTANT**: The GitHub token you shared earlier has been exposed. You must:
1. **Immediately revoke** the token from GitHub Settings → Developer settings → Personal access tokens
2. **Generate a new token** with appropriate permissions
3. **Never share tokens in plain text** in chat, emails, or code comments

## Step 1: Generate New GitHub Token
1. Go to [GitHub Settings](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Salesforce Integration")
4. Select scopes:
   - `repo` (Full control of private repositories)
   - `read:user` (Read user profile data)
   - `read:org` (Read organization data)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)

## Step 2: Deploy Integration Classes
Run the deployment script from your project root:

```bash
chmod +x scripts/deploy-github-integration.sh
./scripts/deploy-github-integration.sh
```

Or deploy manually using SFDX:

```bash
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationService.cls
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationService.cls-meta.xml
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationServiceTest.cls
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationServiceTest.cls-meta.xml
```

## Step 3: Configure GitHub Token
1. Open Salesforce Setup
2. Navigate to Apex Classes
3. Find and open `GitHubIntegrationService`
4. Locate line 108 in the `makeGitHubRequest` method
5. Replace `YOUR_GITHUB_TOKEN` with your actual token:

```apex
request.setHeader('Authorization', 'token ghp_your_actual_token_here');
```

6. Save the class

## Step 4: Test the Integration
1. Open Salesforce Developer Console
2. Go to Debug → Open Execute Anonymous Window
3. Run this code:

```apex
// Test the GitHub connection
String result = GitHubIntegrationService.testConnection();
System.debug('Connection test result: ' + result);

// Get repository information
Map<String, Object> repoInfo = GitHubIntegrationService.getRepositoryInfo();
System.debug('Repository info: ' + repoInfo);

// Get user profile
Map<String, Object> userProfile = GitHubIntegrationService.getUserProfile();
System.debug('User profile: ' + userProfile);
```

## Step 5: Available Methods
The `GitHubIntegrationService` class provides these methods:

- `getRepositoryInfo()` - Get repository details
- `getRepositoryContents(String path)` - List files/directories
- `getUserProfile()` - Get user profile information
- `searchRepositories(String query)` - Search repositories
- `testConnection()` - Test the connection

## Step 6: Custom Metadata (Recommended)
For production use, consider storing the token in Custom Metadata:

1. Create Custom Metadata Type `GitHub_Config__mdt`
2. Add fields: `Token__c`, `Username__c`, `Repository__c`
3. Update the service class to read from metadata instead of hardcoded values

## Troubleshooting

### Common Issues

**"Callout not allowed" error:**
- Ensure your org allows callouts to external sites
- Check if you're in a test context

**"Unauthorized" error:**
- Verify your GitHub token is valid
- Check token permissions
- Ensure token hasn't expired

**"Rate limit exceeded":**
- GitHub API has rate limits
- Implement exponential backoff in production code

### Debug Information
Check Salesforce debug logs for detailed error information and API responses.

## Security Best Practices

1. **Never commit tokens** to version control
2. **Use Custom Metadata** for production configurations
3. **Implement IP restrictions** on GitHub tokens if possible
4. **Regularly rotate tokens** (every 90 days)
5. **Monitor token usage** in GitHub settings
6. **Use least privilege** - only grant necessary permissions

## Next Steps

Once the integration is working, you can:

1. **Extend functionality** - Add methods for creating issues, managing pull requests
2. **Implement webhooks** - Receive real-time updates from GitHub
3. **Build custom UI** - Create Lightning components for GitHub management
4. **Automate workflows** - Trigger Salesforce processes based on GitHub events

## Support

If you encounter issues:
1. Check Salesforce debug logs
2. Verify GitHub token permissions
3. Test API endpoints directly in GitHub
4. Review this guide for common solutions

---

**Remember**: Keep your GitHub tokens secure and never share them in plain text!
