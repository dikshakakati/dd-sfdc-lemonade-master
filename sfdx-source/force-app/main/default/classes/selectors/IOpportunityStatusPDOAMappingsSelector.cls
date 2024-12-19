/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Interface for Opportunity_Status_PDOA_Mapping__mdt custom metadata selector.
 */
public interface IOpportunityStatusPDOAMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch all "Opportunity Status to PDOA Mappings"
     * custom metadata records for the passed Nintex Use Case mapping developer names.
     * @param nintexUseCaseDeveloperNames
     * @return List<Opportunity_Status_PDOA_Mapping__mdt>
     */
    List<Opportunity_Status_PDOA_Mapping__mdt> selectByNintexUseCaseMappings(
        Set<String> nintexUseCaseDeveloperNames
    );
}