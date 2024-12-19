/**
 * @author Deloitte
 * @date 28/07/2022
 * @description Test class for ViewEncryptedDataController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ViewEncryptedDataControllerTest {
    private static final String COMPONENT_LOCATION = 'Contact';
    private static final String FIELD_API_NAME = 'SSN_Last_4Digits__c';
    private static final String FIELD_HELP_TEXT = 'ViewEncryptedDataControllerTest Help Text';
    private static final String FIELD_LABEL = 'SSN (Last 4 Digits)';
    private static final String FIELD_TYPE = 'text';
    private static final String FIELD_VALUE = '1234';
    private static final String OBJECTAPINAME = 'Contact';

    /**
     * @description To test encrypted data for the passed recordId and object.
     */
    @isTest
    private static void testWhenGetEncryptedDataThenReturnEncryptedData() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        EncryptedFieldWrapper encryptedFieldWrapper = new EncryptedFieldWrapper(
            FIELD_API_NAME,
            FIELD_LABEL,
            FIELD_TYPE,
            FIELD_VALUE,
            true
        );
        encryptedFieldWrapper.fieldHelpText = FIELD_HELP_TEXT;
        ViewEncryptedDataWrapper viewEncryptedDataWrapperMock = new ViewEncryptedDataWrapper();
        viewEncryptedDataWrapperMock.businessAccountId = businessAccountId;
        viewEncryptedDataWrapperMock.componentLocation = COMPONENT_LOCATION;
        viewEncryptedDataWrapperMock.recordId = contactId;
        viewEncryptedDataWrapperMock.workOrderId = workOrderId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IViewEncryptedDataService viewEncryptedDataService = (IViewEncryptedDataService) mocks.mock(
            IViewEncryptedDataService.class
        );
        mocks.startStubbing();
        mocks.when(viewEncryptedDataService.getEncryptedData(viewEncryptedDataWrapperMock))
            .thenReturn(new List<EncryptedFieldWrapper>{ encryptedFieldWrapper });
        mocks.stopStubbing();
        Application.SERVICE.setMock(IViewEncryptedDataService.class, viewEncryptedDataService);
        Test.startTest();
        ViewEncryptedDataController.getEncryptedData(viewEncryptedDataWrapperMock);
        Test.stopTest();
        ((IViewEncryptedDataService) mocks.verify(viewEncryptedDataService, 1))
            .getEncryptedData(viewEncryptedDataWrapperMock);
    }

    /**
     * @description To test updatation of encrypted data for the passed recordId and object.
     */
    @isTest
    private static void testWhenUpdateEncryptedDataThenUpdateEncryptedData() {
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        EncryptedFieldWrapper encryptedFieldWrapper = new EncryptedFieldWrapper(
            FIELD_API_NAME,
            FIELD_LABEL,
            FIELD_TYPE,
            FIELD_VALUE,
            true
        );
        encryptedFieldWrapper.fieldHelpText = FIELD_HELP_TEXT;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IViewEncryptedDataService viewEncryptedDataService = (IViewEncryptedDataService) mocks.mock(
            IViewEncryptedDataService.class
        );
        Application.SERVICE.setMock(IViewEncryptedDataService.class, viewEncryptedDataService);
        Test.startTest();
        ViewEncryptedDataController.updateEncryptedData(
            contactId,
            JSON.serialize(new List<EncryptedFieldWrapper>{ encryptedFieldWrapper })
        );
        Test.stopTest();
        ((IViewEncryptedDataService) mocks.verify(viewEncryptedDataService, 1))
            .updateEncryptedData(
                contactId,
                JSON.serialize(new List<EncryptedFieldWrapper>{ encryptedFieldWrapper })
            );
    }
}