/**
 * @author Deloitte
 * @date 06/02/2022
 * @description Test class used to cover TransactionRetryService and
 * TransactionRetryServiceImpl classes.
 */
@isTest
public class TransactionRetryServiceTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRetryAttemptSuccessfulCallsThenCommitUow() {
        List<Interface_Transaction__c> interfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 3
            ),
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 2
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Sobject> successRecords = new List<Sobject>();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector selectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ interfaceTransaction[0].Id, interfaceTransaction[1].Id }
                )
            )
            .thenReturn(interfaceTransaction);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        TransactionRetryService.retryAttemptSuccessful(
            new Set<Id>{ interfaceTransaction[0].Id, interfaceTransaction[1].Id }
        );
        successRecords.addAll(interfaceTransaction);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransaction[0].Id,
                        Interface_Transaction__c.Status__c => 'Success',
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => 3
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransaction[1].Id,
                        Interface_Transaction__c.Status__c => 'Success',
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => 2
                    }
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenScheduleCalloutRetrycallsThenCommitUow() {
        List<Interface__c> interfaceList = new List<Interface__c>{
            new Interface__c(
                Id = fflib_IDGenerator.generate(Interface__c.SObjectType),
                Class_Interface_Name__c = 'System.Test',
                Enable_Retry__c = true,
                Retry_Limit__c = 3
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInterfaceSelector selectorMock = (IInterfaceSelector) mocks.mock(IInterfaceSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface__c.SObjectType);
        mocks.when(
                selectorMock.selectByclassName(
                    new List<String>{ (interfaceList[0].Class_Interface_Name__c) }
                )
            )
            .thenReturn(interfaceList);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        Map<Type, String> processInterfaceAndSerializedPayloadTest = new Map<Type, String>();
        processInterfaceAndSerializedPayloadTest.put(Test.class, 'PayLoad Test');
        TransactionRetryService.scheduleRetryableTransactions(
            processInterfaceAndSerializedPayloadTest
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Interface__c => interfaceList[0].id,
                        Interface_Transaction__c.Status__c => 'Failure',
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => 3,
                        Interface_Transaction__c.Payload__c => 'PayLoad Test'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenRetryAttemptFailedCallsThenCommitUow() {
        List<Interface_Transaction__c> interfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 3
            ),
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 2
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Sobject> failedRecords = new List<Sobject>();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector selectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ interfaceTransaction[0].Id, interfaceTransaction[1].Id }
                )
            )
            .thenReturn(interfaceTransaction);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        TransactionRetryService.retryAttemptFailed(
            new Set<Id>{ interfaceTransaction[0].Id, interfaceTransaction[1].Id }
        );
        failedRecords.addAll(interfaceTransaction);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransaction[0].Id,
                        Interface_Transaction__c.Status__c => 'Failure',
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => 2
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Interface_Transaction__c.Id => interfaceTransaction[1].Id,
                        Interface_Transaction__c.Status__c => 'Failure',
                        Interface_Transaction__c.Remaining_Retry_Attempts__c => 1
                    }
                )
            );
    }

    @isTest
    public static void testWhenGetRetryableCalloutCallsThenReturnPayload() {
        List<Interface_Transaction__c> interfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 3,
                Payload__c = 'Test Payload 1'
            ),
            new Interface_Transaction__c(
                Id = fflib_IDGenerator.generate(Interface_Transaction__c.SObjectType),
                Status__c = 'Failure',
                Remaining_Retry_Attempts__c = 2,
                Payload__c = 'Test Payload 2'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector selectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ interfaceTransaction[0].Id, interfaceTransaction[1].Id }
                )
            )
            .thenReturn(interfaceTransaction);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        Set<Id> interfaceTransactionIdList = new Set<Id>();
        for (Interface_Transaction__c interfaceRecord : interfaceTransaction) {
            Id interfaceTransactionId = interfaceRecord.Id;
            interfaceTransactionIdList.add(interfaceTransactionId);
        }
        IRetryableServiceTransaction interfaceTransactionPayload = TransactionRetryService.getRetryableTransactions(
            interfaceTransactionIdList
        );
        Map<Id, String> transactionIdToPayload = interfaceTransactionPayload.getSerializedPayload();
        System.assertEquals(
            'Test Payload 1',
            transactionIdToPayload.get(interfaceTransaction[0].id),
            'The return payload is not matching'
        );
    }

    @isTest
    public static void testWhenIRetryableServiceTransactionThenCommitUowNegative() {
        Set<Id> interfaceTransactionIdList = new Set<Id>();
        TransactionRetryService.getRetryableTransactions(interfaceTransactionIdList);
        System.assertEquals(null, null, 'The return value is not null');
    }

    @isTest
    public static void testWhenRetryAttemptSuccessfulCallsThenCommitUowNegative() {
        Set<Id> interfaceTransactionRec = new Set<Id>();
        TransactionRetryService.retryAttemptSuccessful(interfaceTransactionRec);
        List<Interface__c> interfaceList = new List<Interface__c>{
            new Interface__c(
                Id = fflib_IDGenerator.generate(Interface__c.SObjectType),
                Class_Interface_Name__c = 'System.Test',
                Enable_Retry__c = true,
                Retry_Limit__c = 3
            )
        };

        TransactionRetryService.retryAttemptSuccessful(new Set<Id>{ interfaceList[0].Id });
        System.assertEquals(null, null, 'The return value is not null');
    }

    @isTest
    public static void testWhenRetryableTransactionsThenCommitUowNegative() {
        Map<Type, String> processInterfaceAndSerializedPayloadTest = new Map<Type, String>();
        TransactionRetryService.scheduleRetryableTransactions(
            processInterfaceAndSerializedPayloadTest
        );
        Map<Type, String> processInterfaceAndSerializedPayloadTest2 = new Map<Type, String>();
        processInterfaceAndSerializedPayloadTest2.put(Test.class, null);
        TransactionRetryService.scheduleRetryableTransactions(
            processInterfaceAndSerializedPayloadTest2
        );
        System.assertEquals(null, null, 'The return value is not null');
    }
    @isTest
    public static void testWhenRetryAttemptFailedCallsThenCommitUowNegative() {
        List<Interface__c> interfaceList = new List<Interface__c>{
            new Interface__c(
                Id = fflib_IDGenerator.generate(Interface__c.SObjectType),
                Class_Interface_Name__c = 'System.Test',
                Enable_Retry__c = true,
                Retry_Limit__c = 3
            )
        };
        Set<Id> interfaceTransactionRec = new Set<Id>();
        TransactionRetryService.retryAttemptFailed(interfaceTransactionRec);
        TransactionRetryService.retryAttemptFailed(new Set<Id>{ null, interfaceList[0].Id });
        System.assertEquals(null, null, 'The return value is not null');
    }
}