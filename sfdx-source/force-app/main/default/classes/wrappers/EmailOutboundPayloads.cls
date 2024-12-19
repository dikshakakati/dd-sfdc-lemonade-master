/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Wrapper Class to store Email details for Outbound Integrations.
 **/
public class EmailOutboundPayloads {
    private static final String EMAIL_ANONYMOUS_ID = 'segmentUserID';
    private static final String EMAIL_EVENT_NAME = 'email-communications-event';
    private static final String EMAIL_PAYLOAD_CONTENT_TYPE = 'application/json';
    private static final String EMAIL_SOURCE = 'ddmx';
    private static final String EMAIL_TYPE = 'track';
    private static final String TIMEFORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String TIMESTAMPZONE = 'GMT';
    private static final String VERSION_VALUE = '1.0';

    /**
     * @description Wrapper Class to store Email details for Outbound Integrations.
     */
    public class EmailOutboundWrapper {
        private String dataContentType;
        private String eventId;
        private String eventName;
        private String sourceSystem;
        private String timeStamp;
        private String version;
        private List<EmailOutboundDetails> requestPayload;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param eventId
         */
        public EmailOutboundWrapper(String eventId) {
            this.dataContentType = EMAIL_PAYLOAD_CONTENT_TYPE;
            this.eventId = eventId;
            this.eventName = EMAIL_EVENT_NAME;
            this.requestPayload = new List<EmailOutboundDetails>();
            this.sourceSystem = EMAIL_SOURCE;
            this.timeStamp = System.Now().format(TIMEFORMAT, TIMESTAMPZONE);
            this.version = VERSION_VALUE;
        }
    }

    /**
     * @description Wrapper Class to store Email details for Outbound Integrations.
     */
    public class EmailOutboundDetails {
        private String anonymousId;
        private String event;
        private String interfaceTransactionSFID;
        private Map<String, String> properties;
        private String type;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param event
         * @param interfaceTransactionSFID
         */
        public EmailOutboundDetails(String event, String interfaceTransactionSFID) {
            this.anonymousId = EMAIL_ANONYMOUS_ID;
            this.event = event;
            this.interfaceTransactionSFID = interfaceTransactionSFID;
            this.properties = new Map<String, String>();
            this.type = EMAIL_TYPE;
        }
    }

    /**
     * @description It gets the salesforce Interface Transaction Ids value from the wrapper
     * @param emailOutboundWrapperInstance
     * @return Set<String>
     */
    public Set<String> getInterfaceTransactionSFIDs(
        EmailOutboundWrapper emailOutboundWrapperInstance
    ) {
        Set<String> interfaceTransactionIds = new Set<String>();
        for (
            EmailOutboundDetails eachEmailOutboundDetails : emailOutboundWrapperInstance.requestPayload
        ) {
            if (String.isNotBlank(eachEmailOutboundDetails.interfaceTransactionSFID)) {
                interfaceTransactionIds.add(eachEmailOutboundDetails.interfaceTransactionSFID);
            }
        }
        return interfaceTransactionIds;
    }

    /**
     * @description It sets the Interface Transaction Id in the wrapper for creating outbound request.
     * @param emailOutboundDetailsInstance
     * @param interfaceTransactionId
     */
    public void setInterfaceTransactionSFID(
        EmailOutboundDetails emailOutboundDetailsInstance,
        String interfaceTransactionId
    ) {
        emailOutboundDetailsInstance.interfaceTransactionSFID = interfaceTransactionId;
    }

    /**
     * @description It sets the request payload in the wrapper for creating outbound request.
     * @param emailOutboundWrapperInstance
     * @param emailOutboundDetailsInstance
     */
    public void setRequestPayload(
        EmailOutboundWrapper emailOutboundWrapperInstance,
        EmailOutboundDetails emailOutboundDetailsInstance
    ) {
        emailOutboundWrapperInstance.requestPayload.add(emailOutboundDetailsInstance);
    }

    /**
     * @description It sets the request payloads in the wrapper for creating outbound request.
     * @param emailOutboundWrapperInstance
     * @param emailOutboundDetailsInstances
     */
    public void setRequestPayload(
        EmailOutboundWrapper emailOutboundWrapperInstance,
        List<EmailOutboundDetails> emailOutboundDetailsInstances
    ) {
        emailOutboundWrapperInstance.requestPayload.addAll(emailOutboundDetailsInstances);
    }

    /**
     * @description It sets the merge field properties in the wrapper for creating outbound request.
     * @param emailOutboundDetailsInstances
     * @param emailProperties
     */
    public void setProperties(
        EmailOutboundDetails emailOutboundDetailsInstances,
        Map<String, String> emailProperties
    ) {
        emailOutboundDetailsInstances.properties = emailProperties;
    }
}