/**
 * @author Deloitte
 * @date 11/29/2022
 * @description Integration test class for NintexWorkOrdersProcessorBatch class.
 */
@isTest(SeeAllData=false)
private class NintexWorkOrdersProcessorIntegrationTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_ID_BUSINESS = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String CHILD_WORK_ORDERS_SIZE_NOT_MATCHED_ASSERT_MESSAGE = 'Unexpected result: Child Work Orders size is not matching on parent Work Order';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final Integer STORE_ACCOUNTS_COUNT = 150;
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To setup relevant test data.
     */
    @testSetup
    private static void setupData() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert businessAccount;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            CloseDate = System.today().addMonths(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            StageName = OPPORTUNITY_STAGE
        );
        insert parentOpportunity;
        List<Account> storeAccounts = new List<Account>();
        for (Integer iterator = 0; iterator < STORE_ACCOUNTS_COUNT; ++iterator) {
            Account storeAccount = ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            storeAccount.Franchise_Parent__c = businessAccount.Id;
            storeAccounts.add(storeAccount);
        }
        insert storeAccounts;
        WorkOrder parentWorkOrder = ServiceIntegrationDataBuilder.createWorkOrderInstance(
            businessAccount.Id,
            WORK_ORDER_TYPE_MARKETPLACE
        );
        parentWorkOrder.Bundled_with_Marketplace__c = BUNDLED_WITH_MARKETPLACE_NO;
        parentWorkOrder.IsStoresAssociationInProgress__c = false;
        parentWorkOrder.Opportunity__c = parentOpportunity.Id;
        insert parentWorkOrder;
    }

    /**
     * @description To test creation of child Work Orders on parent Work Orders related to
     * franchise Accounts of the passed store Accounts through batch execution.
     */
    @isTest
    private static void testWhenStoreAccountsAssociatedWithFranchiseAccountsExecutedInBatchThenCorrespondingChildWorkOrdersCreated() {
        Account businessAccount = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :ACCOUNT_RECORD_TYPE_ID_BUSINESS
        ];
        Opportunity parentOpportunity = [
            SELECT Id
            FROM Opportunity
            WHERE AccountId = :businessAccount.Id
        ];
        WorkOrder parentWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE AccountId = :businessAccount.Id
        ];
        NintexWorkOrdersProcessorBatch batchInstance = new NintexWorkOrdersProcessorBatch(
            new Map<Id, Id>{ businessAccount.Id => parentOpportunity.Id }
        );
        Test.startTest();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        List<WorkOrder> childWorkOrdersResult = [
            SELECT Id
            FROM WorkOrder
            WHERE ParentWorkOrderId = :parentWorkOrder.Id
        ];
        System.assertEquals(
            STORE_ACCOUNTS_COUNT,
            childWorkOrdersResult.size(),
            CHILD_WORK_ORDERS_SIZE_NOT_MATCHED_ASSERT_MESSAGE
        );
    }
}