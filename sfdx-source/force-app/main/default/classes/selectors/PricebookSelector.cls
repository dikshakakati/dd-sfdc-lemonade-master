/**
 * @description Selector Class for Pricebook2 Object
 * @author Deloitte
 */
public inherited sharing class PricebookSelector extends fflib_SObjectSelector implements IPricebookSelector {
    /**
     * @description default constructor for the class
     * @param Opportunity.SObjectType - Opportunity object type
     * @return IPricebookSelector - interface of IPricebookSelector
     */
    public static IPricebookSelector newInstance() {
        return (IPricebookSelector) Application.Selector.newInstance(Pricebook2.SObjectType);
    }
    /**
     * @description This method is for getting the fields on Opportunity object
     * @return Opportunity- Opportunity fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Pricebook2.Id,
            Pricebook2.isActive,
            Pricebook2.isStandard
        };
    }

    /**
     * @description This method is for getting the standard pricebook
     * @return Pricebook2
     */
    public Pricebook2 selectStandardPricebook() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('isStandard = true');
        query.setLimit(1);
        return Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting object type
     * @return Opportunity- Opportunity fields
     */
    public Schema.SObjectType getSObjectType() {
        return Pricebook2.SObjectType;
    }
}