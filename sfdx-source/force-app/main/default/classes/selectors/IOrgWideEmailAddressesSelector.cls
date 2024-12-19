/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Interface for Org Wide Email Address selector class methods.
 */
public interface IOrgWideEmailAddressesSelector extends fflib_ISObjectSelector {
    /**
     * @description It queries Org Wide Email Address based on passed Display Names.
     * @param displayNames
     * @return List<OrgWideEmailAddress>
     */
    List<OrgWideEmailAddress> selectOrgWideAddressByDisplayNames(Set<String> displayNames);
}