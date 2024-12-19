/**
 * @author Deloitte
 * @date 15/03/2022
 * @description This is a test class for DisplayWorkOrdersRelatedList.
 */
@isTest(SeeAllData=false)
private class DisplayWorkOrdersControllerTest {
    /**
     * @description To test the retrieved fields when get fields method is called.
     */
    @isTest
    private static void testWhenRetriveFieldsFromFieldSetThenReturnDefaultFieldsAndTheirAttributesInJsonFormat() {
        String jsonData = DisplayWorkOrdersController.getFields();
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'workOrderNumberHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'WorkOrderNumber',
            dynamicColumn[0].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Work Order Number',
            dynamicColumn[0].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'workOrderNameHyperlink',
            dynamicColumn[1].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Work_Order_Name__c',
            dynamicColumn[1].typeAttributes.label.fieldName,
            'Unexpected Error: Field Name is not matching'
        );
        System.assertEquals(
            'Work Order Name',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Status',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Type',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[4].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Proposed Date of Activation',
            dynamicColumn[4].label,
            'Unexpected Error: Field Label is not matching'
        );
    }

    /**
     * @description To test if unique records are retrieved when get parent work orders method is called.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenGetWorkOrdersRecordsByStoreAccountAndOpportunityThenReturnUniqueParentWorkOrderRecords() {
        Id businessId = Fake.generateId(Account.class);
        Id storeId = Fake.generateId(Account.class);
        Id oppId = Fake.generateId(Opportunity.class);

        WorkOrder[] parentWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = businessId,
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = businessId,
                Opportunity__c = oppId
            )
        };

        WorkOrder[] childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId,
                ParentWorkOrder = parentWorkOrders[0],
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Drive',
                Status = 'Planning',
                AccountId = storeId,
                ParentWorkOrder = parentWorkOrders[0],
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId,
                ParentWorkOrder = parentWorkOrders[1],
                Opportunity__c = oppId
            ),
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = 'Marketplace',
                Status = 'Planning',
                AccountId = storeId,
                ParentWorkOrder = parentWorkOrders[1],
                Opportunity__c = oppId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector selectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(selectorMock.selectWorkOrdersByAccountId(storeId)).thenReturn(childWorkOrders);
        mocks.when(selectorMock.selectWorkOrdersByOpportunityId(oppId)).thenReturn(parentWorkOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        List<WorkOrder> uniqueWorkOrders = DisplayWorkOrdersController.getWorkOrderDetails(
            storeId
        );
        List<WorkOrder> uniqueWorkOrdersForOpp = DisplayWorkOrdersController.getWorkOrderDetails(
            oppId
        );
        System.assertEquals(2, uniqueWorkOrders.size(), 'The list size does not match');
        System.assertEquals(
            parentWorkOrders[0].Id,
            uniqueWorkOrders[0].Id,
            'The work order id does not match'
        );
        System.assertEquals(
            parentWorkOrders[1].Id,
            uniqueWorkOrders[1].Id,
            'The work order id does not match'
        );
        System.assertEquals(2, uniqueWorkOrdersForOpp.size(), 'The list size does not match');
        System.assertEquals(
            parentWorkOrders[0].Id,
            uniqueWorkOrdersForOpp[0].Id,
            'The work order id does not match'
        );
        System.assertEquals(
            parentWorkOrders[1].Id,
            uniqueWorkOrdersForOpp[1].Id,
            'The work order id does not match'
        );
    }
}