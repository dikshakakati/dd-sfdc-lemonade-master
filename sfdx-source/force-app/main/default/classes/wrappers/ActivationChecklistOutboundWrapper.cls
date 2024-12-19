/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Parent wrapper to store Activation Checklist outbound request details.
 */
public class ActivationChecklistOutboundWrapper {
    private static final String ACTIVATION_CHECKLIST_EVENT_NAME = 'activation-checklist-event';
    private static final String ACTIVATION_CHECKLIST_PAYLOAD_CONTENT_TYPE = 'application/json';
    private static final String ACTIVATION_CHECKLIST_VALIDATION_SOURCE = 'ddmx';
    private static final String ACTIVATION_CHECKLIST_VALIDATION_VERSION = '1.0';
    private static final String TIMEFORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String TIMESTAMPZONE = 'GMT';

    public String dataContentType;
    public String eventId;
    public String eventName;
    public List<ActivationChecklistDetails> requestPayload;
    public String sourceSystem;
    public String timeStamp;
    public String version;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param eventId
     * @param requestPayload
     */
    public ActivationChecklistOutboundWrapper(
        String eventId,
        List<ActivationChecklistDetails> requestPayload
    ) {
        this.dataContentType = ACTIVATION_CHECKLIST_PAYLOAD_CONTENT_TYPE;
        this.eventId = eventId;
        this.eventName = ACTIVATION_CHECKLIST_EVENT_NAME;
        this.requestPayload = requestPayload;
        this.sourceSystem = ACTIVATION_CHECKLIST_VALIDATION_SOURCE;
        this.timeStamp = System.Now().format(TIMEFORMAT, TIMESTAMPZONE);
        this.version = ACTIVATION_CHECKLIST_VALIDATION_VERSION;
    }

    /**
     * @description Internal wrapper to store Activation Checklist Work Steps details.
     */
    public class ActivationChecklistDetails {
        public String accountSalesforceId;
        public String businessId;
        public String businessRefSalesforceId;
        public String storeId;
        public List<String> validationsList;
        public String workStepSalesforceId;
        public String xrefSalesforceId;
    }
}