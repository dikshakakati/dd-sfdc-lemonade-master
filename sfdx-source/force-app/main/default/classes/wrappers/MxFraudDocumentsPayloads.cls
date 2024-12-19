/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Wrapper Class to store Mx Fraud Document details for Fraud Outbound Integrations.
 * Suppressed Warnings since the key values in the payload is expected to begin with capital letters.
 * Hence named the variables as per requirement and suppressed the warning.
 **/
@SuppressWarnings('PMD.FieldNamingConventions')
public class MxFraudDocumentsPayloads {
    private static final String UTC_TIMEZONE_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'hh:mm:ss\'.000z\'';

    /**
     * @description Wrapper Class to store  Mx Fraud Document details for Outbound Integrations.
     */
    public class MxFraudDocumentDetails {
        private String ExternalId;
        private String InterfaceTransactionSFID;
        private String StoreId;
        private List<VerificationDocumentsDetails> Documents;

        /**
         * @description Parameterized constructor to initialize class variables.
         * @param storeId
         */
        public MxFraudDocumentDetails(String storeId) {
            this.StoreId = storeId;
            this.ExternalId = '';
            this.InterfaceTransactionSFID = '';
            this.Documents = new List<VerificationDocumentsDetails>();
        }
    }

    /**
     * @description Wrapper Class to store Verification documents details for Outbound Integrations.
     */
    public class VerificationDocumentsDetails {
        private String Title;
        private String DocumentType;
        private String Status;
        private String Notes;
        private String Version;
        private String CreatedDate;
        private String LastModifiedDate;

        /**
         * @description Constructor to initialize class variables.
         */
        public VerificationDocumentsDetails() {
            this.Title = '';
            this.DocumentType = '';
            this.Status = '';
            this.Notes = '';
            this.Version = '';
            this.CreatedDate = '';
            this.LastModifiedDate = '';
        }
    }

    /**
     * @description It gets the Interface Transaction record Ids from the passed MxFraudDocumentDetails wrappers.
     * @param mxFraudDocumentDetails
     * @return String
     */
    public String getInterfaceTransactionSFID(MxFraudDocumentDetails mxFraudDocumentDetails) {
        String interfaceTransactionId = '';
        if (
            mxFraudDocumentDetails.InterfaceTransactionSFID != null &&
            String.isNotBlank(mxFraudDocumentDetails.InterfaceTransactionSFID)
        ) {
            interfaceTransactionId = mxFraudDocumentDetails.InterfaceTransactionSFID;
        }
        return interfaceTransactionId;
    }

    /**
     * @description It sets the Verification Document details in the wrapper for creating payload.
     * @param mxFraudDocumentDetails
     * @param mxFraudDocument
     */
    public void setVerificationDocumentDetails(
        MxFraudDocumentDetails mxFraudDocumentDetails,
        Mx_Fraud_Document__c mxFraudDocument
    ) {
        VerificationDocumentsDetails documentDetails = new VerificationDocumentsDetails();
        Integer timeZoneOffSet = TimeZoneConversion.getTimeZoneOffSet() * -1;
        if (mxFraudDocument != null) {
            documentDetails.Title = mxFraudDocument.Document_Title__c;
            documentDetails.Version = String.valueOf(mxFraudDocument.Document_Version__c);
            documentDetails.DocumentType = mxFraudDocument.Mx_Document_Type__c;
            documentDetails.Status = mxFraudDocument.Mx_Document_Verification_Status__c;
            documentDetails.Notes = mxFraudDocument.Mx_Document_Verification_Notes__c;
            documentDetails.CreatedDate = String.valueOf(
                (mxFraudDocument.CreatedDate)
                    .addhours(timeZoneOffSet)
                    .format(UTC_TIMEZONE_DATETIME_FORMAT)
            );
            documentDetails.LastModifiedDate = String.valueOf(
                (mxFraudDocument.LastModifiedDate)
                    .addhours(timeZoneOffSet)
                    .format(UTC_TIMEZONE_DATETIME_FORMAT)
            );
        }
        mxFraudDocumentDetails.Documents.add(documentDetails);
    }
    /**
     * @description It sets the Interface Transaction record Id in the wrapper for creating payload.
     * @param mxFraudDocumentDetails
     * @param interfaceTransactionId
     */
    public void setInterfaceTransactionSFID(
        MxFraudDocumentDetails mxFraudDocumentDetails,
        String interfaceTransactionId
    ) {
        mxFraudDocumentDetails.InterfaceTransactionSFID = interfaceTransactionId;
    }

    /**
     * @description It sets the Work Plan record Id in the wrapper for creating payload.
     * @param mxFraudDocumentDetails
     * @param workPlanId
     */
    public void setExternalId(MxFraudDocumentDetails mxFraudDocumentDetails, String workPlanId) {
        mxFraudDocumentDetails.ExternalId = workPlanId;
    }
}