/**
 * @description This is a test class created for DisplayUniqueXrefController.
 * @author Deloitte
 * @date 17/05/2022
 */
@isTest(SeeAllData=false)
private class DisplayUniqueXrefControllerTest {
    /**
     * @description To test when segment is Enterprise then return default fields and their attributes.
     */
    @isTest
    private static void testWhenSegmentIsEnterpriseThenRetriveandReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String segment = 'ENT';
        String jsonData = DisplayUniqueXrefController.getFields(segment);
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'merchantBusinessPageHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Mint_BusinessPage__c',
            dynamicColumn[0].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT',
            dynamicColumn[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Mx Portal',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BGID',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Source',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[4].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BizName',
            dynamicColumn[4].label,
            'Unexpected Error: Field Label is not matching'
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
            'Unexpected Error: Field Type is not matching'
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
     * @description To test when segment is SMB then return default fields and their attributes.
     */
    @isTest
    private static void testWhenSegmentIsSMBThenRetriveandReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String segment = 'SMB';
        String jsonData = DisplayUniqueXrefController.getFields(segment);
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'merchantBusinessPageHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Mint_BusinessPage__c',
            dynamicColumn[0].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'MINT',
            dynamicColumn[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Mx Portal',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'onlineOrderingBusinessPageHyperlink',
            dynamicColumn[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Online_Ordering_Business_Page__c',
            dynamicColumn[2].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Biz OO Tool',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BGID',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
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
            'string',
            dynamicColumn[5].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'BizName',
            dynamicColumn[5].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[6].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Type',
            dynamicColumn[6].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'businessReferenceHyperlink',
            dynamicColumn[7].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[7].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Business_Reference__c',
            dynamicColumn[7].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Business Reference',
            dynamicColumn[7].label,
            'Unexpected Error: Field Label is not matching'
        );

    }

    /**
     * @description To test unique xrecords are getting for a business account
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingForXrefRecordssWithABusinessAccountThenReturnUniqueXrefRecords() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();

        Id parentId = Fake.generateId(Account.class);

        Account[] newAccounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentId
            )
        };
        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '881234')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Salesforce_Account_Name__c, newAccounts[0].Id)
                .setFakeId()
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector selectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(selectorMock.selectAllInAccountHierarchy(newAccounts[0].Id)).thenReturn(xrefs);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Xref__c> selectedXrefs = DisplayUniqueXrefController.getXrefDetails(newAccounts[0].Id);
        System.assertEquals(3, selectedXrefs.size(), 'The list size does not match');
        System.assertEquals(selectedXrefs[0].BusinessID__c, '1234', 'The value does not match');
        System.assertEquals(
            selectedXrefs[1].Business_GroupID__c,
            '881234',
            'The value does not match'
        );
        System.assertEquals(selectedXrefs[2].BusinessID__c, '123', 'The value does not match');
    }

    /**
     * @description To check for ultimate parent by aggregating all child unique xref records.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRequestingToAggregateChildXrefRecordsInBusinessAccountHierarchyThenUniqueXrefRecordsAreReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account ultimateBusinessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Ultimate Business')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account parentBusinessAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, ultimateBusinessAccount.Id)
            .setField(Account.Name, 'Parent Business')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();
        Account childAccount = (Account) new Fake(Account.class)
            .setField(Account.ParentId, parentBusinessAccount.Id)
            .setField(Account.Name, 'Child Accoount')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setFakeId()
            .toSObject();

        Id parentId = Fake.generateId(Account.class);

        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Salesforce_Account_Name__c, ultimateBusinessAccount.Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Salesforce_Account_Name__c, ultimateBusinessAccount.Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '976231')
                .setField(Xref__c.Salesforce_Account_Name__c, parentBusinessAccount.Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '123456')
                .setField(Xref__c.Salesforce_Account_Name__c, childAccount.Id)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '123456')
                .setField(Xref__c.Salesforce_Account_Name__c, childAccount.Id)
                .setFakeId()
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector selectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(selectorMock.selectAllInAccountHierarchy(ultimateBusinessAccount.Id))
            .thenReturn(xrefs);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        List<Xref__c> selectedXrefs = DisplayUniqueXrefController.getXrefDetails(
            ultimateBusinessAccount.Id
        );
        System.assertEquals(3, selectedXrefs.size(), 'The list size does not match');
        System.assertEquals(selectedXrefs[0].BusinessID__c, '1234', 'The value does not match');
        System.assertEquals(selectedXrefs[1].BusinessID__c, '976231', 'The value does not match');
        System.assertEquals(
            selectedXrefs[2].Business_GroupID__c,
            '123456',
            'The value does not match'
        );
    }
}