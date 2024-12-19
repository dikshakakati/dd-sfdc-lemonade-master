/**
 * @description Interface to add QuoteLineItems domain class methods
 * @author Deloitte
 */
public interface IQuoteLineItems extends fflib_ISObjects {
    /**
     * @description updates brief items with field data from the quote lines
     */
    void updateBriefItemsQuoteLineSyncFields();
    /**
     * @description update Amended Quotelines to have has brief item field updated
     */
    void updateAmendmentQuoteLines();
}