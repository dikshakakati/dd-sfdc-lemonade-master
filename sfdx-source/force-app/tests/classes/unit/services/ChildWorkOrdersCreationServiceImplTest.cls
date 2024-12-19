/**
 * @author Deloitte
 * @date 06/16/2024
 * @description Test class for AccountsForChildWorkOrderCreationSrvImpl class.
 */
@isTest
private class ChildWorkOrdersCreationServiceImplTest {
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String ACTIVATED_CENTRALLY_NO = 'No';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC = 'Automatic';
    private static final String EMAIL_ORDER_PROTOCOL = 'Email';
    private static final String DISALLOW_PDOX_OVERRIDE_YES = 'Yes';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String MENU_SET_UP_METHOD_NONE = 'None - Menu Setup Complete';
    private static final String MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String WORK_ORDER_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to register child Work Order';
    private static final String TEST_OWNER_EMAIL = 'test@test.com';
    private static final String TYPE_POS = 'POS';
    private static final String WORK_ORDER_ACCOUNT_ID_FIELD = 'AccountId';
    private static final String WORK_ORDER_STATUS_CONFIRMED = 'Confirmed';
    private static final String WORK_ORDER_TYPE = 'Marketing Kit';

    /**
     * @description To test when Parent Marketing Kit is created then associate store Accounts
     * to Parent Marketing Kit WorkOrder.
     */
    @isTest
    private static void testWhenMarketingKitWorkOrdersCreatedThenAssociateStores(){
        Id originatingWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id marketingKitWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        Fake fakeStoreAccountInstance = new Fake(Account.class)
            .setField(Account.Activated_Centrally_AC__c,ACTIVATED_CENTRALLY_NO)
            .setField(Account.Menu_Setup_Method__c,MENU_SET_UP_METHOD_NONE)
            .setField(Account.Menu_to_be_Completed_By__c,MENU_TO_BE_COMPLETED_BY)
            .setField(Account.Order_Protocol__c,EMAIL_ORDER_PROTOCOL)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(
                Account.Data_Verification_Status__c,
                ACCOUNT_DATA_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOM_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.User_Sets_PDOT_Value__c, DISALLOW_PDOX_OVERRIDE_YES)
            .setField(Account.OwnerId, ownerId)
            .setParent(
                'Owner',
                new Fake(User.class)
                    .setField(User.Id, ownerId)
                    .setField(User.Email, TEST_OWNER_EMAIL)
            );
        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id,marketingKitWorkOrderId)
            .setField(WorkOrder.Originating_Work_Order__c,originatingWorkOrderId)
            .setField(WorkOrder.Bundled_with_Marketplace__c,BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Opportunity__c,opportunityId)
            .setField(WorkOrder.Status,WORK_ORDER_STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c,WORK_ORDER_TYPE)
            .setField(WorkOrder.Business_to_Store_Assignment__c,BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC)
            .setField(WorkOrder.Contract__c,contractId)
            .SetField(WorkOrder.OwnerId,ownerId)
            .SetField(WorkOrder.Proposed_Date_of_Activation__c,System.today())
            .SetField(WorkOrder.Proposed_Date_of_Tablet__c,System.today())
            .SetField(WorkOrder.Proposed_Date_of_Tablet__c,System.today())
        .toSObject();
         WorkOrder fakeChildWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
             .setField(WorkOrder.Id,fflib_IDGenerator.generate(WorkOrder.SObjectType))
             .setField(WorkOrder.ParentWorkOrderId,originatingWorkOrderId)
        	 .setParent('Account',fakeStoreAccountInstance)
             .toSObject();
        Map<Id,WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder = new Map<Id,WorkOrder> {
            originatingWorkOrderId => fakeWorkOrder
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id> {originatingWorkOrderId}))
            .thenReturn(new List<WorkOrder> {fakeChildWorkOrder});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Test.startTest();
        ChildWorkOrdersCreationService.initiateStoreAssociationOnMarketingKitWorkOrder(
            originatingWorkOrderIdToMarketingKitWorkOrder
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasChildWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == storeAccountId;
        System.assertEquals(
            true,
            hasChildWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Parent Marketing Kit is created and has no associated store Accounts
     * then No store association happens.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketingKitWorkOrderCreatedByOriginatingWorkOrderWithoutAssociatedStoresThenDoNotAssociateStores(){
        Id originatingWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id marketingKitWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id,marketingKitWorkOrderId)
            .setField(WorkOrder.Originating_Work_Order__c,originatingWorkOrderId)
            .setField(WorkOrder.Bundled_with_Marketplace__c,BUNDLED_WITH_MARKETPLACE_YES)
            .setField(WorkOrder.Opportunity__c,opportunityId)
            .setField(WorkOrder.Status,WORK_ORDER_STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c,WORK_ORDER_TYPE)
            .setField(WorkOrder.Business_to_Store_Assignment__c,BUSINESS_TO_STORE_ASSIGNMENT_AUTOMATIC)
            .setField(WorkOrder.Contract__c,contractId)
            .SetField(WorkOrder.OwnerId,ownerId)
            .SetField(WorkOrder.Proposed_Date_of_Activation__c,System.today())
            .SetField(WorkOrder.Proposed_Date_of_Tablet__c,System.today())
            .SetField(WorkOrder.Proposed_Date_of_Tablet__c,System.today())
        .toSObject();
        Map<Id,WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder = new Map<Id,WorkOrder> {
            originatingWorkOrderId => fakeWorkOrder
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ChildWorkOrdersCreationService.initiateStoreAssociationOnMarketingKitWorkOrder(
            originatingWorkOrderIdToMarketingKitWorkOrder
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}