/**
 * @author Deloitte
 * @date 05/31/2023
 * @description Interface for work objects selector class methods.
 */
public interface IWorkObjectsSyncSelector {
    /**
     * @description This method is being used to get related sobjects such as workorder,
     * workplan etc.
     * @JIRA# 6198
     * @param sobjectIds
     * @return List<SObject>
     */
    List<SObject> selectParentDetailsByChildIds(Set<Id> sobjectIds);
}