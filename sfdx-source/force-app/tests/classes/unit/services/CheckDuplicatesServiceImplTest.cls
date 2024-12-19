/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Test class for CheckDuplicatesServiceImpl class.
 */
@isTest(SeeAllData=false)
public class CheckDuplicatesServiceImplTest {
    private static final String ACCOUNT_NAME = 'Test Dupe Check Account';
    private static final String ACCOUNT_BILLING_STREET = 'Abcd xyz pqrs st.';
    private static final String ACCOUNT_POSTAL_CODE = '201787';
    private static final String ACCOUNT_TYPE = 'Corporate';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String INVALID_ASSERT_MESSAGE = 'Invalid error message';
    /**
     * @description To test if duplicate records map is returned
     */
    @isTest
    private static void testWhenDuplicatesInsertedThenReturnDuplicateRecordsMap() {
        List<Account> duplicateAccounts = new List<Account>{
            new Account(
                Name = 'Account 1',
                BillingStreet = 'GB Road',
                BillingPostalCode = '1234',
                Type = 'Corporate',
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = 'Account 1',
                BillingStreet = 'GB Road',
                BillingPostalCode = '1234',
                Type = 'Corporate',
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = 'Account 1',
                BillingStreet = 'GB Road',
                BillingPostalCode = '1234',
                Type = 'Corporate',
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = 'Account 1',
                BillingStreet = 'GB Road',
                BillingPostalCode = '1234',
                Type = 'Franchisee',
                Segment__c = ACCOUNT_SEGMENT
            )
        };
        insert duplicateAccounts;

        List<Id> accountIds = new List<Id>{
            duplicateAccounts[0].Id,
            duplicateAccounts[1].Id,
            duplicateAccounts[2].Id,
            duplicateAccounts[3].Id
        };

        Map<Id, List<Account>> originalRecordIdWithDuplicates = CheckDuplicatesService.getMapOfSObjectIdWithDuplicates(
            accountIds,
            'Account_Low_Complexity_Duplicate_Rule'
        );

        System.assertEquals(
            2,
            originalRecordIdWithDuplicates.get(duplicateAccounts[0].Id).size(),
            'Duplicate count does not match'
        );
        System.assertEquals(
            2,
            originalRecordIdWithDuplicates.get(duplicateAccounts[1].Id).size(),
            'Duplicate count does not match'
        );
        System.assertEquals(
            2,
            originalRecordIdWithDuplicates.get(duplicateAccounts[2].Id).size(),
            'Duplicate count does not match'
        );
        System.assertEquals(
            0,
            originalRecordIdWithDuplicates.get(duplicateAccounts[3].Id).size(),
            'Duplicate count does not match'
        );
    }

    /**
     * @description It is used to validate when SObject record having duplicates is passed
     * then error message is returned.
     */
    @isTest
    private static void testWhenDuplicatesFoundThenDuplicateErrorMessageReturned() {
        List<Account> duplicateAccounts = new List<Account>{
            new Account(
                Name = ACCOUNT_NAME,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingPostalCode = ACCOUNT_POSTAL_CODE,
                Type = ACCOUNT_TYPE,
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = ACCOUNT_NAME,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingPostalCode = ACCOUNT_POSTAL_CODE,
                Type = ACCOUNT_TYPE,
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = ACCOUNT_NAME,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingPostalCode = ACCOUNT_POSTAL_CODE,
                Type = ACCOUNT_TYPE,
                Segment__c = ACCOUNT_SEGMENT
            ),
            new Account(
                Name = ACCOUNT_NAME,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingPostalCode = ACCOUNT_POSTAL_CODE,
                Type = ACCOUNT_TYPE,
                Segment__c = ACCOUNT_SEGMENT
            )
        };
        insert duplicateAccounts;
        List<String> accountNames = new List<String>{
            duplicateAccounts[0].Name,
            duplicateAccounts[1].Name,
            duplicateAccounts[2].Name,
            duplicateAccounts[3].Name
        };
        Test.startTest();
        List<Account> matchingAccounts = CheckDuplicatesService.getMatchingSObjectsByDuplicateSObjects(
            duplicateAccounts
        );
        Test.stopTest();
        System.assertEquals(
            matchingAccounts[0].Name == ACCOUNT_NAME,
            accountNames.contains(ACCOUNT_NAME),
            INVALID_ASSERT_MESSAGE
        );

    }
}