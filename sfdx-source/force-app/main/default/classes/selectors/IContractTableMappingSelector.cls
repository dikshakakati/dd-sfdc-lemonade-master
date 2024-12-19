/**
 * @author Aethereus
 * @date 05/27/2024
 * @description Interface to add Selector class methods
 */
public interface IContractTableMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Country Attributes Mapping records
     * @return List<Contract_Table_Mapping__mdt> - returns list of metadata records
     */
    List<Contract_Table_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Country_Attributes_Mapping__mdt
     * @return List<Schema.SObjectField>- Contract_Table_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting metadata records sorted by order and custom segment.
     * @param initiatedFromSobject
     * @param customerSegment
     * @return List<Contract_Table_Mapping__mdt>
     */
    List<Contract_Table_Mapping__mdt> selectContractTableMappingSortedByOrder(String initiatedFromSobject, String customerSegment);
    /**
     * @description It is used for getting Subscription metadata records sorted by order and custom segment.
     * @param customerSegment
     * @param splitCategory
     * @return List<Contract_Table_Mapping__mdt>
     */
    List<Contract_Table_Mapping__mdt> selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
        String customerSegment,
        String splitCategory
    );

    /**
     * @description It is used for fething metadata records for Services sorted by order and custom segment.
     * @param customerSegment
     * @return List<Contract_Table_Mapping__mdt>
     */
    List<Contract_Table_Mapping__mdt> selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
        String customerSegment
    );
}