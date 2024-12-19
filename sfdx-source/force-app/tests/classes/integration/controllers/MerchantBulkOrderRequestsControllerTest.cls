/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Test class for MerchantBulkOrderRequestsController
 */
@isTest(SeeAllData=false)
private class MerchantBulkOrderRequestsControllerTest{
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_NAME_BUACC = 'BuAcc';
    private static final String ACCOUNT_NAME_STACC = 'StAcc';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String BUSINESS_ACCOUNT = 'Business Account';
    private static final String CONTACT = 'Contact';
    private static final String CONTACT_FIRST_NAME = 'Test FirstName';
    private static final String CONTACT_LAST_NAME = 'Test LastName';
    private static final String CONTACT_EMAIL = 'test@test.com';
    private static final String DOCUMENT_PATH = '/';
    private static final String DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR = 'Tablet_Net_New_No_Error';
    private static final String DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR = 'Tablet_Return_IMEI_Error';
    private static final String DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR = 'Tablet_Return_Required_Field_Error';
    private static final String DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR = 'Tablet_Return_Restricted_Picklist_Error';
    private static final String DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR = 'Tablet_Return_Cell_Value_Count_Error';
    private static final String DOCUMENT_EXTENSION = '.csv';
    private static final String FAILURE_NO_ERROR_TO_BE_RETURNED = 'Failure - No error should be returned!';
    private static final String FAILURE_ERROR_TO_BE_RETURNED = 'Failure - Error should be returned!';
    private static final String FAILURE_IMEI_ERROR_TO_BE_RETURNED = 'Failure - Error should have \'IMEI\' clause in it!';
    private static final String FAILURE_REQUIRED_ERROR_TO_BE_RETURNED = 'Failure - Error should have \'Required\' clause in it!';
    private static final String FAILURE_RESTRICTED_ERROR_TO_BE_RETURNED = 'Failure - Error should have \'Restricted\' clause in it!';
    private static final String FAILURE_CELL_VALUE_COUNT_ERROR_TO_BE_RETURNED = 'Failure - Error should have \'CSV contains data without column header\' clause in it!';
    private static final String REFERENCE_TYPE_TABLET = 'Tablet';
    private static final String REF_REQ_TYPE_NET_NEW = 'Net-New';
    private static final String REF_REQ_TYPE_RETURN = 'Return';
    private static final String STORE_ACCOUNT = 'Store Account';
    private static final String STRING_CSV_CONTAINS_DATA_WITHOUT_COLUMN_HEADER = 'CSV contains data without column header';
    private static final String STRING_IMEI = 'IMEI';
    private static final String STRING_REQUIRED = 'Required';
    private static final String STRING_RESTRICTED = 'Restricted';
    private static final String STRING_STORE_ACCOUNT_TO_BE_REPLACED = '{StoreId}';
    private static final String STRING_BUSINESS_ACCOUNT_TO_BE_REPLACED = '{BusinessId}';
    private static final String STRING_CONTACT_TO_BE_REPLACED = '{ContactId}';

    private static Id businessAccountId;
    private static Id storeAccountId;
    private static Id contactId;

    @testSetup
    private static void setupData(){
        String csvAsString = '';
        Map<String, Blob> csvNameToBodyAsStringMappings = new Map<String, Blob>();

        insert new List<Account>{
            new Account(Name = ACCOUNT_NAME_STACC, RecordTypeId = STORE_RECORD_TYPE_ID, Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(Name = ACCOUNT_NAME_BUACC, RecordTypeId = BUSINESS_RECORD_TYPE_ID, Segment__c = ACCOUNT_SEGMENT_SMB)
        };

        insert new Contact(
            AccountId = businessAccountId,
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Email = CONTACT_EMAIL
        );

        Map<String, String> typeIdsMap = fetchAccountIds();
        for(StaticResource staticResourceInstance : [Select Name, Body From StaticResource
                                                     Where Name = :DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR
                                                     Or Name = :DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR
                                                     Or Name = :DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR
                                                     Or Name = :DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR
                                                     Or Name = :DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR]){
            csvAsString = staticResourceInstance.Body.toString().replace(STRING_STORE_ACCOUNT_TO_BE_REPLACED, typeIdsMap.get(STORE_ACCOUNT))
                                                                .replace(STRING_BUSINESS_ACCOUNT_TO_BE_REPLACED, typeIdsMap.get(BUSINESS_ACCOUNT))
                                                                .replace(STRING_CONTACT_TO_BE_REPLACED, typeIdsMap.get(CONTACT));
            csvNameToBodyAsStringMappings.put(staticResourceInstance.Name, Blob.valueOf(csvAsString));
        }

        insert new List<Staging_Bulk_Upload_Reference__c>{
            new Staging_Bulk_Upload_Reference__c(Type__c = REFERENCE_TYPE_TABLET, Request_Type__c = REF_REQ_TYPE_NET_NEW),
            new Staging_Bulk_Upload_Reference__c(Type__c = REFERENCE_TYPE_TABLET, Request_Type__c = REF_REQ_TYPE_RETURN)
        };

        insert new List<ContentVersion>{
            new ContentVersion(Title = DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR, PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR + DOCUMENT_EXTENSION, VersionData = csvNameToBodyAsStringMappings.get(DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR)),
            new ContentVersion(Title = DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR, PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR + DOCUMENT_EXTENSION, VersionData = csvNameToBodyAsStringMappings.get(DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR)),
            new ContentVersion(Title = DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR, PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR + DOCUMENT_EXTENSION, VersionData = csvNameToBodyAsStringMappings.get(DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR)),
            new ContentVersion(Title = DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR, PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR + DOCUMENT_EXTENSION, VersionData = csvNameToBodyAsStringMappings.get(DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR)),
            new ContentVersion(Title = DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR, PathOnClient = DOCUMENT_PATH + DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR + DOCUMENT_EXTENSION, VersionData = csvNameToBodyAsStringMappings.get(DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR))
        };
    }

    /**
    * @description Tests if error message is returned when correct file is uploaded
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenCorrectFileIsUploadedThenNoSystemValidationErrorIsThrown(){
        List<String> errors;
        Test.startTest();
        errors = MerchantBulkOrderRequestsController.createStagingRecords(fetchRequests(REFERENCE_TYPE_TABLET, REF_REQ_TYPE_NET_NEW, DOCUMENT_TITLE_TABLET_NET_NEW_NO_ERROR));
        Test.stopTest();

        System.assertEquals(0, errors.size(), FAILURE_NO_ERROR_TO_BE_RETURNED);
    }

    /**
    * @description Tests if custom error message (related to IMEI custom validation) is returned when incorrect file is uploaded
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenIncorrectFileIsUploadedThenCustomValidationErrorIsThrown(){
        List<String> errors;
        Test.startTest();
        errors = MerchantBulkOrderRequestsController.createStagingRecords(fetchRequests(REFERENCE_TYPE_TABLET, REF_REQ_TYPE_RETURN, DOCUMENT_TITLE_TABLET_RETURN_IMEI_ERROR));
        Test.stopTest();

        System.assertEquals(errors.size() > 0, true, FAILURE_ERROR_TO_BE_RETURNED);
        System.assertEquals(errors[0].containsIgnoreCase(STRING_IMEI), true, FAILURE_IMEI_ERROR_TO_BE_RETURNED);
    }

    /**
    * @description Tests if custom error message (related to required field custom validation) is returned when incorrect file is uploaded
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenIncorrectFileIsUploadedThenRequiredFieldCustomValidationErrorIsThrown(){
        List<String> errors;
        Test.startTest();
        errors = MerchantBulkOrderRequestsController.createStagingRecords(fetchRequests(REFERENCE_TYPE_TABLET, REF_REQ_TYPE_RETURN, DOCUMENT_TITLE_TABLET_RETURN_REQUIRED_FIELD_ERROR));
        Test.stopTest();

        System.assertEquals(errors.size() > 0, true, FAILURE_ERROR_TO_BE_RETURNED);
        System.assertEquals(errors[0].containsIgnoreCase(STRING_REQUIRED), true, FAILURE_REQUIRED_ERROR_TO_BE_RETURNED);
    }

    /**
    * @description Tests if custom error message (related to restricted picklist system validation) is returned when incorrect file is uploaded
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenIncorrectFileIsUploadedThenRestrictedPicklistSystemValidationErrorIsThrown(){
        List<String> errors;
        Test.startTest();
        errors = MerchantBulkOrderRequestsController.createStagingRecords(fetchRequests(REFERENCE_TYPE_TABLET, REF_REQ_TYPE_RETURN, DOCUMENT_TITLE_TABLET_RETURN_RESTRICTED_PICKLIST_ERROR));
        Test.stopTest();

        System.assertEquals(errors.size() > 0, true, FAILURE_ERROR_TO_BE_RETURNED);
        System.assertEquals(errors[0].containsIgnoreCase(STRING_RESTRICTED), true, FAILURE_RESTRICTED_ERROR_TO_BE_RETURNED);
    }

    /**
    * @description Tests if custom error message (related to value count in any row of the csv validation) is returned when incorrect file is uploaded
    * @jira #LEM-15978
    */
    @isTest
    private static void testWhenIncorrectFileIsUploadedThenCellValueCountErrorIsThrown(){
        List<String> errors;
        Test.startTest();
        errors = MerchantBulkOrderRequestsController.createStagingRecords(fetchRequests(REFERENCE_TYPE_TABLET, REF_REQ_TYPE_RETURN, DOCUMENT_TITLE_TABLET_RETURN_CELL_VALUE_COUNT_ERROR));
        Test.stopTest();

        System.assertEquals(errors.size() > 0, true, FAILURE_ERROR_TO_BE_RETURNED);
        System.assertEquals(errors[0].containsIgnoreCase(STRING_CSV_CONTAINS_DATA_WITHOUT_COLUMN_HEADER), true, FAILURE_CELL_VALUE_COUNT_ERROR_TO_BE_RETURNED);
    }

    /**
    * @description Fetches Store & Business Account Ids and Contact Id for the file to be uplaoded
    * @jira #LEM-15978
    * @return Map<String, String>
    */
    private static Map<String, String> fetchAccountIds(){
        String businessAccountId, storeAccountId, contactId;
        Map<String, String> accountIdToTypes = new Map<String, String>();
        businessAccountId = [Select Id From Account Where RecordTypeId = :BUSINESS_RECORD_TYPE_ID Limit 1][0].Id;
        storeAccountId = [Select Id From Account Where RecordTypeId = :STORE_RECORD_TYPE_ID Limit 1][0].Id;
        contactId = [Select Id From Contact Limit 1][0].Id;

        accountIdToTypes.put(STORE_ACCOUNT, storeAccountId);
        accountIdToTypes.put(BUSINESS_ACCOUNT, businessAccountId);
        accountIdToTypes.put(CONTACT, contactId);

        return accountIdToTypes;
    }

    /**
    * @description Creates list of MerchantBulkOrderRequestsController.Requests to pass on to the main apex method
    * @jira #LEM-15978
    * @param referenceType
    * @param referenceRequestType
    * @param documentTitle
    * @return List<MerchantBulkOrderRequestsController.Requests>
    */
    private static List<MerchantBulkOrderRequestsController.Requests> fetchRequests(
        String referenceType,
        String referenceRequestType,
        String documentTitle
    ) {
        MerchantBulkOrderRequestsController.Requests request = new MerchantBulkOrderRequestsController.Requests();
        List<MerchantBulkOrderRequestsController.Requests> inputRequests = new List<MerchantBulkOrderRequestsController.Requests>();
        List<Staging_Bulk_Upload_Reference__c> relatedStagingReferences = [Select Id, Type__c, Request_Type__c
                                                                              From Staging_Bulk_Upload_Reference__c
                                                                              Where Type__c = :referenceType And Request_Type__c = :referenceRequestType Limit 1];
        request.referenceRecordId = relatedStagingReferences[0].Id;
        request.referenceType = relatedStagingReferences[0].Type__c;
        request.referenceRequestType = relatedStagingReferences[0].Request_Type__c;
        request.contentDocumentIds = new List<String>{[Select Id, Title, ContentDocumentId From ContentVersion Where Title = :documentTitle][0].ContentDocumentId};
        inputRequests.add(request);
        return inputRequests;
    }
}