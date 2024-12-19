/**
 * @description This is test class for AgreementActivationEvents
 */
@isTest(seeAllData=false)
public class AgreementActivationEventsHandlerTest {
    static final String UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES = 'Update Activation Order And Products For Existing Process';
    static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'Create_Activation_Order_Products';
    private static final String EVENT_TOPIC_UPDATE_MERCHANT_SERVICES = 'Update_Merchant_Services';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP = 'Create_Activation_Order_Products_ARP';
    /**
     * @description Testing the call to the agreement service to activate
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsertEventThenActivateAgreement() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        Agreement_Activation_Event__e activationEvent = new Agreement_Activation_Event__e(
            Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
            Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IActivationOrdersService serviceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IAgreementsService.class, serviceMock);

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(activationEvent);

        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess(),
            'Unexpected Result: agreement activation event publish failed'
        );
    }

    /**
     * @description Testing the call to the agreement service to activate
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsertEventWithTopicThenUpdateServices() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        Agreement_Activation_Event__e activationEvent = new Agreement_Activation_Event__e(
            Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
            Topic__c = UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IActivationOrdersService serviceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IAgreementsService.class, serviceMock);

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(activationEvent);

        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess(),
            'Unexpected Result: agreement activation event publish failed'
        );
    }

        /**
     * @description Testing the call to the activate order ARP
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsertEventCreationActivationOrderArpThenCreateActivationOrder() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        Agreement_Activation_Event__e activationEvent = new Agreement_Activation_Event__e(
            Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
            Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER_ARP
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IActivationOrdersService serviceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IAgreementsService.class, serviceMock);

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(activationEvent);

        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess(),
            'Unexpected Result: agreement activation event publish failed'
        );
    }

    /**
     * @description Testing the call to the Update_Merchant_Services
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsertEventWithTopicUpdateMerchantServicesThenUpdateServices() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);

        Agreement_Activation_Event__e activationEvent = new Agreement_Activation_Event__e(
            Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
            Topic__c = EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IActivationOrdersService serviceMock = (IActivationOrdersService) mocks.mock(
            IActivationOrdersService.class
        );

        Application.SERVICE.setMock(IAgreementsService.class, serviceMock);

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(activationEvent);

        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess(),
            'Unexpected Result: agreement activation event publish failed'
        );
    }
}