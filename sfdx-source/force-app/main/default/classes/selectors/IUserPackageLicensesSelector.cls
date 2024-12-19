/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Interface to UserPackageLicense selector class methods
 */
public interface IUserPackageLicensesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting the fields on UserPackageLicense
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting UserPackageLicenses records by UserIds
     * @param userIds
     * @return List<UserPackageLicense>
     */
    List<UserPackageLicense> selectByUserIds(Set<Id> userIds);
}