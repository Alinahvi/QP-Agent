@IsTest
public with sharing class FRAGENTTestDataFactory {
    // Cache Permission Set Ids keyed by their LABEL to avoid duplicate queries
    private static Map<String, Id> permissionSetCache = new Map<String, Id>();

    /**
     * Creates and optionally inserts a list of User records with a specified profile.
     * This is the single, authoritative method for creating test Users.
     * @param count The number of users to create.
     * @param profileName The name of the Profile to assign to the users.
     * @param doInsert If true, the users will be inserted into the database.
     * @return A list of User records.
     */
    public static List<User> createUsers(Integer count, String profileName, Boolean doInsert) {
        // Default to the running user's profile to ensure a valid ProfileId
        Id profileId = UserInfo.getProfileId();

        // Attempt to locate the profile by name when provided.  Any exception
        // (including insufficient access to the Profile object) is caught so
        // that tests can still proceed by falling back to the running user's
        // profile.
        if (String.isNotBlank(profileName)) {
            try {
                profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'Test data factory could not resolve profile "' + profileName + '": ' + e.getMessage());
            }
        }

        if (profileId == null) {
            // Fallback to a standard user profile if the named one doesn't exist
            // or wasn't accessible.
            try {
                List<Profile> profiles = [
                    SELECT Id FROM Profile WHERE UserType = 'Standard' ORDER BY Name LIMIT 1
                ];
                if (!profiles.isEmpty()) {
                    profileId = profiles[0].Id;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'Test data factory could not query default profile: ' + e.getMessage());
            }
        }

        // Final safeguard - ensure a profile Id was located. If everything above
        // fails, fall back once more to the context user's profile before
        // asserting.
        if (profileId == null) {
            profileId = UserInfo.getProfileId();
        }
        System.assertNotEquals(null, profileId,
            'Test setup failed: No suitable Profile found in this org.');

        List<User> users = new List<User>();
        for (Integer i = 0; i < count; i++) {
            String uniqueSuffix = String.valueOf(System.currentTimeMillis()) + String.valueOf(i);
            String alias = 't' + uniqueSuffix;
            if(alias.length() > 8) {
                alias = alias.substring(alias.length() - 8);
            }
            
            users.add(new User(
                Alias = alias,
                Email = 'testuser' + uniqueSuffix + '@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'testuser' + uniqueSuffix + '@testorg.com'
            ));
        }
        if (doInsert) {
            insert users;
        }
        return users;
    }

    /**
     * Overloaded method to create users with a default profile and insert them.
     */
    public static List<User> createUsers(Integer count) {
        return createUsers(count, 'Standard User', true);
    }

    /**
     * Creates Learner Profile records along with their associated Users.
     * Tests can wrap calls to this method in System.runAs when mixed DML needs
     * to be avoided or specific user permissions are required.
     */
    public static List<Learner_Profile__c> createLearnerProfiles(Integer count, Boolean doInsert) {
        // Create the Users in the current context
        List<User> users = createUsers(count, 'Standard User', doInsert);

        // Create the corresponding Learner Profiles
        List<Learner_Profile__c> profiles = new List<Learner_Profile__c>();
        for (User u : users) {
            profiles.add(new Learner_Profile__c(
                Name = u.LastName,
                User__c = u.Id,
                Status__c = 'Active',
                Primary_Email__c = u.Email,
                SlackId__c = 'SLACK-' + u.Id
            ));
        }
        if (doInsert) {
            insert profiles;
        }
        return profiles;
    }

    /**
     * Creates and optionally inserts test Audience records.
     */
    public static List<Audience__c> createAudiences(Integer count, Boolean doInsert) {
        List<Audience__c> audiences = new List<Audience__c>();
        for (Integer i = 0; i < count; i++) {
            audiences.add(new Audience__c(Name = 'Test Audience ' + i));
        }
        if (doInsert) {
            insert audiences;
        }
        return audiences;
    }

    /**
     * Creates and optionally inserts a list of Audience Member records.
     */
    public static List<Audience_Member__c> createAudienceMembers(Audience__c audience, List<Learner_Profile__c> learners, Boolean doInsert) {
        List<Audience_Member__c> members = new List<Audience_Member__c>();
        for (Learner_Profile__c lp : learners) {
            members.add(new Audience_Member__c(Audience__c = audience.Id, Learner_Profile__c = lp.Id));
        }
        if (doInsert) {
            insert members;
        }
        return members;
    }

    /**
     * Creates and optionally inserts test Checklist records.
     */
    public static List<Checklist__c> createChecklists(Integer count, Boolean doInsert) {
        List<Checklist__c> checklists = new List<Checklist__c>();
        for (Integer i = 0; i < count; i++) {
            checklists.add(new Checklist__c(Name = 'Test Checklist ' + i));
        }
        if (doInsert) {
            insert checklists;
        }
        return checklists;
    }

    /**
     * Creates Asset records. The running user must have permission to create
     * Asset__c records. Tests may assign permission sets and/or use System.runAs
     * when necessary.
     */
    public static List<Asset__c> createAssets(Integer count, Boolean doInsert) {
        // Ensure the current user can create Asset records
        User runUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        assignPermissionSet(runUser, 'ACT Learning Admin');

        List<Asset__c> assets = new List<Asset__c>();
        for (Integer i = 0; i < count; i++) {
            assets.add(new Asset__c(
                Name = 'Test Asset ' + i,
                RecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId()
            ));
        }
        if (doInsert) {
            insert assets;
        }
        return assets;
    }

    public static List<Course__c> createCourses(Integer count) {
        List<Course__c> courses = new List<Course__c>();
        for (Integer i = 0; i < count; i++) {
            courses.add(new Course__c(Name = 'Test Course ' + i));
        }
        return courses;
    }

    public static List<Curriculum__c> createCurricula(Integer count) {
        List<Curriculum__c> curricula = new List<Curriculum__c>();
        for (Integer i = 0; i < count; i++) {
            curricula.add(new Curriculum__c(Name = 'Test Curriculum ' + i));
        }
        return curricula;
    }

    public static ContentVersion createContentVersion(String title, Boolean doInsert) {
        ContentVersion cv = new ContentVersion(Title = title, PathOnClient = title + '.txt', VersionData = Blob.valueOf('Test Content'));
        if (doInsert) {
            insert cv;
        }
        return cv;
    }

    /**
     * @description Creates a PermissionSet if it doesn't exist.
     */
    public static PermissionSet createPermissionSet(String name) {
        if (permissionSetCache.containsKey(name)) {
            return new PermissionSet(Id = permissionSetCache.get(name));
        }

        // Attempt to locate an existing Permission Set by label first. This
        // handles scenarios where the Permission Set comes from a managed
        // package and therefore has a namespaced API name that wouldn't match
        // our sanitized version.
        List<PermissionSet> existingPs = [
            SELECT Id FROM PermissionSet WHERE Label = :name LIMIT 1
        ];

        if (existingPs.isEmpty()) {
            // Fall back to searching by the sanitized API name if no record with
            // the given label exists. This covers Permission Sets created by the
            // test factory itself.
            String apiName = sanitizePermissionSetName(name);
            existingPs = [SELECT Id FROM PermissionSet WHERE Name = :apiName LIMIT 1];
        }

        if (!existingPs.isEmpty()) {
            permissionSetCache.put(name, existingPs[0].Id);
            return existingPs[0];
        }

        // Nothing found, create a new Permission Set with a sanitized API name
        // and the provided label.
        PermissionSet ps = new PermissionSet(
            Name  = sanitizePermissionSetName(name),
            Label = name
        );
        insert ps;
        permissionSetCache.put(name, ps.Id);
        return ps;
    }

    /**
     * FIX: Completed and corrected this method.
     * Assigns a permission set to a user.
     */
    public static void assignPermissionSet(User u, String permLabel) {
        PermissionSet ps = createPermissionSet(permLabel);
        // Use System.runAs to avoid mixed DML errors when called after other DML
        System.runAs(u) {
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }
    }

    /**
     * Overloaded helper to assign a permission set and update the user's alias.
     */
    public static void assignPermissionSet(User u, String permLabel, String alias) {
        if (alias != null) {
            u.Alias = alias.left(8);
            update u;
        }
        assignPermissionSet(u, permLabel);
    }
    
    /**
     * FIX: New helper method to create a user and assign specified permission sets.
     * This is the recommended way to create test users for services that require permissions.
     */
    public static User createTestUserWithPermissions(String profileName, List<String> permissionSetApiNames) {
        // Create the user in the current context
        User testUser = createUsers(1, profileName, true)[0];

        // Assign any requested permission sets
        if (permissionSetApiNames != null && !permissionSetApiNames.isEmpty()) {
            List<PermissionSet> pSetsToAssign = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetApiNames];
            if (!pSetsToAssign.isEmpty()) {
                List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
                for (PermissionSet ps : pSetsToAssign) {
                    assignments.add(new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id));
                }
                insert assignments;
            }
        }

        // Create the associated Learner Profile
        insert new Learner_Profile__c(
            Name = testUser.LastName,
            User__c = testUser.Id,
            Status__c = 'Active',
            Primary_Email__c = testUser.Email
        );

        return testUser;
    }

    /**
     * Utility to generate a fake Id with the proper key prefix for a given object.
     */
    public static Id generateFakeId(Schema.SObjectType sobjectType) {
        String prefix = sobjectType.getDescribe().getKeyPrefix();
        if (String.isBlank(prefix)) {
            prefix = '001';
        }
        String randomPart = Math.abs(Crypto.getRandomInteger()).format().replaceAll('[^0-9]', '');
        randomPart = randomPart.leftPad(12, '0').substring(0, 12);
        return (Id)(prefix + randomPart);
    }

    private static String sanitizePermissionSetName(String name) {
        // Replace invalid characters
        String sanitized = name.replaceAll('[^a-zA-Z0-9]', '_');
        // Create a short hash from the original name to avoid collisions when
        // truncating long labels to meet the 40 character API name limit
        String hash = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(name))
        ).substring(0, 5);
        // Reserve room for the underscore and hash suffix
        sanitized = sanitized.left(34);
        return sanitized + '_' + hash;
    }
}