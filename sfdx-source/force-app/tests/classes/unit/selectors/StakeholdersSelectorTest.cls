/**
 * @author Deloitte
 * @date 06/07/2024
 * @description This is test class for StakeholdersSelector.
 */
@isTest(SeeAllData=false)
private class StakeholdersSelectorTest {
    private static final String AGGREGATE_STAKEHOLDERS_COUNT_ALIAS = 'stakeholdersCount';
    private static final String AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS = 'mxTouchpointId';
    private static final String ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT = 'Unexpected result: incorrect count of Stakeholders returned.';
    private static final String ASSERT_MESSAGE_INCORRECT_MX_TOUCHPOINT_ID = 'Unexpected result: incorrect Mx Touchpoint Id returned.';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business';
    private static final String DOMINOS_MX_TOUCHPOINT_NAME = 'Dominos Touchpoint';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in fields list.';
    private static final String KFC_MX_TOUCHPOINT_NAME = 'KFC Touchpoint';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Stakeholder.';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String TOUCHPOINT_TYPE_BUSINESS_REVIEW = 'Business Review';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        StakeholdersSelector stakeholdersSelectorInstance = (StakeholdersSelector) StakeholdersSelector.newInstance();
        Schema.SObjectType typeOfObject = stakeholdersSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = stakeholdersSelectorInstance.getSObjectFieldList();
        WorkStepsSelector.newInstance();
        System.assertEquals(
            Schema.Stakeholder__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Stakeholder__c.Id,
                Stakeholder__c.Initiative__c,
                Stakeholder__c.Contact__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It verifies whether count of Stakeholders fetched correctly
     * when Mx Touchpoint Ids are passed.
     */
    @isTest
    private static void testWhenMxTouchpointIdsWithStakeholdersPassedThenCountOfStakeholdersReturned() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            ),
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = DOMINOS_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(5),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        List<Stakeholder__c> stakeholders = new List<Stakeholder__c>{
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id),
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id)
        };
        insert stakeholders;
        Test.startTest();
        Aggregate[] aggregateQueryResult = StakeholdersSelector.newInstance()
            .getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
                new Map<Id, Initiative__c>(mxTouchpoints).keySet()
            );
        Test.stopTest();
        System.assertEquals(
            2,
            (Integer) aggregateQueryResult[0].get(AGGREGATE_STAKEHOLDERS_COUNT_ALIAS),
            ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT
        );
        System.assertEquals(
            mxTouchpoints[0].Id,
            (Id) aggregateQueryResult[0].get(AGGREGATE_MX_TOUCHPOINT_ID_FIELD_ALIAS),
            ASSERT_MESSAGE_INCORRECT_MX_TOUCHPOINT_ID
        );
    }

    /**
     * @description It verifies whether count of Stakeholders returned correctly
     * when Mx Touchpoint Ids are passed without stakeholders.
     */
    @isTest
    private static void testWhenMxTouchpointIdsWithoutStakeholdersPassedThenAggregateNotNotReturned() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            ),
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = DOMINOS_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(5),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        Test.startTest();
        Aggregate[] aggregateQueryResult = StakeholdersSelector.newInstance()
            .getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(
                new Map<Id, Initiative__c>(mxTouchpoints).keySet()
            );
        Test.stopTest();
        System.assertEquals(
            true,
            aggregateQueryResult.isEmpty(),
            ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT
        );
    }

    /**
     * @description It verifies whether count of Stakeholders returned correctly
     * when Mx Touchpoint Ids are passed without stakeholders.
     */
    @isTest
    private static void testWhenMxTouchpointIdsWithoutStakeholdersPassedThenReturnStakeholders() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        Contact contact = new Contact(
            AccountId = businessAccount.Id,
            FirstName = 'First Name',
            LastName = 'Last Name',
            Email = 'abc@gmail.com'
        );
        insert contact;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        List<Stakeholder__c> stakeholders = new List<Stakeholder__c>{
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, Contact__c = contact.Id),
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, Contact__c = contact.Id)
        };
        insert stakeholders;
        Test.startTest();
        List<Stakeholder__c> queryResult = StakeholdersSelector.newInstance()
            .getStakeholderContactsByMxTouchPointIds(
                new Map<Id, Initiative__c>(mxTouchpoints).keySet()
            );
        Test.stopTest();
        System.assertEquals(2, queryResult.size(), ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT);
    }

    /**
     * @description It verifies whether count of Stakeholders returned correctly
     * when Mx Touchpoint Ids are passed without stakeholders.
     */
    @isTest
    private static void testWhenMxTouchpointIdsWithoutStakeholdersPassedThenDoNotReturnStakeholders() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        Contact contact = new Contact(
            AccountId = businessAccount.Id,
            FirstName = 'First Name',
            LastName = 'Last Name',
            Email = 'abc@gmail.com'
        );
        insert contact;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            ),
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        List<Stakeholder__c> stakeholders = new List<Stakeholder__c>{
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, Contact__c = contact.Id),
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, Contact__c = contact.Id)
        };
        insert stakeholders;
        Test.startTest();
        List<Stakeholder__c> queryResult = StakeholdersSelector.newInstance()
            .getStakeholderContactsByMxTouchPointIds(new Set<Id>{ mxTouchpoints[1].Id });
        Test.stopTest();
        System.assertEquals(0, queryResult.size(), ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT);
    }

    /**
     * @description It verifies whether count of Stakeholders returned correctly
     * when Mx Touchpoint Ids are passed with stakeholders and User populated
     */
    @isTest
    private static void testWhenMxTouchpointIdsWithStakeholdersPassedThenReturnStakeholders() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        User userRecord = new User(
            Alias = 'test2',
            Email = 'testUser1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'userEmail43063@test.com'
        );
        insert userRecord;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        List<Stakeholder__c> stakeholders = new List<Stakeholder__c>{
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, User__c = userRecord.Id),
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id, User__c = userRecord.Id)
        };
        insert stakeholders;
        Test.startTest();
        List<Stakeholder__c> queryResult = StakeholdersSelector.newInstance()
            .getStakeholderUsersByMxTouchPointIds(
                new Map<Id, Initiative__c>(mxTouchpoints).keySet()
            );
        Test.stopTest();
        System.assertEquals(2, queryResult.size(), ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT);
    }

    /**
     * @description It verifies whether count of Stakeholders returned correctly
     * when Mx Touchpoint Ids are passed with stakeholders and User not populated.
     */
    @isTest
    private static void testWhenMxTouchpointIdsHasStekholdersWithoutUsersThenDoNotReturnStakeholders() {
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        List<Initiative__c> mxTouchpoints = new List<Initiative__c>{
            new Initiative__c(
                Type__c = TOUCHPOINT_TYPE_BUSINESS_REVIEW,
                Name = KFC_MX_TOUCHPOINT_NAME,
                Start_Date__c = System.today().addDays(3),
                Account__c = businessAccount.Id,
                Status__c = STATUS_NOT_STARTED
            )
        };
        insert mxTouchpoints;
        List<Stakeholder__c> stakeholders = new List<Stakeholder__c>{
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id),
            new Stakeholder__c(Initiative__c = mxTouchpoints[0].Id)
        };
        insert stakeholders;
        Test.startTest();
        List<Stakeholder__c> queryResult = StakeholdersSelector.newInstance()
            .getStakeholderUsersByMxTouchPointIds(
                new Map<Id, Initiative__c>(mxTouchpoints).keySet()
            );
        Test.stopTest();
        System.assertEquals(0, queryResult.size(), ASSERT_MESSAGE_INCORRECT_STAKEHOLDERS_COUNT);
    }
}