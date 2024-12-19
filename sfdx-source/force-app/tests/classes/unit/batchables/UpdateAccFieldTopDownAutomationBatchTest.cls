/**
 * @author Deloitte
 * @description This is the test class for UpdateAccountAttributesForTopDownAutomationBatch class
 * @date 23/05/2022
 */
@isTest
private class UpdateAccFieldTopDownAutomationBatchTest {
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenBatchExecutedThenUpdateAccountAttributes() {
        //ARRANGE
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Ultimate Parent')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'Enterprise')
            .setField(Account.Primary_Vertical__c, 'Gifts')
            .setFakeId()
            .toSObject();
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Ultimate_Parent_Account__c, parentAccount.Id)
            .setField(Account.Name, 'Child Store Account')
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setFakeId()
            .toSObject();

        List<Account> accountList = new List<Account>{ parentAccount, storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectAccountAttributesForTopDownAutomationBatch())
            .thenReturn(null);
        mocks.stopStubbing();

        Application.Selector.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(IAccountsService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);

        //ACT
        UpdateAccFieldsTopDownAutomationBatch batch = new UpdateAccFieldsTopDownAutomationBatch();
        batch.start(null);
        batch.execute(null, accountList);
        batch.finish(null);

        //ASSERT
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .updateAccountAttributesTopDownAutomation(accountList);
        ((IAccountsSelector) mocks.verify(accountsSelectorMock, 1))
            .selectAccountAttributesForTopDownAutomationBatch();
    }
}