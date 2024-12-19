/**
 * @author Deloitte
 * @date 07/07/2024
 * @JIRA# LEM-15585
 * @description "Place It For Me" inbound integration payload parser.
 * Suppressed warning since the variable names need to match the payload received from Mulesoft.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public class PlaceItForMePayloadParser {
    private BusinessDetails business;
    private String eventType;
    private String uuid;

    /**
     * @description Constructor to set initialize class variables.
     */
    public PlaceItForMePayloadParser() {
        this.business = new BusinessDetails();
        this.eventType = '';
        this.uuid = '';
    }

    /**
     * @description Wrapper for "Business" information received in the payload.
     */
    public class BusinessDetails {
        private String businessId;
        private String businessName;
        private Boolean isTest;
        private String phone;
        private String placementRequest;
        private String websiteProvider;
        private String websiteUrl;

        /**
         * @description Constructor to set initialize class variables.
         */
        public BusinessDetails() {
            this.businessId = '';
            this.businessName = '';
            this.isTest = false;
            this.phone = '';
            this.placementRequest = '';
            this.websiteProvider = '';
            this.websiteUrl = '';
        }
    }

    /**
     * @description It gets the Website Provider value in the wrapper.
     * @return String
     */
    public String getWebsiteProvider() {
        return this.business.websiteProvider;
    }

    /**
     * @description It gets the Website URL value in the wrapper.
     * @return String
     */
    public String getWebsiteURL() {
        return this.business.websiteUrl;
    }

    /**
     * @description It gets the Placement Request value in the wrapper.
     * @return String
     */
    public String getPlacementRequest() {
        return this.business.placementRequest;
    }
}