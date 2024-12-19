/**
 * @author BizApps
 * @date 4-September-2023
 * @description Test class for BulkStoreOnboardingBatch class.
 **/
@IsTest
private class BulkStoreOnboardingBatchTest {
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final Id BULK_STORE_ONBOARDING_RECORD_TYPE_ID = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Bulk_Store_Onboarding')
        .getRecordTypeId();
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String BUSINESS_ERROR_LOG_TYPE = 'BUSINESS_ERROR';
    private static final String CONTACT_EMAIL = 'test@BulkStoreOnboardingBatchTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String COMMA_SEPARATOR = ',';
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String GOOGLE_SHEET_URL = 'https://docs.google.com/spreadsheets/test';
    private static final String LOG_ERROR_MESSAGE_FOR_FAILED_STORES = 'The stores listed in the table below could not be added to the Work Order due to address verification issues. Please review and update the addresses for these stores. Once this is completed, click the "Retry" button to proceed with onboarding these stores.';
    private static final String LOG_RECORD_METHOD_NAME = 'BulkStoreOnboardingBatch.finish';
    private static final String OPPORTUNITY_NAME = 'McDonald Test';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String PRIMARY_VERTICAL = 'Alcohol';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STATUS_FAILED = 'Failed';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String UPLOAD_COMPLETE = 'Upload Complete';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORKORDER_SUBTYPE_COO = 'COO';
    private static final String WO_TYPE_MARKETPLACE = 'Marketplace';
    private static final String PROCESSING_STORES = 'Processing Stores';
    private static final String SERIALIZED_ENTITLEMENTS_DATA = '{"selected":[{"productSubId":[{"productName":"Pickup","productId":"a21O20000006sLtIAI"},{"productName":"Delivery","productId":"a21O20000006tRdIAI"},{"productName":"Cx Delivery Fee","productId":"a21O20000006tTFIAY"}],"packageName":"Marketplace","packageId":"a21O20000004LXJIA2"},{"productSubId":[{"productName":"Mx Delivery Fee","productId":"a21O20000006tZhIAI"}],"packageName":"Self-Delivery","packageId":"a21O20000004LXKIA2"},{"productSubId":[{"productName":"Pickup","productId":"a21O20000006sNVIAY"},{"productName":"Alcohol Delivery","productId":"a21O20000006tcvIAA"}],"packageName":"Storefront","packageId":"a21O20000004LXLIA2"},{"productSubId":[],"packageName":"Drive","packageId":"a21O20000004LXNIA2"},{"productSubId":[{"productName":"Regulatory Fee","productId":"a21O20000006vJlIAI"},{"productName":"Caviar Weblinks","productId":"a21O20000006vEvIAI"}],"packageName":"Caviar","packageId":"a21O20000004LXMIA2"}],"deselected":[{"selectedPackageId":"a21O20000004LXJIA2","productDeselected":["a21O20000006sP7IAI"]},{"selectedPackageId":"a21O20000004LXKIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXLIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXNIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXMIA2","productDeselected":[]}]}';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String MENU_TO_BE_COMPLETED_BY_MX = 'Merchant';

    @IsTest
    static void testWhenFlowRequestDataIsSetThenUpdateStoresInBulk() {
        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = PROCESSING_STORES,
            RecordTypeId = BULK_STORE_ONBOARDING_RECORD_TYPE_ID,
            OwnerId = UserInfo.getUserId()
        );
        insert flowRequest;

        Account bizAccount = new Account(
            Name = 'Test Business',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Commission_Calculation_Methodology__c = 'DoorDash Platform Price',
            BillingCountryCode = 'US',
            Control_of_Price__c = 'DoorDash',
            Primary_Vertical__c = 'Alcohol',
            Segment__c = 'Enterprise'
        );
        insert bizAccount;

        Account storeAccount = new Account(
            Name = 'Test Store',
            ParentId = bizAccount.Id,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            BillingCountryCode = 'US',
            Commission_Calculation_Methodology__c = 'DoorDash Platform Price',
            Control_of_Price__c = 'DoorDash',
            Bulk_Corporate_Onboarding_Request__c = flowRequest.Id,
            Segment__c = 'Enterprise'
        );
        insert storeAccount;

        // Insert a Contact related to the Business Account
        Contact businessContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'testcontact@BulkStoreOnboardingBatchTest.com',
            AccountId = bizAccount.Id
        );
        insert businessContact;

        Opportunity parentOpportunity = new Opportunity(
            AccountId = bizAccount.Id,
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(14),
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard'
        );
        insert parentOpportunity;

        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = bizAccount.Id,
            Status = 'Planning',
            Opportunity__c = parentOpportunity.Id,
            Type__c = WO_TYPE_MARKETPLACE,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MX,
            Activated_Centrally_AC__c = 'Yes',
            Proposed_Date_of_Activation__c = getNonWeekendDate(System.today().addDays(14)),
            Proposed_Date_of_Tablet__c = System.today().addDays(4),
            Google_Sheet_URL__c = GOOGLE_SHEET_URL
        );
        insert parentWorkOrder;

        WorkOrder childWorkOrder = new WorkOrder(
            Status = 'Planning',
            Type__c = WO_TYPE_MARKETPLACE,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MX,
            Activated_Centrally_AC__c = 'Yes',
            Proposed_Date_of_Activation__c = getNonWeekendDate(System.today().addDays(14)),
            Proposed_Date_of_Tablet__c = System.today().addDays(4),
            ParentWorkOrderId = parentWorkOrder.Id
        );
        insert childWorkOrder;

        Contract contract = new Contract(AccountId = bizAccount.Id);
        insert contract;

        Payment_Account__c paymentAccount = new Payment_Account__c(
            Business_Account__c = bizAccount.Id
        );
        insert paymentAccount;

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
        storeInfos.add(
            new BulkCorporateOnboardingWrappers.StoreInfo(
                storeAccount.Id,
                paymentAccount.Id,
                businessContact.Id
            )
        );

        flowRequest.Work_Order__c = parentWorkOrder.Id;
        flowRequest.Contract__c = contract.Id;
        flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
            storeInfos
        );
        flowRequest.Serialized_Entitlements_Data__c = SERIALIZED_ENTITLEMENTS_DATA;
        update flowRequest;

        Test.startTest();
        BulkStoreOnboardingBatch storeBatch = new BulkStoreOnboardingBatch(flowRequest.Id);
        Database.executeBatch(storeBatch);
        Test.stopTest();

        flowRequest = [
            SELECT Id, Status__c, Stage__c
            FROM Process_Flow_Request__c
            WHERE Id = :flowRequest.Id
            LIMIT 1
        ];
        Integer insertedPaymentAccountLinks = [
            SELECT COUNT()
            FROM Account_Payment_Account_Relation__c
            WHERE Account__c = :storeAccount.Id AND Payment_Account__c = :paymentAccount.Id
        ];
        Integer insertedDecisionMakers = [
            SELECT COUNT()
            FROM AccountContactRelation
            WHERE AccountId = :storeAccount.Id AND ContactId = :businessContact.Id
        ];
        System.assertEquals(
            REQUEST_STATUS_FAILED,
            flowRequest.Status__c,
            'The PFR Status should be set to Completed'
        );
        System.assertEquals(
            UPLOAD_COMPLETE,
            flowRequest.Stage__c,
            'The PFR Status should be set to Completed'
        );
        System.assertEquals(
            1,
            insertedPaymentAccountLinks,
            'A Account_Payment_Account_Relation__c should have been inserted for the Store'
        );
        System.assertEquals(
            1,
            insertedDecisionMakers,
            'A AccountContactRelation should have been inserted for the Store'
        );
    }

    /**
     * @description To test creation of business error logs when store association fails
     * while bulk onboarding stores.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoresAssociationFailsThenSendBusinessErrorsNotification() {
        Id contractId = Fake.generateId(Contract.class);
        Set<String> recipientIds = new Set<String>();
        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = PROCESSING_STORES,
            RecordTypeId = BULK_STORE_ONBOARDING_RECORD_TYPE_ID,
            OwnerId = UserInfo.getUserId()
        );
        insert flowRequest;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Segment__c = 'Enterprise',
            Primary_Vertical__c = PRIMARY_VERTICAL
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = ACCOUNT_NAME,
            ParentId = businessAccount.Id,
            Segment__c = 'Enterprise',
            RecordTypeId = STORE_RECORD_TYPE_ID,
            Bulk_Corporate_Onboarding_Request__c = flowRequest.Id
        );
        insert storeAccount;
        // Insert a Contact related to the Business Account.
        Contact businessContact = new Contact(
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Email = CONTACT_EMAIL,
            AccountId = businessAccount.Id
        );
        insert businessContact;
        Opportunity parentOpportunity = new Opportunity(
            AccountId = businessAccount.Id,
            Name = OPPORTUNITY_NAME,
            StageName = OPPORTUNITY_STAGE,
            CloseDate = System.today().addDays(14),
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard'
        );
        insert parentOpportunity;
        WorkOrder parentWorkOrder = new WorkOrder(
            AccountId = businessAccount.Id,
            Status = 'Planning',
            Opportunity__c = parentOpportunity.Id,
            Type__c = WO_TYPE_MARKETPLACE,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = MENU_TO_BE_COMPLETED_BY_MX,
            Activated_Centrally_AC__c = 'Yes',
            Proposed_Date_of_Activation__c = getNonWeekendDate(System.today().addDays(14)),
            Proposed_Date_of_Tablet__c = System.today().addDays(4),
            OwnerId = UserInfo.getUserId()
        );
        insert parentWorkOrder;
        Contract contract = new Contract(AccountId = businessAccount.Id);
        insert contract;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Business_Account__c = businessAccount.Id
        );
        insert paymentAccount;
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
        storeInfos.add(
            new BulkCorporateOnboardingWrappers.StoreInfo(
                storeAccount.Id,
                paymentAccount.Id,
                businessContact.Id
            )
        );
        flowRequest.Work_Order__c = parentWorkOrder.Id;
        flowRequest.Contract__c = contract.Id;
        flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
            storeInfos
        );
        update flowRequest;
        recipientIds.add(storeAccount.Parent.OwnerId);
        recipientIds.add(parentWorkOrder.OwnerId);
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            businessAccount.Id,
            LOG_ERROR_MESSAGE_FOR_FAILED_STORES,
            userInfo.getUserId(),
            contractId,
            storeAccount.Id
        );
        logMessageEntryInstance.franchiseAccountId = null;
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.recipientIdsToNotify = String.join(
            new List<String>(recipientIds),
            COMMA_SEPARATOR
        );
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.severityLevel = LogEntry.SeverityLevel.HIGH.name();
        logMessageEntryInstance.storeAccountName = storeAccount.Name;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        BulkStoreOnboardingBatch bulkStoreOnboardingBatch = new BulkStoreOnboardingBatch(
            flowRequest.Id
        );
        Database.executeBatch(bulkStoreOnboardingBatch);
        bulkStoreOnboardingBatch.logErrors(
            LOG_ERROR_MESSAGE_FOR_FAILED_STORES,
            storeAccount,
            LogEntry.LogCategory.BUSINESS_ERROR.name(),
            true,
            contractId,
            LogEntry.SeverityLevel.HIGH.name()
        );
        bulkStoreOnboardingBatch.createLogEntries();
        Test.stopTest();
        // Added check to verify logs creation for business errors.
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => new List<String>{
                        JSON.serialize(
                            new List<LogCreationEntry>{
                                new LogCreationEntry(
                                    BulkStoreOnboardingBatch.class.getName(),
                                    LOG_RECORD_METHOD_NAME,
                                    new List<LogMessageEntry>{ logMessageEntryInstance }
                                )
                            }
                        )
                    }
                }
            );
    }

    /**
     * @description Takes an inputted date and ensures that it does not fall on a weekend
     * @param proposedDateToUse
     * @return Date
     **/
    private static Date getNonWeekendDate(Date proposedDateToUse) {
        Date dateToReturn = proposedDateToUse;
        Datetime dt = (DateTime) dateToReturn; // Needed to get the day of the week
        String dayOfWeek = dt.formatGmt('EEEE');

        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
            dateToReturn = dateToReturn.addDays(3); // Set the date to sometime during the week
        }
        return dateToReturn;
    }
}