/**
 * @description This class is responsible for selecting RESSMO_Configuration__mdt records.
 */
public inherited sharing class RessmoConfigurationsSelector extends fflib_SObjectSelector implements IRessmoConfigurationsSelector{
     private static final String BACKEND_ELIGIBILITY = 'Backend_Eligibility';
    
    /**
     * @description Default constructor for the RessmoMappingsSelector class.
     * @return IRessmoConfigurationsSelector - interface of IRessmoConfigurationsSelector
     */
    public static IRessmoConfigurationsSelector newInstance() {
        return (IRessmoConfigurationsSelector) Application.Selector.newInstance(
            RESSMO_Configuration__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting RESSMO_Configuration__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return RESSMO_Configuration__mdt.SObjectType;
    }
    
     /**
     * @description It is used for getting the fields on RESSMO_Configuration__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RESSMO_Configuration__mdt.Label,
            RESSMO_Configuration__mdt.MasterLabel,
            RESSMO_Configuration__mdt.DeveloperName,
            RESSMO_Configuration__mdt.Enable_Backend_Eligibility__c
        };
    }

    /**
     * @description It is used for selecting the RESSMO_Configuration__mdt record with DeveloperName 'Backend_Eligibility'.
     * @return RESSMO_Configuration__mdt - the selected RESSMO_Configuration__mdt record
     */
    public RESSMO_Configuration__mdt selectRessmoEligibilityConfiguration(){
        return (RESSMO_Configuration__mdt)Database.query(
                                            newQueryFactory()
                                                .setCondition('DeveloperName =:BACKEND_ELIGIBILITY')
                                                .toSOQL()
                                            );
    }
}