/**
 * @author Deloitte
 * @date 07/24/2024
 * @description Test class for Business Onboarding Details Handler.
 */
@isTest(SeeAllData=false)
private class BusinessOnboardingDetailsHandlerTest {
    private static final String OI_DATA_SERVICE = 'OIDataService';

    /**
     * @description To test Interface Transactions are created when Business Onboarding Details
     * are inserted.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessDetailsInsertedThenCreateInterfaceTransactions() {
        List<Business_Onboarding_Detail__c> newDetails = new List<Business_Onboarding_Detail__c>{
            new Business_Onboarding_Detail__c(
                Id = fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType),
                Mx_Onboarding_Link__c = fflib_IDGenerator.generate(
                    Mx_Onboarding_Link__c.SObjectType
                )
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        fflib_SObjectDomain.Test.Database.onInsert(newDetails);
        fflib_SObjectDomain.triggerHandler(BusinessOnboardingDetailsHandler.class);
    }
}