/**
 * @description This is test class for Agreement__c Trigger handler class
 * @author ATG
 * @date 05/26/2022
 */
@isTest(seeAllData=false)
public class AgreementsHandlerTest {
    private static final String ACTIVE_STATUS = 'Active';
    private static final String PENDING_STATUS = 'Pending';
    private static final String AGREED_TO_SERVICES_ALL = 'All';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement';
    private static final String STATUS_CANCELLED = 'Cancelled';

    /**
     * @description To test method call on Agreement__c insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInsertAgreementsThenCallPublish() {
        Id agreementId1 = Fake.generateId(Agreement__c.class);
        Id agreementId2 = Fake.generateId(Agreement__c.class);

        List<Agreement__c> agreementList = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS,
                Agreed_To_Services__c = AGREED_TO_SERVICES_ALL
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreements agreementsMock = (IAgreements) mocks.mock(IAgreements.class);
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        mocks.startStubbing();
        mocks.when(agreementsMock.getType()).thenReturn(Schema.Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId1 }))
            .thenReturn(new List<Agreement__c>{ agreementList[0] });
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId2 }))
            .thenReturn(new List<Agreement__c>{ agreementList[1] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.Domain.setMock(agreementsMock);
        IAgreementsService agreementsServiceMock = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );
        Application.SERVICE.setMock(IAgreementsService.class, agreementsServiceMock);
        IActivationOrdersService activationOrdersServiceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersServiceMock);
        fflib_SObjectDomain.Test.Database.onInsert(agreementList);
        fflib_SObjectDomain.triggerHandler(AgreementsHandler.class);
        ((IAgreements) mocks.verify(agreementsMock, 1))
            .onAfterInsertHandleRelatedRecords(agreementList);
        ((IAgreementsService) mocks.verify(agreementsServiceMock, 1))
            .publishAgreementActivationEvents(new List<Agreement__c>{ agreementList[0] }, false);
        ((IActivationOrdersService) mocks.verify(activationOrdersServiceMock, 1))
            .createActivationOrdersAndProducts(new List<Agreement__c>{ agreementList[1] }, false);
    }

    /**
     * @description To test method call on Agreement__c update
     * @JIRA #LEM-15980
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateAgreementsThenCallCreateActivationOrders() {
        Id agreementId1 = Fake.generateId(Agreement__c.class);
        Id agreementId2 = Fake.generateId(Agreement__c.class);
        Id agreementId3 = Fake.generateId(Agreement__c.class);
        Id agreementId4 = Fake.generateId(Agreement__c.class);
        Id agreementId5 = Fake.generateId(Agreement__c.class);
        Id agreementId6 = Fake.generateId(Agreement__c.class);
        Id agreementId7 = Fake.generateId(Agreement__c.class);

        List<Agreement__c> agreementList = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS,
                Agreed_To_Services__c = AGREED_TO_SERVICES_ALL,
                Serialized_Entitlements_Data__c = null
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = PENDING_STATUS
            ),
            new Agreement__c(
                Id = agreementId3,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = PENDING_STATUS
            ),
            new Agreement__c(
                Id = agreementId4,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            ),
            new Agreement__c(
                Id = agreementId5,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            ),
            new Agreement__c(
                Id = agreementId6,
                Type__c = AGREEMENT_TYPE_STORE,
                Deactivation_Date__c = System.today()
            ),
            new Agreement__c(
                Id = agreementId7,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED
            )
        };

        List<Agreement__c> oldAgreementList = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS,
                Agreed_To_Services__c = AGREED_TO_SERVICES_ALL,
                Serialized_Entitlements_Data__c = '{"selected" : [], "deselected" : []}'
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = PENDING_STATUS
            ),
            new Agreement__c(
                Id = agreementId3,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            ),
            new Agreement__c(
                Id = agreementId4,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = PENDING_STATUS
            ),
            new Agreement__c(
                Id = agreementId5,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED
            ),
            new Agreement__c(
                Id = agreementId6,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            ),
            new Agreement__c(
                Id = agreementId7,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = ACTIVE_STATUS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IAgreements agreementsMock = (IAgreements) mocks.mock(IAgreements.class);
        mocks.startStubbing();
        mocks.when(agreementsMock.getType()).thenReturn(Schema.Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId1 }))
            .thenReturn(new List<Agreement__c>{ agreementList[0] });
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId2 }))
            .thenReturn(new List<Agreement__c>{ agreementList[1] });
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId3 }))
            .thenReturn(new List<Agreement__c>{ agreementList[2] });
        mocks.when(agreementsSelectorMock.selectById(new Set<Id>{ agreementId4 }))
            .thenReturn(new List<Agreement__c>{ agreementList[3] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.Domain.setMock(agreementsMock);

        IActivationOrdersService activationOrdersService = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );
        Application.SERVICE.setMock(IActivationOrdersService.class, activationOrdersService);

        IAgreementsService agreementsServiceMock = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );
        Application.SERVICE.setMock(IAgreementsService.class, agreementsServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            agreementList,
            new Map<Id, SObject>(oldAgreementList)
        );
        fflib_SObjectDomain.triggerHandler(AgreementsHandler.class);

        //Call the service for all agreements with changed status
        ((IActivationOrdersService) mocks.verify(activationOrdersService, 0))
            .createActivationOrdersAndProducts(new List<Agreement__c>{ agreementList[2] }, true);
        //Updated Active to Pending - call the service
        // ((IActivationOrdersService) mocks.verify(activationOrdersService, 1))
        //     .createActivationOrdersAndProducts(new List<Agreement__c>{ agreementList[3] }, false);
        //Updated Pending to Pending - Do Not call the service
        ((IActivationOrdersService) mocks.verify(activationOrdersService, 0))
            .createActivationOrdersAndProducts(new List<Agreement__c>{ agreementList[1] }, true);
        //Updated Active to Active - Do Not call the service
        ((IActivationOrdersService) mocks.verify(activationOrdersService, 0))
            .createActivationOrdersAndProducts(new List<Agreement__c>{ agreementList[0] }, false);
        ((IAgreementsService) mocks.verify(agreementsServiceMock, 1))
            .publishAgreementActivationEvents(new List<Agreement__c>{ agreementList[0] }, true);
        //((IAgreements) mocks.verify(agreementsMock, 1)).updateDeactivationDateOrStatus(new List<Agreement__c>{ agreementList[5]});
    }
}