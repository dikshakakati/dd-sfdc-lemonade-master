/**
 * @description Test class for the DisplayAccountsController class
**/
@IsTest
private class DisplayAccountsControllerTest {
    @IsTest
    private static void testWhenCallingFetchAccountsThenReturnList() {
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);

        Account fakeAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.Name, 'Fake 1')
            .toSObject();

        Account fakeAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.Name, 'Fake 2')
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        Set<String> fieldsToQuery = new Set<String>{
            'Hours_of_Operation__c',
            'Legal_Business_Name__c',
            'Shopping_Protocol__c'        
        };

        mocks.startStubbing();
            mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelectorMock.selectFilteredAccount(fieldsToQuery, new List<Id>{accountId1, accountId2})).thenReturn(new List<Account>{ fakeAccount1, fakeAccount2 });
        mocks.stopStubbing();
        
        Application.SELECTOR.setMock(accountSelectorMock);

        List<Account> results = DisplayAccountsController.fetchAccountResultsList(new List<Id>{accountId1, accountId2});

        System.assertEquals(results.size(), 2, 'The list should Contain 2 Accounts');
    }
}