/**
 * @author Deloitte
 * @date 07/11/2024
 * @description Interface for Content Versions domain class methods.
 */
public interface IContentVersions extends fflib_ISObjects {
    /**
     * @description It associates the newly created Fraud Content Version records to Fraud Library
     * and Mx Fraud Document record.
     * @JIRA LEM-17403
     */
    void addToMxFraudDocuments();
}