/**
 * @author Deloitte
 * @date 29/09/2022
 * @description Test class for PaymentAccountIntegrationsServiceImpl class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class PaymentAccountIntegrationServiceImplTest {
    /**
     * @description - - System should  create platform events for the selected Payment_Account__c record Id.
     */
    @isTest
    private static void testWhenPublishEventsCalledWithPaymentAccountIdThenPaymentAccountIntegrationEventPublished() {
        Id accountPaymentId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
		fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        PaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(new Set<Id>{accountPaymentId});
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description - System should not create platform events for the empty Id's.
    */
    @isTest
    private static void testWhenPublishEventsCalledWithoutPaymentAccountIdThenPaymentAccountIntegrationEventShouldNotPublished() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        PaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(null);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}