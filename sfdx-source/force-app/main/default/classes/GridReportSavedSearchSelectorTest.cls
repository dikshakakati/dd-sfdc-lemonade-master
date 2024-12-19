/**
 * @author CriticlRiver
 * @date Sept 2024
 * @description Test class for GridReportSavedSearchSelectorTest, To Fetch the saved report filters
 */
@isTest
public without sharing class GridReportSavedSearchSelectorTest {
    public static final String TEST_DD_RUN_USERNAME = 'test.runninguser@doordash.com';
    /**
     * @description Prepare and return the test running user
     * @return User Should return the user object record
     */
    private static User getTestRunUser() {
        User testRunUser = null;
        for (User u : [SELECT Id FROM User WHERE UserName = :TEST_DD_RUN_USERNAME]){
            testRunUser = u;
        }
        if (testRunUser == null){
            testRunUser = TestDataFactory.createUser(false);
            testRunUser.Username = TEST_DD_RUN_USERNAME;
        }
        return testRunUser;
    }

    @IsTest
    static void testWhenGetDDGridReportSavedSearchThenForReportByUser(){
        System.runAs(getTestRunUser()){
            DD_Grid_Report_Saved_Search__c savedSearch = new DD_Grid_Report_Saved_Search__c();
            savedSearch.Report_Name__c = 'Figment_Support_Report';
            savedSearch.Config__c = 'Test Config';
            savedSearch.Name = 'Test Save Search';
            insert savedSearch;

            List<DD_Grid_Report_Saved_Search__c> expectedSaveSearch = GridReportSavedSearchSelector.newInstance().getDDGridReportSavedSearchForReportByUser(UserInfo.getUserId(), 'Figment_Support_Report');
            System.assertEquals(1, expectedSaveSearch.size(), 'Number of Save Search records are not same as expected.');
            System.assertEquals(expectedSaveSearch[0].Id, savedSearch.Id, 'Save Search record Id is not same as expected.');
        }
    }
}