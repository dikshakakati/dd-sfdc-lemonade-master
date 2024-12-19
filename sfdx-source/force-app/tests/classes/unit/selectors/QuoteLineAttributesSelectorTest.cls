/**
 * @author DoorDash
 * @date 07/06/2022
 * @description Test class for QuoteLineDrawAttributesSelector class
 */
@isTest(seeAllData=false)
public with sharing class QuoteLineAttributesSelectorTest {
    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Quote_Line_Drawer_Attributes__mdt.Id,
            Quote_Line_Drawer_Attributes__mdt.Is_Active__c,
            Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c,
            Quote_Line_Drawer_Attributes__mdt.Field_Label__c,
            Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c,
            Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c,
            Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
            Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c,
            Quote_Line_Drawer_Attributes__mdt.Eligible_for_Product__c,
            Quote_Line_Drawer_Attributes__mdt.Is_Required__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        QuoteLineDrawAttributesSelector mockquoteAttributesMapping = (QuoteLineDrawAttributesSelector) mocks.mock(
            QuoteLineDrawAttributesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockquoteAttributesMapping.getSObjectType())
            .thenReturn(Quote_Line_Drawer_Attributes__mdt.SObjectType);
        mocks.when(mockquoteAttributesMapping.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockquoteAttributesMapping);

        Schema.SObjectType typeOfObject = QuoteLineDrawAttributesSelector.newInstance()
            .SObjectType();
        List<Schema.SObjectField> sObjectFields = QuoteLineDrawAttributesSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Quote_Line_Drawer_Attributes__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Quote Line Attributes Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
	 * @description This method test that attributes are retrieved when product code is passed
	 */
    @isTest
    private static void testWhenProductCodeIsPassedThenSelectQLAttributes() {
        List<Quote_Line_Drawer_Attributes__mdt> qleAttributesData = QuoteLineDrawAttributesSelector.newInstance().selectQLAttributesByProductCode('10080');
        System.assertEquals(true, qleAttributesData.size() > 0, 'Quote Line Attributes exist for 10080');
    }
}