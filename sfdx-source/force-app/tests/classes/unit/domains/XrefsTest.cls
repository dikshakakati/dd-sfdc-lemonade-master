/**
 * @author Doordash
 * @date 2023-04-18
 * @description This is test class for Xrefs class
 */
@isTest
public class XrefsTest {
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String BUSINESS_ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String BUSINESS_ACCOUNT_TEST_NAME_DOMINOS = 'Dominos';
    /**
     * @description To test xrefs invokeCooProcess call
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefCooProcessUpdatedThenAsyncProcessInvoked() {
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id xrefId3 = Fake.generateId(Xref__c.class);
        List<Xref__c> xrefsList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                Coo_Process__c = Xrefs.COO_PROCESS_VIA_ASYNC
            ),
            new Xref__c(
                Id = xrefId2,
                Coo_Process__c = Xrefs.COO_PROCESS_VIA_ASYNC
            ),
            new Xref__c(
                Id = xrefId3,
                Coo_Process__c = 'Processed'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IChangeOfOwnershipService cooMock = (IChangeOfOwnershipService) mocks.mock(
            IChangeOfOwnershipService.class
        );
        Application.SERVICE.setMock(IChangeOfOwnershipService.class, cooMock);

        Test.startTest();
        IXrefs xrefsInstance = Xrefs.newInstance(xrefsList);
        xrefsInstance.invokeCooProcess();
        Test.stopTest();

        ((IChangeOfOwnershipService) mocks.verify(cooMock, 1))
            .processCooXrefsMarkedForAsyncProcess(new Set<Id>{xrefId1, xrefId2});
    }

     /**
     * @description To test more than 50 xrefs updated to async mode for Coo Process
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefCooProcessUpdatedToAsyncModeGreaterThanThresholdThenCooProcessUpdatedToBatch() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        for(Integer i=0; i<=100; i++){
            Xref__c xref = new Xref__c(
                Id = Fake.generateId(Xref__c.class),
                Coo_Process__c = Xrefs.COO_PROCESS_VIA_ASYNC
            );
            xrefsList.add(xref);
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);


        IChangeOfOwnershipService cooMock = (IChangeOfOwnershipService) mocks.mock(
            IChangeOfOwnershipService.class
        );
        Application.SERVICE.setMock(IChangeOfOwnershipService.class, cooMock);

        Test.startTest();
        IXrefs xrefsInstance = Xrefs.newInstance(xrefsList);
        xrefsInstance.invokeCooProcess();
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /*
    * @description to test the Integration message convertion to business friendly message format
    */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningMessageOnXrefUpdatedThenIntgerationMessageFormatted() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        Id xrefId = Fake.generateId(Xref__c.class);
        string newProvisioningMessage = 'Test Integration Message';
        xref__c xref = new xref__c(
            Id = xrefId,
            Provisioning_Error_Message__c = newProvisioningMessage
        );
        xrefsList.add(xref);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IGetBusinessFriendlyMessageService serviceMock = (IGetBusinessFriendlyMessageService) mocks.mock(
            IGetBusinessFriendlyMessageService.class
        );
        Application.SERVICE.setMock(IGetBusinessFriendlyMessageService.class, serviceMock);

        Test.startTest();
        IXrefs xrefsInstance = Xrefs.newInstance(xrefsList);
        xrefsInstance.updateIntegrationMessageAndProvisioningCategory();
        Test.stopTest();

        ((IGetBusinessFriendlyMessageService) mocks.verify(serviceMock, 1))
            .getMessageDetails(newProvisioningMessage, Xrefs.INTEGRATION_TYPE);
    }

     /*
    * @description to test the Integration message update to success
    */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningMessageOnXrefUpdatedToSuccessThenIntgerationMessageIsSuccess() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        Id xrefId = Fake.generateId(Xref__c.class);
        string newProvisioningMessage = 'Success';
        xref__c xref = new xref__c(
            Id = xrefId,
            Provisioning_Error_Message__c = newProvisioningMessage
        );
        xrefsList.add(xref);

        Test.startTest();
        IXrefs xrefsInstance = Xrefs.newInstance(xrefsList);
        xrefsInstance.updateIntegrationMessageAndProvisioningCategory();
        Test.stopTest();

        xref__c updatedXref = xrefsList[0];
        Assert.areEqual(
            newProvisioningMessage,
            updatedXref.Integration_Message__c,
            'Integration Message did not got updated to success'
        );
    }

     /*
    * @description to test the Integration message update to null
    */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProvisioningMessageOnXrefUpdatedToNullThenIntgerationMessageIsNull() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        Id xrefId = Fake.generateId(Xref__c.class);
        string newProvisioningMessage = '';
        xref__c xref = new xref__c(
            Id = xrefId,
            Provisioning_Error_Message__c = newProvisioningMessage
        );
        xrefsList.add(xref);

        Test.startTest();
        IXrefs xrefsInstance = Xrefs.newInstance(xrefsList);
        xrefsInstance.updateIntegrationMessageAndProvisioningCategory();
        Test.stopTest();

        xref__c updatedXref = xrefsList[0];
        Assert.areEqual(
            newProvisioningMessage,
            updatedXref.Integration_Message__c,
            'Integration Message did not got updated to null'
        );
    }

    /*
     * @description To test when Xrefs are inserted then
     set brand method is invoked for setting brands on Business References.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefInsertedThenSetBrandCalled() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        Id brandId = Fake.generateId(Brand__c.class);
        Account pizzaHut = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_DOMINOS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_SMB)
            .setField(Account.Brand__c, brandId)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, '')
            .setFakeId()
            .toSObject();
        Map<Id, Id> businessRefToBrandId = new Map<Id, Id>();
        businessRefToBrandId.put(businessReference.Id, brandId);
        Xref__c xrefFakeInstance = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, pizzaHut.Id)
            .setField(Xref__c.Business_Reference__c, businessReference.Id)
            .setFakeId()
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Id, businessReference.Id)
            )
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, pizzaHut.Id)
                    .setField(Account.Brand__c, brandId)
            )
            .toSObject();
        xrefsList.add(xrefFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferences businessReferencesMock = (IBusinessReferences) mocks.mock(
            IBusinessReferences.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectByAccountIds(new Set<Id>{ pizzaHut.Id }))
            .thenReturn(xrefsList);
        mocks.stopStubbing();
        Application.Domain.setMock(businessReferencesMock);
        Application.Selector.setMock(xrefSelectorMock);
        businessReferencesMock.setBrandOnBusinessReference(businessRefToBrandId);
        Test.startTest();
        Xrefs.newInstance(xrefsList)
            .invokeBrandOnBusinessReferencesByXrefs(new Set<Id>{ pizzaHut.Id });
        Test.stopTest();
        ((IBusinessReferences) mocks.verify(businessReferencesMock, 1))
            .setBrandOnBusinessReference(businessRefToBrandId);
    }

    /*
     * @description To test when Xrefs are inserted with empty brand
     on related Business References then set brand method is invoked for
     setting brands on Business References.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenXrefWithBrandPopulatedOnBusinessRefInsertedThenSetBrandNotCalled() {
        List<Xref__c> xrefsList = new List<Xref__c>();
        Id brandId = Fake.generateId(Brand__c.class);
        Account dominos = (Account) new Fake(Account.class)
            .setField(Account.Name, BUSINESS_ACCOUNT_TEST_NAME_DOMINOS)
            .setField(Account.Record_Type_Name__c, BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .setField(Account.Segment__c, BUSINESS_ACCOUNT_SEGMENT_SMB)
            .setField(Account.Brand__c, brandId)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Brand__c, brandId)
            .setFakeId()
            .toSObject();
        Map<Id, Id> businessRefToBrandId = new Map<Id, Id>();
        businessRefToBrandId.put(businessReference.Id, brandId);
        Xref__c xrefFakeInstance = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, dominos.Id)
            .setField(Xref__c.Business_Reference__c, businessReference.Id)
            .setFakeId()
            .setParent(
                'Business_Reference__r',
                new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Id, businessReference.Id)
                    .setField(Business_Reference__c.Brand__c, brandId)
            )
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Id, dominos.Id)
                    .setField(Account.Brand__c, brandId)
            )
            .toSObject();
        xrefsList.add(xrefFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferences businessReferencesMock = (IBusinessReferences) mocks.mock(
            IBusinessReferences.class
        );
        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectByAccountIds(new Set<Id>{ dominos.Id }))
            .thenReturn(xrefsList);
        mocks.stopStubbing();
        Application.Domain.setMock(businessReferencesMock);
        Application.Selector.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        Xrefs.newInstance(xrefsList)
            .invokeBrandOnBusinessReferencesByXrefs(new Set<Id>{ dominos.Id });
        Test.stopTest();
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
    }
}