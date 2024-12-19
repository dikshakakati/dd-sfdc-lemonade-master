/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Test class for ApproversServiceImpl.
 */
@isTest(SeeAllData=false)
private class ApproversServiceImplTest {
    private static final String DYNAMIC_APPROVER_NAME = 'Dynamic Approver for user Id: ';

    /*
     * @description It is used to test that new Approvers are created when existing Approvers
     * are not found for the passed user ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUserIdsPassedThenNewApproversCreated() {
        Id newUserId = Fake.generateId(User.class);
        Id existingUserId = Fake.generateId(User.class);
        Id existingApproverId = Fake.generateId(sbaa__Approver__c.class);
        sbaa__Approver__c existingApprovers = (sbaa__Approver__c) new Fake(sbaa__Approver__c.class)
            .setField(sbaa__Approver__c.Id, existingApproverId)
            .setField(sbaa__Approver__c.sbaa__User__c, existingUserId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IApproversSelector mockApproversSelector = (IApproversSelector) mocks.mock(
            IApproversSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockApproversSelector.sObjectType()).thenReturn(sbaa__Approver__c.SObjectType);
        mocks.when(mockApproversSelector.selectByUserIds(new Set<Id>{ newUserId, existingUserId }))
            .thenReturn(new List<sbaa__Approver__c>{ existingApprovers });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockApproversSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ApproversService.createApproversByUserIds(new Set<Id>{ newUserId, existingUserId });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ sbaa__Approver__c.sbaa__User__c => newUserId }
                )
            );
    }

    /*
     * @description It is used to test that new Approvers are not created when existing Approvers
     * are found for the passed user ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenExistingUserIdsPassedThenNewApproversNotCreated() {
        Id newUserId = Fake.generateId(User.class);
        Id existingUserId = Fake.generateId(User.class);
        Id existingApproverId = Fake.generateId(sbaa__Approver__c.class);
        sbaa__Approver__c existingApprovers = (sbaa__Approver__c) new Fake(sbaa__Approver__c.class)
            .setField(sbaa__Approver__c.Id, existingApproverId)
            .setField(sbaa__Approver__c.sbaa__User__c, existingUserId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IApproversSelector mockApproversSelector = (IApproversSelector) mocks.mock(
            IApproversSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockApproversSelector.sObjectType()).thenReturn(sbaa__Approver__c.SObjectType);
        mocks.when(mockApproversSelector.selectByUserIds(new Set<Id>{ existingUserId }))
            .thenReturn(new List<sbaa__Approver__c>{ existingApprovers });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockApproversSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ApproversService.createApproversByUserIds(new Set<Id>{ existingUserId });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ sbaa__Approver__c.sbaa__User__c => newUserId }
                )
            );
    }
}