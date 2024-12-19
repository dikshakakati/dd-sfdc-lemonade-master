/**
 * @author Deloitte
 * @date 04/25/2024
 * @description This is test class for ProductBundleSelector class
 */
@isTest(seeAllData=false)
public class ProductBundlesSelectorTest {
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Product Bundle.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String TABLET_BUNDLE_US = 'Tablet Bundle (US)';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ProductBundlesSelector productBundleSelectorInstance = (ProductBundlesSelector) ProductBundlesSelector.newInstance();
        Schema.SObjectType typeOfObject = productBundleSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = productBundleSelectorInstance.getSObjectFieldList();
        Mx_Order_Product_Bundle__c productBundleInstance = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundleInstance;
        System.assertEquals(
            Schema.Mx_Order_Product_Bundle__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Mx_Order_Product_Bundle__c.Id,
                Mx_Order_Product_Bundle__c.Name,
                Mx_Order_Product_Bundle__c.Bundle_Name__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description It checks if the relevant Products are fetched
     * when product names are sent.
     */
    @isTest
    private static void testWhenProductBundleNameThenProductBundleReturned() {
        Mx_Order_Product_Bundle__c productBundle1 = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_CAN
        );
        insert productBundle1;
        Mx_Order_Product_Bundle__c productBundle2 = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_US
        );
        insert productBundle2;
        List<String> productBundleNames = new List<String>{ TABLET_BUNDLE_US, TABLET_BUNDLE_CAN };
        Test.startTest();
        List<Mx_Order_Product_Bundle__c> productBundles = ProductBundlesSelector.newInstance()
            .selectByName(productBundleNames);
        Test.stopTest();
        System.assertEquals(2, productBundles.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}