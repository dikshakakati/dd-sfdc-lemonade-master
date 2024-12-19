/**
* @description       : RESSMO_Mapping__mdt Selector Test class
* @author            : SamikshaDD
* @group             : DDMx RESSMO - Aethereus
* @last modified on  : 07-30-2024
* @last modified by  : Pankaj
**/

@isTest
public with sharing class RessmoMappingsSelectorTest {

    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be RESSMOMapping custom metadata';
    private static final String ASSERT_MESSAGE_COUNT_NOT_MATCHING = 'assert count not matching';
    private static final String QUOTE = 'Quote';
    private static final String CONTRACT = 'Contract';

    /**
    * @description This method used to test RessmoMappingsSelector class
    */
    @isTest
    private static void testWhenRessmoMappingsSelectorInstantiatesThenCall() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
                RESSMO_Mapping__mdt.Label,
            	RESSMO_Mapping__mdt.MasterLabel,
                RESSMO_Mapping__mdt.DeveloperName,
                RESSMO_Mapping__mdt.Add_to_Request__c,
                RESSMO_Mapping__mdt.Add_to_Update__c,
                RESSMO_Mapping__mdt.API_Property__c,
                RESSMO_Mapping__mdt.Data_Type__c,
                RESSMO_Mapping__mdt.Field_Details__c,
                RESSMO_Mapping__mdt.Field_Name__c,
                RESSMO_Mapping__mdt.Is_Banking__c,
                RESSMO_Mapping__mdt.Is_Required__c,
                RESSMO_Mapping__mdt.JSON_Object__c,
                RESSMO_Mapping__mdt.Object_Name__c,
                RESSMO_Mapping__mdt.Products__c
                };

        RessmoMappingsSelector ressmoMappingsSelectorInstance = new RessmoMappingsSelector();
        Schema.SObjectType typeOfObject = ressmoMappingsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = ressmoMappingsSelectorInstance.getSObjectFieldList();
        RessmoMappingsSelector.newInstance();
        Assert.areEqual(
            RESSMO_Mapping__mdt.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        Assert.areEqual(
            sObjectFieldsMock,
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
    * @description To test RESSMO Mapping selector methods.
    */
    @isTest
    private static void testWhenAllRessmoMappingsThenReturnAllMetaData() {
        List<RESSMO_Mapping__mdt> ressmoMappingResult = RessmoMappingsSelector.newInstance().selectAllRessmoMappings();
        Assert.areEqual([SELECT Id from RESSMO_Mapping__mdt WHERE Applicable_For__c =:QUOTE].size(), ressmoMappingResult.size(), ASSERT_MESSAGE_COUNT_NOT_MATCHING);
    }

    /**
     * @description : Test method to verify the behavior of the selectAddToUpdateRessmoMappings() method in the RessmoMappingsSelector class.
     * It verifies that the method returns a list of RESSMO_Mapping__mdt records where the Add_to_Update__c field is set to true.
     *
     * @isTest
     * @private
     *
     * @see RessmoMappingsSelector#selectAddToUpdateRessmoMappings
     */
    @isTest
    private static void testWhenAddToUpdateRessmoMappingsThenReturnWhereAddToUpdateTrue(){
        List<RESSMO_Mapping__mdt> ressmoMappingResult = RessmoMappingsSelector.newInstance().selectAddToUpdateRessmoMappings();
        Assert.areEqual([SELECT Id from RESSMO_Mapping__mdt WHERE Add_to_Update__c = TRUE AND Applicable_For__c =:QUOTE].size(), ressmoMappingResult.size(), ASSERT_MESSAGE_COUNT_NOT_MATCHING);
    }
    /**
    * @description To test RESSMO Mapping selector methods for Contract.
    */
    @isTest
    private static void testWhenContractRessmoMappingsThenReturnContractMetaData() {
        List<RESSMO_Mapping__mdt> ressmoMappingResult = RessmoMappingsSelector.newInstance().selectRessmoMappingsOfContract();
        Assert.areEqual([SELECT Id from RESSMO_Mapping__mdt WHERE Applicable_For__c =:CONTRACT].size(), ressmoMappingResult.size(), ASSERT_MESSAGE_COUNT_NOT_MATCHING);
    }

}