@isTest
public class FlowErrorLogControllerTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLogErrorIsInvokedFromFlowThenCreateLog() {
        // Arrange
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(Id = agreementId)
        };
        FlowErrorLogController.ErrorDetails errorDetails = new FlowErrorLogController.ErrorDetails();
        errorDetails.deactivatedAgreementsList = agreements;
        errorDetails.error = 'Test error message';

        List<FlowErrorLogController.ErrorDetails> errorDetailsWithagreementsList = new List<FlowErrorLogController.ErrorDetails>{
            errorDetails
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);

        // Act
        Test.startTest();
        FlowErrorLogController.logError(errorDetailsWithagreementsList);
        Test.stopTest();

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLogErrorIsInvokedWithNullAgreementsThenCreateLog() {
        // Arrange
        FlowErrorLogController.ErrorDetails errorDetails = new FlowErrorLogController.ErrorDetails();
        errorDetails.deactivatedAgreementsList = null;
        errorDetails.error = 'Test error message';

        List<FlowErrorLogController.ErrorDetails> errorDetailsWithagreementsList = new List<FlowErrorLogController.ErrorDetails>{
            errorDetails
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUnitOfWork);

        // Act
        Test.startTest();
        FlowErrorLogController.logError(errorDetailsWithagreementsList);
        Test.stopTest();

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
    }
}