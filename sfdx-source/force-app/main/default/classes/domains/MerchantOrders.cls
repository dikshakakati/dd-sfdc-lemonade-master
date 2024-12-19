/**
 * @author Deloitte
 * @date 06/20/2024
 * @description Domain class for Merchant Order object.
 */
public inherited sharing class MerchantOrders extends fflib_SObjects implements IMerchantOrders {
    private static final String LOG_SERVICE_MERCHANT_ORDERS = 'Merchant Orders Service';
    private static final String LOG_DOMAIN_TABLET_INTEGRATION = 'Tablet Outbound Integration';
    private static final String MX_ORDER_STATUS_DRAFT = 'Draft';
    private static final String MX_ORDER_STATUS_NOT_APPLICABLE = 'Not Applicable';
    private static final String MX_ORDER_TYPE_OF_REQUEST_RETURN = 'Return';
    private static final String MX_ORDER_TYPE_OF_REQUEST_REPLACEMENT = 'Replacement';
    private static final String MX_ORDER_VENDOR_DENALI = 'Denali';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_NAME_DELIVER_RETURN_LABEL = 'Deliver Return Label';
    private static final String LOG_WORK_STEP_UPDATE_FAILED = 'Update on Work Step records failed';
    private static final String LOG_DOMAIN = 'Work Step Service';

    /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public MerchantOrders(List<MX_Order__c> sObjects) {
        super(sObjects, Schema.MX_Order__c.SObjectType);
    }

    /**
     * @description It is used to return the IMerchantOders interface.
     * @param mxOrders - MerchantOrders record list
     * @return IMerchantOrders - instance of IMerchantOders interface
     */
    public static IMerchantOrders newInstance(List<MX_Order__c> mxOrders) {
        return (IMerchantOrders) Application.Domain.newInstance(mxOrders);
    }

    /**
     * @description It is used to update Merchant Order fields based on newly updated Vendor.
     * @JIRA# LEM-20315
     * @param merchantOrders
     */
    public void resetMerchantOrdersOnVendorChange(List<MX_Order__c> merchantOrders) {
        for (MX_Order__c eachMerchantOrder : merchantOrders) {
            eachMerchantOrder.Status__c = MX_ORDER_STATUS_DRAFT;
            eachMerchantOrder.Order_Status_Description__c = '';
            eachMerchantOrder.Vendor_Order_ID__c = '';
        }
        updateMerchantOrderStatus(merchantOrders);
    }

    /**
     * @description It is used to update Status of Merchant Order to 'Not Available' for Merchant Order
     * where Vendor is 'Denali' and Type of Request is 'Return'.
     * @JIRA# LEM-14703
     * @param merchantOrders
     */
    public void updateMerchantOrderStatus(List<MX_Order__c> merchantOrders) {
        for (
            MX_Order__c eachMerchantOrder : mxOrdersWithTypeOfRequestReturnAndDenaliVendor(
                merchantOrders
            )
        ) {
            eachMerchantOrder.Status__c = MX_ORDER_STATUS_NOT_APPLICABLE;
        }
    }

    /**
     * @description It filters the Mx Order records to collect  Merchant Order
     * where Vendor is 'Denali' and Type of Request is 'Return'.
     * @JIRA# LEM-14703
     * @param mxOrders
     * @return List<MX_Order__c>
     */
    private List<MX_Order__c> mxOrdersWithTypeOfRequestReturnAndDenaliVendor(
        List<MX_Order__c> mxOrders
    ) {
        List<MX_Order__c> filteredMxOrders = new List<MX_Order__c>();
        for (MX_Order__c eachMxOrder : mxOrders) {
            if (
                eachmxOrder.Type_Of_Request__c == MX_ORDER_TYPE_OF_REQUEST_RETURN &&
                eachmxOrder.Work_Order_Sub_Type__c == MX_ORDER_TYPE_OF_REQUEST_REPLACEMENT &&
                eachmxOrder.Vendor__c == MX_ORDER_VENDOR_DENALI
            ) {
                filteredMxOrders.add(eachMxOrder);
            }
        }
        return filteredMxOrders;
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return MerchantOrders - List of MerchantOrders
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (MerchantOrders.constructorMock != null) {
                return (fflib_SObjects) MerchantOrders.constructorMock.construct(objectList);
            }
            return new MerchantOrders((List<SObject>) objectList);
        }
    }
}