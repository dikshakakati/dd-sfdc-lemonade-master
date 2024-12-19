/**
 * @author Deloitte
 * @date 09/13/2022
 * @description Test class for OpportunityStatusPDOAMappingsSelector class.
 */
@isTest(SeeAllData=false)
private class OpportunityStatusPDOAMappingSelectorTest {
    private static final string NINTEX_MAPPING_NEW_FRANCHISE_UNKNOWN = 'New Franchise - Unknown';
    private static final string NINTEX_MAPPING_NEW_FRANCHISE_UNKNOWN_DEVELOPER_NAME = 'New_Franchise_Unknown';
    private static final String FIELD_TO_REFER = 'CloseDate';
    private static final string OBJECT_TO_REFER = 'Opportunity';
    private static final String OPPORTUNITY_STAGE_NAME = 'Closed Won';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in fields list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the object type must be Opportunity_Status_PDOA_Mapping__mdt metadata';
    private static final String NINTEX_USE_CASE_MISMATCH_ASSERT_MESSAGE = 'Unexepected result: the nintex use case value does not match';
    private static final String NO_OPPORTUNITY_STATUS_TO_PDOA_MAPPINGS_RETURNED_ASSERT_MESSAGE = 'Unexepected result: there were no Opportunity status to PDOA mappings returned';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        OpportunityStatusPDOAMappingsSelector opportunityMappingsSelectorInstance = new OpportunityStatusPDOAMappingsSelector();
        Schema.SObjectType typeOfObject = opportunityMappingsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = opportunityMappingsSelectorInstance.getSObjectFieldList();
        OpportunityStatusPDOAMappingsSelector.newInstance();
        System.assertEquals(
            Opportunity_Status_PDOA_Mapping__mdt.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c,
                Opportunity_Status_PDOA_Mapping__mdt.Field_To_Refer__c,
                Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
                Opportunity_Status_PDOA_Mapping__mdt.Object_To_Refer__c,
                Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
                Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Compare__c,
                Opportunity_Status_PDOA_Mapping__mdt.Operator__c,
                Opportunity_Status_PDOA_Mapping__mdt.Opportunity_Status__c,
                Opportunity_Status_PDOA_Mapping__mdt.Order_Number__c,
                Opportunity_Status_PDOA_Mapping__mdt.Override_Offset_To_Apply__c,
                Opportunity_Status_PDOA_Mapping__mdt.Sub_Type_To_Override__c,
                Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply__c,
                Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply_Type__c,
                Opportunity_Status_PDOA_Mapping__mdt.Value_To_Compare__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Opportunity_Status_PDOA_Mapping__mdt for
     * getting metadata records using passed nintex use case developer names.
     */
    @isTest
    private static void testWhenNintexUseCaseDeveloperNamesPassedThenOppStatusToPDOAMappingReturned() {
        Id opportunityStatusMappingId = fflib_IDGenerator.generate(
            Opportunity_Status_PDOA_Mapping__mdt.SObjectType
        );
        Id pdoaMappingsId = fflib_IDGenerator.generate(Nintex_Work_Order_Mapping__mdt.SObjectType);
        Nintex_Work_Order_Mapping__mdt customMetadataMock = (Nintex_Work_Order_Mapping__mdt) ServiceMockDataBuilder.convertToSObject(
            new Fake(Nintex_Work_Order_Mapping__mdt.class)
                .setField(
                    Nintex_Work_Order_Mapping__mdt.DeveloperName,
                    NINTEX_MAPPING_NEW_FRANCHISE_UNKNOWN_DEVELOPER_NAME
                )
                .setField(
                    Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                    NINTEX_MAPPING_NEW_FRANCHISE_UNKNOWN
                )
                .setField(Nintex_Work_Order_Mapping__mdt.Id, pdoaMappingsId)
                .setChildren(
                    'PDOAMappings__r',
                    new List<Fake>{
                        ServiceMockDataBuilder.createOpportunityStatusPDOAMappingFakeInstance(
                                FIELD_TO_REFER,
                                OBJECT_TO_REFER,
                                OPPORTUNITY_STAGE_NAME,
                                1
                            )
                            .setField(Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c, false)
                            .setField(
                                Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
                                String.valueOf(7)
                            )
                            .setField(
                                Opportunity_Status_PDOA_Mapping__mdt.Id,
                                opportunityStatusMappingId
                            )
                            .setField(
                                Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
                                pdoaMappingsId
                            )
                    }
                )
        );
        Set<String> nintexUseCaseDeveloperNames = new Set<String>{
            NINTEX_MAPPING_NEW_FRANCHISE_UNKNOWN_DEVELOPER_NAME
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunityStatusPDOAMappingsSelector mockOppStatusPDOAMappingSelector = (OpportunityStatusPDOAMappingsSelector) mocks.mock(
            OpportunityStatusPDOAMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOppStatusPDOAMappingSelector.getSObjectType())
            .thenReturn(Opportunity_Status_PDOA_Mapping__mdt.SObjectType);
        mocks.when(
                mockOppStatusPDOAMappingSelector.selectByNintexUseCaseMappings(
                    nintexUseCaseDeveloperNames
                )
            )
            .thenReturn(customMetadataMock.PDOAMappings__r);
        Application.SELECTOR.setMock(mockOppStatusPDOAMappingSelector);
        List<Opportunity_Status_PDOA_Mapping__mdt> opportunityStatusToPDOAMappingsResult = OpportunityStatusPDOAMappingsSelector.newInstance()
            .selectByNintexUseCaseMappings(nintexUseCaseDeveloperNames);
        System.assertEquals(
            true,
            !opportunityStatusToPDOAMappingsResult.isEmpty(),
            NO_OPPORTUNITY_STATUS_TO_PDOA_MAPPINGS_RETURNED_ASSERT_MESSAGE
        );
        System.assertEquals(
            customMetadataMock.Nintex_Use_Case__c,
            opportunityStatusToPDOAMappingsResult[0].Nintex_Mapping__r.Nintex_Use_Case__c,
            NINTEX_USE_CASE_MISMATCH_ASSERT_MESSAGE
        );
    }
}