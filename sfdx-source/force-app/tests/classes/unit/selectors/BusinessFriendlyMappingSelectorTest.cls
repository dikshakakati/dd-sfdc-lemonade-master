/**
 * @description This is test class for BusinessFriendlyMappingSelector class
 * update: 10/18/23: added new field Order__c to the class & test class
 */
@isTest
public with sharing class BusinessFriendlyMappingSelectorTest {

    /**
     * @description This method used to test BusinessFriendlyMappingSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        BusinessFriendlyMappingSelector selector = new BusinessFriendlyMappingSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        Assert.areEqual(
            new List<Schema.SObjectField>{
                Business_Friendly_Mapping__mdt.Order__c,
                Business_Friendly_Mapping__mdt.Active__c,
                Business_Friendly_Mapping__mdt.MasterLabel,
                Business_Friendly_Mapping__mdt.DeveloperName,
                Business_Friendly_Mapping__mdt.Message_Category__c,
                Business_Friendly_Mapping__mdt.Integration_Type__c,
                Business_Friendly_Mapping__mdt.Integration_Key_String__c,
                Business_Friendly_Mapping__mdt.Business_Friendly_Message__c
            },
            fieldList,
            ' Mismatch in field list'
        );
        Assert.areEqual(Schema.Business_Friendly_Mapping__mdt.SObjectType, typeOfObj, 'The object type must be Business Friendly Mapping');
    }

    @isTest
    private static void testWhenSelectByIntegrationTypeInvokedThenReturnTestRecord() {
        BusinessFriendlyMappingSelector selector = new BusinessFriendlyMappingSelector();
        List<Business_Friendly_Mapping__mdt> businessFriendlyMappings = selector.selectByIntegrationType('Test Type');
        Integer businnessFriendlyMappingCount = businessFriendlyMappings.size();
        String businessFriendlyMessage = 'Test Business Friendly Message';
        Assert.areEqual(1, businnessFriendlyMappingCount, 'Business Friendly Message Test count is not as expected');
        Assert.areEqual(businessFriendlyMessage, businessFriendlyMappings[0].Business_Friendly_Message__c, 'Test Business Friendly Mapping message is not as expected');
    }
}