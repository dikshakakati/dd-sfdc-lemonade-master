/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Service class for Mx Fraud Document related logic.
 */
public inherited sharing class MxFraudDocumentsService {
    /**
     * @description It generates payload based on Mx Fraud Document details
     * and sends payload for outbound integration.
     * @JIRA# LEM-15836
     * @param mxFraudDocuments
     */
    public static void sendMxFraudDocumentDetailsForOutboundIntegration(
        List<Mx_Fraud_Document__c> mxFraudDocuments
    ) {
        service().sendMxFraudDocumentDetailsForOutboundIntegration(mxFraudDocuments);
    }

    /**
     * @description It creates and returns instance of IMxFraudDocumentsService
     * to call methods from MxFraudDocumentsServiceImpl.
     * @JIRA# LEM-15836
     * @return IMxFraudDocumentsService
     */
    private static IMxFraudDocumentsService service() {
        return (IMxFraudDocumentsService) Application.SERVICE.newInstance(
            IMxFraudDocumentsService.class
        );
    }
}