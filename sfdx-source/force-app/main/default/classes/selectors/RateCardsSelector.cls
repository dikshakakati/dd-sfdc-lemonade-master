/**
 * @author DoorDash
 * @date 08/25/2023
 * @description Selector class for Rate_Card__c object.
 */
public inherited sharing class RateCardsSelector extends fflib_SObjectSelector implements IRateCardsSelector {
    /**
     * @description Default constructor for the class.
     * @return IRateCardsSelector - Returns interface of RateCardsSelector
     */
    public static IRateCardsSelector newInstance() {
        return (IRateCardsSelector) Application.Selector.newInstance(Rate_Card__c.SObjectType);
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Rate_Card__c.SObjectType;
    }

    /**
     * @description It is for getting the fields of Rate_Card__c.
     * @return List<Schema.SObjectField> - Rate_Card__c fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Rate_Card__c.Id,
            Rate_Card__c.State__c,
            Rate_Card__c.Fee_Type__c,
            Rate_Card__c.Requested_Fee__c,
            Rate_Card__c.Quote_Line__c
        };
    }

    /**
     * @description It queries Rate Cards and Rate Card Tiers by set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<Rate_Card__c>
     */
    public List<Rate_Card__c> selectByQuoteLineIds(Set<Id> quoteLineIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Quote_Line__c IN: quoteLineIds');

        new RateCardTiersSelector()
            .addQueryFactorySubselect(query, 'Rate_Card_Tiers__r')
            .setOrdering('Fee_Value__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        return (List<Rate_Card__c>) Database.query(query.toSOQL());
    }
}