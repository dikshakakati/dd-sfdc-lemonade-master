/**
 * @author Doordash
 * @date 06/30/2022
 * @description Selector class for Quote Line Drawer Attributes Mapping
 */
public inherited sharing class QuoteLineDrawAttributesSelector extends fflib_SObjectSelector implements IQuoteLineDrawAttributesSelector {
    /**
     * @description Default constructor for the Quote Line Drawer Attributes selector class
     * @return IQuoteLineDrawAttributesSelector - interface of IQuoteLineDrawAttributesSelector
     */
    public static IQuoteLineDrawAttributesSelector newInstance() {
        return (IQuoteLineDrawAttributesSelector) Application.Selector.newInstance(
            Quote_Line_Drawer_Attributes__mdt.SObjectType
        );
    }
    /**
     * @description It is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Quote_Line_Drawer_Attributes__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields on Quote_Line_Drawer_Attributes__mdt Metadata
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Quote_Line_Drawer_Attributes__mdt.Id,
            Quote_Line_Drawer_Attributes__mdt.Is_Active__c,
            Quote_Line_Drawer_Attributes__mdt.Field_API_Name__c,
            Quote_Line_Drawer_Attributes__mdt.Field_Label__c,
            Quote_Line_Drawer_Attributes__mdt.Required_for_Segment__c,
            Quote_Line_Drawer_Attributes__mdt.Applicable_Segment__c,
            Quote_Line_Drawer_Attributes__mdt.Quote_Line_Drawer_Products__c,
            Quote_Line_Drawer_Attributes__mdt.Eligible_Packages__c,
            Quote_Line_Drawer_Attributes__mdt.Eligible_for_Product__c,
            Quote_Line_Drawer_Attributes__mdt.Is_Required__c
        };
    }

    /**
     * @description This method is for getting Quote Line Attributes for a particular product
     * @JIRA# LEM-6458
     * @param prodCode
     * @return List<Quote_Line_Drawer_Attributes__mdt>
     */
    public List<Quote_Line_Drawer_Attributes__mdt> selectQLAttributesByProductCode(
        String prodCode
    ) {
        fflib_QueryFactory quoteLineAttributeQuery = newQueryFactory(false)
            .selectField('Eligible_Packages__c')
            .selectField('Eligible_for_Product__c')
            .selectField('Field_API_Name__c')
            .selectField('Required_for_Segment__c')
            .selectField('Applicable_Segment__c')
            .selectField('Is_Required__c')
            .selectField('Quote_Line_Drawer_Products__r.Is_Active__c')
            .selectField('Quote_Line_Drawer_Products__r.Product_Code__c')
            .setCondition(
                'Is_Active__c = true ' +
                    'AND Quote_Line_Drawer_Products__r.Is_Active__c = true ' +
                    'AND Quote_Line_Drawer_Products__r.Product_Code__c = :prodCode'
            );
        return (List<Quote_Line_Drawer_Attributes__mdt>) Database.query(
            quoteLineAttributeQuery.toSOQL()
        );
    }
}