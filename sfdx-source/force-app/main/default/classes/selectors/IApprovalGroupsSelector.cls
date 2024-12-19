/**
 * @author Deloitte
 * @date 04/20/2024
 * @description Interface to add selector class methods.
 */
public interface IApprovalGroupsSelector extends fflib_ISObjectSelector {

    /**
     * @description This method is for getting the fields on Approval_Group__mdt
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description This method is used for getting Approval_Group__mdt
     * @return list<Approval_Group__mdt>
     */
    List<Approval_Group__mdt> selectApprovalGroups();
}