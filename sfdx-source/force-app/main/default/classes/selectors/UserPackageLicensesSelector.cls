/**
 * @author Deloitte
 * @date 02/27/2023
 * @description Selector class for UserPackageLicense object.
 */
public inherited sharing class UserPackageLicensesSelector extends fflib_SObjectSelector implements IUserPackageLicensesSelector {
    /**
     * @description Default constructor for the UserPackageLicense selector class.
     * @return IUserPackageLicensesSelector
     */
    public static IUserPackageLicensesSelector newInstance() {
        return (IUserPackageLicensesSelector) Application.Selector.newInstance(
            UserPackageLicense.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on UserPackageLicense object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ UserPackageLicense.Id };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return UserPackageLicense.SObjectType;
    }

    /**
     * @description This method is used for getting UserPackageLicense records by UserIds
     * @param userIds
     * @return List<UserPackageLicense>
     */
    public List<UserPackageLicense> selectByUserIds(Set<Id> userIds) {
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory().setCondition('UserId IN: userIds');
        return (List<UserPackageLicense>) Database.query(query.toSOQL());
    }
}