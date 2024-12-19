/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Test class for MxReturnLabelEmailBatch.
 */
@isTest(SeeAllData=false)
private class MxReturnLabelEmailBatchTest {
    /**
     * @description To test Return label email sending process is initiated
     * when MxOrders is attached with return label.
     * Suppressing Warning as mock.verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxReturnLabelEmailBatchExecutesThenVerifyReturnLabelEmailInitiated() {
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        List<MX_Order__c> mxOrdersWithReturnLabels = new List<MX_Order__c>{
            new MX_Order__c(Id = mxOrderId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxReturnLabelEmailService serviceMock = (IMxReturnLabelEmailService) mocks.mock(
            IMxReturnLabelEmailService.class
        );
        Application.SERVICE.setMock(IMxReturnLabelEmailService.class, serviceMock);
        MxReturnLabelEmailBatch batch = new MxReturnLabelEmailBatch();
        batch.start(null);
        batch.execute(null, mxOrdersWithReturnLabels);
        batch.finish(null);
        batch.execute(null);
        ((IMxReturnLabelEmailService) mocks.verify(serviceMock, 1))
            .sendReturnLabelEmailsToMerchants(mxOrdersWithReturnLabels);
    }
}