/**
 * @description       : RESSMO_Mapping__mdt Selector class
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 08-02-2024
 * @last modified by  : Pankaj
**/
public inherited sharing class RessmoMappingsSelector extends fflib_SObjectSelector implements IRessmoMappingsSelector{
    private static final String QUOTE = 'Quote';
    private static final String CONTRACT = 'Contract';
    /**
     * @description Default constructor for the RessmoMappingsSelector class.
     * @return IRessmoMappingsSelector - interface of IRessmoMappingsSelector
     */
    public static IRessmoMappingsSelector newInstance() {
        return (IRessmoMappingsSelector) Application.Selector.newInstance(
            RESSMO_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting RESSMO_Mapping__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return RESSMO_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on RESSMO_Mapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RESSMO_Mapping__mdt.Label,
            RESSMO_Mapping__mdt.MasterLabel,
            RESSMO_Mapping__mdt.DeveloperName,
            RESSMO_Mapping__mdt.Add_to_Request__c,
            RESSMO_Mapping__mdt.Add_to_Update__c,
            RESSMO_Mapping__mdt.API_Property__c,
            RESSMO_Mapping__mdt.Data_Type__c,
            RESSMO_Mapping__mdt.Field_Details__c,
            RESSMO_Mapping__mdt.Field_Name__c,
            RESSMO_Mapping__mdt.Is_Banking__c,
            RESSMO_Mapping__mdt.Is_Required__c,
            RESSMO_Mapping__mdt.JSON_Object__c,
            RESSMO_Mapping__mdt.Object_Name__c,
            RESSMO_Mapping__mdt.Products__c
        };
    }

    /**
     * @description Retrieves all the RESSMO mappings.
     *
     * @return A list of RESSMO_Mapping__mdt records representing the mappings.
     */
    public List<RESSMO_Mapping__mdt> selectAllRessmoMappings(){
        return (List<RESSMO_Mapping__mdt>)Database.query(
                                            newQueryFactory()
                                                .setCondition('Applicable_For__c =:QUOTE')
                                                .toSOQL()
                                            );
    }

    /**
     * @description Retrieves a list of RESSMO_Mapping__mdt records where the Add_to_Update__c field is set to TRUE.
     *
     * @return List<RESSMO_Mapping__mdt> - A list of RESSMO_Mapping__mdt records.
     */
    public List<RESSMO_Mapping__mdt> selectAddToUpdateRessmoMappings(){
        return (List<RESSMO_Mapping__mdt>)Database.query(
            newQueryFactory()
            .setCondition('Add_to_Update__c = TRUE AND Applicable_For__c =:QUOTE')
            .toSOQL()
        );
    }


    /**
    * @description Select RESSMO Mapping of Contract
    * @Jira LEM-15497
    * @return List<RESSMO_Mapping__mdt>
    **/
    public List<RESSMO_Mapping__mdt> selectRessmoMappingsOfContract(){
        return (List<RESSMO_Mapping__mdt>)Database.query(
            newQueryFactory()
            .setCondition('Applicable_For__c =:CONTRACT')
            .toSOQL()
        );
    }

}