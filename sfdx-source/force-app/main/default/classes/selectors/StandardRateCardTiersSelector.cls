/**
 * @author DoorDash
 * @date 08/25/2023
 * @description Selector class for the Standard_Rate_Card_Tier__mdt custom metadata.
**/
public inherited sharing class StandardRateCardTiersSelector extends fflib_SObjectSelector implements IStandardRateCardTiersSelector {
    /**
     * @description Default constructor for the class.
     * @return IStandardRateCardTiersSelector - Returns interface of StandardRateCardTiersSelector
     */
    public static IStandardRateCardTiersSelector newInstance() {
        return (IStandardRateCardTiersSelector) Application.Selector.newInstance(Standard_Rate_Card_Tier__mdt.SObjectType);
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Standard_Rate_Card_Tier__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields of Standard_Rate_Card_Tier__mdt.
     * @return List<Schema.SObjectField> - Standard_Rate_Card_Tier__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Standard_Rate_Card_Tier__mdt.Lower_Bound__c,
            Standard_Rate_Card_Tier__mdt.Upper_Bound__c,
            Standard_Rate_Card_Tier__mdt.Fee_Value__c
        };
    }

    /**
     * @description Returns a List of Standard_Rate_Card_Tier__mdt
     * @return List<Standard_Rate_Card_Tier__mdt>
     */
    public List<Standard_Rate_Card_Tier__mdt> getAllValues() {
        fflib_QueryFactory query = newQueryFactory()
            .setOrdering('Fee_Value__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        return (List<Standard_Rate_Card_Tier__mdt>) Database.query(query.toSOQL());
    }
}