/**
 * @author Deloitte
 * @date 04/18/2024
 * @description Test class used to cover TimeZoneCalculationServiceImpl
 */
@isTest
private class TimeZoneCalculationServiceImplTest {
    static final String TEST_ACCOUNT_NAME = 'Test Account';
    static final String TEST_LEAD_NAME = 'Test Lead';
    static final String TIME_ZONE_BACKEND_VALUE = 'America/New_York';
    static final String INVALID_TIME_ZONE_MESSAGE = 'Invalid Time Zone';
    static final String TIME_ZONE_ABBREVIATION_EDT = 'EDT';
    static final String GET_TIME_ZONE_DIFFERENCE_HOURS = 'System should return the difference in hours between the logged in user\'s time zone and the system time zone.';
    /**
     * @description To test if the Time Zone abbereviation is returned for Accounts.
     */
    @isTest
    private static void testWhenGetTimeZoneForAccountThenReturnTimeZoneAbbreviation() {
        Id accountId = Fake.generateId(Account.class);
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = TEST_ACCOUNT_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_VALUE
            )
        };
        TimeZoneCalculationService.calculateTimeZone(newAccounts);
        System.assertEquals(
            TIME_ZONE_ABBREVIATION_EDT,
            newAccounts[0].Time_Zone__c,
            INVALID_TIME_ZONE_MESSAGE
        );
    }

    /**
     * @description To test if the Time Zone abbereviation is returned for Leads.
     */
    @isTest
    private static void testWhenGetTimeZoneForLeadThenReturnTimeZoneAbbreviation() {
        Id leadId = Fake.generateId(Lead.class);
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                LastName = TEST_LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_VALUE
            )
        };
        TimeZoneCalculationService.calculateTimeZone(newLeads);
        System.assertEquals(
            TIME_ZONE_ABBREVIATION_EDT,
            newLeads[0].Time_Zone__c,
            INVALID_TIME_ZONE_MESSAGE
        );
    }
    /**
     * @description Get timezone different hour for the logged in user.
     */
    @isTest
    private static void testWhenGetDifferenceHoursThenReturnUserProfileAndSystemTime() {
        System.assertEquals(
            true,
            (TimeZoneConversion.getTimeZoneOffSets()).size() > 0,
            GET_TIME_ZONE_DIFFERENCE_HOURS
        );
    }
}