/**
 * @author Deloitte
 * @date 26/05/2022
 * @description Wrapper class to prepare JSON payload for Tablet Case integration.
 */
public class TabletCaseEntry {
    public String figmentId;
    public Id workStepId;
    public Id workOrderId;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param workStepId
     * @param workOrderId
     */
    public TabletCaseEntry(String workStepId, String workOrderId) {
        this.workStepId = workStepId;
        this.workOrderId = workOrderId;
    }
}