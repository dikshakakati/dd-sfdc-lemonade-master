/**
 * @author Deloitte
 * @date 05/21/2024
 * @description Selector Class for Pricebook Entry
 */
public inherited sharing class PricebookEntriesSelector extends fflib_SObjectSelector implements IPricebookEntriesSelector {
    /**
     * @description Default Constructor for the Product Options Selector Class
     * @return IPricebookEntriesSelector - Interface of IPricebookEntriesSelector
     */
    public static IPricebookEntriesSelector newInstance() {
        return (IPricebookEntriesSelector) Application.Selector.newInstance(
            PricebookEntry.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Product Options Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ PricebookEntry.Id, PricebookEntry.Product2Id };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PricebookEntry.SObjectType;
    }

    /**
     * @description It is used for getting Pricebook Entries based on Product names and currency.
     * @param productNames
     * @param currencyIsoCode
     * @return List<PricebookEntry>
     */
    public List<PricebookEntry> selectByProductNamesAndCurrency(
        Set<String> productNames,
        String currencyIsoCode
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Product2.Id')
            .selectField('Product2.Name')
            .selectField('Product2.Description')
            .setCondition('Product2.Name IN :productNames AND CurrencyIsoCode = :currencyIsoCode');
        return (List<PricebookEntry>) Database.query(query.toSOQL());
    }
}