/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Wrapper Class for Business Verification Details.
 **/
public with sharing class BusinessVerficationDetails {
    public String storeId;
    public BusinessVerificationStatusDetails businessVerificationDetails;
    /**
     * @description Constructor to initialize the variables.
     * @param storeId
     **/
    public BusinessVerficationDetails(String storeId) {
        this.storeId = storeId;
        this.businessVerificationDetails = new BusinessVerificationStatusDetails();
    }
    /**
     * @description Wrapper to store Business Verification details.
     */
    public class BusinessVerificationStatusDetails {
        public String status;
        public String statusReason;
        public String statusNotes;
        /**
         * @description Default Constructor to initialize wrapper.
         */
        public BusinessVerificationStatusDetails() {
            this.status = null;
            this.statusReason = null;
            this.statusNotes = null;
        }
        /**
         * @description Constructor to intialize the variables.
         * @param status
         * @param statusReason
         * @param statusNotes
         */
        public BusinessVerificationStatusDetails(
            String status,
            String statusReason,
            String statusNotes
        ) {
            this.status = status;
            this.statusReason = statusReason;
            this.statusNotes = statusNotes;
        }
    }
}