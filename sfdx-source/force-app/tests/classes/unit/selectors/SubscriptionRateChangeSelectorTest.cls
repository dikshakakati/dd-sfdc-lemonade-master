/**
 * @author Deloitte
 * @date 16/09/2023
 * @description This is test class for SubscriptionRateChangeSelector class
 */
@isTest(seeAllData=false)
public class SubscriptionRateChangeSelectorTest {
    @testSetup
    static void setupData() {
        SBQQ.TriggerControl.disable();

        Id soCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('SO_Support_Request')
            .getRecordTypeId();

        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;

        OrderItem orderItem = CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);

        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contract.Id;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        subRec.SBQQ__OrderProduct__c = orderItem.Id;
        insert subRec;

        Case soSupportCase = new Case();
        soSupportCase.AccountId = testAccount.Id;
        soSupportCase.RecordTypeId = soCaseRecordTypeId;
        insert soSupportCase;

        Rate_Change_Request__c rateChange1 = new Rate_Change_Request__c();
        rateChange1.Effective_Date__c = System.today();
        rateChange1.Contract__c = contract.Id;
        rateChange1.S_O_Support_Request_Link__c = soSupportCase.Id;
        rateChange1.Activation_Status__c = 'New';
        rateChange1.Status__c = 'Approved';
        rateChange1.Order_Products_Updated__c = false;
        rateChange1.Associated_stores_updated__c = true;
        insert rateChange1;

        Subscription_Rate_Change__c subscriptionRateChange1 = new Subscription_Rate_Change__c();
        subscriptionRateChange1.Rate_Change_Request__c = rateChange1.Id;
        subscriptionRateChange1.Subscription__c = subRec.Id;
        subscriptionRateChange1.Update_complete__c = true;
        subscriptionRateChange1.Updated_Active_Commission__c = 20;
        subscriptionRateChange1.Updated_Active_Fee__c = 10;
        insert subscriptionRateChange1;

        SBQQ.TriggerControl.enable();
    }

    /**
     * @description This is method used to test SubscriptionRateChangeSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        SubscriptionRateChangeSelector selectorInstance = new SubscriptionRateChangeSelector();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        System.assertEquals(
            Schema.Subscription_Rate_Change__c.SObjectType,
            typeOfObject,
            'The object type must be Subscription_Rate_Change__c'
        );

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Subscription_Rate_Change__c.Rate_Change_Request__c,
                Subscription_Rate_Change__c.Subscription__c,
                Subscription_Rate_Change__c.Update_complete__c,
                Subscription_Rate_Change__c.Updated_Active_Commission__c,
                Subscription_Rate_Change__c.Updated_Active_Fee__c,
                Subscription_Rate_Change__c.Rate_Change_Request_Status__c,
                Subscription_Rate_Change__c.Name,
                Subscription_Rate_Change__c.Current_Active_Fee__c,
                Subscription_Rate_Change__c.Current_Active_Commission__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenSubscriptionRateChangeInsertedThenSelectorCallSelectById() {
        List<Subscription_Rate_Change__c> subscriptionRateChangeData = [
            SELECT id
            FROM Subscription_Rate_Change__c
            LIMIT 1
        ];
        Set<Id> subscriptionRateChangeIds = new Set<Id>();
        for (Subscription_Rate_Change__c src : subscriptionRateChangeData) {
            subscriptionRateChangeIds.add(src.Id);
        }

        Test.startTest();
        List<Subscription_Rate_Change__c> subscriptionRateChangeQueryData = SubscriptionRateChangeSelector.newInstance()
            .selectById(subscriptionRateChangeIds);
        Test.stopTest();
        System.assertEquals(
            1,
            subscriptionRateChangeQueryData.size(),
            'The return record is not matching with passed record'
        );
    }

    /**
     * @description This method tests if all Accounts with past NDA Dates are queries or not.
     */
    @isTest
    private static void testWhenEffectiveDateIsReachedThenSubscriptionRateChangeFetched() {
        List<Rate_Change_Request__c> rateChangeData = [
            SELECT id
            FROM Rate_Change_Request__c
            LIMIT 1
        ];

        List<Subscription_Rate_Change__c> subscriptionRateChangeData = [
            SELECT id
            FROM Subscription_Rate_Change__c
            LIMIT 1
        ];

        SubscriptionRateChangeSelector subscriptionRateChangeSelectorForIntegrationTest = new SubscriptionRateChangeSelector();
        Database.QueryLocator querySubscriptionRateChange = subscriptionRateChangeSelectorForIntegrationTest.selectByRateChangeIds(
            new Set<Id>{ rateChangeData[0].Id }
        );

        Database.QueryLocatorIterator iteratorOnSRC = querySubscriptionRateChange.iterator();

        Subscription_Rate_Change__c fetchedSRC = new Subscription_Rate_Change__c();

        while (iteratorOnSRC.hasNext()) {
            fetchedSRC = (Subscription_Rate_Change__c) iteratorOnSRC.next();
        }

        System.assertEquals(
            subscriptionRateChangeData[0].Id,
            fetchedSRC.Id,
            'The expected Subscription Rate Change was not fetched'
        );
    }
}