/**
 * @description       : Test Class for RESSMOUIInputsSelector
 * @author            : SamikshaDD
 * @group             : Aethereus
 * @last modified on  : 10-07-2024
 * @last modified by  : Soumya Dash
**/
@isTest
public with sharing class RESSMOUIInputsSelectorTest {

    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be RESSMOUIInput custom metadata';
    private static final String ASSERT_MESSAGE_APPLICABLE_FIELD_CONTRACT = 'The "Applicable_For__c" field should be "Contract"';
    private static final String ASSERT_MESSAGE_APPLICABLE_FIELD_QUOTE = 'The "Applicable_For__c" field should be "Quote"';
    private static final String APPLICABLE_FOR_CONTRACT = 'Contract';
    private static final String ASSERT_MESSAGE_COUNT_NOT_MATCHING = 'assert count not matching';

    /**
    * @description test When RESSMO UI Inputs Selector Instantiates Then Call
    * @author SamikshaDD | 07-29-2024
    **/
    @isTest
    private static void testWhenRESSMOUIInputsSelectorInstantiatesThenCall() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            RESSMO_UI_Input__mdt.Label,
            RESSMO_UI_Input__mdt.MasterLabel,
            RESSMO_UI_Input__mdt.DeveloperName,
            RESSMO_UI_Input__mdt.Applicable_For__c,
            RESSMO_UI_Input__mdt.Field_API_Name__c,
            RESSMO_UI_Input__mdt.Input_Type__c,
            RESSMO_UI_Input__mdt.Input_UI_Label__c,
            RESSMO_UI_Input__mdt.Object_API_Name__c,
            RESSMO_UI_Input__mdt.Order__c,
            RESSMO_UI_Input__mdt.Validation__c,
            RESSMO_UI_Input__mdt.Section__c,
            RESSMO_UI_Input__mdt.Type__c,
            RESSMO_UI_Input__mdt.UI_Validation_Message__c,
            RESSMO_UI_Input__mdt.Picklist_Values__c
        };

        RESSMOUIInputsSelector ressmoUIInputsSelectorInstance = new RESSMOUIInputsSelector();
        Schema.SObjectType typeOfObject = ressmoUIInputsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = ressmoUIInputsSelectorInstance.getSObjectFieldList();
        RESSMOUIInputsSelector.newInstance();

        Assert.areEqual(
            RESSMO_UI_Input__mdt.SObjectType,
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
    * @description test When RESSMO Ui Inputs Of Contract Then Return
    * @author SamikshaDD | 07-29-2024
    **/
    @isTest
    public static void testWhenRESSMOUiInputsOfContractThenReturn(){

        RESSMO_UI_Input__mdt ressmoUiInputContract = new RESSMO_UI_Input__mdt(
            MasterLabel = 'Test Contract Mapping',
            Applicable_For__c = 'Contract',
            Is_Active__c = true
        );

        List<RESSMO_UI_Input__mdt> ressmoUiInputContractList = RESSMOUIInputsSelector.newInstance().selectRessmoUiInputsOfContract();
        Assert.areEqual(ressmoUiInputContract.Applicable_For__c, ressmoUiInputContractList[0].Applicable_For__c, ASSERT_MESSAGE_APPLICABLE_FIELD_CONTRACT);
    }


    /**
    * @description test When RESSMO Ui Inputs Of Quote Then Return
    * @author SamikshaDD | 07-29-2024
    **/
    @isTest
    public static void testWhenRESSMOUiInputsOfQuoteThenReturn(){

        RESSMO_UI_Input__mdt ressmoUiInputContract = new RESSMO_UI_Input__mdt(
            MasterLabel = 'Test Contract Mapping',
            Applicable_For__c = 'Quote',
            Is_Active__c = true
        );

        List<RESSMO_UI_Input__mdt> ressmoUiInputContractList = RESSMOUIInputsSelector.newInstance().selectRessmoUiInputsOfQuote();
        Assert.areEqual(ressmoUiInputContract.Applicable_For__c, ressmoUiInputContractList[0].Applicable_For__c, ASSERT_MESSAGE_APPLICABLE_FIELD_QUOTE);
    }

    @isTest
    public static void testWhenRESSMOAndOIATTributesThenReturnALLRecords(){

        List<RESSMO_UI_Input__mdt> ressmoUiInputContractList = RESSMOUIInputsSelector.newInstance().selectAllREESMOUIInputContract();
        Assert.areEqual([SELECT Id from RESSMO_UI_Input__mdt WHERE Applicable_For__c =:APPLICABLE_FOR_CONTRACT  AND Is_Active__c = true].size(), ressmoUiInputContractList.size(),ASSERT_MESSAGE_COUNT_NOT_MATCHING );
    }


}