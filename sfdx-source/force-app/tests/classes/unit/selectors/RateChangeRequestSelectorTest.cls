/**
 * @author Deloitte
 * @date 16/09/2023
 * @description This is test class for RateChangeRequestSelector class
 */
@isTest(seeAllData=false)
public class RateChangeRequestSelectorTest {
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
        RateChangeRequestSelector selectorInstance = new RateChangeRequestSelector();
        Schema.SObjectType typeOfObject = selectorInstance.getSObjectType();
        System.assertEquals(
            Schema.Rate_Change_Request__c.SObjectType,
            typeOfObject,
            'The object type must be Rate_Change_Request__c'
        );

        List<Schema.SObjectField> fieldList = selectorInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Rate_Change_Request__c.Id,
                Rate_Change_Request__c.Activation_Status__c,
                Rate_Change_Request__c.Order_Products_Updated__c,
                Rate_Change_Request__c.Contract__c,
                Rate_Change_Request__c.Effective_Date__c,
                Rate_Change_Request__c.Name,
                Rate_Change_Request__c.S_O_Support_Request_Link__c,
                Rate_Change_Request__c.Status__c,
                Rate_Change_Request__c.Associated_stores_updated__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenRateChangesArePassedThenSelectorCallSelectRateChangeRequestById() {
        List<Rate_Change_Request__c> rateChangeData = [
            SELECT id
            FROM Rate_Change_Request__c
            LIMIT 1
        ];
        Set<Id> rateChangeIds = new Set<Id>();
        for (Rate_Change_Request__c rateChange : rateChangeData) {
            rateChangeIds.add(rateChange.Id);
        }

        Test.startTest();
        List<Rate_Change_Request__c> rateChangeQueryData = RateChangeRequestSelector.newInstance()
            .selectRateChangeRequestById(rateChangeIds);
        RateChangeRequestSelector.newInstance().selectByEffectiveDateToday();
        RateChangeRequestSelector.newInstance().selectRateChangeRequestByPastEffectiveDate();
        Test.stopTest();
        System.assertEquals(
            1,
            rateChangeQueryData.size(),
            'The return record is not matching with passed record'
        );
    }
}