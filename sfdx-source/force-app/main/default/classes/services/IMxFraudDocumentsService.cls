/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Interface of service class for Mx Fraud Document related logic.
 */
public interface IMxFraudDocumentsService {
    /**
     * @description It generates payload based on Mx Fraud Document details
     * and sends payload for outbound integration.
     * @param mxFraudDocuments
     */
    void sendMxFraudDocumentDetailsForOutboundIntegration(
        List<Mx_Fraud_Document__c> mxFraudDocuments
    );
}