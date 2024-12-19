/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Test class for WorkOrderSettingsServiceImpl class.
 */
@isTest(SeeAllData=false)
private class WorkOrderSettingsServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String ASSERT_MESSAGE_DECISION_MAKER_APPLICABLE_ON_CHILD_WORKORDER = 'Unexpected result: Decision Maker population is applicable on child Work Order';
    private static final String ASSERT_MESSAGE_DECISION_MAKER_NOT_APPLICABLE_ON_CHILD_WORKORDER = 'Unexpected result: Decision Maker population is not applicable on child Work Order';
    private static final String ASSERT_MESSAGE_PDOA_MATCHING_ENABLED = 'Unexpected result: PDOA matching logic is enabled for passed Order Item where product Work Order Type and Sub Type matches';
    private static final String ASSERT_MESSAGE_PDOA_MATCHING_DISABLED = 'Unexpected result: PDOA matching logic is disabled for passed Order Item where product Work Order Type and Sub Type matches';
    private static final String ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_BYPASSED = 'Unexpected result: provisioning status notification is bypassed on parent Work Order where stores are expected';
    private static final String ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED = 'Unexpected result: provisioning status notification is not bypassed on parent Work Order where stores are not expected';
    private static final String ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_BYPASSED_CHILD_WORKORDER = 'Unexpected result: provisioning status notification is bypassed on child Work Order';
    private static final String ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED_CHILD_WORKORDER = 'Unexpected result: provisioning status notification is not bypassed on child Work Order';
    private static final String ASSERT_MESSAGE_READINESS_CHECK_BYPASSED = 'Unexpected result: readiness check bypassed on parent Work Order where stores are not expected ';
    private static final String ASSERT_MESSAGE_TYPE_MATCHING_DISABLED = 'Unexpected result: Type matching logic is disabled for Work Order Types other than Drive';
    private static final String ASSERT_MESSAGE_TYPE_MATCHING_ENABLED = 'Unexpected result: Type matching logic is enabled for Drive Work Order Type';
    private static final String ASSERT_MESSAGE_WORK_PLAN_ELIGIBILITY_BYPASSED = 'Unexpected result: Work Plan creation criteria is bypassed for parent Work Order where stores are not expected';
    private static final String ASSERT_MESSAGE_WORK_PLAN_AUTO_CREATION_ENABLED = 'Unexpected result: Work Plan auto creation is enabled for parent Work Order where stores are not expected';
    private static final String DRIVE_AMENDMENT_USE_CASE = 'Drive - Amendment';
    private static final String DRIVE_FORM_FRANCHISE_USE_CASE = 'Drive Form - Franchise';
    private static final String DRIVE_INTEGRATED_FRANCHISE_USE_CASE = 'Integrated Franchise';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String NONE_USE_CASE = 'None';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_ORDER_SUB_TYPE_COO = 'COO';
    private static final String WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION = 'Partnership creation/update';
    private static final String WORK_ORDER_SUB_TYPE_SAAS_FEE_SETUP = 'SaaS Fee Setup';
    private static final String WORK_ORDER_SUB_TYPE_WITHHOLDING = 'Withholding';

    /**
     * @description To test whether the passed Work Order is eligible for automatic creation
     * of Work Plans when Type is 'Drive' and Sub Type is 'Partnership creation/update'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypePartnershipCreationThenWorkPlanAutoCreationEnabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansAutoCreationEnabled(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_AUTO_CREATION_ENABLED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for automatic creation
     * of Work Plans when Type is 'Drive' and Sub Type is 'COO'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeCOOThenWorkPlanAutoCreationEnabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_COO)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansAutoCreationEnabled(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_AUTO_CREATION_ENABLED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for Work Plan creation
     * when Type is 'Drive' and Sub Type is 'Auto-Activations' Nintex scenario.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeAutoActivationsThenWorkPlanCreationCheckBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_ELIGIBILITY_BYPASSED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for Work Plan creation
     * when Type is 'Drive' and Sub Type is 'Net-new business' corporate scenario.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeNetNewBusinessThenWorkPlanCreationCheckBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, NONE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_ELIGIBILITY_BYPASSED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for readiness check
     * when Type is 'Drive' and Sub Type is 'Partnership creation/update'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypePartnershipCreationThenReadinessCheckBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_AMENDMENT_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_READINESS_CHECK_BYPASSED);
    }

    /**
     * @description To test whether the passed Work Order is not eligible for readiness check
     * when Type is 'Drive' and Sub Type is 'Net-new business'
     * for 'Drive Form - Franchise' use case.
     */
    @isTest
    private static void testWhenTypeDriveAndSubTypeNetNewBusinessWithDriveFormFranchiseUseCaseThenReadinessCheckNotBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_FORM_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(false, isEligible, ASSERT_MESSAGE_READINESS_CHECK_BYPASSED);
    }

    /**
     * @description To test whether the passed Work Order is not eligible for readiness check
     * when Type is 'Drive' and Sub Type is 'Auto-Activations' for corporate scenario.
     */
    @isTest
    private static void testWhenTypeDriveAndSubTypeAutoActivationsThenReadinessCheckNotBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, NONE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_READINESS_CHECK_BYPASSED);
    }

    /**
     * @description To test whether provisioning status notification is enabled for
     * parent work order when Type is 'Drive' and Sub Type is 'Net-new business'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeNetNewBusinessThenProvisioningStatusNotificationEnabledOnParentWorkOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            true,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED
        );
    }

    /**
     * @description To test whether provisioning status notification is enabled for parent work
     * order when Type is 'Drive' and Sub Type is 'Auto-activations' for corporate scenario.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeAutoActivationsThenProvisioningStatusNotificationEnabledOnParentWorkOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            true,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED
        );
    }

    /**
     * @description To test whether provisioning status notification is disabled for
     * parent work order when Type is 'Marketplace'.
     */
    @isTest
    private static void testWhenParentWorkOrderTypeMarketplacePassedThenProvisioningStatusNotificationDisabledOnParentWorkOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            false,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_BYPASSED
        );
    }

    /**
     * @description To test whether PDOA matching logic considered for passed Type Sub Type
     * key value when Type is 'Marketplace'.
     */
    @isTest
    private static void testWhenWorkOrderTypeMarketplaceThenPDOAMatchingEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id marketplaceProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Id priceBookEntryId = fflib_IDGenerator.generate(PricebookEntry.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        // store Account fake instance
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setParent('Parent', businessAccountFakeInstance);
        // Opportunity fake instance
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        // Order fake instance
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccountId
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        // marketplace Product fake instance
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_MARKETPLACE
            )
            .setField(Product2.Id, marketplaceProductId)
            .setField(Product2.Work_Order_Type__c, TYPE_MARKETPLACE);
        // OrderItem fake instance
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                marketplaceProductId
            )
            .setField(OrderItem.PricebookEntryId, priceBookEntryId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        // mocked OrderItem instance
        OrderItem orderItemSObjectInstance = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isPDOAMatchingEnabled(
            orderItemSObjectInstance.Product2.Work_Order_Type__c +
                SEPARATOR +
                orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
        );
        System.assertEquals(true, isEnabled, ASSERT_MESSAGE_PDOA_MATCHING_ENABLED);
    }

    /**
     * @description To test whether PDOA matching logic is considered for passed Type Sub Type
     * key value when Type is 'Storefront'.
     */
    @isTest
    private static void testWhenWorkOrderTypeStorefrontThenPDOAMatchingDisabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storefrontProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Id priceBookEntryId = fflib_IDGenerator.generate(PricebookEntry.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        // store Account fake instance
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setParent('Parent', businessAccountFakeInstance);
        // Opportunity fake instance
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        // Order fake instance
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccountId
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        // storefront Product fake instance
        Fake storefrontProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Id, storefrontProductId)
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        // OrderItem fake instance
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                storefrontProductId
            )
            .setField(OrderItem.PricebookEntryId, priceBookEntryId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', storefrontProductFakeInstance);
        // mocked OrderItem instance
        OrderItem orderItemSObjectInstance = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isPDOAMatchingEnabled(
            orderItemSObjectInstance.Product2.Work_Order_Type__c +
                SEPARATOR +
                orderItemSObjectInstance.Product2.Work_Order_Sub_Type__c
        );
        System.assertEquals(false, isEnabled, ASSERT_MESSAGE_PDOA_MATCHING_DISABLED);
    }

    /**
     * @description To test Provisioning Status notification is disabled
     * for child Work Order of COO type.
     */
    @isTest
    private static void testWhenChildWorkOrderTypeCOOThenProvisioningStatusNotificationDisabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_SUB_TYPE_COO
            )
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            false,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED_CHILD_WORKORDER
        );
    }

    /**
     * @description To test Provisioning Status notification is enabled
     * for child Work Order of Marketplace type.
     */
    @isTest
    private static void testWhenChildWorkOrderTypeMarketplaceThenProvisioningStatusNotificationEnabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            true,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_BYPASSED_CHILD_WORKORDER
        );
    }

    /**
     * @description To test Decision Maker population is applicable
     * for child Work Order of COO type.
     */
    @isTest
    private static void testWhenChildWorkOrderTypeCOOThenDecisionMakerApplicable() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccountId,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
            storeAccount.Id,
            WORK_ORDER_SUB_TYPE_COO,
            parentWorkOrderId
        );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Boolean isApplicable = WorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(
            childWorkOrder
        );
        System.assertEquals(
            true,
            isApplicable,
            ASSERT_MESSAGE_DECISION_MAKER_NOT_APPLICABLE_ON_CHILD_WORKORDER
        );
    }

    /**
     * @description To test Decision Maker population is not applicable
     * for child Work Order of Drive type.
     */
    @isTest
    private static void testWhenChildWorkOrderTypeDriveThenDecisionMakerNotApplicable() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
            businessAccountId,
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
            storeAccount.Id,
            WORK_ORDER_TYPE_DRIVE,
            parentWorkOrderId
        );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Boolean isApplicable = WorkOrderSettingsService.isDecisionMakerApplicableOnWorkOrder(
            childWorkOrder
        );
        System.assertEquals(
            false,
            isApplicable,
            ASSERT_MESSAGE_DECISION_MAKER_APPLICABLE_ON_CHILD_WORKORDER
        );
    }

    /**
     * @description To test Provisioning Status notification is disabled
     * for child Work Order of Drive type and SaaS Fee Setup Sub-Type.
     */
    @isTest
    private static void testWhenChildWorkOrderTypeDriveAndSubTypeSaaSFeeSetupThenProvisioningStatusNotificationDisabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_SAAS_FEE_SETUP)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            false,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED_CHILD_WORKORDER
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for automatic creation
     * of Work Plans when Type is 'Drive' and Sub Type is 'SaaS Fee Setup'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeSaaSFeeSetupThenWorkPlanAutoCreationEnabled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_SAAS_FEE_SETUP)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansAutoCreationEnabled(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_AUTO_CREATION_ENABLED);
    }

    /**
     * @description To test whether matching by Type logic considered for passed Work Order Type
     * value when Type is 'Storefront'.
     */
    @isTest
    private static void testWhenWorkOrderTypeStorefrontThenTypeMatchingEnabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storefrontProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Id priceBookEntryId = fflib_IDGenerator.generate(PricebookEntry.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        // store Account fake instance
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setParent('Parent', businessAccountFakeInstance);
        // Opportunity fake instance
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        // Order fake instance
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccountId
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        // marketplace Product fake instance
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                TYPE_STOREFRONT
            )
            .setField(Product2.Id, storefrontProductId)
            .setField(Product2.Work_Order_Type__c, TYPE_STOREFRONT);
        // OrderItem fake instance
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                storefrontProductId
            )
            .setField(OrderItem.PricebookEntryId, priceBookEntryId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        // mocked OrderItem instance
        OrderItem orderItemSObjectInstance = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Boolean isDisabled = WorkOrderSettingsService.isMatchByTypeDisabled(
            orderItemSObjectInstance.Product2.Work_Order_Type__c
        );
        System.assertEquals(false, isDisabled, ASSERT_MESSAGE_TYPE_MATCHING_DISABLED);
    }

    /**
     * @description To test whether matching by Type logic considered for passed Work Order Type
     * value when Type is 'Drive'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveThenTypeMatchingDisabled() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id marketplaceProductId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Id priceBookEntryId = fflib_IDGenerator.generate(PricebookEntry.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        // store Account fake instance
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccountId,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setParent('Parent', businessAccountFakeInstance);
        // Opportunity fake instance
        Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        // Order fake instance
        Fake parentOrderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccountId
            )
            .setParent('Account', storeAccountFakeInstance)
            .setParent('Opportunity', parentOpportunityFakeInstance);
        // marketplace Product fake instance
        Fake marketplaceProductFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(Product2.Id, marketplaceProductId)
            .setField(Product2.Work_Order_Type__c, WORK_ORDER_TYPE_DRIVE);
        // OrderItem fake instance
        Fake orderItemFakeInstance = ServiceMockDataBuilder.createActivationOrderItemFakeInstance(
                orderId,
                marketplaceProductId
            )
            .setField(OrderItem.PricebookEntryId, priceBookEntryId)
            .setParent('Order', parentOrderFakeInstance)
            .setParent('Product2', marketplaceProductFakeInstance);
        // mocked OrderItem instance
        OrderItem orderItemSObjectInstance = (OrderItem) ServiceMockDataBuilder.convertToSObject(
            orderItemFakeInstance
        );
        Boolean isDisabled = WorkOrderSettingsService.isMatchByTypeDisabled(
            orderItemSObjectInstance.Product2.Work_Order_Type__c
        );
        System.assertEquals(true, isDisabled, ASSERT_MESSAGE_TYPE_MATCHING_ENABLED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for readiness check
     * by skipping store accounts when Type is 'Drive' and Sub Type is 'Withholding'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeWithholdingThenReadinessCheckBypassedByStoreAccounts() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_WITHHOLDING)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isReadinessCheckEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_READINESS_CHECK_BYPASSED);
    }

    /**
     * @description To test whether the passed Work Order is eligible for Work Plan creation
     * by skipping store accounts when Type is 'Drive' and Sub Type is 'Withholding' Nintex scenario.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeAutoActivationsThenWorkPlanCreationCheckBypassedByStoreAccounts() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_WITHHOLDING)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEligible = WorkOrderSettingsService.isWorkPlansEligibilityByStoreBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isEligible, ASSERT_MESSAGE_WORK_PLAN_ELIGIBILITY_BYPASSED);
    }

    /**
     * @description To test whether provisioning status notification is enabled for parent work
     * order when Type is 'Drive' and Sub Type is 'Withholding'.
     */
    @isTest
    private static void testWhenWorkOrderTypeDriveAndSubTypeWithholdingThenProvisioningStatusNotificationEnabledOnParentWorkOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Segment__c, SEGMENT_ENTERPRISE)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_DRIVE)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_WITHHOLDING)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Nintex_Use_Case__c, DRIVE_INTEGRATED_FRANCHISE_USE_CASE)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isEnabled = WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
            parentWorkOrder
        );
        System.assertEquals(
            true,
            isEnabled,
            ASSERT_MESSAGE_PROVISIONING_STATUS_NOTIFICATION_NOT_BYPASSED
        );
    }

    /**
     * @description To test whether the passed Work Order is eligible for readiness check
     * when Type is 'Photoshoot'.
     */
    @isTest
    private static void testWhenWorkOrderTypePhotoshootThenReadinessCheckBypassed() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORK_ORDER_TYPE_PHOTOSHOOT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Segment__c, SEGMENT_SMB)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_PHOTOSHOOT)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Boolean isBypassed = WorkOrderSettingsService.isReadinessCheckEligibilityByParentBypassed(
            parentWorkOrder
        );
        System.assertEquals(true, isBypassed, ASSERT_MESSAGE_READINESS_CHECK_BYPASSED);
    }
}