/**
 * @author Deloitte
 * @date 04/25/2024
 * @description This is test class for MerchantOrdersSelector class
 */
@isTest
public class MerchantOrdersSelectorTest {
    private static final String ACCOUNT_NAME = 'Rx Business';
    private static final String ACCOUNT_ORDER_PROTOCOL = 'Tablet (DoorDash Owns)';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ASSERT_MESSAGE_FIELD_LIST = 'Unexpected Error: Mismatch in field list';
    private static final String ASSERT_MESSAGE_INVALID_RECORD_RETRIEVE = 'Unexpected Error: Records are retrieved for invalid Mx Order Names';
    private static final String ASSERT_MESSAGE_OBJECT_TYPE = 'Unexpected Error: The object type must be Merchant Order';
    private static final String ASSERT_MESSAGE_RECORD_RETRIEVE = 'Unexpected Error: Records are not retrieved';
    private static final string CONTACT_FIRSTNAME = 'Test';
    private static final string CONTACT_LASTNAME = 'Contact';
    private static final string CONTACT_EMAIL = 'MerchantOrdersSelectorTest@test.com';
    private static final String MOCK_MX_ORDER_NUMBER = 'MX00000112';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String PHOTOSHOOT_BUNDLE = 'Photoshoot Bundle';
    private static final String RETURN_LABEL_STATUS_BINDING_NAME = 'returnLabelStatus';
    private static final String ROLE = 'Decision Maker';
    private static final String SEGMENT = 'Enterprise';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_FAILED_RETURN_LABEL_TO_MX = 'Failed to Send to Mx';
    private static final String STATUS_RETURN_LABEL_GENERATED = 'Return Label Generated';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String TABLET_INTEGRATION = 'Tablet_Integration';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';

    /**
     * @description To test Merchant Orders and child Merchant Order Items are retrived
     * when merchant order ids are received.
     */
    @isTest
    private static void testWhenIdSentThenMerchantOrdersReturned() {
        Account tabletAccount = new Account(
            Name = ACCOUNT_NAME,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert tabletAccount;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = tabletAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = tabletAccount.Order_Protocol__c
        );
        insert tabletMerchantOrder;

        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectMerchantOrderRelatedDetailsById(new Set<Id>{ tabletMerchantOrder.Id });

        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Orders are retrieved when WorkOrderId is sent.
     */
    @isTest
    private static void testWhenWorkOrderIdsSentThenMerchantOrdersReturned() {
        Account tabletAccount = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert tabletAccount;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = tabletAccount.Id,
            Estimated_Number_of_Stores__c = 2
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = tabletAccount.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c tabletMerchantOrder = new Mx_Order__c(
            Account__c = tabletAccount.Id,
            Product_Bundle__c = productBundle.Id,
            Store_Order_Protocol__c = tabletAccount.Order_Protocol__c,
            Work_Order__c = parentWorkOrder.Id,
            Work_Step__c = null
        );
        insert tabletMerchantOrder;

        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectByWorkOrderIds(new Set<Id>{ parentWorkOrder.Id });

        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test SObject type and field lists are retrieved as expected
     * when class instantiates.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        MerchantOrdersSelector merchantOrdersSelectorInstance = new MerchantOrdersSelector();

        Schema.SObjectType typeOfObj = merchantOrdersSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = merchantOrdersSelectorInstance.getSObjectFieldList();

        MerchantOrdersSelector.newInstance();

        System.assertEquals(Schema.MX_Order__c.SObjectType, typeOfObj, ASSERT_MESSAGE_OBJECT_TYPE);
        System.assertEquals(
            new List<Schema.SObjectField>{
                MX_Order__c.Account__c,
                MX_Order__c.Merchant_Address__c,
                MX_Order__c.Contact__c,
                MX_Order__c.Internal_Deployment__c,
                MX_Order__c.Last_Tracked_Update_Time__c,
                MX_Order__c.Legacy_ID__c,
                MX_Order__c.Name,
                MX_Order__c.Printer_IMEI__c,
                MX_Order__c.Product_Bundle__c,
                MX_Order__c.Reason_for_Replacement__c,
                MX_Order__c.Replacement_Reason_Other__c,
                MX_Order__c.Shipment_Status__c,
                MX_Order__c.Shipment_Status_Description__c,
                MX_Order__c.Shipping_Carrier__c,
                MX_Order__c.Shipping_Type__c,
                MX_Order__c.Status__c,
                MX_Order__c.Store_Order_Protocol__c,
                MX_Order__c.Tablet_IMEI__c,
                MX_Order__c.Tracking_Number__c,
                MX_Order__c.Type__c,
                MX_Order__c.Type_Of_Request__c,
                MX_Order__c.Vendor__c,
                MX_Order__c.Work_Order__c,
                MX_Order__c.Work_Order_Type__c,
                MX_Order__c.Work_Plan__c
            },
            fieldList,
            ASSERT_MESSAGE_FIELD_LIST
        );
    }

    /**
     * @description To test Photoshoot Merchant Order details are retrived
     * when merchant order ids are received.
     */
    @isTest
    private static void testWhenPhotoshootOrderIdsReceivedThenPhotoshootMerchantOrdersReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectPhotoshootDetailsByMxOrderIds(new Set<Id>{ merchantOrder.Id });
        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Order object query when Work Plan Ids are passed.
     */
    @isTest
    private static void testWhenWorkPlanIdsPassedThenMerchantOrdersReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectByWorkPlanIds(new Set<Id>{ parentWorkPlan.Id });
        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Order with return label details are retrived
     * as query locator.
     */
    @isTest
    private static void testWhenQueryLocatorMxOrdersWithReturnLabelsThenMerchantOrdersReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Return_Label_Status__c = STATUS_RETURN_LABEL_GENERATED,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        Database.QueryLocator queryData = MerchantOrdersSelector.newInstance()
            .queryLocatorMxOrdersWithReturnLabels(
                new Map<String, Object>{
                    RETURN_LABEL_STATUS_BINDING_NAME => new Set<String>{
                        STATUS_RETURN_LABEL_GENERATED,
                        STATUS_FAILED_RETURN_LABEL_TO_MX
                    }
                }
            );
        List<Mx_Order__c> merchantOrdersRetrieved = Database.queryWithBinds(
            queryData.getQuery(),
            new Map<String, Object>{
                RETURN_LABEL_STATUS_BINDING_NAME => new Set<String>{
                    STATUS_RETURN_LABEL_GENERATED,
                    STATUS_FAILED_RETURN_LABEL_TO_MX
                }
            },
            AccessLevel.USER_MODE
        );
        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Order details are retrived
     * when merchant order ids are received.
     */
    @isTest
    private static void testWhenMxOrderIdsReceivedThenMerchantOrdersReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectById(new Set<Id>{ merchantOrder.Id });
        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Order details are retrived
     * based on passed Merchant Order Names.
     */
    @isTest
    private static void testWhenMxOrderNamesReceivedThenMerchantOrdersReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        String mxOrderName;
        Test.startTest();
        mxOrderName = [SELECT Name FROM Mx_Order__c WHERE Id = :merchantOrder.Id][0].Name;
        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectByName(new Set<String>{ mxOrderName });
        Test.stopTest();
        System.assertEquals(1, merchantOrdersRetrieved.size(), ASSERT_MESSAGE_RECORD_RETRIEVE);
    }

    /**
     * @description To test Merchant Order details are not retrived
     * when invalid Merchant Order Names are passed.
     */
    @isTest
    private static void testWhenInvalidMxOrderNamesReceivedThenMerchantOrdersNotReturned() {
        Account account = new Account(
            Name = ACCOUNT_NAME,
            Segment__c = SEGMENT,
            Order_Protocol__c = ACCOUNT_ORDER_PROTOCOL
        );
        insert account;
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL
        );
        insert contact;
        Opportunity parentOpportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addYears(2),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = account.Id
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = account.Id,
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            Opportunity__c = parentOpportunity.Id,
            Proposed_Date_of_Activation__c = System.today().addDays(10),
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_PLAN_NAME_STOREFRONT
        );
        insert parentWorkOrder;
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = WORK_PLAN_NAME_STOREFRONT,
            ParentRecordId = parentWorkOrder.Id,
            Status__c = STATUS_NOT_STARTED
        );
        insert parentWorkPlan;
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Mx_Order__c merchantOrder = new Mx_Order__c(
            Account__c = account.Id,
            Store_Order_Protocol__c = account.Order_Protocol__c,
            Work_Plan__c = parentWorkPlan.Id,
            Product_Bundle__c = productBundle.Id,
            Work_Order__c = parentWorkOrder.Id
        );
        insert merchantOrder;
        Test.startTest();
        List<Mx_Order__c> merchantOrdersRetrieved = new MerchantOrdersSelector()
            .selectByName(new Set<String>{ MOCK_MX_ORDER_NUMBER });
        Test.stopTest();
        System.assertEquals(
            0,
            merchantOrdersRetrieved.size(),
            ASSERT_MESSAGE_INVALID_RECORD_RETRIEVE
        );
    }
}