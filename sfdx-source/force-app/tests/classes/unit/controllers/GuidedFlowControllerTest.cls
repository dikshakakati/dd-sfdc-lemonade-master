/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Test class for Guided flow controller.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class GuidedFlowControllerTest {
    /**
     * @description It is used to test if MxOrder creation is called successfully when flow inputs
     * are received.
     */
    @isTest
    private static void testWhenNetNewFlowInputsAreReceivedThenMxOrderCreationCalled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id relatedContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id relatedAccountId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<GuidedFlowInputs> flowInputs = new List<GuidedFlowInputs>();
        GuidedFlowInputs flowInput = new GuidedFlowInputs();
        flowInput.workOrderId = parentWorkOrderId;
        flowInput.typeOfRequest = 'Net-New';
        flowInput.productBundleName = 'Tablet Bundle(US)';
        flowInput.tabletIMEI = null;
        flowInput.printerIMEI = null;
        flowInput.contactId = relatedContactId;
        flowInput.accountId = relatedAccountId;
        flowInput.shippingStateCode = 'CA';
        flowInput.shippingCountryCode = 'US';
        flowInput.shippingCity = 'City';
        flowInput.shippingStreet = 'Street';
        flowInput.shippingPostalCode = '12345';
        flowInput.workOrder = new WorkOrder(Id = parentWorkOrderId);
        flowInput.replacementReason = null;
        flowInput.reasonForReturn = null;
        flowInputs.add(flowInput);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderCreationService mxOrderCreationService = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderCreationService);
        Test.startTest();
        GuidedFlowController.generateMxOrderAndMxOrderItem(flowInputs);
        Test.stopTest();
        ((IMxOrderCreationService) mocks.verify(mxOrderCreationService, 1))
            .generateMerchantOrder(flowInputs[0], true);
    }

    /**
     * @description It is used to test if MxOrder creation is called successfully when flow inputs
     * are received.
     */
    @isTest
    private static void testWhenReplacementFlowInputsAreReceivedThenMxOrderCreationCalled() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id relatedContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id relatedAccountId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<GuidedFlowInputs> flowInputs = new List<GuidedFlowInputs>();
        GuidedFlowInputs flowInput = new GuidedFlowInputs();
        flowInput.workOrderId = parentWorkOrderId;
        flowInput.typeOfRequest = 'Replacement';
        flowInput.productBundleName = 'Tablet Bundle(US)';
        flowInput.tabletIMEI = null;
        flowInput.printerIMEI = null;
        flowInput.contactId = relatedContactId;
        flowInput.accountId = relatedAccountId;
        flowInput.shippingStateCode = 'CA';
        flowInput.shippingCountryCode = 'US';
        flowInput.shippingCity = 'City';
        flowInput.shippingStreet = 'Street';
        flowInput.shippingPostalCode = '12345';
        flowInput.workOrder = new WorkOrder(Id = parentWorkOrderId);
        flowInput.replacementReason = null;
        flowInput.reasonForReturn = null;
        flowInputs.add(flowInput);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderCreationService mxOrderCreationService = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        Application.SERVICE.setMock(IMxOrderCreationService.class, mxOrderCreationService);
        Test.startTest();
        GuidedFlowController.generateMxOrderAndMxOrderItem(flowInputs);
        Test.stopTest();
        ((IMxOrderCreationService) mocks.verify(mxOrderCreationService, 1))
            .generateMerchantOrder(flowInputs[0], true);
    }
}