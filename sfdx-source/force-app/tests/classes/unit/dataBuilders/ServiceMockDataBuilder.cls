/**
 * @author Deloitte
 * @date 10/06/2022
 * @description Test Data Factory class for creating WorkOrder, WorkPlan, WorkStep record(s)
 * for utilizing in the test classes.
 * Suppressed Warnings since data builder does not require system assert statements
 * and Test word suffix.
 */
@isTest(seeAllData=false)
@SuppressWarnings(
    'PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions, PMD.ExcessivePublicCount'
)
public class ServiceMockDataBuilder {
    private static final Id ACCOUNT_ID = fflib_IDGenerator.generate(Account.SObjectType);
    private static final Id NINTEX_MAPPING_ID = fflib_IDGenerator.generate(
        Nintex_Work_Order_Mapping__mdt.SObjectType
    );
    private static final Id WORK_ORDER_ID = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    private static final Id WORK_PLAN_ID = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    private static final String ACCOUNT_ACTIVATION_STATUS = 'Active';
    private static final String ACCOUNT_BILLING_CITY = 'Port Byron';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_COUNTRY_CODE = 'US';
    private static final String ACCOUNT_BILLING_POSTALCODE = '13140';
    private static final String ACCOUNT_BILLING_STATE = 'New York';
    private static final String ACCOUNT_BILLING_STREET = 'South Street Road';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final Integer ACCOUNT_HOURS_OF_OPERATION = 12;
    private static final String ACCOUNT_LIFECYCLE_STATUS = 'Unvetted';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Premium';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final RecordType ACCOUNT_STORE_RECORD_TYPE = new RecordType(
        Id = ACCOUNT_STORE_RECORD_TYPE_ID,
        Name = ACCOUNT_RECORD_TYPE_NAME_STORE
    );
    private static final String ACCOUNT_TYPE = 'Franchisee';
    private static final String ACTIVATE_CENTRALLY_AC_YES = 'Yes';
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final String ORDER_RECORD_TYPE_ACTIVATION = 'Activation Order';
    private static final String ORDER_RECORD_TYPE_PRIMARY = 'Primary Order';
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByName()
        .get(ORDER_RECORD_TYPE_ACTIVATION)
        .getRecordTypeId();
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByName()
        .get(ORDER_RECORD_TYPE_PRIMARY)
        .getRecordTypeId();
    private static final String BUSINESS_ACCOUNT_NAME = 'Subway';
    private static final String MENU_COMPLETED_BY_NONE = 'None - Menu Setup Complete';
    private static final String MENU_SETUP_METHOD_NONE = 'None - Menu Setup Complete';
    private static final Integer ORDER_ITEM_QUANTITY = 10;
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final Decimal PRICEBOOK_ENTRY_UNIT_PRICE = 12.00;
    private static final String SALES_NOTES_FOR_MENU_TEAM = 'Test Notes';
    private static final String SERVICE_CLASS_NAME = 'IWorkOrdersValidationService';
    private static final String SERVICE_METHOD_VALIDATE_ACTIVATEDCENTRALLY = 'validateActivateCentrally';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_COMPLETE_IMPLEMENTED_ON_CALL = 'Complete - Implemented on the call';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STORE_ACCOUNT_NAME = 'Subway - NYC';
    private static final String WORK_ORDER_ACCOUNT_RECORD_TYPE = 'Store';
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORKORDER_OBJECT_NAME = 'WorkOrder';
    private static final String WORKORDER_ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORKPLAN_NAME = 'Onboarding';
    private static final string WORK_STEP_NAME = 'Setup Banking';
    private static final string WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_LINK_IMPLEMENTATION = 'Link Implementation';
    private static final String WORK_STEP_TYPE_LINK_OPTIMIZATION = 'Link Optimization';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String INTEGRATION_ID = '112223344';
    private static final string INTEGRATION_PROVIDER = 'square';
    private static final string IR_SFDC_STATUS = 'Pending';
    private static final string ONBOARDING_ID = '222-8888-999-4444';
    private static final string ACTION = 'CREATE';
    private static final string WORK_STEP_TYPE_QA_MENU = 'QA Menu';
    private static final string WORK_STEP_TYPE_INGEST_MENU = 'Ingest Menu';
    private static final string WORK_STEP_TYPE_COMPLETE_PRE_WORK = 'Complete pre-work';
    private static final string WORK_STEP_TYPE_CONFIGURE_POS = 'Configure POS';
    private static final string WORK_STEP_TYPE_ENABLE_INTEGRATION = 'Enable Integration';

    private enum AccountRecordTypeName {
        BUSINESS,
        STORE
    }
    private static final Map<String, AccountRecordTypeName> RECORDTYPENAMESTRINGTOENUM = new Map<String, AccountRecordTypeName>{
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS => AccountRecordTypeName.BUSINESS,
        ACCOUNT_RECORD_TYPE_NAME_STORE => AccountRecordTypeName.STORE
    };

    /**
     * @description To create fake Account record with the passed Primary Vertical value
     * and Record Type name.
     * @param primaryVertical
     * @param recordTypeName
     * @return Fake
     */
    public static Fake createAccountFakeInstance(String primaryVertical, String recordTypeName) {
        switch on RECORDTYPENAMESTRINGTOENUM.get(recordTypeName) {
            when BUSINESS {
                return new Fake(Account.class)
                    .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
                    .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
                    .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
                    .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
                    .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
                    .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
                    .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
                    .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                    .setField(Account.Primary_Vertical__c, primaryVertical)
                    .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(Account.Type, ACCOUNT_TYPE)
                    .setFakeId()
                    .setParent(
                        'RecordType',
                        new Fake(RecordType.class)
                            .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                            .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                            .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    );
            }
            when STORE {
                return new Fake(Account.class)
                    .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
                    .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
                    .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
                    .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
                    .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
                    .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
                    .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                    .setField(Account.Hours_of_Operation__c, ACCOUNT_HOURS_OF_OPERATION)
                    .setField(Account.Name, STORE_ACCOUNT_NAME)
                    .setField(Account.Primary_Vertical__c, primaryVertical)
                    .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                    .setFakeId();
            }
            when else {
                return new Fake(Account.class)
                    .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
                    .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
                    .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
                    .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
                    .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
                    .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
                    .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                    .setField(Account.Hours_of_Operation__c, ACCOUNT_HOURS_OF_OPERATION)
                    .setField(Account.Name, STORE_ACCOUNT_NAME)
                    .setField(Account.Primary_Vertical__c, primaryVertical)
                    .setFakeId();
            }
        }
    }

    /**
     * @description To create fake Opportunity_Status_PDOA_Mapping__mdt custom metadata instance.
     * @param fieldToRefer
     * @param objectToRefer
     * @param opportunityStage
     * @param ordernumber
     * @return Fake
     */
    public static Fake createOpportunityStatusPDOAMappingFakeInstance(
        String fieldToRefer,
        String objectToRefer,
        String opportunityStage,
        Integer ordernumber
    ) {
        return new Fake(Opportunity_Status_PDOA_Mapping__mdt.class)
            .setField(Opportunity_Status_PDOA_Mapping__mdt.Field_To_Refer__c, fieldToRefer)
            .setField(Opportunity_Status_PDOA_Mapping__mdt.Object_To_Refer__c, objectToRefer)
            .setField(Opportunity_Status_PDOA_Mapping__mdt.Opportunity_Status__c, opportunityStage)
            .setField(Opportunity_Status_PDOA_Mapping__mdt.Order_Number__c, ordernumber)
            .setFakeId();
    }

    /**
     * @description To create fake store Account record with the passed Primary Vertical value.
     * @param parentAccountId
     * @param primaryVertical
     * @return Fake
     */
    public static Fake createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        String parentAccountId,
        String primaryVertical
    ) {
        return new Fake(Account.class)
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY_AC_YES)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Hours_of_Operation__c, ACCOUNT_HOURS_OF_OPERATION)
            .setField(Account.Menu_Setup_Method__c, MENU_SETUP_METHOD_NONE)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY_NONE)
            .setField(Account.Name, STORE_ACCOUNT_NAME)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Primary_Vertical__c, primaryVertical)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 30)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE.Id)
            .setField(Account.Sales_Notes_for_Menu_Team__c, SALES_NOTES_FOR_MENU_TEAM)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.Id, ACCOUNT_STORE_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_STORE)
            );
    }

    /**
     * @description To create fake WorkOrder record with the passed AccountId and Type value.
     * @param accountId
     * @param workOrderType
     * @return Fake
     */
    public static Fake createWorkOrderFakeInstance(String accountId, String workOrderType) {
        return new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, WORKORDER_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Order_Protocol__c, WORKORDER_ORDER_PROTOCOL_EMAIL)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 30)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, workOrderType)
            .setFakeId();
    }

    /**
     * @description To create fake child WorkOrder record with the passed values.
     * @param accountId
     * @param workOrderType
     * @param parentWorkOrderId
     * @return Fake
     */
    public static Fake createChildWorkOrderFakeInstance(
        String accountId,
        String workOrderType,
        String parentWorkOrderId
    ) {
        return new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, WORKORDER_ACTIVATED_CENTRALLY_YES)
            .setField(WorkOrder.Order_Protocol__c, WORKORDER_ORDER_PROTOCOL_EMAIL)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 30)
            .setField(WorkOrder.Status, STATUS_PLANNING)
            .setField(WorkOrder.Type__c, workOrderType)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setField(WorkOrder.Account_Record_Type_Name__c, WORK_ORDER_ACCOUNT_RECORD_TYPE)
            .setFakeId()
            .setParent(
                'ParentWorkOrder',
                new Fake(WorkOrder.class).setField(WorkOrder.Id, parentWorkOrderId)
            );
    }

    /**
     * @description To create fake WorkPlan record with the passed WorkOrderId.
     * @param workOrderId
     * @return Fake
     */
    public static Fake createWorkPlanFakeInstance(String workOrderId) {
        return new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, WORKPLAN_NAME)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.Status__c, STATUS_NOT_WORKABLE)
            .setFakeId();
    }

    /**
     * @description To create fake WorkPlan record with the passed WorkOrderId, WorkPlanTemplate and ParentWorkPlanId.
     * @param parentWorkPlanId
     * @param workOrderId
     * @param workPlanTemplate
     * @return Fake
     */
    public static Fake createWorkPlanFakeInstanceWithParentWorkPlanId(
        String parentWorkPlanId,
        String workOrderId,
        WorkPlanTemplate workPlanTemplate
    ) {
        return new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, workPlanTemplate.Name)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.Status__c, workPlanTemplate.Work_Plan_Default_Status__c)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplate.Id)
            .setField(WorkPlan.Type__c, workPlanTemplate.Type__c)
            .setField(WorkPlan.ExecutionOrder, workPlanTemplate.RelativeExecutionOrder)
            .setFakeId()
            .setParent(
                'Parent_Work_Plan__r',
                new Fake(WorkPlan.class).setField(WorkPlan.Id, parentWorkPlanId)
            );
    }

    /**
     * @description To create fake WorkPlan record with the passed values.
     * @param workOrderId
     * @param workPlanTemplate
     * @return Fake
     */
    public static Fake createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
        String workOrderId,
        WorkPlanTemplate workPlanTemplate
    ) {
        return new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, workPlanTemplate.Name)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplate.Id)
            .setField(WorkPlan.Status__c, workPlanTemplate.Work_Plan_Default_Status__c)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplate.Id)
            .setField(WorkPlan.Type__c, workPlanTemplate.Type__c)
            .setField(WorkPlan.ExecutionOrder, workPlanTemplate.RelativeExecutionOrder)
            .setFakeId();
    }

    /**
     * @description To create fake WorkPlan record with the passed WorkOrderId, WorkPlanTemplateId
     * and name.
     * @param workOrderId
     * @param workPlanTemplateId
     * @param workPlanName
     * @return Fake
     */
    public static Fake createWorkPlanFakeInstanceWithProvidedWorkPlanTemplateId(
        String workOrderId,
        String workPlanTemplateId,
        String workPlanName
    ) {
        return new Fake(WorkPlan.class)
            .setField(WorkPlan.Name, workPlanName)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.Status__c, STATUS_NOT_WORKABLE)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setFakeId();
    }

    /**
     * @description To create fake WorkStep record with the passed WorkOrderId and WorkPlanId.
     * @param workOrderId
     * @param workPlanId
     * @return Fake
     */
    public static Fake createWorkStepFakeInstance(String workOrderId, String workPlanId) {
        return new Fake(WorkStep.class)
            .setField(WorkStep.Name, WORK_STEP_NAME)
            .setField(WorkStep.Status__c, STATUS_NOT_WORKABLE)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_BANKING)
            .setField(WorkStep.WorkOrderId, workOrderId)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setFakeId();
    }

    /**
     * @description To create fake WorkStep record with the passed WorkPlanTemplate name and execution order.
     * @param workPlanTemplateName
     * @param executionOrder
     * @return Fake
     */
    public static Fake createWorkPlanTemplateFakeInstance(
        String workPlanTemplateName,
        Integer executionOrder
    ) {
        return new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.IsActive, true)
            .setField(WorkPlanTemplate.Name, workPlanTemplateName)
            .setField(WorkPlanTemplate.Type__c, workPlanTemplateName)
            .setField(WorkPlanTemplate.RelativeExecutionOrder, executionOrder)
            .setFakeId();
    }

    /**
     * @description To create fake Product record with the given name.
     * @param productName
     * @return Fake
     */
    public static Fake createProductFakeInstance(String productName) {
        return new Fake(Product2.class)
            .setField(Product2.IsActive, true)
            .setField(Product2.Name, productName)
            .setFakeId();
    }

    /**
     * @description To create fake PricebookEntry record with the given Product.
     * @param productId
     * @return Fake
     */
    public static Fake createPricebookEntryFakeInstance(String productId) {
        return new Fake(PricebookEntry.class)
            .setField(PricebookEntry.IsActive, true)
            .setField(PricebookEntry.Pricebook2Id, Test.getStandardPricebookId())
            .setField(PricebookEntry.Product2Id, productId)
            .setField(PricebookEntry.UnitPrice, PRICEBOOK_ENTRY_UNIT_PRICE)
            .setFakeId();
    }

    /**
     * @description To create fake activation Order record with the passed Account Id.
     * @param accountId
     * @return Fake
     */
    public static Fake createActivationOrderFakeInstance(String accountId) {
        return new Fake(Order.class)
            .setField(Order.AccountId, accountId)
            .setField(Order.EffectiveDate, System.today() + 10)
            .setField(Order.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Order.RecordTypeId, ACTIVATION_ORDER_RECORD_TYPE_ID)
            .setField(Order.Status, ORDER_STATUS_DRAFT)
            .setFakeId()
            .setParent('Account', new Fake(Account.class).setField(Account.Id, accountId));
    }

    /**
     * @description To create fake activation OrderItem record with the passed OrderId
     * and ProductId.
     * @param orderId
     * @param productId
     * @return Fake
     */
    public static Fake createActivationOrderItemFakeInstance(String orderId, String productId) {
        return new Fake(OrderItem.class)
            .setField(OrderItem.OrderId, orderId)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Quantity, ORDER_ITEM_QUANTITY)
            .setField(OrderItem.UnitPrice, PRICEBOOK_ENTRY_UNIT_PRICE)
            .setFakeId()
            .setParent('Order', new Fake(Order.class).setField(Order.Id, orderId));
    }

    /**
     * @description To create fake primary Order record with the passed Account Id.
     * @param accountId
     * @return Fake
     */
    public static Fake createPrimaryOrderFakeInstance(String accountId) {
        return new Fake(Order.class)
            .setField(Order.AccountId, accountId)
            .setField(Order.EffectiveDate, System.today() + 10)
            .setField(Order.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Order.RecordTypeId, PRIMARY_ORDER_RECORD_TYPE_ID)
            .setField(Order.Status, ORDER_STATUS_DRAFT)
            .setFakeId()
            .setParent('Account', new Fake(Account.class).setField(Account.Id, accountId));
    }

    /**
     * @description To create fake primary OrderItem record with the passed OrderId
     * and ProductId.
     * @param orderId
     * @param productId
     * @return Fake
     */
    public static Fake createPrimaryOrderItemFakeInstance(String orderId, String productId) {
        return new Fake(OrderItem.class)
            .setField(OrderItem.OrderId, orderId)
            .setField(OrderItem.Product2Id, productId)
            .setField(OrderItem.Quantity, ORDER_ITEM_QUANTITY)
            .setField(OrderItem.UnitPrice, PRICEBOOK_ENTRY_UNIT_PRICE)
            .setFakeId()
            .setParent('Order', new Fake(Order.class).setField(Order.Id, orderId));
    }

    /**
     * @description To create fake Store_Readiness_Validation_Rule__mdt Custom MetaData record
     * with the passed method name and Field name for WorkOrdersValidationService.
     * @param errorMessage
     * @param fieldName
     * @param methodName
     * @param objectName
     * @param serviceClassName
     * @return Fake
     */
    public static Fake createStoreReadinessValidationRuleFakeInstance(
        String errorMessage,
        String fieldName,
        String methodName,
        String objectName,
        String serviceClassName
    ) {
        return new Fake(Store_Readiness_Validation_Rule__mdt.class)
            .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, fieldName)
            .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, errorMessage)
            .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
            .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, objectName)
            .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, serviceClassName)
            .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, methodName)
            .setFakeId();
    }

    /**
     * @description To create fake Cross_Object_Status_Mapping__mdt custom metaData record
     * with the passed values.
     * @param sourceStatus
     * @param targetStatus
     * @param active
     * @param process
     * @param type
     * @return Fake
     */
    public static Fake createCrossObjectStatusMappingFakeInstance(
        String sourceStatus,
        String targetStatus,
        Boolean active,
        String process,
        String type
    ) {
        return new Fake(Cross_Object_Status_Mapping__mdt.class)
            .setField(Cross_Object_Status_Mapping__mdt.Source_Status__c, sourceStatus)
            .setField(Cross_Object_Status_Mapping__mdt.Target_Status__c, targetStatus)
            .setField(Cross_Object_Status_Mapping__mdt.Active__c, true)
            .setField(Cross_Object_Status_Mapping__mdt.Process__c, process)
            .setField(Cross_Object_Status_Mapping__mdt.Type__c, type)
            .setFakeId();
    }

    /**
     * @description To create fake instances of Storefront Work Steps using the passed values.
     * @param childWorkPlanId
     * @param childWorkPlanFakeInstance
     * @param parentWorkStepId
     * @param parentWorkStepFakeInstance
     * @param storeAccountId
     * @return List<Fake>
     */
    public static List<Fake> generateStorefrontWorkSteps(
        Id childWorkPlanId,
        Fake childWorkPlanFakeInstance,
        Id parentWorkStepId,
        Fake parentWorkStepFakeInstance,
        Id storeAccountId
    ) {
        return new List<Fake>{
            MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(STATUS_COMPLETE)
                .setField(WorkStep.Name, WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE)
                .setField(WorkStep.Status, STATUS_COMPLETE)
                .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.WorkPlanId, childWorkPlanId)
                .setParent('WorkPlan', childWorkPlanFakeInstance),
            MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                    STATUS_COMPLETE_IMPLEMENTED_ON_CALL
                )
                .setField(WorkStep.Name, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
                .setField(WorkStep.Status, STATUS_COMPLETE_IMPLEMENTED_ON_CALL)
                .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
                .setField(WorkStep.WorkPlanId, childWorkPlanId)
                .setParent('WorkPlan', childWorkPlanFakeInstance)
                .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance),
            MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(STATUS_COMPLETE)
                .setField(WorkStep.Name, WORK_STEP_TYPE_LINK_IMPLEMENTATION)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_LINK_IMPLEMENTATION)
                .setField(WorkStep.Status, STATUS_COMPLETE)
                .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.WorkPlanId, childWorkPlanId)
                .setParent('WorkPlan', childWorkPlanFakeInstance),
            MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(STATUS_COMPLETE)
                .setField(WorkStep.Name, WORK_STEP_TYPE_LINK_OPTIMIZATION)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_LINK_OPTIMIZATION)
                .setField(WorkStep.Status, STATUS_COMPLETE)
                .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
                .setField(WorkStep.Store_Account__c, storeAccountId)
                .setField(WorkStep.WorkPlanId, childWorkPlanId)
                .setParent('WorkPlan', childWorkPlanFakeInstance)
        };
    }

    /**
     * @description To create fake WorkStep record with the passed WorkOrderId and WorkPlanId.
     * @param wpId
     * @param woId
     * @param type
     * @param status
     * @return Fake
     */
    public static Fake createWorkStepFakeInstance(Id wpId, Id woId, String type, String status) {
        return new Fake(WorkStep.class)
            .setField(WorkStep.Name, type)
            .setField(WorkStep.Status__c, status)
            .setField(WorkStep.Type__c, type)
            .setField(WorkStep.WorkOrderId, woId)
            .setField(WorkStep.WorkPlanId, wpId)
            .setFakeId();
    }
    /**
     * @description This method generates a list of fake WorkStep records with the passed WorkOrderId and WorkPlanId
     * @param workPlanId - The ID of the WorkPlan record for which the WorkSteps need to be generated
     * @param workOrderId - The ID of the WorkOrder record for which the WorkSteps need to be generated
     * @param status - The status to be set for the generated WorkSteps
     * @param workPlanFakeInstance - The fake WorkPlan instance to which the generated WorkSteps need to be associated
     * @return List<Fake> - A list of fake WorkStep records with the given WorkPlanId and WorkOrderId
     */
    public static List<Fake> generatePosWorkSteps(
        Id workPlanId,
        Id workOrderId,
        String status,
        Fake workPlanFakeInstance
    ) {
        List<String> posWorkSteps = new List<String>{
            WORK_STEP_TYPE_QA_MENU,
            WORK_STEP_TYPE_INGEST_MENU,
            WORK_STEP_TYPE_COMPLETE_PRE_WORK,
            WORK_STEP_TYPE_CONFIGURE_POS,
            WORK_STEP_TYPE_ENABLE_INTEGRATION
        };
        List<Fake> childWorkSteps = new List<Fake>();
        for (String eachWsType : posWorkSteps) {
            childWorkSteps.add(
                createWorkStepFakeInstance(workPlanId, workOrderId, eachWsType, status)
            );
        }
        return childWorkSteps;
    }
    /**
     * @description To create fake instances of Integration Requests passed values.
     * @param storeId
     * @return Fake
     */
    public static Fake createIntegrationRequestFakeInstance(String storeId) {
        return new Fake(Integration_request__c.class)
            .setField(Integration_request__c.Action__c, ACTION)
            .setField(Integration_request__c.Onboarding_Id__c, ONBOARDING_ID)
            .setField(Integration_request__c.Sfdc_Status__c, IR_SFDC_STATUS)
            .setField(Integration_request__c.Integration_Id__c, INTEGRATION_ID)
            .setField(Integration_request__c.Integration_Provider__c, INTEGRATION_PROVIDER)
            .setField(Integration_request__c.Store_Id__c, storeId)
            .setFakeId();
    }
    /**
     * @description To convert the fake instance to SObject instance.
     * @param fakeInstance
     * @return sObject
     */
    public static sObject convertToSObject(Fake fakeInstance) {
        return fakeInstance.toSObject();
    }

    /**
     * @description To convert a list of fake instances to SObject instances.
     * @param fakeInstances
     * @return List<sObject>
     */
    public static List<sObject> convertToSObject(List<Fake> fakeInstances) {
        List<sObject> sObjects = new List<sObject>();
        for (Fake eachFakeInstance : fakeInstances) {
            sObjects.add(eachFakeInstance.toSObject());
        }
        return sObjects;
    }
}