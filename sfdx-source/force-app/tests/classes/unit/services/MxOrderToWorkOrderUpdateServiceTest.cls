/**
 * @author Deloitte
 * @date 11/18/2024
 * @description Test class for MxOrderToWorkOrderUpdateServiceImpl class.
 */
@isTest(SeeAllData=false)
public class MxOrderToWorkOrderUpdateServiceTest {
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_NAME = 'MX-0001';
    private static final String MX_ORDER_VENDOR_DENALI = 'Denali';
    private static final String MX_ORDER_VENDOR_SOCIAL_MOBILE = 'Social Mobile';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';

    /**
     * @description To test when Photoshoot Mx Order with Work Order is Passed
     * then update Photoshoot Date and Time on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPhotoshootMxOrderWithWorkOrderPassedThenUpdatePhotoshootDateTimeOnWorkOrder() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, TYPE_PHOTOSHOOT)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_DENALI)
            .setField(MX_Order__c.Work_Order__c, workOrderId)
            .toSObject();
        Application.UNITOFWORK.setMock(mockUOW);
        MxOrderToWorkOrderUpdateService.updateWorkOrderPhotoShootDateAndTime(new List<MX_Order__c>{ mockMxOrder });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tablet Mx Order with Work Order is Passed
     * then do not update Photoshoot Date and Time on Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTabletMxOrderWithWorkOrderPassedThenDoNotUpdatePhotoshootDateTimeOnWorkOrder() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        MX_Order__c mockMxOrder = (Mx_Order__c) new Fake(Mx_Order__c.class)
            .setField(MX_Order__c.Id, mxOrderId)
            .setField(MX_Order__c.Account__c, storeAccountId)
            .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
            .setField(MX_Order__c.Name, MX_ORDER_NAME)
            .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_DENALI)
            .setField(MX_Order__c.Work_Order__c, workOrderId)
            .toSObject();
        Application.UNITOFWORK.setMock(mockUOW);
        MxOrderToWorkOrderUpdateService.updateWorkOrderPhotoShootDateAndTime(new List<MX_Order__c>{ mockMxOrder });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerDirty(
            fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        MX_Order__c.Work_Order__c => workOrderId
                    }
                )
	    );
    }
}