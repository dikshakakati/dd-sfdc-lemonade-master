/**
 * @author ATG
 * @date 2022-04-05
 * @description Domain Class for Order Object
 */
public inherited sharing class Orders extends fflib_SObjects implements IOrders {
    public static final String ACTIVATED = 'Activated';
    public static final Id PRIMARY_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    public static final Id ACTIVATION_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_TYPE_A_P = 'A&P';
    public static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    /**
     * @description This method is used to return the IOrders interface
     * @param recordList - Orders record list
     * @return IOrders - Returns IOrders Interface
     */
    public static IOrders newInstance(List<Order> recordList) {
        return (IOrders) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Orders(List<Order> sObjectList) {
        super(sObjectList, Schema.Order.SObjectType);
    }

    /**
     * @description Set Ready for Activation
     */
    public void setReadyForActivation() {
        for (Order order : (List<Order>) getRecords()) {
            order.RecordTypeId = ACTIVATION_RECORD_TYPE_ID;
            order.Ready_for_Activation__c = false;
            if (order.SBQQ__Quote__c != null) {
                order.RecordTypeId = PRIMARY_RECORD_TYPE_ID;
                order.Ready_for_Activation__c = true;
            }
        }
    }

    /**
     * @description set Order as Status = 'Activated'
     */
    public void setActive() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (
            Order ord : (List<Order>) getRecordsByFieldValue(
                Order.RecordTypeId,
                PRIMARY_RECORD_TYPE_ID
            )
        ) {
            if ((ord.Ready_for_Activation__c == true) && (ord.Status != ACTIVATED)) {
                Order newOrder = new Order(Id = ord.Id, Status = ACTIVATED);
                uow.registerDirty(newOrder, new List<SObjectField>{ Order.Status });
            }
        }
        commitWork(uow);
    }
    /**
     * @description It is used to set Order Status as 'Activated' for 'Activation Order'
     * for Order Type as 'A&P'.
     * @JIRA# LEM-14261
     */
    public void setStatusForActivationOrder() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            Order eachOrder : (List<Order>) getRecordsByFieldValue(
                Order.RecordTypeId,
                ACTIVATION_RECORD_TYPE_ID
            )
        ) {
            if (
                eachOrder.Account_Segment__c == ACCOUNT_SEGMENT_SMB &&
                eachOrder.Status != ACTIVATED &&
                (eachOrder.Type == ORDER_TYPE_A_P ||
                eachOrder.Unique_Identifier__c != null)
            ) {
                uow.registerDirty(
                    new Order(Id = eachOrder.Id, Status = ACTIVATED),
                    new List<SObjectField>{ Order.Status }
                );
            }
        }

        commitWork(uow);
    }

    /**
     * @description set Order as SBQQ__Contracted__c = true
     */
    public void setContracted() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for (
            Order ord : (List<Order>) getRecordsByFieldValue(
                Order.RecordTypeId,
                PRIMARY_RECORD_TYPE_ID
            )
        ) {
            if ((ord.SBQQ__Contracted__c == false) && (ord.Status == ACTIVATED)) {
                Order newOrder = new Order(Id = ord.Id, SBQQ__Contracted__c = true);
                uow.registerDirty(newOrder, new List<SObjectField>{ Order.SBQQ__Contracted__c });
            }
        }

        commitWork(uow);
    }

    /**
     * @description if an order is migrated, set the start date to the related quote's start date
     */
    public void updateEffectiveDateForMigratedOrders() {
        Map<Id, Order> quoteIdToOrderMap = new Map<Id, Order>();

        for (Order order : (List<Order>) getRecords()) {
            if (order.SBQQ__Quote__c != null) {
                quoteIdToOrderMap.put(order.SBQQ__Quote__c, order);
            }
        }

        if (quoteIdToOrderMap.isEmpty()) {
            return;
        }

        for (
            SBQQ__Quote__c quote : QuotesSelector.newInstance()
                .selectById(quoteIdToOrderMap.keySet())
        ) {
            if (
                quoteIdToOrderMap.containsKey(quote.Id) &&
                quote.Migrated_Record__c == true &&
                quote.Quote_Migration_External_ID__c != null
            ) {
                Order order = quoteIdToOrderMap.get(quote.Id);

                if (order.EffectiveDate != quote.SBQQ__StartDate__c) {
                    order.EffectiveDate = quote.SBQQ__StartDate__c;
                }
            }
        }
    }

    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Orders - List of Orders
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Orders.constructorMock != null) {
                return (fflib_SObjects) Orders.constructorMock.construct(objectList);
            }
            return new Orders((List<SObject>) objectList);
        }
    }
}