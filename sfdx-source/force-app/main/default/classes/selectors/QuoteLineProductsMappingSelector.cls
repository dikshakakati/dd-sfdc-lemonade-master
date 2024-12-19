/**
 * @author DoorDash
 * @date 06/30/2022
 * @description Selector class for Quote Line DrawerProducts Custom Metadata mapping
 */
public inherited sharing class QuoteLineProductsMappingSelector extends fflib_SObjectSelector implements IQuoteLineProductsMappingsSelector {
    /**
     * @description default constructor for the class
     * @return IQuoteLineProductsMappingsSelector - interface of QuoteLineProductsMappingSelector
     */
    public static IQuoteLineProductsMappingsSelector newInstance() {
        return (IQuoteLineProductsMappingsSelector) Application.Selector.newInstance(
            Quote_Line_Drawer_Products__mdt.SObjectType
        );
    }
    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Quote_Line_Drawer_Products__mdt.SObjectType;
    }

    /**
     * @description Method fetches all metadata records
     * @return List<Quote_Line_Drawer_Products__mdt> - returns list of metadata records
     */
    public List<Quote_Line_Drawer_Products__mdt> getAllActiveQuoteLineProducts() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Is_Active__c = true');
        return (List<Quote_Line_Drawer_Products__mdt>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting the fields on Quote_Line_Drawer_Products__mdt
     * @return List<Schema.SObjectField>- Quote_Line_Drawer_Products__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Quote_Line_Drawer_Products__mdt.Id,
            Quote_Line_Drawer_Products__mdt.Is_Active__c,
            Quote_Line_Drawer_Products__mdt.Product_Code__c
        };
    }
    /**
     * @description This method is for getting Quote Line Products with Attributes
     * @JIRA# LEM-1486
     * @return List<Quote_Line_Drawer_Products__mdt>
     */
    public List<Quote_Line_Drawer_Products__mdt> selectQLProductsWithAttributes() {
        fflib_QueryFactory quoteLineProductsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Product_Code__c')
            .selectField('Package__c')
            .selectField('Is_Active__c')
            .setCondition('Is_Active__c = true');

        QuoteLineDrawAttributesSelector qleAttributesSelector = new QuoteLineDrawAttributesSelector();
        qleAttributesSelector.ignoreCRUD();
        qleAttributesSelector.addQueryFactorySubselect(
                quoteLineProductsQuery,
                'Quote_Line_Drawer_Attributes__r'
            )
            .selectField('Is_Active__c')
            .selectField('Field_API_Name__c')
            .selectField('Required_for_Segment__c')
            .selectField('Applicable_Segment__c')
            .setCondition('Is_Active__c = true')
            .addOrdering('Is_Active__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Quote_Line_Drawer_Products__mdt>) Database.query(
            quoteLineProductsQuery.toSOQL()
        );
    }

    /**
     * @description It is used to fetch Quote Line Products with Attributes related to the passed set of Product Codes.
     * @param productCodes
     * @return List<Quote_Line_Drawer_Products__mdt>
     */
    public List<Quote_Line_Drawer_Products__mdt> selectQLProductsWithRequiredAttributesByProductCode(
        Set<String> productCodes
    ) {
        fflib_QueryFactory quoteLineProductsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Product_Code__c')
            .selectField('Package__c')
            .selectField('Is_Active__c')
            .setCondition('Is_Active__c = true AND Product_Code__c IN: productCodes');

        QuoteLineDrawAttributesSelector qleAttributesSelector = new QuoteLineDrawAttributesSelector();
        qleAttributesSelector.ignoreCRUD();
        qleAttributesSelector.addQueryFactorySubselect(
                quoteLineProductsQuery,
                'Quote_Line_Drawer_Attributes__r'
            )
            .selectField('Is_Active__c')
            .selectField('Field_API_Name__c')
            .selectField('Required_for_Segment__c')
            .selectField('Applicable_Segment__c')
            .selectField('Eligible_Packages__c')
            .selectField('Eligible_for_Product__c')
            .setCondition('Is_Active__c = true AND Required_for_Segment__c != null')
            .setCondition('Is_Active__c = true AND Is_Required__c = true');
        return (List<Quote_Line_Drawer_Products__mdt>) Database.query(
            quoteLineProductsQuery.toSOQL()
        );
    }
}