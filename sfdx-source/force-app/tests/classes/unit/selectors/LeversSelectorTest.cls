/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Test class for LeversSelector.
 */
@isTest(SeeAllData=false)
private class LeversSelectorTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan';
    private static final String ACTIVE = 'Active';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELD_LIST = 'Unexpected Result: Mismatch in field list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected Result: The object type must be Lever.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST = 'Unexpected Result: The Levers were not appropriately fetched.';
    private static final String BUSINESS_ACCOUNT_NAME = 'Business Account';
    private static final String BUSINESS = 'Business';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String SEGMENT_SMB = 'SMB';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        LeversSelector selector = new LeversSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Lever__c.Id,
                Lever__c.Name,
                Lever__c.Category__c,
                Lever__c.Predicted_Incremental_Sales__c,
                Lever__c.Solution_Name__c,
                Lever__c.Lever_Points__c,
                Lever__c.Account__c
            },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELD_LIST
        );
        System.assertEquals(
            Schema.Lever__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }

    /**
     * @description To test if the Lever records are fetched when set of Ids are passed.
     */
    @isTest
    private static void testWhenLeverIdsArePassedThenLeversAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccount.Id,
                Status__c = ACTIVE
            )
        };
        insert accountPlans;
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(Account__c = businessAccount.Id, Account_Plan__c = accountPlans[0].Id)
        };
        insert levers;
        Test.startTest();
        List<Lever__c> queryResult = LeversSelector.newInstance()
            .selectById(new Set<Id>{ levers[0].Id });
        Test.stopTest();
        System.assertEquals(1, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
    }

    /**
     * @description To test if the Lever records are fetched when set of Ids are passed.
     */
    @isTest
    private static void testWhenLeverIdsAreNotPassedThenLeversAreNotFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = SEGMENT_SMB
        );
        insert businessAccount;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccount.Id,
                Status__c = ACTIVE
            )
        };
        insert accountPlans;
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(Account__c = businessAccount.Id, Account_Plan__c = accountPlans[0].Id)
        };
        insert levers;
        Test.startTest();
        List<Lever__c> queryResult = LeversSelector.newInstance().selectById(new Set<Id>{});
        Test.stopTest();
        System.assertEquals(0, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
    }

    /**
     * @description To test if the Levers are fetched when Account Plan Ids are passed
     */
    @isTest
    private static void testWhenAccountPlanIdsArePassedThenLeversAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = SEGMENT_SMB
            )
        };
        insert businessAccounts;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccounts[0].Id,
                Status__c = ACTIVE
            )
        };
        insert accountPlans;
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS
            ),
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS
            )
        };
        insert levers;

        List<Lever__c> queryResult = LeversSelector.newInstance()
            .selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlans[0].Id });
        System.assertEquals(2, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
    }

    /**
     * @description To test if the Levers are fetched when Account Plan Ids are passed
     */
    @isTest
    private static void testWhenAccountPlanIdsArePassedThenLeversAreNotFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = SEGMENT_SMB
            )
        };
        insert businessAccounts;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccounts[0].Id,
                Status__c = ACTIVE
            ),
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccounts[0].Id,
                Status__c = ACTIVE
            )
        };
        insert accountPlans;
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS
            ),
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS
            )
        };
        insert levers;

        List<Lever__c> queryResult = LeversSelector.newInstance()
            .selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlans[1].Id });
        System.assertEquals(0, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
    }

    /**
     * @description To test if the Lever Records are fetched when cloned Lever Ids are passed.
     */
    @isTest
    private static void testWhenClonedByLeverIdsArePassedThenLeversAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS)
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = 'SMB'
            )
        };
        insert businessAccounts;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = ACCOUNT_PLAN_NAME,
                Account__c = businessAccounts[0].Id,
                Status__c = ACTIVE
            )
        };
        insert accountPlans;
        Lever__c[] oldLevers = new List<Lever__c>{
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS
            )
        };
        insert oldLevers;
        Lever__c[] newLevers = new List<Lever__c>{
            new Lever__c(
                Account__c = businessAccounts[0].Id,
                Account_Plan__c = accountPlans[0].Id,
                Status__c = IN_PROGRESS,
                Cloned_From_Lever_Id__c = oldLevers[0].Id
            )
        };
        insert newLevers;

        List<Lever__c> queryResult = LeversSelector.newInstance()
            .selectByClonedLeverId(new Set<Id>{ oldLevers[0].Id });

        System.assertEquals(1, queryResult.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
    }
}