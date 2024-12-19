/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Test class for ParentWorkOrderMatcherServiceImpl class.
 */
@isTest(SeeAllData=false)
private class ParentWorkOrderMatcherServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String NO_PARENT_WORK_ORDER_ASSERT_MESSAGE = 'Unexpected result: parent Work Order receieved';
    private static final String OPPORTUNITY_DRIVE_NINTEX_ID = 'ParentWorkOrderMatcherServiceImplTestDriveNintexId';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'ParentWorkOrderMatcherServiceImplTestMarketPlaceNintexId';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_SUB_TYPE_DOWNGRADE = 'Downgrade';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String PARENT_WORK_ORDER_ASSERT_MESSAGE = 'Unexpected result: failed to receieve matching parent Work Order';
    private static final String PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE = 'Unexpected result: failed to receieve correct matched type';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_CONTRACT = 'Contract';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID = 'Nintex Id';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_PDOA = 'PDOA';
    private static final String PARENT_WORK_ORDER_MATCHED_BY_TYPE = 'Type';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SUB_TYPE_ADS_AND_PROMOS = 'Ads and Promo - Activate';
    private static final String SUB_TYPE_RATE_CHANGE = 'Rate Change';
    private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String MANAGE_PRICING_CREATION_SOURCE = 'Manage Pricing';
    private static final String UNIQUE_INDENTIFIER = '123';

    /**
     * @description To test matching parent Work Order returned when Opportunity is
     * associated and Type is 'Post-Sales' and sub type is 'Rate Change'
     */
    @isTest
    private static void testWhenPostSalesRateChangeWorkOrderMatchedByContractThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_DOWNGRADE)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_POST_SALES
            )
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Nintex_Use_Case__c, System.Label.NintexUseCaseNone)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_COO)
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake primaryOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderItemFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByContractOnRateChange(
            orderItem,
            new Map<Id, List<WorkOrder>>{ contractId => new List<WorkOrder>{ parentWorkOrder } }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_CONTRACT,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when Opportunity is
     * associated and Type is 'Post-Sales' and sub type is 'Rate Change' and Contract is populated
     * on Primary Order Product.
     */
    @isTest
    private static void testWhenPostSalesRateChangeWorkOrderMatchedByPrimaryOrderProductContractThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_UPGRADE)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_POST_SALES
            )
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Nintex_Use_Case__c, System.Label.NintexUseCaseNone)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_COO)
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem primaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            primaryOrderItemFakeInstance
        );
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake activationOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderItem.Id)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderItemFakeInstance);
        OrderItem activationOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            activationOrderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByContractOnRateChange(
            activationOrderItem,
            new Map<Id, List<WorkOrder>>{ contractId => new List<WorkOrder>{ parentWorkOrder } }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_CONTRACT,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when
     * Marketplace Nintex Id of store Account on Order Product matches with
     * Marketplace Nintex Id of Opportunity on parent Work Order.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByMarketplaceNintexIdThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, parentOpportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() - 40)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByNintexId(
            orderItem,
            new Map<String, List<WorkOrder>>{
                OPPORTUNITY_MARKETPLACE_NINTEX_ID => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when
     * Order Product and businessAccountIdToParentWorkOrders map is passed.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByPDOAThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 45);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByPDOA(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_PDOA,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when Opportunity is
     * associated and Type is 'Post-Sales' and sub type is 'Rate Change'
     * @JIRA# LEM-12932
     */
    @isTest
    private static void testWhenPostSalesRateChangeWorkOrderMatchedByRateChangeRequestThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 45);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_POST_SALES
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Nintex_Use_Case__c, System.Label.NintexUseCaseNone)
            .setField(WorkOrder.Sub_Type__c, SUB_TYPE_RATE_CHANGE)
            .setField(WorkOrder.Creation_Source__c, MANAGE_PRICING_CREATION_SOURCE)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_POST_SALES
            )
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES);
        //.setField(Product2.Sub_Type__c, SUB_TYPE_RATE_CHANGE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );

        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByRateChangeTypeFromRateChangeRequest(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test parent Work Order when parent Work Order with null PDOA not returned when
     * Order Product and businessAccountIdToParentWorkOrders map is passed.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByPDOAThenParentWorkOrderWithNullPDOANotReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, null)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByPDOA(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            true,
            matchedParentWorkOrder == null,
            NO_PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when
     * Order Product and parent Work Orders are passed.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByTypeThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByType(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_TYPE,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when Marketplace type
     * Order Product and parent Work Orders are passed.
     */
    @isTest
    private static void testWhenMarketplaceTypeStoreAccountWorkOrderMatchedByTypeThenParentWorkOrderNotReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByType(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            true,
            matchedParentWorkOrder == null,
            NO_PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned when
     * Drive Nintex Id of store Account on Order Product matches with
     * Drive Nintex Id of Opportunity on parent Work Order.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByDriveNintexIdThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, parentOpportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() - 40)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Marketplace_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByNintexId(
            orderItem,
            new Map<String, List<WorkOrder>>{
                OPPORTUNITY_DRIVE_NINTEX_ID => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned by PDOA when Marketplace type
     * Order Product and businessAccountIdToParentWorkOrders map is passed.
     */
    @isTest
    private static void testWhenMarketplaceTypeWorkOrderMatchedByPDOAThenParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 45);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 60)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByPDOA(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(
            true,
            matchedParentWorkOrder == parentWorkOrder,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_PDOA,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test matching parent Work Order returned as null when Drive type
     * Order Product and parent Work Orders are passed.
     */
    @isTest
    private static void testWhenDriveTypeWorkOrderMatchedByTypeThenParentWorkOrderNotReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_DRIVE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_DRIVE
            )
            .setField(Product2.Work_Order_Type__c, TYPE_DRIVE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByType(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                parentBusinessAccount.Id => new List<WorkOrder>{ parentWorkOrder }
            }
        );
        System.assertEquals(null, matchedParentWorkOrder, NO_PARENT_WORK_ORDER_ASSERT_MESSAGE);
    }

    /**
     * @description To test matching parent Work Order returned as null when business Account
     * associated to Contract of primary Order Product not present in the passed
     * business Account Id to parent Work Orders mapping.
     */
    @isTest
    private static void testWhenBusinessAccountIdNotPresentInPassedMappingThenParentWorkOrderNotReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByType(
            orderItem,
            new Map<Id, List<WorkOrder>>{
                fflib_IDGenerator.generate(Account.SObjectType) => new List<WorkOrder>{
                    parentWorkOrder
                }
            }
        );
        System.assertEquals(null, matchedParentWorkOrder, NO_PARENT_WORK_ORDER_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Storefront OrderItem and parent Work Orders passed are matched by Onboarding Link unique
     * identifier then return matching parent Work Order.
     */
    @isTest
    private static void testWhenStorefrontWorkOrderMatchedByOnboardingLinkIdThenReturnMatchingParentWorkOrder() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_INDENTIFIER)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders = new Map<String, List<WorkOrder>>{
            UNIQUE_INDENTIFIER => new List<WorkOrder>{ parentWorkOrder }
        };
        Test.startTest();
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByMxOnboardingLink(
            orderItem,
            uniqueIdentifierToParentWorkOrders
        );
        Test.stopTest();
        System.assertEquals(
            true,
            matchedParentWorkOrder == parentWorkOrder,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Storefront OrderItem and parent Work Orders passed are not matched by Onboarding Link unique
     * identifier then return Null.
     */
    @isTest
    private static void testWhenStorefrontWorkOrderNotMatchedByOnboardingLinkIdThenReturnNull() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_INDENTIFIER)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders = new Map<String, List<WorkOrder>>{
            UNIQUE_INDENTIFIER => new List<WorkOrder>{ parentWorkOrder }
        };
        Test.startTest();
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByMxOnboardingLink(
            orderItem,
            uniqueIdentifierToParentWorkOrders
        );
        Test.stopTest();
        System.assertEquals(matchedParentWorkOrder, null, PARENT_WORK_ORDER_ASSERT_MESSAGE);
    }

    /**
     * @description To test matching parent Work Order returned when Opportunity is
     * associated and Type is 'Ads & Promos' and Contract is populated
     * on Primary Order Product.
     */
    @isTest
    private static void testWhenAdsPromosWorkOrderMatchedByPrimaryOrderProductContractThenMatchingParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Opportunity_Sub_Type__c, OPPORTUNITY_SUB_TYPE_ADS_AND_PROMOS)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Type, OPPORTUNITY_TYPE_EXISTING);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_ADS_AND_PROMOS
            )
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Nintex_Use_Case__c, System.Label.NintexUseCaseNone)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_COO)
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Product2.Work_Order_Sub_Type__c, SUB_TYPE_ADS_AND_PROMOS);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderItemFakeInstance = ServiceMockDataBuilder.createPrimaryOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', primaryOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        OrderItem primaryOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            primaryOrderItemFakeInstance
        );
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake activationOrderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderItem.Id)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderItemFakeInstance);
        OrderItem activationOrderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            activationOrderItemFakeInstance
        );
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByContractOnRateChange(
            activationOrderItem,
            new Map<Id, List<WorkOrder>>{ contractId => new List<WorkOrder>{ parentWorkOrder } }
        );
        System.assertEquals(
            parentWorkOrder.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_CONTRACT,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Ads & Promos OrderItem and parent Work Orders passed are matched by Onboarding Link unique
     * identifier then return matching parent Work Order.
     */
    @isTest
    private static void testWhenAdsAndPromosWorkOrderMatchedByOnboardingLinkIdThenReturnMatchingParentWorkOrder() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_ADS_AND_PROMOS
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_INDENTIFIER)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_COO)
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Product2.Work_Order_Sub_Type__c, SUB_TYPE_ADS_AND_PROMOS);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders = new Map<String, List<WorkOrder>>{
            UNIQUE_INDENTIFIER => new List<WorkOrder>{ parentWorkOrder }
        };
        Test.startTest();
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByMxOnboardingLink(
            orderItem,
            uniqueIdentifierToParentWorkOrders
        );
        Test.stopTest();
        System.assertEquals(
            true,
            matchedParentWorkOrder == parentWorkOrder,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Ads & Promos OrderItem and parent Work Orders passed are not matched by Onboarding Link unique
     * identifier then return Null.
     */
    private static void testWhenAdsAndPromosWorkOrderNotMatchedByOnboardingLinkIdThenReturnNull() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id primaryOrderProductId = fflib_IDGenerator.generate(OrderItem.SObjectType);
        String uniqueIdentifier = '7123';
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_ADS_AND_PROMOS
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 10)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_INDENTIFIER)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_COO)
            .setField(Product2.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Product2.Work_Order_Sub_Type__c, SUB_TYPE_ADS_AND_PROMOS);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake contractFakeInstance = new Fake(OrderItem.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Fake primaryOrderFakeInstance = ServiceMockDataBuilder.createPrimaryOrderFakeInstance(
                parentBusinessAccount.Id
            )
            .setParent('Account', parentBusinessAccountFakeInstance);
        Order primaryOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            primaryOrderFakeInstance
        );
        Fake primaryOrderProductFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                primaryOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.Id, primaryOrderProductId)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Contract__r', contractFakeInstance);
        Fake activationOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance);
        Order activationOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            activationOrderFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                activationOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setField(OrderItem.Primary_Order_Product__c, primaryOrderProductId)
            .setParent('Order', activationOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance)
            .setParent('Primary_Order_Product__r', primaryOrderProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders = new Map<String, List<WorkOrder>>{
            uniqueIdentifier => new List<WorkOrder>{ parentWorkOrder }
        };
        Test.startTest();
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByMxOnboardingLink(
            orderItem,
            uniqueIdentifierToParentWorkOrders
        );
        Test.startTest();
        System.assertEquals(matchedParentWorkOrder, null, PARENT_WORK_ORDER_ASSERT_MESSAGE);
    }

    /**
     * @description To test matching Storefront parent Work Order returned when
     * Marketplace Nintex Id of store Account on Order Product matches with
     * Marketplace Nintex Id of Opportunity on parent Work Order and Product type is Storefront.
     */
    @isTest
    private static void testWhenStoreAccountWorkOrderMatchedByMarketplaceNintexIdThenMatchingStorefrontParentWorkOrderReturned() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, parentOpportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        Opportunity parentOpportunity = (Opportunity) parentOpportunityFakeInstance.toSObject();
        Fake parentWorkOrderInstance1 = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() - 40)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder1 = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance1
        );
        Fake parentWorkOrderInstance2 = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_STOREFRONT
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() - 40)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', parentOpportunityFakeInstance);
        WorkOrder parentWorkOrder2 = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance2
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        Order parentOrder = (Order) ServiceMockDataBuilder.convertToSObject(
            parentOrderFakeInstance
        );
        Fake activeProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        Product2 activeProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
            activeProductFakeInstance
        );
        Fake pricebookEntryFakeInstance = ServiceMockDataBuilder.createPricebookEntryFakeInstance(
            activeProduct.Id
        );
        PricebookEntry pricebookEntry = (PricebookEntry) ServiceMockDataBuilder.convertToSObject(
            pricebookEntryFakeInstance
        );
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                parentOrder.Id,
                activeProduct.Id
            )
            .setField(OrderItem.PricebookEntryId, pricebookEntry.Id)
            .setField(OrderItem.SBQQ__Contract__c, contractId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', activeProductFakeInstance);
        OrderItem orderItem = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Test.startTest();
        WorkOrder matchedParentWorkOrder = ParentWorkOrderMatcherService.matchByNintexId(
            orderItem,
            new Map<String, List<WorkOrder>>{
                OPPORTUNITY_MARKETPLACE_NINTEX_ID => new List<WorkOrder>{
                    parentWorkOrder1,
                    parentWorkOrder2
                }
            }
        );
        Test.stopTest();
        System.assertEquals(
            parentWorkOrder2.Id,
            matchedParentWorkOrder.Id,
            PARENT_WORK_ORDER_ASSERT_MESSAGE
        );
        System.assertEquals(
            PARENT_WORK_ORDER_MATCHED_BY_NINTEX_ID,
            matchedParentWorkOrder.Matched_By__c,
            PARENT_WORK_ORDER_MATCH_BY_ASSERT_MESSAGE
        );
    }
}