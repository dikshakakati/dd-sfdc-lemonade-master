/**
 * @author ATG
 * @date 10/10/23
 * @description Test Class to check if Opportunity Line Items are Mapped to Briefs correctly
 */
@isTest(SeeAllData = false)
public class OpportunityToBriefMappingSelectorTest {
    @isTest
    public static void testWhenClassInstantiatesThenValidateSObjectType(){
        List<Opportunity_to_Brief_Item_Mapping__mdt> mockCustomMetaData = new List<Opportunity_to_Brief_Item_Mapping__mdt>{
            new Opportunity_to_Brief_Item_Mapping__mdt(
                MasterLabel = 'Campaign TLDR',
                DeveloperName = 'Campaign_TLDR',
                BriefFieldAPIName__c = 'Campaign_TLDR__c',
                OpportunityFieldAPIName__c = 'Campaign_TLDR__c'

            )
        };

        List<Schema.SOBjectField> mockSObjectFields = new List<Schema.SObjectField>{
            Opportunity_to_Brief_Item_Mapping__mdt.BriefFieldAPIName__c,
            Opportunity_to_Brief_Item_Mapping__mdt.OpportunityFieldAPIName__c

        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunityToBriefMappingSelector oppBriefMappingMock = (OpportunityToBriefMappingSelector) mocks.mock(OpportunityToBriefMappingSelector.class);
        //Mock Creation End

        mocks.startStubbing();
        mocks.when(oppBriefMappingMock.getSObjectType()).thenReturn(Opportunity_to_Brief_Item_Mapping__mdt.SObjectType);
        mocks.when(oppBriefMappingMock.getAllValues()).thenReturn(mockCustomMetaData);
        mocks.when(oppBriefMappingMock.getSObjectFieldList()).thenReturn(mockSObjectFields);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(oppBriefMappingMock);
        Schema.SObjectType typeOfObject = OpportunityToBriefMappingSelector.newInstance().getSObjectType();
        List<Schema.SObjectField> sObjectFields = OpportunityToBriefMappingSelector.newInstance().getSObjectFieldList();
        List<Opportunity_to_Brief_Item_Mapping__mdt> allMetaDataFields = OpportunityToBriefMappingSelector.newInstance().getAllValues();
        Set<Schema.SObjectField> oppFieldSet = OpportunityToBriefMappingSelector.newInstance().getOpportunityFieldSet();
        List<Schema.SObjectField> briefFieldList = OpportunityToBriefMappingSelector.newInstance().getBriefFieldsList();

        System.assertEquals(typeOfObject,Opportunity_to_Brief_Item_Mapping__mdt.SObjectType, 'Custom MetaData Type not correct');
        System.assertNotEquals(sObjectFields[0],null, 'SObjectFields not Mocked correctly');
        System.assertNotEquals(allMetaDataFields,null, 'Custom MetaData not Mocked correctly');
        System.assertNotEquals(oppFieldSet,null, 'QuoteLine Fields not Mocked correctly');
        System.assertNotEquals(briefFieldList[0],null, 'Brief ItemFields not Mocked correctly');

    }
}