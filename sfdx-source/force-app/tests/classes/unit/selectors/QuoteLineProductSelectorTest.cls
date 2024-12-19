/**
 * @author DoorDash
 * @date 07/06/2022
 * @description Test class for QuoteLineProductsMappingSelector class
 */
@isTest(seeAllData=false)
public with sharing class QuoteLineProductSelectorTest {
    @isTest
    private static void testWhenGetAllProductsThenReturnAppropriateValues() {
        List<Quote_Line_Drawer_Products__mdt> allQLEProductData = QuoteLineProductsMappingSelector.newInstance()
            .getAllActiveQuoteLineProducts();
        System.assertEquals(
            true,
            allQLEProductData.size() > 0,
            'Custom metadata records are not matching with actual Vs Expected'
        );
    }
    @isTest
    private static void testWhenQueryProductsThenReturnAttributesValues() {
        List<Quote_Line_Drawer_Products__mdt> allQLEProductData = QuoteLineProductsMappingSelector.newInstance()
            .selectQLProductsWithAttributes();
        System.assertEquals(true, allQLEProductData.size() > 0, 'Quote Line Products exist');
        System.assertEquals(
            true,
            allQLEProductData[0].Quote_Line_Drawer_Attributes__r.size() > 0,
            'Quote Line Products has Quote LineAttrbutes'
        );
    }
    @isTest
    static void testWhenQueryingRecordsThenItShouldIncludeTheDefaultFields() {
        List<Schema.SObjectField> expectedFields = new List<Schema.SObjectField>{
            Quote_Line_Drawer_Products__mdt.Id,
            Quote_Line_Drawer_Products__mdt.Is_Active__c,
            Quote_Line_Drawer_Products__mdt.Product_Code__c
        };

        List<Schema.SObjectField> actualFields = QuoteLineProductsMappingSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            expectedFields,
            actualFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    @isTest
    static void testWhenQueryingRecordsThenItShouldQueryTheCorrectSObject() {
        Schema.SObjectType typeOfObject = QuoteLineProductsMappingSelector.newInstance()
            .SObjectType();

        System.assertEquals(
            Quote_Line_Drawer_Products__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Quote Line Products Mapping Metadata'
        );
    }

    @isTest
    private static void testWhenSelectQLProductsThenRequiredAttributesByProductCode() {
        Set<String> productCodes = new Set<String>{ '10019' };
        List<Quote_Line_Drawer_Products__mdt> allQLEProductData = QuoteLineProductsMappingSelector.newInstance()
            .selectQLProductsWithRequiredAttributesByProductCode(productCodes);
        System.assertEquals(true, allQLEProductData.size() > 0, 'Quote Line Products exist');
        System.assertEquals(
            true,
            allQLEProductData[0].Quote_Line_Drawer_Attributes__r.size() > 0,
            'Quote Line Products has Quote LineAttrbutes'
        );
    }
}