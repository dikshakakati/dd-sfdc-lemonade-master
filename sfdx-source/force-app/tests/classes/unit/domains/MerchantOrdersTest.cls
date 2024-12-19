/**
 * @author Deloitte
 * @date 06/20/2024
 * @description Test class for MerchantOrders class.
 */
@isTest(SeeAllData=false)
private class MerchantOrdersTest {
    private static final String FIELD_UPDATE_ASSERT_MESSAGE = 'Unexpected result: Field is not updated with expected value';
    private static final String MOCK_ORDER_STATUS_DESCRIPTION = 'MerchantOrdersTest Status Description';
    private static final String MOCK_VENDOR_ORDER_ID = 'MerchantOrdersTest0101';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_NAME = 'MX-0001';
    private static final String MX_ORDER_VENDOR_DENALI = 'Denali';
    private static final String MX_ORDER_VENDOR_SOCIAL_MOBILE = 'Social Mobile';
    private static final String MX_ORDER_TYPE_OF_REQUEST = 'Return';
    private static final String MX_ORDER_STATUS_NOT_APPLICABLE = 'Not Applicable';
    private static final String MX_ORDER_TYPE_OF_REQUEST_REPLACEMENT = 'Replacement';
    private static final String STATUS_UPDATE_ASSERT_MESSAGE = 'Unexpected result: Status is not correct';
    private static final String WORK_STEP_NAME_DELIVER_RETURN_LABEL = 'Deliver Return Label';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_DRAFT = 'Draft';

    /**
     * @description To test when the Mx Order vendor is Denali and the request type is Return
     * then the status should be updatd to Not Applicable.
     */
    @isTest
    private static void testWhenMxOrderVendorDenaliAndReturnRequestThenSetStatusNotApplicable() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_DENALI)
            .setField(MX_Order__c.Type_Of_Request__c, MX_ORDER_TYPE_OF_REQUEST)
            .setField(MX_Order__c.Work_Order_Sub_Type__c, MX_ORDER_TYPE_OF_REQUEST_REPLACEMENT)
            .toSObject();
        IMerchantOrders mxOrdersInstance = MerchantOrders.newInstance(
            new List<MX_Order__c>{ mockMxOrder }
        );
        mxOrdersInstance.updateMerchantOrderStatus(new List<MX_Order__c>{ mockMxOrder });
        system.assertEquals(
            MX_ORDER_STATUS_NOT_APPLICABLE,
            mockMxOrder.Status__c,
            STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when the Mx Order vendor is Social Mobile and the request type is Return
     * then the status should not be updatd to Not Applicable.
     */
    @isTest
    private static void testWhenMxOrderVendorSocialMobileAndReturnRequestThenDoNotSetStatusNotApplicable() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_SOCIAL_MOBILE)
            .setField(MX_Order__c.Type_Of_Request__c, MX_ORDER_TYPE_OF_REQUEST)
            .toSObject();
        IMerchantOrders mxOrdersInstance = MerchantOrders.newInstance(
            new List<MX_Order__c>{ mockMxOrder }
        );
        mxOrdersInstance.updateMerchantOrderStatus(new List<MX_Order__c>{ mockMxOrder });
        system.assertNotEquals(
            MX_ORDER_STATUS_NOT_APPLICABLE,
            mockMxOrder.Status__c,
            STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when the Mx Order Vendor is changed then update Mx Order fields.
     */
    @isTest
    private static void testWhenMxOrderVendorChangedThenUpdateMxOrderFields() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake mockMxOrderFakeInstance = new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Order_Status_Description__c, MOCK_ORDER_STATUS_DESCRIPTION)
            .setField(MX_Order__c.Status__c, MX_ORDER_STATUS_NOT_APPLICABLE)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Type_Of_Request__c, MX_ORDER_TYPE_OF_REQUEST)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_SOCIAL_MOBILE)
            .setField(MX_Order__c.Vendor_Order_ID__c, MOCK_VENDOR_ORDER_ID);

        MX_Order__c mockMxOrder = (Mx_Order__c) mockMxOrderFakeInstance.toSObject();
        IMerchantOrders mxOrdersInstance = MerchantOrders.newInstance(
            new List<MX_Order__c>{ mockMxOrder }
        );
        mxOrdersInstance.resetMerchantOrdersOnVendorChange(new List<MX_Order__c>{ mockMxOrder });
        System.assertEquals(
            WORK_STEP_STATUS_DRAFT,
            mockMxOrder.Status__c,
            STATUS_UPDATE_ASSERT_MESSAGE
        );
        System.assertEquals(
            '',
            mockMxOrder.Order_Status_Description__c,
            FIELD_UPDATE_ASSERT_MESSAGE
        );
        System.assertEquals('', mockMxOrder.Vendor_Order_ID__c, FIELD_UPDATE_ASSERT_MESSAGE);
    }
}