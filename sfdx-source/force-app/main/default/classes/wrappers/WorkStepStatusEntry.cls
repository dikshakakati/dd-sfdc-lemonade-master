/**
 * @author Deloitte
 * @date 01/15/2023
 * @description It is used to prepare JSON payload for Work Step Status roll up.
 */
public class WorkStepStatusEntry {
    public Set<Id> parentIds;
    public Integer retryCount;
    public Set<Id> xrefIds;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param parentIds
     * @param retryCount
     */
    public WorkStepStatusEntry(Set<Id> parentIds, Integer retryCount) {
        this.parentIds = parentIds;
        this.retryCount = retryCount;
        this.xrefIds = new Set<Id>();
    }
}