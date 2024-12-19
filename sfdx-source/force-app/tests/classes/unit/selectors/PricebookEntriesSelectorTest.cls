/**
 * @author Deloitte
 * @date 05/21/2024
 * @description This is test class for PricebookEntriesSelector class
 */
@isTest
public class PricebookEntriesSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be PricebookEntry.';
    private static final String USD_CURRENCY = 'USD';
    private static final String LIST_SIZE_ERROR_MESSAGE = 'Lists size does not match.';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final DECIMAL UNIT_PRICE = 0;
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        PricebookEntriesSelector pricebookEntriesSelectorInstance = new PricebookEntriesSelector();

        Schema.SObjectType typeOfObj = pricebookEntriesSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = pricebookEntriesSelectorInstance.getSObjectFieldList();

        PricebookEntriesSelector.newInstance();

        System.assertEquals(
            Schema.PricebookEntry.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ PricebookEntry.Id, PricebookEntry.Product2Id },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test when Product Names and Currency are passed then PricebookEntries
     * having same Product and Currency returned.
     */
    @isTest
    private static void testWhenProductNamesAndCurrencyPassedThenPricebookEntriesReturned() {
        Product2 product = CPQTestDataFactory.createProduct(true);
        product.Name = PRODUCT_MARKETPLACE;
        update product;
        PricebookEntry pricebookEntry = CPQTestDataFactory.createPriceBookEntry(
            product,
            USD_CURRENCY,
            true
        );
        pricebookEntry.UnitPrice = UNIT_PRICE;
        update pricebookEntry;
        List<PricebookEntry> pricebookEntriesList = new PricebookEntriesSelector()
            .selectByProductNamesAndCurrency(new Set<String>{ PRODUCT_MARKETPLACE }, USD_CURRENCY);
        System.assertEquals(1, pricebookEntriesList.size(), LIST_SIZE_ERROR_MESSAGE);
    }
}