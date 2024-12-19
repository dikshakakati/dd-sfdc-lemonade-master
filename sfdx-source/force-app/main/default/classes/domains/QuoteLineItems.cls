/**
 * @author Deloitte
 * @date 2023-04-25
 * @description Domain Class for SBQQ__QuoteLine__c Object
 */
public inherited sharing class QuoteLineItems extends fflib_SObjects implements IQuoteLineItems {
    static final String PIPELINE_PRODUCT_CODE = '10082';

    /**
     * @description This method is used to return the IQuoteLineItems interface
     * @param recordList - Orders record list
     * @return IQuoteLineItems - Returns IQuoteLineItems Interface
     */
    public static IQuoteLineItems newInstance(List<SBQQ__QuoteLine__c> recordList) {
        return (IQuoteLineItems) Application.Domain.newInstance(recordList);
    }
    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public QuoteLineItems(List<SBQQ__QuoteLine__c> sObjectList) {
        super(sObjectList, Schema.SBQQ__QuoteLine__c.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return QuoteLineItems - List of QuoteLineItems
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (QuoteLineItems.constructorMock != null) {
                return (fflib_SObjects) QuoteLineItems.constructorMock.construct(objectList);
            }
            return new QuoteLineItems((List<SObject>) objectList);
        }
    }
    /**
     * @description syncs quotelinefields back to the Brief Items
     */

    public void updateBriefItemsQuoteLineSyncFields() {
        QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(
            (List<SBQQ__QuoteLine__c>) getRecords()
        );
    }

    /**
     * @description updates quotelines from amendments to have Has brief item field updated
     */
    public void updateAmendmentQuoteLines() {
        QuoteLineItemsService.updateAmendmentQuoteLines((List<SBQQ__QuoteLine__c>) getRecords());
    }
}