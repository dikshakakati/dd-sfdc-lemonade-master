/**
 * @author DoorDash
 * @date 08/25/2023
 * @description Selector class for Rate_Card_Tier__c object.
 */
public inherited sharing class RateCardTiersSelector extends fflib_SObjectSelector implements IRateCardTiersSelector {
    /**
     * @description Default constructor for the class.
     * @return IRateCardTiersSelector - Returns interface of RateCardTiersSelector
     */
    public static IRateCardTiersSelector newInstance() {
        return (IRateCardTiersSelector) Application.Selector.newInstance(Rate_Card_Tier__c.SObjectType);
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Rate_Card_Tier__c.SObjectType;
    }

    /**
     * @description It is for getting the fields of Rate_Card_Tier__c.
     * @return List<Schema.SObjectField> - Rate_Card_Tier__c fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Rate_Card_Tier__c.Id,
            Rate_Card_Tier__c.Lower_Bound__c,
            Rate_Card_Tier__c.Upper_Bound__c,
            Rate_Card_Tier__c.Fee_Value__c,
            Rate_Card_Tier__c.Rate_Card__c
        };
    }
}