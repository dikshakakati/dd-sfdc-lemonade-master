/**
 * @description This is a test class created for DisplayActiveXrefsParentWOController.
 * @author Deloitte
 * @date 07/05/2023
 */
@isTest(SeeAllData=false)
private class DisplayActiveXrefsParentWOControllerTest {
    /**
     * @description To test the retrieved fields when get fields method is called.
     */
    @isTest
    private static void testWhenRetriveFieldsFromFieldSetThenReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String jsonData = DisplayActiveXrefsParentWOController.getFields();
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
            'Name',
            dynamicColumn[0].typeAttributes.label.fieldName,
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
            'Salesforce_Account_Name__c',
            dynamicColumn[1].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'businessReferenceHyperlink',
            dynamicColumn[2].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Business_Reference__c',
            dynamicColumn[2].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
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
            'Integration_Status__c',
            dynamicColumn[5].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[5].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Integration Status',
            dynamicColumn[5].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'Integration_Message__c',
            dynamicColumn[6].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[6].type,
            'Unexpected Error: Field Type is not matching'
        );
        System.assertEquals(
            'Integration Message',
            dynamicColumn[6].label,
            'Unexpected Error: Field Label is not matching'
        );
    }

    /**
     * @description To test if active records are retrieved when get get xrefs details method is
     * called from Parent WorkOrder For MarketPlace
     */
    @IsTest
    private static void testWhenGetXrefsRecordsByStoreAccountThenReturnActiveXrefsRecords() {
        Id businessId = Fake.generateId(Account.class);
        Id storeId1 = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);
        Id storeId4 = Fake.generateId(Account.class);
        Id oppId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, 'Marketplace')
            .setField(WorkOrder.Status, 'Planning')
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, oppId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId1,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId2,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId3,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId4,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            )
        };
        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId1)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '5678')
                .setField(Xref__c.Business_GroupID__c, '982356')
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId2)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '881234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId3)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId4)
                .setFakeId()
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector selectorWOMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector selectorXrefMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorWOMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(selectorWOMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(childWorkOrders);
        mocks.when(selectorXrefMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                selectorXrefMock.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeId1, storeId2, storeId3, storeId4 }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefs[0], xrefs[2], xrefs[3] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorWOMock);
        Application.SELECTOR.setMock(selectorXrefMock);
        List<Xref__c> activeXrefs = DisplayActiveXrefsParentWOController.getXrefDetails(
            parentWorkOrder.Id
        );
        System.assertEquals(3, activeXrefs.size(), 'The list size does not match');
        System.assertEquals(activeXrefs[0].BusinessID__c, '1234', 'The value does not match');
        System.assertEquals(
            activeXrefs[1].Business_GroupID__c,
            '881234',
            'The value does not match'
        );
        System.assertEquals(activeXrefs[2].BusinessID__c, '123', 'The value does not match');
    }

    /**
     * @description To test if active records are retrieved when get get xrefs details method is
     * called from Parent WorkOrder For Drive
     */
    @IsTest
    private static void testWhenGetXrefsRecordsByStoreAccountThenReturnActiveXrefsRecordsForDriveWorkOrder() {
        Id businessId = Fake.generateId(Account.class);
        Id oppId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, 'Drive')
            .setField(WorkOrder.Status, 'Planning')
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, oppId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, businessId)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '5678')
                .setField(Xref__c.Business_GroupID__c, '982356')
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Salesforce_Account_Name__c, businessId)
                .setFakeId()
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector selectorWOMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector selectorXrefMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorWOMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(selectorWOMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(selectorXrefMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                selectorXrefMock.selectActiveXrefsBySalesforceAccountName(new Set<Id>{ businessId })
            )
            .thenReturn(new List<Xref__c>{ xrefs[0] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorWOMock);
        Application.SELECTOR.setMock(selectorXrefMock);
        List<Xref__c> activeXrefs = DisplayActiveXrefsParentWOController.getXrefDetails(
            parentWorkOrder.Id
        );
        System.assertEquals(1, activeXrefs.size(), 'The list size does not match');
        System.assertEquals(activeXrefs[0].BusinessID__c, '1234', 'The value does not match');
    }

    /**
     * @description To test if active records are retrieved when get get xrefs details method is
     * called from Parent WorkOrder For Drive
     */
    @IsTest
    private static void testWhenGetXrefsRecordsByStoreAccountThenReturnActiveXrefsRecordsForDrive() {
        Id businessId = Fake.generateId(Account.class);
        Id storeId1 = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);
        Id storeId4 = Fake.generateId(Account.class);
        Id oppId = Fake.generateId(Opportunity.class);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, Fake.generateId(WorkOrder.class))
            .setField(WorkOrder.Type__c, 'Drive')
            .setField(WorkOrder.Status, 'Planning')
            .setField(WorkOrder.AccountId, businessId)
            .setField(WorkOrder.Opportunity__c, oppId);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId1,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId2,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId3,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId4,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = oppId
            )
        };
        Xref__c[] xrefs = new List<Xref__c>{
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '1234')
                .setField(Xref__c.Business_GroupID__c, '981234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId1)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '5678')
                .setField(Xref__c.Business_GroupID__c, '982356')
                .setField(Xref__c.Xref_Status__c, 'Inactive')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId2)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.Business_GroupID__c, '881234')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId3)
                .setFakeId()
                .toSObject(),
            (Xref__c) new Fake(Xref__c.class)
                .setField(Xref__c.BusinessID__c, '123')
                .setField(Xref__c.Xref_Status__c, 'Active')
                .setField(Xref__c.Salesforce_Account_Name__c, storeId4)
                .setFakeId()
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector selectorWOMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector selectorXrefMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorWOMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(selectorWOMock.selectParentAndChildWOsByWorkOrderIds(parentWorkOrder.Id))
            .thenReturn(childWorkOrders);
        mocks.when(selectorXrefMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                selectorXrefMock.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeId1, storeId2, storeId3, storeId4 }
                )
            )
            .thenReturn(new List<Xref__c>{ xrefs[0], xrefs[2], xrefs[3] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorWOMock);
        Application.SELECTOR.setMock(selectorXrefMock);
        List<Xref__c> activeXrefs = DisplayActiveXrefsParentWOController.getXrefDetails(
            parentWorkOrder.Id
        );
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