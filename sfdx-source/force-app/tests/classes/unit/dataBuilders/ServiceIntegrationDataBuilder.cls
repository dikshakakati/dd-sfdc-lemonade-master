/**
 * @author Deloitte
 * @date 20/06/2022
 * @description Test Data Factory class for creating WorkOrder, WorkPlan, WorkStep record(s)
 * for utilizing in the test classes.
 * Suppressed Warnings since data builder does not require system assert statements
 * and Test word suffix.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class ServiceIntegrationDataBuilder {
    private static final String ACCOUNT_ACTIVATION_STATUS = 'Active';
    private static final String ACCOUNT_BILLING_CITY = 'Port Byron';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_COUNTRY_CODE = 'US';
    private static final String ACCOUNT_BILLING_POSTALCODE = '13140';
    private static final String ACCOUNT_BILLING_STATE = 'New York';
    private static final String ACCOUNT_BILLING_STREET = 'South Street Road';
    private static final String ACCOUNT_HOURS_OF_OPERATION = '12';
    private static final String ACCOUNT_LIFECYCLE_STATUS = 'Unvetted';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ACCOUNT_TYPE = 'Franchisee';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String ORDER_RECORD_TYPE_ACTIVATION = 'Activation Order';
    private static final String ORDER_RECORD_TYPE_PRIMARY = 'Primary Order';
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByName()
        .get(ORDER_RECORD_TYPE_ACTIVATION)
        .getRecordTypeId();
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByName()
        .get(ORDER_RECORD_TYPE_PRIMARY)
        .getRecordTypeId();
    private static final String BUSINESS_ACCOUNT_NAME = 'Subway';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String MENU_TO_BE_COMPLETED_BY = 'DoorDash Onboarding Team';
    private static final Integer ORDER_ITEM_QUANTITY = 10;
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final Decimal PRICEBOOK_ENTRY_UNIT_PRICE = 12.00;
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STORE_ACCOUNT_NAME = 'Subway - NYC';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORKORDER_ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKPLAN_NAME = 'Onboarding';
    private static final string WORK_STEP_NAME = 'Setup Banking';
    private static final string WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String INTEGRATION_ID = '112223344';
    private static final string INTEGRATION_PROVIDER = 'square';
    private static final string IR_SFDC_STATUS = 'Pending';
    private static final string ONBOARDING_ID = '222-8888-999-4444';
	private static final string ACTION = 'CREATE';
   	private static final String SEGMENT_ACCOUNT = 'Enterprise';


    /**
     * @description To create business Account record with the passed Primary Vertical value.
     * @param primaryVertical
     * @return Account
     */
    public static Account createBusinessAccountInstance(String primaryVertical) {
        return new Account(
            Account_Lifecycle_Status__c = ACCOUNT_LIFECYCLE_STATUS,
            Address_Verification_Status__c = ADDRESS_VERIFICATION_STATUS,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingCountryCode = ACCOUNT_BILLING_COUNTRY_CODE,
            BillingPostalCode = ACCOUNT_BILLING_POSTALCODE,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingStreet = ACCOUNT_BILLING_STREET,
            Coverage__c = IN_COVERAGE,
            Name = BUSINESS_ACCOUNT_NAME,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            Primary_Vertical__c = primaryVertical,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            RecordType = new RecordType(
                Id = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                DeveloperName = ACCOUNT_RECORD_TYPE_NAME_BUSINESS,
                Name = ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            ),
            Type = ACCOUNT_TYPE,
            Segment__c = SEGMENT_ACCOUNT
        );
    }

    /**
     * @description To create store Account record with the passed ParentId
     * and Primary Vertical value.
     * @param parentAccountId
     * @param primaryVertical
     * @return Account
     */
    public static Account createStoreAccountInstance(
        String parentAccountId,
        String primaryVertical
    ) {
        return new Account(
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS,
            Address_Verification_Status__c = ADDRESS_VERIFICATION_STATUS,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingCountryCode = ACCOUNT_BILLING_COUNTRY_CODE,
            BillingPostalCode = ACCOUNT_BILLING_POSTALCODE,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingStreet = ACCOUNT_BILLING_STREET,
            Coverage__c = IN_COVERAGE,
            Hours_of_Operation__c = ACCOUNT_HOURS_OF_OPERATION,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccountId,
            Primary_Vertical__c = primaryVertical,
            RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID,
            RecordType = new RecordType(
                Id = ACCOUNT_STORE_RECORD_TYPE_ID,
                Name = ACCOUNT_RECORD_TYPE_NAME_STORE
            ),
            Segment__c = SEGMENT_ACCOUNT
        );
    }

    /**
     * @description To create Product record with the given name.
     * @param productName
     * @return Product2
     */
    public static Product2 createProductInstance(String productName) {
        return new Product2(IsActive = true, Name = productName);
    }

    /**
     * @description To create Pricebook entry record with the given ProductId.
     * @param productId
     * @return PricebookEntry
     */
    public static PricebookEntry createPricebookEntryInstance(String productId) {
        return new PricebookEntry(
            IsActive = true,
            Product2Id = productId,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = PRICEBOOK_ENTRY_UNIT_PRICE
        );
    }

    /**
     * @description To create activation Order record with the passed AccounId.
     * @param accountId
     * @return Order
     */
    public static Order createActivationOrderInstance(String accountId) {
        return new Order(
            AccountId = accountId,
            EffectiveDate = System.today() + 10,
            Pricebook2Id = Test.getStandardPricebookId(),
            RecordTypeId = ACTIVATION_ORDER_RECORD_TYPE_ID,
            Status = ORDER_STATUS_DRAFT,
            RecordType = new RecordType(
                Id = ACTIVATION_ORDER_RECORD_TYPE_ID,
                Name = ORDER_RECORD_TYPE_ACTIVATION
            )
        );
    }

    /**
     * @description To create activation OrderItem record with the passed OrderId and ProductId.
     * @param orderId
     * @param productId
     * @return OrderItem
     */
    public static OrderItem createActivationOrderItemInstance(String orderId, String productId) {
        return new OrderItem(
            OrderId = orderId,
            Product2Id = productId,
            Quantity = ORDER_ITEM_QUANTITY,
            UnitPrice = PRICEBOOK_ENTRY_UNIT_PRICE
        );
    }

    /**
     * @description To create primary Order record with the passed AccounId.
     * @param accountId
     * @return Order
     */
    public static Order createPrimaryOrderInstance(String accountId) {
        return new Order(
            AccountId = accountId,
            EffectiveDate = System.today() + 10,
            Pricebook2Id = Test.getStandardPricebookId(),
            RecordTypeId = PRIMARY_ORDER_RECORD_TYPE_ID,
            Status = ORDER_STATUS_DRAFT
        );
    }

    /**
     * @description To create WorkOrder record with the passed AccountId and Type value.
     * @param accountId
     * @param workOrderType
     * @return WorkOrder
     */
    public static WorkOrder createWorkOrderInstance(String accountId, String workOrderType) {
        return new WorkOrder(
            AccountId = accountId,
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = WORKORDER_ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 30,
            Status = STATUS_PLANNING,
            Type__c = workOrderType
        );
    }

    /**
     * @description To create WorkPlan record with the passed WorkOrderId.
     * @param workOrderId
     * @return WorkPlan
     */
    public static WorkPlan createWorkPlanInstance(String workOrderId) {
        return new WorkPlan(
            Name = WORKPLAN_NAME,
            ParentRecordId = workOrderId,
            Status__c = STATUS_NOT_WORKABLE
        );
    }

    /**
     * @description To create WorkPlan record with the passed WorkOrderId and ParentWorkPlanId.
     * @param workOrderId
     * @param parentWorkPlanId
     * @return WorkPlan
     */
    public static WorkPlan createWorkPlanInstanceWithParentWorkPlanId(
        String workOrderId,
        String parentWorkPlanId
    ) {
        return new WorkPlan(
            Name = WORKPLAN_NAME,
            ParentRecordId = workOrderId,
            Parent_Work_Plan__c = parentWorkPlanId,
            Status__c = STATUS_NOT_WORKABLE
        );
    }

    /**
     * @description To create WorkStep record with the passed WorkPlanId.
     * @param workPlanId
     * @return WorkStep
     */
    public static WorkStep createWorkStepInstance(String workPlanId) {
        return new WorkStep(
            Name = WORK_STEP_NAME,
            Status__c = STATUS_NOT_WORKABLE,
            Type__c = WORK_STEP_TYPE_SETUP_BANKING,
            WorkPlanId = workPlanId
        );
    }

    /**
     * @description To create child WorkStep record with the passed parent WorkStep Id, WorkPlanId and Status value.
     * @param parentWorkStepId
     * @param status
     * @param workPlanId
     * @return WorkStep
     */
    public static WorkStep createChildWorkStepInstance(
        String parentWorkStepId,
        String status,
        String workPlanId
    ) {
        return new WorkStep(
            Name = WORK_STEP_NAME,
            Parent_Work_Step__c = parentWorkStepId,
            Status__c = status,
            Type__c = WORK_STEP_TYPE_SETUP_BANKING,
            WorkPlanId = workPlanId
        );
    }
    /**
     * @description To create Contract with Passed AccountId
     * @param accountId
     * @return Contract
     */
    public static Contract createContractsInstance(String accountId) {
        return new Contract(AccountId = accountId, StartDate = system.today(), ContractTerm = 12);
    }
    /**
     * @description To create Subscription with passed Params
     * @param accountId
     * @param contractId
     * @param productId
     * @return SBQQ__Subscription__c
     */
    public static SBQQ__Subscription__c createSubscriptionInstance(
        String accountId,
        String contractId,
        String productId
    ) {
        return new SBQQ__Subscription__c(
            SBQQ__Product__c = productId,
            SBQQ__Contract__c = contractId,
            SBQQ__Account__c = accountId,
            SBQQ__Quantity__c = 200
        );
    }
    /**
     * @description To create Service Records with passed Params
     * @param accountObj
     * @param subscriptionObj
     * @return Merchant_Service__c
     */
    public static Merchant_Service__c createMerchantServiceInstance(
        Account accountObj,
        SBQQ__Subscription__c subscriptionObj
    ) {
        return new Merchant_Service__c(
            Account__c = accountObj.Id,
            Subscription__c = subscriptionObj.Id
        );
    }
    /**
     * @description To create Service Records with passed Params
     * @param storeId
     * @return Integration_Request__c
     */
    public static Integration_Request__c createIntegrationRequestInstance(
        String storeId
    ) {
        return new Integration_Request__c(
            Action__c = ACTION,
            Store_Id__c = StoreId,
            Onboarding_Id__c = ONBOARDING_ID,
            Sfdc_Status__c = IR_SFDC_STATUS,
            Integration_Id__c = INTEGRATION_ID,
            Integration_Provider__c = INTEGRATION_PROVIDER

        );
    }

    /**
     * @description To insert list of SObjects.
     * @param sObjects
     */
    public static void insertSObjects(List<SObject> sObjects) {
        insert sObjects;
    }
}