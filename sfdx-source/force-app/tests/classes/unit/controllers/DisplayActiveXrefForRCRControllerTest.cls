/**
 * @description This is a test class created for DisplayActiveXrefForRateChangeRequest.
 * @author Deloitte
 * @date 27/09/2023
 */
@isTest(SeeAllData=false)
private class DisplayActiveXrefForRCRControllerTest {
    /**
     * @description To test the retrieved fields when get fields method is called.
     */
    @isTest
    private static void testWhenRetriveFieldsFromFieldSetThenReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String jsonData = DisplayActiveXrefForRCRController.getFields();
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'xrefHyperLink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Xref Name',
            dynamicColumn[0].label,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'accountNameHyperLink',
            dynamicColumn[1].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Salesforce Account Name',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'Integration_Status__c',
            dynamicColumn[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Integration Status',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'External_ID__c',
            dynamicColumn[3].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'External ID',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'External_ID_Source__c',
            dynamicColumn[4].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[4].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'External Source',
            dynamicColumn[4].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'BusinessID__c',
            dynamicColumn[5].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[5].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Business ID',
            dynamicColumn[5].label,
            'Unexpected Error: Field Label is not matching'
        );
    }

    /**
     * @description To test if active records are retrieved when get get xrefs details method is
     * called from Parent WorkOrder For MarketPlace
     */
    @IsTest
    private static void testWhenGetXrefsRecordsByStoreAccountThenReturnActiveXrefsRecords() {
        Id storeId1 = Fake.generateId(Account.class);
        Id rcrId = Fake.generateId(Rate_Change_Request__c.class);
        Id xrefId = Fake.generateId(Xref__c.class);

        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.ID, xrefId)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId1)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, storeId1)
                        .setField(Account.Rate_Change_Request__c, rcrId)
                )
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IXrefsSelector selectorXrefMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();

        mocks.when(selectorXrefMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(selectorXrefMock.selectRelatedRateChangeIds(new Set<Id>{ rcrId }))
            .thenReturn(new List<Xref__c>{ xrefs[0] });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorXrefMock);
        List<Xref__c> activeXrefs = DisplayActiveXrefForRCRController.getXrefDetails(rcrId);
        System.assertEquals(1, activeXrefs.size(), 'The list size does not match');
    }
}