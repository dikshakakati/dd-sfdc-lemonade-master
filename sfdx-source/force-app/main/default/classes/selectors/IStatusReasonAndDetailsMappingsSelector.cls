/**
 * @author Deloitte
 * @date 10/13/2023
 * @description Interface of selector class for Status_Reason_And_Details_Mapping__mdt metadata.
 *
 */
public interface IStatusReasonAndDetailsMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting all records and associated Business Friendly Mappings for
     * Status_Reason_And_Details_Mapping__mdt.
     * @JIRA# LEM-9964
     * @return List<Status_Reason_And_Details_Mapping__mdt>
     */
    List<Status_Reason_And_Details_Mapping__mdt> getAllMappings();
}