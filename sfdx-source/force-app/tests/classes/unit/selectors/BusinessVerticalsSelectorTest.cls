/**
 * @author Deloitte
 * @date 11/10/2023
 * @description Test class for BusinessVerticalsSelector class.
 */
@isTest(SeeAllData=false)
public class BusinessVerticalsSelectorTest {
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Business_Vertical__c.';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected result';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        BusinessVerticalsSelector businessVerticalsSelectorInstance = (BusinessVerticalsSelector) BusinessVerticalsSelector.newInstance();
        Schema.SObjectType typeOfObject = businessVerticalsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = businessVerticalsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Business_Vertical__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Business_Vertical__c.Id,
                Business_Vertical__c.Business_Vertical_ID__c,
                Business_Vertical__c.Primary_Vertical__c,
                Business_Vertical__c.Menu_UI_Type__c,
                Business_Vertical__c.Name,
                Business_Vertical__c.Vertical_Name__c,
                Business_Vertical__c.Product__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test that Business Verticals are queried based on the Business Vertical Ids passed.
     */
    @isTest
    public static void testWhenBusinessVerticalIdsPassedThenBusinessVerticalsReturned() {
        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = BUSINESS_VERTICAL_NAME,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME,
            Active__c = true
        );

        insert businessVertical;
        Test.startTest();
        List<Business_Vertical__c> businessVerticals = BusinessVerticalsSelector.newInstance()
            .selectById(new Set<Id>{ businessVertical.Id });
        Test.stopTest();
        System.assertEquals(1, businessVerticals.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description To test that Business Verticals are queried on Marketplace.
     */
    @isTest
    public static void testWhenBusinessVerticalIsQueriedThenForMarketplace() {
        List<Business_Vertical__c> businessVertical = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = BUSINESS_VERTICAL_NAME,
                Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
                Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
                Product__c = PRODUCT_MARKETPLACE,
                Vertical_Name__c = VERTICAL_NAME,
                Active__c = true
            )
        };
        insert businessVertical;
        Test.startTest();
        BusinessVerticalsSelector businessVerSelectorTest = new BusinessVerticalsSelector();
        List<Business_Vertical__c> businessVerticalsList = businessVerSelectorTest.selectBusinessVerticalRecords();
        Test.stopTest();
        System.assertEquals(1, businessVerticalsList.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test records for Menu UI Type from Business Verticals are queried on Marketplace.
     */
    @isTest
    public static void testWhenBusinessVerticalIsQueriedThenForMenuUIType() {
        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = BUSINESS_VERTICAL_NAME,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME,
            Active__c = true
        );
        insert businessVertical;
        Test.startTest();
        BusinessVerticalsSelector businessVerSelectorTest = new BusinessVerticalsSelector();
        Business_Vertical__c businessVerticals = businessVerSelectorTest.selectMenuUITypeByBusinessVerticalIds(
            businessVertical.id
        );
        Test.stopTest();
        System.assertEquals(
            MENU_UI_TYPE_RETAIL,
            businessVerticals.Menu_UI_Type__c,
            'The expected Menu UI Type were not fetched in the selector.'
        );
    }
    /**
     * @description test Business Verticals are queried for SSMO.
     */
    @isTest
    public static void testWhenNamePassedThenBusinessVertical() {
        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = 'Rx',
            Primary_Vertical__c = 'Rx',
            Menu_UI_Type__c = 'Restaurant',
            Product__c = 'MarketPlace',
            Vertical_Name__c = 'Rx',
            Active__c = true
        );
        insert businessVertical;
        Test.startTest();
        List<Business_Vertical__c> businessVerticals = BusinessVerticalsSelector.newInstance()
            .selectBusinessVerticalByName('Rx');
        Test.stopTest();
        System.assertEquals(1, businessVerticals.size(), INVALID_ASSERT_MESSAGE);
    }
}