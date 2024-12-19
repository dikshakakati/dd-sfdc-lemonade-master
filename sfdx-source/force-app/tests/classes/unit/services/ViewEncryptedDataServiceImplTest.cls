/**
 * @author Deloitte
 * @date 28/07/2022
 * @description Test class for ViewEncryptedDataServiceImpl class.
 */
@isTest(seeAllData=false)
private class ViewEncryptedDataServiceImplTest {
    private static final String ASSERT_MESSAGE = 'Unexpected result: encrypted data is not fetched';
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE = 'Unexpected result: exception message is not matching';
    private static final String COMPONENT_LOCATION = 'Contact';
    private static final String COMPONENT_LOCATION_WORKPLAN = 'WorkPlan';
    private static final String FIELD_API_NAME_BANK_ACCOUNT_NUMBER = 'Bank_Account_Number__c';
    private static final String FIELD_API_NAME_BIRTHDATE = 'Birthdate';
    private static final String FIELD_API_NAME = 'SSN_Last_4Digits__c';
    private static final String FIELD_API_NAME_LEGAL_BUSINESS_NAME = 'Legal_Business_Name__c';
    private static final String FIELD_API_NAME_LEGAL_BUSINESS_NAME_STORE = 'Legal_Business_Name_Store__c';
    private static final String FIELD_API_NAME_ROUTING_NUMBER = 'RoutingNumber__c';
    private static final String FIELD_API_NAME_TAX_ID = 'TaxID__c';
    private static final String FIELD_HELP_TEXT = 'ViewEncryptedDataServiceImplTest Help Text';
    private static final String FIELD_LABEL = 'SSN (Last 4 Digits)';
    private static final Integer FIELD_LENGTH = 20;
    private static final String FIELD_SET_NAME = 'Encrypted_Fields';
    private static final String FIELD_SET_NAME_BANKING_INFORMATION = 'Banking_Information';
    private static final String FIELD_TYPE = 'text';
    private static final String FIELD_VALUE = '1234';
    private static final String FIELD_VALUE_LEGAL_BUSINESS_NAME = 'Legal business name';
    private static final String FIELD_VALUE_LEGAL_BUSINESS_NAME_STORE = 'Legal Business Name (Store)';
    private static final String ID_FIELD = 'Id';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String OBJECT_API_NAME_ACCOUNT = 'Account';
    private static final String OBJECT_API_NAME_CONTACT = 'Contact';
    private static final String OBJECT_API_NAME_PAYMENT_ACCOUNT = 'Payment_Account__c';
    private static final String OBJECT_API_NAME_WORKORDER = 'WorkOrder';
    private static final String OBJECT_API_NAME_WORKPLAN = 'WorkPlan';
    private static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';
    private static final String VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION = 'View_Encrypted_Banking_Information';

    /**
     * @description To test that an exception is thrown when end-user don't have the
     * "View Encrypted Banking Information" custom permission.
     */
    @isTest
    private static void testWhenGetEncryptedDataWithoutPermissionThenThrowException() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        ViewEncryptedDataWrapper viewEncryptedDataWrapperMock = new ViewEncryptedDataWrapper();
        viewEncryptedDataWrapperMock.businessAccountId = businessAccountId;
        viewEncryptedDataWrapperMock.componentLocation = COMPONENT_LOCATION;
        viewEncryptedDataWrapperMock.recordId = contactId;
        viewEncryptedDataWrapperMock.workOrderId = workOrderId;
        Test.startTest();
        String noAccessExceptionMessage;
        try {
            ViewEncryptedDataService.getEncryptedData(viewEncryptedDataWrapperMock);
        } catch (AuraHandledException exceptionMessage) {
            noAccessExceptionMessage = exceptionMessage.getMessage();
        }
        Test.stopTest();
        System.assertEquals(
            SCRIPT_THROWN_EXCEPTION,
            noAccessExceptionMessage,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE
        );
    }

    /**
     * @description To test encrypted data associated to an object are correctly fetched.
     */
    @isTest
    private static void testWhenGetEncryptedDataThenReturnEncryptedData() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<Encrypted_Fields_Configuration__mdt> customMetadataMocks = new List<Encrypted_Fields_Configuration__mdt>{
            new Encrypted_Fields_Configuration__mdt(
                Component_Location__c = OBJECT_API_NAME_CONTACT,
                FieldSet_Name__c = FIELD_SET_NAME,
                Object_Api_Name__c = OBJECT_API_NAME_CONTACT
            )
        };
        SObject sObjectInstance = Schema.getGlobalDescribe()
            .get(String.valueOf(contactId.getSobjectType()))
            .newSObject();
        sObjectInstance.put(ID_FIELD, contactId);
        sObjectInstance.put(FIELD_API_NAME, FIELD_VALUE);
        List<SObject> sObjectMocks = new List<SObject>{ sObjectInstance };
        ViewEncryptedDataWrapper viewEncryptedDataWrapperMock = new ViewEncryptedDataWrapper();
        viewEncryptedDataWrapperMock.businessAccountId = businessAccountId;
        viewEncryptedDataWrapperMock.componentLocation = COMPONENT_LOCATION;
        viewEncryptedDataWrapperMock.recordId = contactId;
        viewEncryptedDataWrapperMock.workOrderId = workOrderId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEncryptedFieldsConfigurationsSelector encryptedFieldsConfigsSelectorMock = (IEncryptedFieldsConfigurationsSelector) mocks.mock(
            IEncryptedFieldsConfigurationsSelector.class
        );
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        ContactsSelector contactsSelectorMock = (ContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION
                )
            )
            .thenReturn(true);
        mocks.when(encryptedFieldsConfigsSelectorMock.sObjectType())
            .thenReturn(Encrypted_Fields_Configuration__mdt.SObjectType);
        mocks.when(
                encryptedFieldsConfigsSelectorMock.selectByComponetLocationAndObjectApiName(
                    COMPONENT_LOCATION
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        // Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        mocks.when(
                contactsSelectorMock.selectEncryptedData(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(sObjectMocks);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        Application.SELECTOR.setMock(encryptedFieldsConfigsSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);
        Test.startTest();
        List<EncryptedFieldWrapper> encryptedFieldWrappers = ViewEncryptedDataService.getEncryptedData(
            viewEncryptedDataWrapperMock
        );
        Test.stopTest();
        System.assertEquals(1, encryptedFieldWrappers.size(), ASSERT_MESSAGE);
    }

    /**
     * @description To test encrypted data associated to an object is correctly updated.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateEncryptedDataCalledThenUpdateEncryptedData() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        EncryptedFieldWrapper encryptedFieldWrapper = new EncryptedFieldWrapper(
            FIELD_API_NAME,
            FIELD_LABEL,
            FIELD_TYPE,
            FIELD_VALUE,
            true
        );
        encryptedFieldWrapper.fieldHelpText = FIELD_HELP_TEXT;
        encryptedFieldWrapper.fieldLength = FIELD_LENGTH;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        ViewEncryptedDataService.updateEncryptedData(
            contactId,
            JSON.serialize(new List<EncryptedFieldWrapper>{ encryptedFieldWrapper })
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.SObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Contact.Id => contactId,
                            Contact.SSN_Last_4Digits__c => FIELD_VALUE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test encrypted data associated to Contact are fetched from Payment Account's
     * Billing Contact when component location is Work Plan.
     */
    @isTest
    private static void testWhenGetEncryptedDataCalledOnWorkPlanThenReturnEncryptedData() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.Billing_Contact_Name__c, contactId);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        List<Encrypted_Fields_Configuration__mdt> customMetadataMocks = new List<Encrypted_Fields_Configuration__mdt>{
            new Encrypted_Fields_Configuration__mdt(
                Component_Location__c = OBJECT_API_NAME_WORKPLAN,
                FieldSet_Name__c = FIELD_SET_NAME_BANKING_INFORMATION,
                Object_Api_Name__c = OBJECT_API_NAME_CONTACT
            ),
            new Encrypted_Fields_Configuration__mdt(
                Component_Location__c = OBJECT_API_NAME_WORKPLAN,
                FieldSet_Name__c = FIELD_SET_NAME_BANKING_INFORMATION,
                Object_Api_Name__c = OBJECT_API_NAME_PAYMENT_ACCOUNT
            ),
            new Encrypted_Fields_Configuration__mdt(
                Component_Location__c = OBJECT_API_NAME_WORKPLAN,
                FieldSet_Name__c = FIELD_SET_NAME_BANKING_INFORMATION,
                Object_Api_Name__c = OBJECT_API_NAME_ACCOUNT
            ),
            new Encrypted_Fields_Configuration__mdt(
                Component_Location__c = OBJECT_API_NAME_WORKPLAN,
                FieldSet_Name__c = FIELD_SET_NAME_BANKING_INFORMATION,
                Object_Api_Name__c = OBJECT_API_NAME_WORKORDER
            )
        };
        SObject sObjectInstanceAccount = Schema.getGlobalDescribe()
            .get(String.valueOf(businessAccountId.getSobjectType()))
            .newSObject();
        sObjectInstanceAccount.put(ID_FIELD, businessAccountId);
        sObjectInstanceAccount.put(
            FIELD_API_NAME_LEGAL_BUSINESS_NAME,
            FIELD_VALUE_LEGAL_BUSINESS_NAME
        );
        sObjectInstanceAccount.put(FIELD_API_NAME_TAX_ID, FIELD_VALUE);
        SObject sObjectInstanceContact = Schema.getGlobalDescribe()
            .get(String.valueOf(contactId.getSobjectType()))
            .newSObject();
        sObjectInstanceContact.put(ID_FIELD, contactId);
        sObjectInstanceContact.put(FIELD_API_NAME, FIELD_VALUE);
        sObjectInstanceContact.put(FIELD_API_NAME_BIRTHDATE, Date.newInstance(1990, 5, 18));
        SObject sObjectInstancePaymentAccount = Schema.getGlobalDescribe()
            .get(String.valueOf(paymentAccountId.getSobjectType()))
            .newSObject();
        sObjectInstancePaymentAccount.put(ID_FIELD, paymentAccountId);
        sObjectInstancePaymentAccount.put(FIELD_API_NAME_BANK_ACCOUNT_NUMBER, FIELD_VALUE);
        sObjectInstancePaymentAccount.put(FIELD_API_NAME_ROUTING_NUMBER, FIELD_VALUE);
        SObject sObjectInstanceWorkOrder = (SObject) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Legal_Business_Name_Store__c, FIELD_VALUE_LEGAL_BUSINESS_NAME_STORE)
            .toSObject();
        List<SObject> sObjectMockAccount = new List<SObject>{ sObjectInstanceAccount };
        List<SObject> sObjectMockContact = new List<SObject>{ sObjectInstanceContact };
        List<SObject> sObjectMockPaymentAccount = new List<SObject>{
            sObjectInstancePaymentAccount
        };
        List<SObject> sObjectMockWorkOrder = new List<SObject>{ sObjectInstanceWorkOrder };
        ViewEncryptedDataWrapper viewEncryptedDataWrapperMock = new ViewEncryptedDataWrapper();
        viewEncryptedDataWrapperMock.businessAccountId = businessAccountId;
        viewEncryptedDataWrapperMock.componentLocation = COMPONENT_LOCATION_WORKPLAN;
        viewEncryptedDataWrapperMock.recordId = paymentAccountId;
        viewEncryptedDataWrapperMock.paymentRecordIds = paymentAccountId;
        viewEncryptedDataWrapperMock.workOrderId = workOrderId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEncryptedFieldsConfigurationsSelector encryptedFieldsConfigsSelectorMock = (IEncryptedFieldsConfigurationsSelector) mocks.mock(
            IEncryptedFieldsConfigurationsSelector.class
        );
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        AccountsSelector accountsSelectorMock = (AccountsSelector) mocks.mock(
            AccountsSelector.class
        );
        ContactsSelector contactsSelectorMock = (ContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        PaymentAccountsSelector paymentAccountsSelectorMock = (PaymentAccountsSelector) mocks.mock(
            PaymentAccountsSelector.class
        );
        WorkOrdersSelector workOrdersSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION
                )
            )
            .thenReturn(true);
        mocks.when(encryptedFieldsConfigsSelectorMock.sObjectType())
            .thenReturn(Encrypted_Fields_Configuration__mdt.SObjectType);
        mocks.when(
                encryptedFieldsConfigsSelectorMock.selectByComponetLocationAndObjectApiName(
                    OBJECT_API_NAME_WORKPLAN
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.when(paymentAccountsSelectorMock.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(paymentAccountsSelectorMock.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        // Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        mocks.when(
                contactsSelectorMock.selectEncryptedData(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(sObjectMockContact);
        mocks.when(
                paymentAccountsSelectorMock.selectEncryptedData(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(sObjectMockPaymentAccount);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        // Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        mocks.when(
                accountsSelectorMock.selectEncryptedData(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(sObjectMockAccount);
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        // Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        mocks.when(
                workOrdersSelectorMock.selectEncryptedData(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(sObjectMockWorkOrder);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        Application.SELECTOR.setMock(encryptedFieldsConfigsSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);
        Application.SELECTOR.setMock(paymentAccountsSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Test.startTest();
        List<EncryptedFieldWrapper> encryptedFieldWrappers = ViewEncryptedDataService.getEncryptedData(
            viewEncryptedDataWrapperMock
        );
        Test.stopTest();
        System.assertEquals(7, encryptedFieldWrappers.size(), ASSERT_MESSAGE);
        for (EncryptedFieldWrapper eachEncryptedFieldWrapper : encryptedFieldWrappers) {
            if (eachEncryptedFieldWrapper.fieldApiName == FIELD_API_NAME) {
                system.assertEquals(
                    FIELD_VALUE,
                    eachEncryptedFieldWrapper.fieldValue,
                    ASSERT_MESSAGE
                );
            }
        }
    }

    /**
     * @description To validate exception message thrown on update of encrypted data associated
     * to an object.
     */
    @isTest
    private static void testWhenDMLExceptionOccurredOnEncryptedDataUpdateThenExceptionWithMessageThrown() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        String exceptionMessage;
        EncryptedFieldWrapper encryptedFieldWrapper = new EncryptedFieldWrapper(
            FIELD_API_NAME,
            FIELD_LABEL,
            FIELD_TYPE,
            FIELD_VALUE,
            true
        );
        encryptedFieldWrapper.fieldHelpText = FIELD_HELP_TEXT;
        encryptedFieldWrapper.fieldLength = FIELD_LENGTH;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            ViewEncryptedDataService.updateEncryptedData(
                contactId,
                JSON.serialize(new List<EncryptedFieldWrapper>{ encryptedFieldWrapper })
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        System.assertEquals(
            SCRIPT_THROWN_EXCEPTION,
            exceptionMessage,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE
        );
    }
}