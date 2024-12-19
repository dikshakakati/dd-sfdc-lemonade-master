/**
 * @author Deloitte
 * @date 04/25/2024
 * @description This is test class for ProductsOptionsSelector class
 */
@isTest(seeAllData=false)
public class ProductOptionsSelectorTest {
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Product Option.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String PRODUCT_OPTION_NAME = 'Test Product Option Name';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ProductOptionsSelector productOptionsSelectorInstance = (ProductOptionsSelector) ProductOptionsSelector.newInstance();
        Schema.SObjectType typeOfObject = productOptionsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = productOptionsSelectorInstance.getSObjectFieldList();
        Mx_Order_Product_Option__c productOptionInstance = new Mx_Order_Product_Option__c(
            Product_Option_Name__c = PRODUCT_OPTION_NAME
        );
        insert productOptionInstance;
        System.assertEquals(
            Schema.Mx_Order_Product_Option__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Mx_Order_Product_Option__c.Id,
                Mx_Order_Product_Option__c.Name,
                Mx_Order_Product_Option__c.Product__c,
                Mx_Order_Product_Option__c.Product_Option_Name__c,
                Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test if the corresponding product options are returned when productBundleIds are sent
     */
    @isTest
    private static void testWhenProductBundleIdsSentThenCorrespondingProductOptionsReturned() {
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Bundle_Name__c = TABLET_BUNDLE_CAN
        );
        insert productBundle;
        Mx_Order_Product_Option__c productOption1 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption1;
        Mx_Order_Product_Option__c productOption2 = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = productBundle.Id
        );
        insert productOption2;
        Test.startTest();
        List<Mx_Order_Product_Option__c> productOptions = ProductOptionsSelector.newInstance()
            .selectProductOptionsByProductBundle(new Set<Id>{ productBundle.Id });
        Test.stopTest();
        System.assertEquals(2, productOptions.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}