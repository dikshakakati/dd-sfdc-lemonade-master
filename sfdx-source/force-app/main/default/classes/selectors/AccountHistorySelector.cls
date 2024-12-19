/**
 * @author Aethereus
 * @date 03/04/2024
 * @description Selector class for AccountHistory object.
 */
public inherited sharing class AccountHistorySelector extends fflib_SObjectSelector implements IAccountHistorySelector {

    /**
     * @description Default constructor for the class
     * @return IAccounthistorySelector
     */
    public static IAccountHistorySelector newInstance() {
        return (IAccountHistorySelector) Application.Selector.newInstance(AccountHistory.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AccountHistory.SObjectType;
    }

    /**
     * @description Overriding default getSObjectFieldList method
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AccountHistory.Id,
            AccountHistory.AccountId,
            AccountHistory.CreatedById,
            AccountHistory.CreatedDate,
            AccountHistory.Field,
            AccountHistory.DataType,
            AccountHistory.IsDeleted,
            AccountHistory.NewValue,
            AccountHistory.OldValue

        };
    }

    /**
     * @description Retrieves AccountHistory records based on the provided criteria.
     * @param allFields - Set of all fields.
     * @param accIds - Set of Account Ids.
     * @param userIds - List of User Ids.
     * @param woCreatedDate - Created Date of the Work Order.
     * @return List of AccountHistory records.
     */
    public List<AccountHistory> selectAccountHistory(Set<String> allFields, Set<Id> accIds, List<String> userIds, DateTime woCreatedDate) {

        fflib_QueryFactory accountHistory = newQueryFactory()
   				.selectField('Account.Name')
                .setCondition('AccountId IN :accIds AND Field IN : allFields AND CreatedById IN :userIds AND CreatedDate >= :woCreatedDate')
                .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

                return (List<AccountHistory>) Database.query(accountHistory.toSOQL());
    }

}