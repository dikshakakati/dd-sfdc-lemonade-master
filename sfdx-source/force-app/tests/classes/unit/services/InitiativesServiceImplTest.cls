/**
 * @author Deloitte
 * @date 25/11/2022
 * @description Test class for InitiativesServiceImpl class.
 */
@isTest(seeAllData=false)
private class InitiativesServiceImplTest {
    /**
     * @description Tests when Initiatives are provided then IsParentAccountMerged field set to True.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInitiativesAreProvidedThenIsParentAccountMergedFieldSetToTrue() {
        Initiative__c initiative1 = (Initiative__c) new Fake(Initiative__c.class)
            .setFakeId()
            .setField(Initiative__c.Is_Parent_Account_Merged__c, false)
            .toSObject();

        Initiative__c initiative2 = (Initiative__c) new Fake(Initiative__c.class)
            .setFakeId()
            .setField(Initiative__c.Is_Parent_Account_Merged__c, false)
            .toSObject();

        List<Initiative__c> initiatives = new List<Initiative__c>{ initiative1, initiative2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InitiativesService.processMergedAccountsRelatedRecords(initiatives);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Initiative__c.Id => initiative1.Id,
                        Initiative__c.Is_Parent_Account_Merged__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Initiative__c.Id => initiative2.Id,
                        Initiative__c.Is_Parent_Account_Merged__c => true
                    }
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReparentedOpportunitiesAreProvidedThenExceptionIsThrown() {
        Initiative__c initiative1 = (Initiative__c) new Fake(Initiative__c.class)
            .setFakeId()
            .setField(Initiative__c.Is_Parent_Account_Merged__c, false)
            .toSObject();

        Initiative__c initiative2 = (Initiative__c) new Fake(Initiative__c.class)
            .setFakeId()
            .setField(Initiative__c.Is_Parent_Account_Merged__c, false)
            .toSObject();

        List<Initiative__c> initiatives = new List<Initiative__c>{ initiative1, initiative2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);

        try {
            InitiativesService.processMergedAccountsRelatedRecords(initiatives);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }
}