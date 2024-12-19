/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Selector class for Org Wide Email Address object.
 */
public inherited sharing class OrgWideEmailAddressesSelector extends fflib_SObjectSelector implements IOrgWideEmailAddressesSelector {
    /**
     * @description Default constructor for the class.
     * @return IOrgWideEmailAddressesSelector
     */
    public static IOrgWideEmailAddressesSelector newInstance() {
        return (IOrgWideEmailAddressesSelector) Application.Selector.newInstance(
            OrgWideEmailAddress.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Org Wide Email Address.
     * @JIRA# LEM-14703
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OrgWideEmailAddress.Id,
            OrgWideEmailAddress.Address,
            OrgWideEmailAddress.DisplayName
        };
    }

    /**
     * @description It queries Org Wide Email Address based on passed Display Names.
     * @JIRA# LEM-14703
     * @param displayNames
     * @return List<OrgWideEmailAddress>
     */
    public List<OrgWideEmailAddress> selectOrgWideAddressByDisplayNames(Set<String> displayNames) {
        fflib_QueryFactory orgWideEmailAddressQuery = newQueryFactory()
            .setCondition('DisplayName IN :displayNames');
        return (List<OrgWideEmailAddress>) Database.query(orgWideEmailAddressQuery.toSOQL());
    }
}