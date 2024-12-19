/**
 * @author Deloitte
 * @date 12/13/2023
 * @description Test class for DisplayRelatedStoresInformationCtrl.
 */
@isTest(SeeAllData=false)
private class DisplayRelatedStoresInformationCtrlTest {
    private static final String ERROR_MESSAGE = 'Unexpected Error: Values do not match.';
    private static final String COLUMNS_TO_DISPLAY_STATIC_CONFIG = 'RelatedStoresInformationColumnsViewOrder';

    /**
     * @description To test the retrieved field values when getFields method is called.
     */
    @isTest
    private static void testWhenGetFieldsMethodCalledThenReturnColumnsWithCorrectFieldsAndAtrributes() {
        String jsonData = DisplayRelatedStoresInformationCtrl.getFields();
        List<DynamicColumn> dynamicColumns = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        String columnsToDisplay = StaticConfigurationsSelector.newInstance()
            .getInstanceValue(COLUMNS_TO_DISPLAY_STATIC_CONFIG)
            .Configuration_Value__c;
        for (DynamicColumn eachDynamicColumn : dynamicColumns) {
            System.assertEquals(
                true,
                columnsToDisplay.contains(eachDynamicColumn.label),
                ERROR_MESSAGE
            );
        }
    }

    /**
     * @description To test if account details are retrieved when getAccountDetails method is called.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenGetAccountRecordsByParentWorkOrderThenReturnStoreRecords() {
        Id parentWorkOrderId = Fake.generateId(WorkOrder.class);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                Merchant_Supplied_ID__c = '789',
                RecordTypeId = storeRecordTypeId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                Merchant_Supplied_ID__c = '456',
                RecordTypeId = storeRecordTypeId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectRelatedStoreAccountsInformation(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(newAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        List<Account> relatedAccounts = DisplayRelatedStoresInformationCtrl.getAccountDetails(
            parentWorkOrderId
        );
        System.assertEquals(2, relatedAccounts.size(), ERROR_MESSAGE);
        System.assertEquals(relatedAccounts[0].Name, 'Test 1', ERROR_MESSAGE);
        System.assertEquals(relatedAccounts[1].Name, 'Test 2', ERROR_MESSAGE);
        System.assertEquals(relatedAccounts[0].Merchant_Supplied_ID__c, '789', ERROR_MESSAGE);
        System.assertEquals(relatedAccounts[1].Merchant_Supplied_ID__c, '456', ERROR_MESSAGE);
    }
}