/**
 * @author Deloitte
 * @date 06/20/2022
 * @description This is test class for AccountTeamMembersSelector class
 */
@isTest
private class AccountTeamMembersSelectorTest {
    private static final String ASSERT_MISMATCH_IN_RECORDS = 'The records are not retrieved correctly';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    /**
     * @description This is method used to test AccountTeamMembersSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        AccountTeamMembersSelector selectorInstance = new AccountTeamMembersSelector();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        System.assertEquals(
            Schema.AccountTeamMember.SObjectType,
            typeOfObject,
            'The object type must be AccountTeamMember'
        );

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                AccountTeamMember.Id,
                AccountTeamMember.TeamMemberRole,
                AccountTeamMember.UserId
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This method used to test the method called selectFranchiseRepRoleAccountTeamMembersByAccountId by providing an account id.
     */
    @isTest
    private static void testWhenAccountIdProvidedThenReturnFranchiseRepTeamMembers() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail4306@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail43063@test.com'
            )
        };
        insert users;
        Account franchiseParent = new Account(Name = 'Franchise Parent Account',Segment__c = ACCOUNT_SEGMENT_SMB);
        insert franchiseParent;
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                TeamMemberRole = 'Franchise Representative',
                UserId = users[0].Id,
                AccountId = franchiseParent.id
            ),
            new AccountTeamMember(
                TeamMemberRole = 'Team Lead',
                UserId = users[1].Id,
                AccountId = franchiseParent.id
            )
        };
        insert accountTeamMembers;
        List<AccountTeamMember> teamMembers = AccountTeamMembersSelector.newInstance()
            .selectFranchiseRepRoleAccountTeamMembersByAccountId(franchiseParent.id);
        System.assertEquals(teamMembers.size(), 1, 'The list should have one record');
    }

    /**
     * @description To test if the Account Team Members are returned when Account Id is passed.
     */
    @isTest
    private static void testWhenAccountIdPassedThenReturnAccountTeamMembers() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail4306@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail43063@test.com'
            )
        };
        insert users;
        Account accountRecord1 = new Account(Name = 'Test Account',Segment__c = ACCOUNT_SEGMENT_SMB);
        insert accountRecord1;
        Account accountRecord2 = new Account(Name = 'Test Account',Segment__c = ACCOUNT_SEGMENT_SMB);
        insert accountRecord2;
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                TeamMemberRole = 'Franchise Representative',
                UserId = users[0].Id,
                AccountId = accountRecord1.Id
            ),
            new AccountTeamMember(
                TeamMemberRole = 'Team Lead',
                UserId = users[1].Id,
                AccountId = accountRecord1.Id
            )
        };
        insert accountTeamMembers;
        List<AccountTeamMember> teamMembers = AccountTeamMembersSelector.newInstance()
            .selectAccountTeamMembersByAccountId(accountRecord1.Id);
        List<AccountTeamMember> queryResult = AccountTeamMembersSelector.newInstance()
            .selectAccountTeamMembersByAccountId(accountRecord2.Id);
        System.assertEquals(teamMembers.size(), 2, ASSERT_MISMATCH_IN_RECORDS);
        System.assertEquals(queryResult.size(), 0, ASSERT_MISMATCH_IN_RECORDS);
    }

    /**
     * @description To test if the Account Team Members are returned when Account Id is passed.
     */
    @isTest
    private static void testWhenAccountIdPassedThenDoNotReturnAccountTeamMembers() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail4306@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail43063@test.com'
            )
        };
        insert users;
        Account accountRecord1 = new Account(Name = 'Test Account', Segment__c = ACCOUNT_SEGMENT_SMB);
        insert accountRecord1;
        Account accountRecord2 = new Account(Name = 'Test Account', Segment__c = ACCOUNT_SEGMENT_SMB);
        insert accountRecord2;
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                TeamMemberRole = 'Franchise Representative',
                UserId = users[0].Id,
                AccountId = accountRecord1.Id
            ),
            new AccountTeamMember(
                TeamMemberRole = 'Team Lead',
                UserId = users[1].Id,
                AccountId = accountRecord1.Id
            )
        };
        insert accountTeamMembers;
        List<AccountTeamMember> queryResult = AccountTeamMembersSelector.newInstance()
            .selectAccountTeamMembersByAccountId(accountRecord2.Id);
        System.assertEquals(queryResult.size(), 0, ASSERT_MISMATCH_IN_RECORDS);
    }
}