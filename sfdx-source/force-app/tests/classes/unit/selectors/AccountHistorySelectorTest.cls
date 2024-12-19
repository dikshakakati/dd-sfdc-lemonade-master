/**
 * @author Aethereus
 * @date 03/07/2024
 * @description Test class for AccountHistorySelector class.
 */
@isTest(seeAllData=false)
private class AccountHistorySelectorTest {


    /**
     * @description Test method for selectAccountHistory method.
     * This method tests the behavior when the method is called with valid parameters.
     */
    @isTest
    Private static void testWhenSelectAccountHistoryThenReturnHistory() {

        Account testAccount = TestDataFactory.createAccount(true);

		List<String> userIds = System.Label.MINT_Upate_Users .split(';');
        List<User> users = [SELECT ID FROM USER WHERE ID IN : userIds];

        List<AccountHistory> accountHistories = AccountHistorySelector.newInstance().selectAccountHistory(
            new Set<String>{'Name'},
            new Set<Id>{testAccount.Id},
            new List<String>{users[0].Id},
            DateTime.now().addDays(-1)
        );

        System.assertNotEquals(1, accountHistories.size(), 'No account history should be returned');
    }


}