/**
 * @author DoorDash
 * @description Test class for the ProcessFlowRequestChunksSelector Selector class
**/
@IsTest
private class ProcessFlowRequestChunksSelectorTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STAGE_ACCOUNT_FILE_UPLOAD = 'Account File Upload';
    private static final String REQUEST_STAGE_WORK_ORDER_TYPE_SELECTION = 'Work Order Type Selection';

    @TestSetup
    static void setupData() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();

        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Enterprise'
        );
        insert parentAccount;

        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Address_Id__c = '12345',
            Legal_Business_Name__c = 'Legal Name LLC',
            Menu_UI_Type__c = ACCOUNT_MENU_UI_TYPE_RETAIL,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            Segment__c = 'Enterprise'
        );
        insert storeAccount;

        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;

        // Create a Process_Flow_Request__c object and insert
        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            Contract__c = contract.Id,
            Stage__c = REQUEST_STAGE_WORK_ORDER_TYPE_SELECTION,
            Status__c = REQUEST_STATUS_IN_PROGRESS
        );
        insert processFlowRequest;

        // Create a chunk record and insert
        Process_Flow_Request_Chunk__c pfrChunk = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 1
        );
        Process_Flow_Request_Chunk__c pfrChunk2 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 2
        );

        insert new List<Process_Flow_Request_Chunk__c>{ pfrChunk, pfrChunk2 };
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ProcessFlowRequestChunksSelector selectorInstance = new ProcessFlowRequestChunksSelector();
        Schema.SObjectType typeOfObj = selectorInstance.getSObjectType();
        System.assertEquals(Schema.Process_Flow_Request_Chunk__c.SObjectType, typeOfObj, 'The object type must match Process_Flow_Request_Chunk__c');

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Process_Flow_Request_Chunk__c.Id,
                Process_Flow_Request_Chunk__c.Name,
                Process_Flow_Request_Chunk__c.CreatedDate,
                Process_Flow_Request_Chunk__c.CreatedById,
                Process_Flow_Request_Chunk__c.LastModifiedDate,
                Process_Flow_Request_Chunk__c.LastModifiedById,
                Process_Flow_Request_Chunk__c.OwnerId,
                Process_Flow_Request_Chunk__c.Chunk_Number__c,
                Process_Flow_Request_Chunk__c.Error_Message__c,
                Process_Flow_Request_Chunk__c.Process_Flow_Request__c,
                Process_Flow_Request_Chunk__c.Serialized_Data__c,
                Process_Flow_Request_Chunk__c.Status__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @IsTest
    static void testWhenQueryingByIdsThenReturnRecords() {
        Map<Id, Process_Flow_Request_Chunk__c> expectedMap = new Map<Id, Process_Flow_Request_Chunk__c>([SELECT Id, Chunk_Number__c, Process_Flow_Request__c FROM Process_Flow_Request_Chunk__c ORDER BY Chunk_Number__c ASC]);

        List<Process_Flow_Request_Chunk__c> actual = ProcessFlowRequestChunksSelector.newInstance().selectById(expectedMap.keySet());
        System.assertEquals(expectedMap.size(), actual.size(), 'The `selectById` method should retrieve all records by their inputted IDs');

        Id parentId = actual[0].Process_Flow_Request__c;
        List<Process_Flow_Request_Chunk__c> actualById = ProcessFlowRequestChunksSelector.newInstance().selectByRequestId(parentId);
        System.assertNotEquals(0, actualById.size(), 'Records should be retrieved by Parent PFR ID');
    }

    @IsTest
    static void testWhenSelectingOpenChunksThenReturnOpenSubsetOfChunks() {
        // Create a Process_Flow_Request__c object and insert
        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            Stage__c = REQUEST_STAGE_ACCOUNT_FILE_UPLOAD,
            Status__c = REQUEST_STATUS_IN_PROGRESS
        );
        insert processFlowRequest;

        // Create a chunk record and insert
        Process_Flow_Request_Chunk__c pfrChunk = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_COMPLETED,
            Chunk_Number__c = 1
        );
        Process_Flow_Request_Chunk__c pfrChunk2 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 2
        );
        Process_Flow_Request_Chunk__c pfrChunk3 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 3
        );
        Process_Flow_Request_Chunk__c pfrChunk4 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = processFlowRequest.Id,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 4
        );

        insert new List<Process_Flow_Request_Chunk__c>{ pfrChunk, pfrChunk2, pfrChunk3, pfrChunk4 };

        List<Process_Flow_Request_Chunk__c> actuals = ProcessFlowRequestChunksSelector.newInstance().selectSubsetOfOpenChunksByRequestId(processFlowRequest.Id, 2);
        System.assertEquals(2, actuals.size(), 'Only two chunks should be returned, per batch size and given that one is already completed.');
        System.assertEquals(2, actuals[0].Chunk_Number__c, 'The first chunk should be #2');
        System.assertEquals(3, actuals[1].Chunk_Number__c, 'The second chunk should be #3');
    }
}