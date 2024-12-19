/**
 * @author Deloitte
 * @date 04/20/2024
 * @description Selector Class for Approval_Group__mdt Object
 */
public inherited sharing class ApprovalGroupsSelector extends fflib_SObjectSelector implements IApprovalGroupsSelector {
    /**
     * @description Default constructor for the Approval Groups Selector class
     * @return IApprovalGroupSelector - interface of IApprovalGroupSelector
     */
    public static IApprovalGroupsSelector newInstance() {
        return (IApprovalGroupsSelector) Application.Selector.newInstance(
            Approval_Group__mdt.SObjectType
        );
    }

    /**
     * @description This method is used for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Approval_Group__mdt.SObjectType;
    }

    /**
     * @description This method is used for getting the fields on Approval_Group__mdt object
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Approval_Group__mdt.Id,
            Approval_Group__mdt.DeveloperName
        };
    }

    /**
     * @description This method is used for getting Approval_Group__mdt based on developerName
     * @JIRA# LEM-14013
     * @return list<Approval_Group__mdt>
     */
    public List<Approval_Group__mdt> selectApprovalGroups() {
        fflib_QueryFactory approvalGroupsQuery = newQueryFactory();
        return (List<Approval_Group__mdt>) Database.query(approvalGroupsQuery.toSOQL());
    }
}