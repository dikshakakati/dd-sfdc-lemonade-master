/**
 * @author Deloitte
 * @date 26/05/2022
 * @description Test class used to cover BatchApexErrorEventHandler and BatchApexErrorEvents trigger class.
 */
@isTest
public class BatchApexErrorEventTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBatchApexErrorEventInsertedThenCheckScopeSize() {
        BatchApexErrorEvent batchApexEvent = new BatchApexErrorEvent(
            StackTrace = 'Class.BatchApexErrorEventTest.execute: line 35',
            Message = 'Test',
            jobScope = '000012345600000,0000123456000009'
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onInsert(new List<BatchApexErrorEvent>{ batchApexEvent });
        fflib_SObjectDomain.triggerHandler(BatchApexErrorEventHandler.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => 'GENERIC_LOG',
                        Log__c.Class_Name__c => 'BatchApexErrorEventTest',
                        Log__c.Detailed_Message__c => 'Class.BatchApexErrorEventTest.execute: line 35'
                    }
                )
            );
    }
}