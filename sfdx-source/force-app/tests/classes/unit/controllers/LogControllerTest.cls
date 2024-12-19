/**
 * @description This is a test class created to handle exception in case of any exception scenarios in lightning component.
 * @author Deloitte
 * @date 04/03/2022
 */
@isTest(SeeAllData=false)
private class LogControllerTest {
    private static final String COMPONENT_NAME = 'Test Aura Component';
    private static final String ERROR_MESSAGE = 'Exception occurred in Aura Component';
    private static final String METHOD_NAME = 'Test AuraEnabled Method';
    private static final String DESCRIBE_NAME = 'Payment Account';
    private static final String SOBJECT_NAME =  'Payment_Account__c';
    /**
     * @description This method is used to create log when an exception occur in aura components
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenErrorOccurredInLWCThenCreateLog() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UNITOFWORK.setMock(uowMock);

        LogController.createLog(COMPONENT_NAME, METHOD_NAME, ERROR_MESSAGE);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Class_Method_Name__c => METHOD_NAME,
                        Log__c.Class_Name__c => COMPONENT_NAME,
                        Log__c.Quiddity__c => String.valueOf(Request.getCurrent().getQuiddity())
                    }
                )
            );
    }
}
