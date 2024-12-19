/**
 * @description DecisionMakerWrapper for showDecisionMakerOnWorkPlan lightning web component.
 * @date 07/12/2024
 * @JIRA# LEM-15997
 * @param contactId
 * @param contactName
 * @param decisionMakerDetail
 * @param phoneNumber
 */
public class DecisionMakerWrapper {
    /**
     * @description getter/setter for DecisionMakerWrapper variable
     */
    @AuraEnabled
    public String contactId { get; set; }
    /**
     * @description getter/setter for DecisionMakerWrapper variable
     */
    @AuraEnabled
    public String contactName { get; set; }
    /**
     * @description getter/setter for DecisionMakerWrapper variable
     */
    @AuraEnabled
    public List<DecisionMakerDetails> decisionMakerDetail { get; set; }
    /**
     * @description getter/setter for DecisionMakerWrapper variable
     */
    @AuraEnabled
    public String phoneNumber { get; set; }
    /**
     * @description Constructor
     * @JIRA# LEM-15997
     * @param contactId
     * @param contactName
     * @param decisionMakerDetail
     * @param phoneNumber
     */
    public DecisionMakerWrapper(
        String contactId,
        String contactName,
        List<DecisionMakerDetails> decisionMakerDetail,
        String phoneNumber
    ) {
        this.contactId = contactId;
        this.contactName = contactName;
        this.decisionMakerDetail = decisionMakerDetail;
        this.phoneNumber = phoneNumber;
    }

    /**
     * @description DecisionMakerDetails inner wrapper for workplan details.
     * @JIRA# LEM-15997
     * @param accountName
     * @param contactId
     * @param contactName
     * @param numberCallAttempts
     * @param recordId
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public class DecisionMakerDetails {
        /**
         * @description getter/setter for DecisionMakerDetails variable
         */
        @AuraEnabled
        public String accountName { get; set; }
        /**
         * @description getter/setter for DecisionMakerWrapper variable
         */
        @AuraEnabled
        public String contactId { get; set; }
        /**
         * @description getter/setter for DecisionMakerDetails variable
         */
        @AuraEnabled
        public String contactName { get; set; }
        /**
         * @description getter/setter for DecisionMakerDetails variable
         */
        @AuraEnabled
        public Integer numberCallAttempts { get; set; }
        /**
         * @description getter/setter for DecisionMakerDetails variable
         */
        @AuraEnabled
        public Id recordId;
        /**
         * @description getter/setter for DecisionMakerDetails variable
         */
        @AuraEnabled
        public String storeId;

        /**
         * @description Constructor
         * @JIRA# LEM-15997
         * @param accountName
         * @param contactId
         * @param contactName
         * @param numberCallAttempts
         * @param recordId
         * @param storeId
         */
        public DecisionMakerDetails(
            String accountName,
            String contactId,
            String contactName,
            Integer numberCallAttempts,
            Id recordId,
            String storeId
        ) {
            this.accountName = accountName;
            this.contactId = contactId;
            this.contactName = contactName;
            this.numberCallAttempts = numberCallAttempts;
            this.recordId = recordId;
            this.storeId = storeId;
        }
    }
}