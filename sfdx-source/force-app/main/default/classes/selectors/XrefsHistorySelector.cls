/**
 * @author Aethereus
 * @date 03/06/2024
 * @description Selector class for XrefsHistory object.
 */
public inherited sharing class XrefsHistorySelector extends fflib_SObjectSelector implements IXrefsHistorySelector {
    static final String TEXT = 'Text';

    /**
     * @description Default constructor for the class
     * @return IXrefsHistorySelector
     */
    public static IXrefsHistorySelector newInstance() {
        return (IXrefsHistorySelector) Application.Selector.newInstance(Xref__History.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Xref__History.SObjectType;
    }

    /**
     * @description Overriding default getSObjectFieldList method
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Xref__History.Id,
            Xref__History.CreatedDate,
            Xref__History.Field,
            Xref__History.ParentId,
            Xref__History.NewValue,
            Xref__History.OldValue
        };
    }

    /**
     * @description Retrieves Xref__History records based on the provided criteria.
     * @param allxRefFields - Set of all xref fields.
     * @param alllookUpXref - Set of all lookup xref fields.
     * @param userIds - List of user Ids.
     * @param woCreatedDate - Created date of the work order.
     * @return List of Xref__History records.
     */
    public List<Xref__History> selectXrefHistory(Set<String> allxRefFields, Set<String> alllookUpXref , List<String> userIds, DateTime woCreatedDate) {

        fflib_QueryFactory query = newQueryFactory()
            .selectField('Parent.Salesforce_Account_Name__c')
            .setCondition('(FIELD IN : allxRefFields OR (FIELD IN : alllookupxref AND DataType =: TEXT)) AND CreatedById IN :userIds AND CreatedDate >= :woCreatedDate')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Xref__History>) Database.query(query.toSOQL());
    }

}