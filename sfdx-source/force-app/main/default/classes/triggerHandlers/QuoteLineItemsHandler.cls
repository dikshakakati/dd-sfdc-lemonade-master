/**
 * @author Deloitte
 * @date 2023-04-25
 * @description SBQQ__QuoteLine__c Object Trigger Handler.
 */
public with sharing class QuoteLineItemsHandler extends ApplicationDomainHandler {
    private Set<Schema.SObjectField> qLineFields = new Set<Schema.SOBjectField>();
    private static final String AMENDED = 'Amended';
    /**
     * @description Constructor Method for QuoteLineItemsHandler class
     * @param sObjects - SBQQ__QuoteLine__c Records List
     */
    public QuoteLineItemsHandler(List<SBQQ__QuoteLine__c> sObjects) {
        super(sObjects);
        setContextBypass(SBQQ__QuoteLine__c.SObjectType, QuoteLineItemsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - List of SObjects
         * @return AccountContactRelationsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new QuoteLineItemsHandler(sObjects);
        }
    }

    public override void onBeforeInsert() {
        QuoteLineItems.newInstance(amendedQuoteLines()).updateAmendmentQuoteLines();
    }

    /**
     * @description LEM-13065 Delete Brief Items before delete an associated Quote Line.
     */
    public override void onBeforeDelete(){
        QuoteLineItemsService.deleteBriefItemBeforeQuoteLineIsDeleted((List<SBQQ__QuoteLine__c>) existingRecords.values());
    }

    /**
     * @description Used to get a list of quotelines that are amendment quotelines
     * @return List<SBQQ__QuoteLine__c>
     */
    private List<SBQQ__QuoteLine__c> amendedQuoteLines() {
        return new List<SBQQ__QuoteLine__c>(
            (List<SBQQ__QuoteLine__c>) getRecordsByFieldValue(SBQQ__QuoteLine__c.Type__c, AMENDED)
        );
    }
}