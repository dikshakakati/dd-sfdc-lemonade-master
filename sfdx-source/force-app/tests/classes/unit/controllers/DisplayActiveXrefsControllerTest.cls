/**
 * @description This is a test class created for DisplayActiveXrefController.
 * @author Deloitte
 * @date 17/03/2023
 */
@isTest(SeeAllData=false)
private class DisplayActiveXrefsControllerTest {
    /**
     * @description To test when segment is Enterprise then return default fields and their attributes.
     */
    @isTest
    private static void testWhenSegmentIsEnterpriseThenRetriveandReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String segment = 'Enterprise';
        String jsonData = DisplayActiveXrefController.getFields(segment);
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'mintStorePageHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'MINT_Store_Page__c',
            dynamicColumn[0].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT',
            dynamicColumn[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'merchantPortalHyperlink',
            dynamicColumn[1].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Merchant_Portal__c',
            dynamicColumn[1].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Mx Portal',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'BusinessID__c',
            dynamicColumn[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BizID',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'mintBusinessPageHyperlink',
            dynamicColumn[3].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Mint_BusinessPage__c',
            dynamicColumn[3].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT BizID',
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
            'Source',
            dynamicColumn[4].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'Account_Type__c',
            dynamicColumn[5].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[5].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Type',
            dynamicColumn[5].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'businessReferenceHyperlink',
            dynamicColumn[6].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[6].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Business_Reference__c',
            dynamicColumn[6].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Business Reference',
            dynamicColumn[6].label,
            'Unexpected Error: Field Label is not matching'
        );
    }
     /**
     * @description To test when segment is SMB then return default fields and their attributes
     */
    @isTest
    private static void testWhenSegmentIsSMBThenRetriveandReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String segment = 'SMB';
        String jsonData = DisplayActiveXrefController.getFields(segment);
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'mintStorePageHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'MINT_Store_Page__c',
            dynamicColumn[0].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT',
            dynamicColumn[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'merchantPortalHyperlink',
            dynamicColumn[1].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Merchant_Portal__c',
            dynamicColumn[1].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Mx Portal',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'onlineOrderingStorePageHyperlink',
            dynamicColumn[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Online_Ordering_Store_Page__c',
            dynamicColumn[2].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Store OO Tool',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'BusinessID__c',
            dynamicColumn[3].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BizID',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'mintBusinessPageHyperlink',
            dynamicColumn[4].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[4].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Mint_BusinessPage__c',
            dynamicColumn[4].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT BizID',
            dynamicColumn[4].label,
            'Unexpected Error: Field Label is not matching'
        );
       System.assertEquals(
            'onlineOrderingBusinessPageHyperlink',
            dynamicColumn[5].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[5].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Online_Ordering_Business_Page__c',
            dynamicColumn[5].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Biz OO Tool',
            dynamicColumn[5].label,
            'Unexpected Error: Field Label is not matching'
        );

        System.assertEquals(
            'External_ID_Source__c',
            dynamicColumn[6].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[6].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Source',
            dynamicColumn[6].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'Account_Type__c',
            dynamicColumn[7].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[7].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Type',
            dynamicColumn[7].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'businessReferenceHyperlink',
            dynamicColumn[8].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[8].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Business_Reference__c',
            dynamicColumn[8].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Business Reference',
            dynamicColumn[8].label,
            'Unexpected Error: Field Label is not matching'
        );
    }

    /**
     * @description To test if active records are retrieved when get get xrefs details method is called.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenGetXrefsRecordsByStoreAccountThenReturnActiveXrefsRecords() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Id parentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = storeRecordTypeId,
                ParentId = parentId
            )
        };
        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '881234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector selectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(selectorMock.selectActiveXrefsByAccountId(newAccounts[0].Id))
            .thenReturn(new List<Xref__c>{ xrefs[0], xrefs[2], xrefs[3] });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Xref__c> activeXrefs = DisplayActiveXrefController.getXrefDetails(newAccounts[0].Id);
        System.assertEquals(3, activeXrefs.size(), 'The list size does not match');
        System.assertEquals(activeXrefs[0].BusinessID__c, '1234', 'The value does not match');
        System.assertEquals(
            activeXrefs[1].Business_GroupID__c,
            '881234',
            'The value does not match'
        );
        System.assertEquals(activeXrefs[2].BusinessID__c, '123', 'The value does not match');
    }
}