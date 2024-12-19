/**
 * @description       : IRessmoMappingsSelector interface for RessmoMappingsSelector
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 07-31-2024
 * @last modified by  : Pankaj
**/
public interface IRessmoMappingsSelector extends fflib_ISObjectSelector
{
    /**
     * @description Retrieves all the RESSMO mappings.
     *
     * @return A list of RESSMO_Mapping__mdt records representing the mappings.
     */
    List<RESSMO_Mapping__mdt> selectAllRessmoMappings();

    /**
     * @description Retrieves a list of RESSMO_Mapping__mdt records where the Add_to_Update__c field is set to TRUE.
     *
     * @return List<RESSMO_Mapping__mdt> - A list of RESSMO_Mapping__mdt records.
     */
    List<RESSMO_Mapping__mdt> selectAddToUpdateRessmoMappings();

    /**
    * @description Select RESSMO Mapping of Contract where Applicable_For__c = contract
    * @Jira LEM-15497
    * @return List<RESSMO_Mapping__mdt>
    **/
    List<RESSMO_Mapping__mdt> selectRessmoMappingsOfContract();
}