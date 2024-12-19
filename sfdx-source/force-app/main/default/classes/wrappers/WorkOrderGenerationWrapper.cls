/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Wrapper Class for Work Order Creation.
 **/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public class WorkOrderGenerationWrapper {
    private String type;
    private String subType;
    private String status;
    private String accountId;
    private String opportunityId;
    private String mxOnboardingLinkId;
    private String contractId;
    private Date proposedDateofActivation;
    private String primaryVertical;
    private String photoshootRequest;
    private String segment;
    private String creationSource;
    private String storeAccountIds;
    private String provisioningProcess;
    private Date proposedDateOfMenu;
    private String orderProtocol;
    private String posIntegrationType;
    private String activatedCentrally;
    private String menuToBeCompletedBy;
    private String provisioningStatus;
    private String originatingWorkOrderId;
    private String workOrderSource;
    private String menuSetUpMethod;
    private String salesNotesForMenuTeam;
    private Date photoShootDate;
    private Time photoShootTime;
    private String bundledWithMarketplace;
    private Double estimatedNumberofStores;
    private Date proposedDateofImplementation;
    private String integrationRequestId;
    private String uniqueIdentifier;
    private String businessId;
    private Boolean hasWorkPlansGenerated;
    private Id salesRepName;

    /**
     * @description Contructor to add new Work Order.
     */
    public WorkOrderGenerationWrapper() {
        this.type = '';
        this.subType = '';
        this.status = '';
        this.accountId = '';
        this.opportunityId = '';
        this.mxOnboardingLinkId = '';
        this.contractId = '';
        this.proposedDateofActivation = null;
        this.primaryVertical = '';
        this.segment = '';
        this.creationSource = '';
        this.storeAccountIds = '';
        this.provisioningProcess = '';
        this.proposedDateOfMenu = null;
        this.orderProtocol = '';
        this.posIntegrationType = '';
        this.activatedCentrally = '';
        this.menuToBeCompletedBy = '';
        this.provisioningStatus = '';
        this.originatingWorkOrderId = '';
        this.workOrderSource = '';
        this.photoshootRequest = '';
        this.menuSetUpMethod = '';
        this.salesNotesForMenuTeam = '';
        this.photoShootDate = null;
        this.photoShootTime = null;
        this.bundledWithMarketplace = '';
        this.proposedDateofImplementation = null;
        this.integrationRequestId = '';
        this.uniqueIdentifier = '';
        this.businessId = '';
        this.hasWorkPlansGenerated = false;
        this.salesRepName = null;
    }

    /**
     * @description It sets the hasWorkPlansGenerated value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setHasWorkPlansGenerated(Boolean valueToSet) {
        this.hasWorkPlansGenerated = valueToSet;
    }

    /**
     * @description It sets the integrationRequestId value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setIntegrationRequestId(String valueToSet) {
        this.integrationRequestId = valueToSet;
    }

    /**
     * @description It sets the proposedDateofImplementation value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setProposedDateOfImplementation(Date valueToSet) {
        this.proposedDateofImplementation = valueToSet;
    }

    /**
     * @description It sets the type value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setType(String valueToSet) {
        this.type = valueToSet;
    }

    /**
     * @description It sets the sub-type value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setSubType(String valueToSet) {
        this.subType = valueToSet;
    }

    /**
     * @description It sets the workOrderSource value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setWorkOrderSource(String valueToSet) {
        this.workOrderSource = valueToSet;
    }

    /**
     * @description It sets the status value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setStatus(String valueToSet) {
        this.status = valueToSet;
    }

    /**
     * @description It sets the accountId in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setAccountId(String valueToSet) {
        this.accountId = valueToSet;
    }

    /**
     * @description It sets the opportunityId in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setOpportunityId(String valueToSet) {
        this.opportunityId = valueToSet;
    }

    /**
     * @description It sets the mxOnboardingLinkId in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setMxOnboardingLinkId(String valueToSet) {
        this.mxOnboardingLinkId = valueToSet;
    }

    /**
     * @description It sets the contractId in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setContractId(String valueToSet) {
        this.contractId = valueToSet;
    }

    /**
     * @description It sets the proposedDateofActivation value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setProposedDateOfActivation(Date valueToSet) {
        this.proposedDateofActivation = valueToSet;
    }

    /**
     * @description It sets the primaryVertical value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setPrimaryVertical(String valueToSet) {
        this.primaryVertical = valueToSet;
    }

    /**
     * @description It sets the segment value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setSegment(String valueToSet) {
        this.segment = valueToSet;
    }

    /**
     * @description It sets the creationSource value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setCreationSource(String valueToSet) {
        this.creationSource = valueToSet;
    }

    /**
     * @description It sets the storeAccountIds value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setStoreAccountIds(String valueToSet) {
        this.storeAccountIds = valueToSet;
    }

    /**
     * @description It sets the provisioningProcess value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setProvisioningProcess(String valueToSet) {
        this.provisioningProcess = valueToSet;
    }

    /**
     * @description It sets the proposedDateOfMenu value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setProposedDateOfMenu(Date valueToSet) {
        this.proposedDateOfMenu = valueToSet;
    }

    /**
     * @description It sets the photoshootRequest value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setPhotoShootRequest(String valueToSet) {
        this.photoshootRequest = valueToSet;
    }

    /**
     * @description It sets the orderProtocol value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setOrderProtocol(String valueToSet) {
        this.orderProtocol = valueToSet;
    }

    /**
     * @description It sets the posIntegrationType value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setPosIntegrationType(String valueToSet) {
        this.posIntegrationType = valueToSet;
    }

    /**
     * @description It sets the activatedCentrally value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setActivatedCentrally(String valueToSet) {
        this.activatedCentrally = valueToSet;
    }

    /**
     * @description It sets the menuToBeCompletedBy value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setMenuToBeCompletedBy(String valueToSet) {
        this.menuToBeCompletedBy = valueToSet;
    }

    /**
     * @description It sets the provisioningStatus value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setProvisioningStatus(String valueToSet) {
        this.provisioningStatus = valueToSet;
    }

    /**
     * @description It sets the originatingWorkOrderId value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setOriginatingWorkOrderId(String valueToSet) {
        this.originatingWorkOrderId = valueToSet;
    }

    /**
     * @description It sets the menuSetUpMethod value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setMenuSetUpMethod(String valueToSet) {
        this.menuSetUpMethod = valueToSet;
    }

    /**
     * @description It sets the salesNotesForMenuTeam value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setSalesNotesForMenuTeam(String valueToSet) {
        this.salesNotesForMenuTeam = valueToSet;
    }

    /**
     * @description It sets the photoShootDate value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setPhotoShootDate(Date valueToSet) {
        this.photoShootDate = valueToSet;
    }

    /**
     * @description It sets the photoShootTime value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setPhotoShootTime(Time valueToSet) {
        this.photoShootTime = valueToSet;
    }

    /**
     * @description It sets the salesNotesForMenuTeam value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setBundledWithMarketplace(String valueToSet) {
        this.bundledWithMarketplace = valueToSet;
    }

    /**
     * @description It sets the estimatedNumberofStores value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setEstimatedNumberofStores(Double valueToSet) {
        this.estimatedNumberofStores = valueToSet;
    }

    /**
     * @description It sets the uniqueIdentifier value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setUniqueIdentifier(String valueToSet) {
        this.uniqueIdentifier = valueToSet;
    }

    /**
     * @description It sets the businessId value in the Wrapper for creating payload.
     * @param valueToSet
     */
    public void setBusinessId(String valueToSet) {
        this.businessId = valueToSet;
    }

    /**
     * @description It gets the type value in the wrapper for creating Work Order.
     * @return String
     */
    public String getType() {
        return this.type;
    }

    /**
     * @description It gets the Sub-type value in the wrapper for creating Work Order.
     * @return String
     */
    public String getSubType() {
        return this.subType;
    }

    /**
     * @description It gets the workOrderSource value in the wrapper for creating Work Order.
     * @return String
     */
    public String getWorkOrderSource() {
        return this.workOrderSource;
    }

    /**
     * @description It gets the status value in the wrapper for creating Work Order.
     * @return String
     */
    public String getStatus() {
        return this.status;
    }

    /**
     * @description It gets the accountId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getAccountId() {
        return this.accountId;
    }

    /**
     * @description It gets the opportunityId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getOpportunityId() {
        return this.opportunityId;
    }

    /**
     * @description It gets the mxOnboardingLinkId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getMxOnboardingLinkId() {
        return this.mxOnboardingLinkId;
    }

    /**
     * @description It gets the contractId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getContractId() {
        return this.contractId;
    }

    /**
     * @description It gets the proposedDateOfActivation value in the wrapper for creating Work Order.
     * @return Date
     */
    public Date getProposedDateOfActivation() {
        return this.proposedDateOfActivation;
    }

    /**
     * @description It gets the primaryVertical value in the wrapper for creating Work Order.
     * @return String
     */
    public String getPrimaryVertical() {
        return this.primaryVertical;
    }

    /**
     * @description It gets the photoshootRequest value in the wrapper for creating payload.
     * @return String
     */
    public String getPhotoShootRequest() {
        return this.photoshootRequest;
    }

    /**
     * @description It gets the segment value in the wrapper for creating Work Order.
     * @return String
     */
    public String getSegment() {
        return this.segment;
    }

    /**
     * @description It gets the creationSource value in the wrapper for creating Work Order.
     * @return String
     */
    public String getCreationSource() {
        return this.creationSource;
    }

    /**
     * @description It gets the storeAccountIds value in the wrapper for creating Work Order.
     * @return String
     */
    public String getStoreAccountIds() {
        return this.storeAccountIds;
    }

    /**
     * @description It gets the provisioningProcess value in the wrapper for creating Work Order.
     * @return String
     */
    public String getProvisioningProcess() {
        return this.provisioningProcess;
    }

    /**
     * @description It gets the proposedDateOfMenu value in the wrapper for creating Work Order.
     * @return Date
     */
    public Date getproposedDateOfMenu() {
        return this.proposedDateOfMenu;
    }

    /**
     * @description It gets the orderProtocol value in the wrapper for creating Work Order.
     * @return String
     */
    public String getOrderProtocol() {
        return this.orderProtocol;
    }

    /**
     * @description It gets the posIntegrationType value in the wrapper for creating Work Order.
     * @return String
     */
    public String getPosIntegrationType() {
        return this.posIntegrationType;
    }

    /**
     * @description It gets the activatedCentrally value in the wrapper for creating Work Order.
     * @return String
     */
    public String getActivatedCentrally() {
        return this.activatedCentrally;
    }

    /**
     * @description It gets the menuToBeCompletedBy value in the wrapper for creating Work Order.
     * @return String
     */
    public String getMenuToBeCompletedBy() {
        return this.menuToBeCompletedBy;
    }

    /**
     * @description It gets the provisioningStatus value in the wrapper for creating Work Order.
     * @return String
     */
    public String getProvisioningStatus() {
        return this.provisioningStatus;
    }

    /**
     * @description It gets the originatingWorkOrderId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getOriginatingWorkOrderId() {
        return this.originatingWorkOrderId;
    }

    /**
     * @description It gets the menuSetUpMethod value in the wrapper for creating Work Order.
     * @return String
     */
    public String getMenuSetUpMethod() {
        return this.menuSetUpMethod;
    }

    /**
     * @description It gets the setSalesNotesForMenuTeam value in the wrapper for creating Work Order.
     * @return String
     */
    public String getSalesNotesForMenuTeam() {
        return this.salesNotesForMenuTeam;
    }

    /**
     * @description It gets the photoShootDate value in the wrapper for creating Work Order.
     * @return Date
     */
    public Date getPhotoShootDate() {
        return this.photoShootDate;
    }

    /**
     * @description It gets the photoShootTime value in the wrapper for creating Work Order.
     * @return Date
     */
    public Time getPhotoShootTime() {
        return this.photoShootTime;
    }

    /**
     * @description It gets the photoShootTime value in the wrapper for creating Work Order.
     * @return String
     */
    public String getBundledWithMarketplace() {
        return this.bundledWithMarketplace;
    }

    /**
     * @description It gets the estimatedNumberofStores value in the wrapper for creating Work Order.
     * @return Double
     */
    public Double getEstimatedNumberofStores() {
        return this.estimatedNumberofStores;
    }

    /**
     * @description It gets the proposedDateofImplementation value in the wrapper for creating Work Order.
     * @return Date
     */
    public Date getProposedDateofImplementation() {
        return this.proposedDateofImplementation;
    }

    /**
     * @description It gets the integrationRequestId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getIntegrationRequestId() {
        return this.integrationRequestId;
    }

    /**
     * @description It gets the uniqueIdentifier value in the wrapper for creating Work Order.
     * @return String
     */
    public String getUniqueIdentifier() {
        return this.uniqueIdentifier;
    }

    /**
     * @description It gets the businessId value in the wrapper for creating Work Order.
     * @return String
     */
    public String getBusinessId() {
        return this.businessId;
    }

    /**
     * @description It gets the hasWorkPlansGenerated value in the wrapper for creating Work Order.
     * @return Boolean
     */
    public Boolean getHasWorkPlansGenerated() {
        return this.hasWorkPlansGenerated;
    }

    /**
     * @description It gets the Sales Rep Name value in the wrapper for creating Work Order.
     * @return String
     */
    public String getSalesRepName() {
        return this.salesRepName;
    }

    /**
     * @description It sets the salesRepName value in the wrapper for creating payload.
     * @param valueToSet
     */
    public void setSalesRepName(Id valueToSet) {
        this.salesRepName = valueToSet;
    }
}