/**
 * @author Deloitte
 * @date 05/21/2024
 * @description This is test class for CPQProductOptionsSelector class
 */
@isTest
public class CPQProductOptionsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Product Option.';
    private static final String LIST_SIZE_ERROR_MESSAGE = 'Lists size does not match.';
    private static final String PRODUCT_OPTION_DELIVERY = 'Delivery';
    private static final String PRODUCT_OPTION_PICKUP = 'Pickup';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        CPQProductOptionsSelector productOptionSelectorInstance = new CPQProductOptionsSelector();

        Schema.SObjectType typeOfObj = productOptionSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = productOptionSelectorInstance.getSObjectFieldList();

        CPQProductOptionsSelector.newInstance();

        System.assertEquals(
            Schema.SBQQ__ProductOption__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                SBQQ__ProductOption__c.Id,
                SBQQ__ProductOption__c.SBQQ__ConfiguredSKU__r.Name,
                SBQQ__ProductOption__c.SBQQ__OptionalSKU__r.Name
            },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test when Product Names are passed then Product Options with have
     * Optional SKU as the Product Name returned.
     */
    @isTest
    private static void testWhenProductNamesPassedThenProductOptionsReturned() {
        Product2 product1 = CPQTestDataFactory.createProduct(true);
        product1.Name = PRODUCT_OPTION_DELIVERY;
        update product1;
        Product2 product2 = CPQTestDataFactory.createCoDProduct(true);
        product2.Name = PRODUCT_OPTION_PICKUP;
        update product2;
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = product2.Id,
            SBQQ__OptionalSKU__c = product1.Id,
            SBQQ__Number__c = 10
        );
        insert productOption;
        List<SBQQ__ProductOption__c> productOptionsList = new CPQProductOptionsSelector()
            .selectByProductNames(
                new Set<String>{ PRODUCT_OPTION_DELIVERY },
                new Set<String>{ PRODUCT_OPTION_PICKUP }
            );
        System.assertEquals(1, productOptionsList.size(), LIST_SIZE_ERROR_MESSAGE);
    }
}