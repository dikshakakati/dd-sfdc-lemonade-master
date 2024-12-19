/**
 * @author atg
 * @date 05/23/2022
 * @description This is test class for creating standard objects that will be used in tests.
 */
@isTest
@SuppressWarnings(
    'PMD.ClassNamingConventions'
) // PMD rules are requiring test classes to end in 'Test'
public class TestDataFactory {
    /**
     * @description Creates an Account record for test purposes using the default values
     *
     * @param doInsert (Boolean)
     * @return Account
     */
    public static Account createAccount(Boolean doInsert) {
        Account newAccount = new Account(Name = 'Test Account', Segment__c = 'Enterprise');
        if (doInsert) {
            insert newAccount;
        }
        return newAccount;
    }

    /**
     * @description Creates an User record for test purposes using the default values
     *
     * @param doInsert (Boolean)
     * @return User
     */
    public static User createUser(Boolean doInsert) {
        Profile systemAdminProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
        User newUser = new User(
            Alias = 'Test',
            Email = 'Doordash' + Datetime.now().getTime() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'DoordashUser',
            LanguageLocaleKey = 'en_US',
            ProfileId = systemAdminProfile.Id,
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'Doordash' + Datetime.now().getTime() + '@test.com'
        );
        if (doInsert) {
            insert newUser;
        }
        return newUser;
    }
}