@isTest(SeeAllData = false)
public class QuoteLineBriefItemMappingSelectorTest {
    @isTest
    public static void testWhenQuoteLineIsUpdatedThenValidateFields(){
        //Mock Creation
        List<Quote_Line_to_Brief_Item_Mapping__mdt> mockCustomMetaData = new List<Quote_Line_to_Brief_Item_Mapping__mdt>{
            new Quote_Line_to_Brief_Item_Mapping__mdt(
                MasterLabel = 'Keywords',
                DeveloperName = 'Keywords',
                BriefItemFieldAPIName__c = 'Sponsored_Listing_Terms__c',
                QuoteLineFieldAPIName__c = 'Keywords__c'
            )
        };

        List<Schema.SOBjectField> mockSObjectFields = new List<Schema.SObjectField>{
            Quote_Line_to_Brief_Item_Mapping__mdt.BriefItemFieldAPIName__c,
            Quote_Line_to_Brief_Item_Mapping__mdt.QuoteLineFieldAPIName__c

        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        QuoteLineBriefItemMappingSelector quoteLineBriefItemMappingMock = (QuoteLineBriefItemMappingSelector) mocks.mock(QuoteLineBriefItemMappingSelector.class);
        //Mock Creation End

        mocks.startStubbing();
        mocks.when(quoteLineBriefItemMappingMock.getSObjectType()).thenReturn(Quote_Line_to_Brief_Item_Mapping__mdt.SObjectType);
        mocks.when(quoteLineBriefItemMappingMock.getAllValues()).thenReturn(mockCustomMetaData);
        mocks.when(quoteLineBriefItemMappingMock.getSObjectFieldList()).thenReturn(mockSObjectFields);
        // mocks.when(quoteLineBriefItemMappingMock.getQuoteLineFieldSet()).thenReturn();
        // mocks.when(quoteLineBriefItemMappingMock.getBriefItemFieldsList()).thenReturn();
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quoteLineBriefItemMappingMock);
        Schema.SObjectType typeOfObject = QuoteLineBriefItemMappingSelector.newInstance().getSObjectType();
        List<Schema.SObjectField> sObjectFields = QuoteLineBriefItemMappingSelector.newInstance().getSObjectFieldList();
        List<Quote_Line_to_Brief_Item_Mapping__mdt> allMetaDataFields = QuoteLineBriefItemMappingSelector.newInstance().getAllValues();
        Set<Schema.SObjectField> quoteLineFieldSet = QuoteLineBriefItemMappingSelector.newInstance().getQuoteLineFieldSet();
        List<Schema.SObjectField> briefItemFieldsList = QuoteLineBriefItemMappingSelector.newInstance().getBriefItemFieldsList();

        System.assertEquals(typeOfObject,Quote_Line_to_Brief_Item_Mapping__mdt.SObjectType, 'Custom MetaData Type not correct');
        System.assertNotEquals(sObjectFields[0],null, 'SObjectFields not Mocked correctly');
        System.assertNotEquals(allMetaDataFields,null, 'Custom MetaData not Mocked correctly');
        System.assertNotEquals(quoteLineFieldSet,null, 'QuoteLine Fields not Mocked correctly');
        System.assertNotEquals(briefItemFieldsList[0],null, 'Brief ItemFields not Mocked correctly');
    }

}