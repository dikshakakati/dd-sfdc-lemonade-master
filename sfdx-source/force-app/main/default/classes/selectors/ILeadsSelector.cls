/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Interface to add Lead Selector class methods
 */
public interface ILeadsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get Leads with matching
     * email address, company and address.
     * @JIRA# 13420
     * @param emailAddress
     * @param company
     * @return List<Lead>
     */
    List<Lead> selectLeadsByEmailAndCompany(String emailAddress, String company);

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Lead>
     */
    List<Lead> selectById(Set<Id> idSet);

    /**
     * @description It is used to get Leads by passed matching unique identifiers.
     * @param uniqueIdentifiers
     * @return List<Lead>
     */
    List<Lead> selectByUniqueIdentifiers(Set<String> uniqueIdentifiers);
}