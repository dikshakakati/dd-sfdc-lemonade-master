/**
 * @author Deloitte
 * @date 07/02/2024
 * @description Wrapper Class to store onboarding details for Outbound Integrations
 * related to Activation tracker.
 * Suppressed Warnings since the key values in the payload is expected to begin with capital letters.
 * Hence named the variables as per requirement and suppressed the warning.
 **/
@SuppressWarnings('PMD.FieldNamingConventions, PMD.ExcessivePublicCount')
public class OnboardingDetailsWrapper {
    private static final String OPPORTUNITY_SUBTYPE_COO = 'COO';
    private static final String OPPORTUNITY_TYPE_CHANGE_OF_OWNERSHIP = 'Change of Ownership';
    private static final String WORK_ORDER_STATUS_COMPLETE = 'Complete';
    private static final String WORK_ORDER_STATUS_ONBOARDING_COMPLETE = 'Onboarding Complete';

    /**
     * @description Wrapper Class to store Onboarding details for Outbound Integrations.
     */
    public class OnboardingDetailsOutboundWrapper {
        private String StoreId;
        private String DecisionMakerEmail;
        private String DecisionMakerPhone;
        private String OrderProtocol;
        private String OpportunityType;
        private ActivationsChecklistWrapper ActivationsChecklist;
        private ActivateStoreWrapper ActivateStore;
        private BusinessVerificationWrapper BusinessVerification;
        private BankingWrapper Banking;
        private CaseWrapper CaseDetailsWrapper;
        private MenuWrapper Menu;
        private IngestPOSMenuWrapper IngestPOSMenu;
        private SetupStoreWrapper SetupStore;
        private StorePOSIntegrationSetupWrapper StorePOSIntegrationSetup;
        private TabletWrapper Tablet;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param storeIdValue
         */
        public OnboardingDetailsOutboundWrapper(String storeIdValue) {
            this.StoreId = storeIdValue;
            this.DecisionMakerEmail = '';
            this.DecisionMakerPhone = '';
            this.OrderProtocol = '';
            this.OpportunityType = '';
            this.ActivationsChecklist = new ActivationsChecklistWrapper();
            this.ActivateStore = new ActivateStoreWrapper();
            this.BusinessVerification = new BusinessVerificationWrapper();
            this.Banking = new BankingWrapper();
            this.CaseDetailsWrapper = new CaseWrapper();
            this.Menu = new MenuWrapper();
            this.IngestPOSMenu = new IngestPOSMenuWrapper();
            this.SetupStore = new SetupStoreWrapper();
            this.StorePOSIntegrationSetup = new StorePOSIntegrationSetupWrapper();
            this.Tablet = new TabletWrapper();
        }
    }

    /**
     * @description Wrapper Class to store Activations Checklist details for Outbound Integrations.
     */
    public class ActivationsChecklistWrapper {
        private String Status;
        private String StatusReason;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public ActivationsChecklistWrapper() {
            this.Status = '';
            this.StatusReason = '';
        }
    }

    /**
     * @description Wrapper Class to store Activate Store details for Outbound Integrations.
     */
    public class ActivateStoreWrapper {
        private String Status;
        private String StatusReason;
        private Date ProposedDateofActivation;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public ActivateStoreWrapper() {
            this.Status = '';
            this.StatusReason = '';
            this.ProposedDateofActivation = null;
        }
    }

    /**
     * @description Wrapper Class to store Business Verification details for Outbound Integrations.
     */
    public class BusinessVerificationWrapper {
        private String Status;
        private String StatusReason;
        private List<VerificationDocumentsWrapper> Documents;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public BusinessVerificationWrapper() {
            this.Status = '';
            this.StatusReason = '';
            this.Documents = new List<VerificationDocumentsWrapper>();
        }
    }

    /**
     * @description Wrapper Class to store Verification documents details for Outbound Integrations.
     */
    public class VerificationDocumentsWrapper {
        private String Title;
        private String DocumentType;
        private String Status;
        private String Notes;
        private String Version;
        private Datetime CreatedDate;
        private Datetime LastModifiedDate;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public VerificationDocumentsWrapper() {
            this.Title = '';
            this.DocumentType = '';
            this.Status = '';
            this.Notes = '';
            this.Version = '';
            this.CreatedDate = null;
            this.LastModifiedDate = null;
        }
    }

    /**
     * @description Wrapper Class to store Banking details for Outbound Integrations.
     */
    public class BankingWrapper {
        private String Status;
        private String StatusReason;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public BankingWrapper() {
            this.Status = '';
            this.StatusReason = '';
        }
    }

    /**
     * @description Wrapper Class to store Case details for Outbound Integrations.
     */
    public class CaseWrapper {
        private String Status;
        private String StatusReason;
        private Datetime CreatedDateTime;
        private String stage;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public CaseWrapper() {
            this.Status = '';
            this.StatusReason = '';
            this.CreatedDateTime = null;
            this.stage = '';
        }
    }

    /**
     * @description Wrapper Class to store Menu details for Outbound Integrations.
     */
    public class MenuWrapper {
        private String Status;
        private String StatusReason;
        private Date ProposedDateofMenu;
        private String MenuUrl;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public MenuWrapper() {
            this.Status = '';
            this.StatusReason = '';
            this.ProposedDateofMenu = null;
            this.MenuUrl = '';
        }
    }

    /**
     * @description Wrapper Class to store Ingest POS Menu details for Outbound Integrations.
     */
    public class IngestPOSMenuWrapper {
        private String Status;
        private String StatusReason;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public IngestPOSMenuWrapper() {
            this.Status = '';
            this.StatusReason = '';
        }
    }

    /**
     * @description Wrapper Class to store Setup Store details for Outbound Integrations.
     */
    public class SetupStoreWrapper {
        private String Status;
        private String StatusReason;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public SetupStoreWrapper() {
            this.Status = '';
            this.StatusReason = '';
        }
    }

    /**
     * @description Wrapper Class to store Store POS Integration Setup details for Outbound Integrations.
     */
    public class StorePOSIntegrationSetupWrapper {
        private String Status;
        private String StatusReason;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public StorePOSIntegrationSetupWrapper() {
            this.Status = '';
            this.StatusReason = '';
        }
    }

    /**
     * @description Wrapper Class to store Tablet details for Outbound Integrations.
     */
    public class TabletWrapper {
        private String Status;
        private String StatusReason;
        private String OwnerFirstName;
        private String OwnerLastName;
        private String DeliveryMethod;
        private String TrackingNumber;
        private String ShippingCarrier;
        private String ShippingStatus;
        private String TrackingStatus;
        private String ReceivedDate;
        private ShippingAddressWrapper ShippingAddress;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public TabletWrapper() {
            this.Status = '';
            this.StatusReason = '';
            this.OwnerFirstName = '';
            this.OwnerLastName = '';
            this.DeliveryMethod = '';
            this.TrackingNumber = '';
            this.ShippingCarrier = '';
            this.ShippingStatus = '';
            this.TrackingStatus = '';
            this.ReceivedDate = '';
            this.ShippingAddress = new ShippingAddressWrapper();
        }
    }

    /**
     * @description Wrapper Class to store Shipping Address details for Outbound Integrations.
     */
    public class ShippingAddressWrapper {
        private String AddressLine1;
        private String AddressLine2;
        private String City;
        private String State;
        private String Country;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         */
        public ShippingAddressWrapper() {
            this.AddressLine1 = '';
            this.AddressLine2 = '';
            this.City = '';
            this.State = '';
            this.Country = '';
        }
    }

    /**
     * @description Wrapper Class to send failure details for Outbound Integrations.
     */
    public class FailureResponseWrapper {
        private String message;
        private Boolean successful;
        private Integer statusCode;

        /**
         * @description Parameterized constructor to set wrapper class variables.
         * @param failureMessage
         * @param isSuccess
         * @param failureStatusCode
         */
        public FailureResponseWrapper(
            String failureMessage,
            Boolean isSuccess,
            Integer failureStatusCode
        ) {
            this.message = failureMessage;
            this.successful = isSuccess;
            this.statusCode = failureStatusCode;
        }
    }

    /**
     * @description It sets the Account details in the wrapper for creating payload
     * @param onboardingDetails
     * @param storeAccount
     */
    public void setStoreAccountDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        Account storeAccount
    ) {
        onboardingDetails.OrderProtocol = setFieldValueOnPayload(storeAccount.Order_Protocol__c);
        onboardingDetails.Menu.MenuUrl = setFieldValueOnPayload(storeAccount.Menu_URL__c);
        onboardingDetails.Tablet.DeliveryMethod = setFieldValueOnPayload(
            storeAccount.Tablet_Delivery_Method__c
        );
    }

    /**
     * @description It sets the Contact details in the wrapper for creating payload
     * @param onboardingDetails
     * @param decisionMakerContact
     */
    public void setDecisionMakerContactDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        Contact decisionMakerContact
    ) {
        onboardingDetails.DecisionMakerEmail = setFieldValueOnPayload(decisionMakerContact.Email);
        onboardingDetails.DecisionMakerPhone = setFieldValueOnPayload(decisionMakerContact.Phone);
    }

    /**
     * @description It sets the Work Order details in the wrapper for creating payload
     * @param onboardingDetails
     * @param workOrder
     */
    public void setWorkOrderDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkOrder workOrder
    ) {
        onboardingDetails.ActivateStore.ProposedDateofActivation = workOrder
            ?.ParentWorkOrder
            ?.Proposed_Date_of_Activation__c;
        onboardingDetails.Menu.ProposedDateofMenu = workOrder
            ?.ParentWorkOrder
            ?.Proposed_Date_of_Menu__c;
        onboardingDetails.OpportunityType = setFieldValueOnPayload(
            workOrder.ParentWorkOrder?.Opportunity__r?.Opportunity_Sub_Type__c ==
                OPPORTUNITY_SUBTYPE_COO
                ? OPPORTUNITY_TYPE_CHANGE_OF_OWNERSHIP
                : workOrder.ParentWorkOrder?.Opportunity__r?.Type
        );
        onboardingDetails.CaseDetailsWrapper.CreatedDateTime = workOrder.CreatedDate;
        onboardingDetails.CaseDetailsWrapper.Status = setFieldValueOnPayload(
            workOrder.Status == WORK_ORDER_STATUS_ONBOARDING_COMPLETE
                ? WORK_ORDER_STATUS_COMPLETE
                : workOrder.Status
        );
    }

    /**
     * @description It sets the Activations Checklist details in the wrapper for creating payload
     * @param onboardingDetails
     * @param activationsChecklistWorkStep
     */
    public void setActivationsChecklistDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep activationsChecklistWorkStep
    ) {
        onboardingDetails.ActivationsChecklist.Status = setFieldValueOnPayload(
            activationsChecklistWorkStep.Status__c
        );
        onboardingDetails.ActivationsChecklist.StatusReason = setFieldValueOnPayload(
            activationsChecklistWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Activate Store details in the wrapper for creating payload
     * @param onboardingDetails
     * @param activateStoreWorkStep
     */
    public void setActivateStoreDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep activateStoreWorkStep
    ) {
        onboardingDetails.ActivateStore.Status = setFieldValueOnPayload(
            activateStoreWorkStep.Status__c
        );
        onboardingDetails.ActivateStore.StatusReason = setFieldValueOnPayload(
            activateStoreWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Banking details in the wrapper for creating payload
     * @param onboardingDetails
     * @param bankingWorkStep
     */
    public void setBankingDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep bankingWorkStep
    ) {
        onboardingDetails.Banking.Status = setFieldValueOnPayload(bankingWorkStep.Status__c);
        onboardingDetails.Banking.StatusReason = setFieldValueOnPayload(
            bankingWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Menu details in the wrapper for creating payload
     * @param onboardingDetails
     * @param menuWorkStep
     */
    public void setMenuDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep menuWorkStep
    ) {
        onboardingDetails.Menu.Status = setFieldValueOnPayload(menuWorkStep.Status__c);
        onboardingDetails.Menu.StatusReason = setFieldValueOnPayload(menuWorkStep.Status_Reason__c);
    }

    /**
     * @description It sets the Ingest POS Menu details in the wrapper for creating payload
     * @param onboardingDetails
     * @param ingestMenuWorkStep
     */
    public void setIngestPOSMenuDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep ingestMenuWorkStep
    ) {
        onboardingDetails.IngestPOSMenu.Status = setFieldValueOnPayload(
            ingestMenuWorkStep.Status__c
        );
        onboardingDetails.IngestPOSMenu.StatusReason = setFieldValueOnPayload(
            ingestMenuWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Setup Store details in the wrapper for creating payload
     * @param onboardingDetails
     * @param setupStoreWorkStep
     */
    public void setSetupStoreDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep setupStoreWorkStep
    ) {
        onboardingDetails.SetupStore.Status = setFieldValueOnPayload(setupStoreWorkStep.Status__c);
        onboardingDetails.SetupStore.StatusReason = setFieldValueOnPayload(
            setupStoreWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Store POS Integration Setup details in the wrapper for creating payload
     * @param onboardingDetails
     * @param integrationWorkStep
     */
    public void setStorePOSIntegrationSetupDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep integrationWorkStep
    ) {
        onboardingDetails.StorePOSIntegrationSetup.Status = setFieldValueOnPayload(
            integrationWorkStep.Status__c
        );
        onboardingDetails.StorePOSIntegrationSetup.StatusReason = setFieldValueOnPayload(
            integrationWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Tablet details in the wrapper for creating payload
     * @param onboardingDetails
     * @param tabletWorkStep
     */
    public void setTabletDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep tabletWorkStep
    ) {
        onboardingDetails.Tablet.Status = setFieldValueOnPayload(tabletWorkStep.Status__c);
        onboardingDetails.Tablet.StatusReason = setFieldValueOnPayload(
            tabletWorkStep.Status_Reason__c
        );
    }

    /**
     * @description It sets the Tablet Mx Order details in the wrapper for creating payload.
     * @param onboardingDetails
     * @param tabletMxOrder
     */
    public void setTabletMxOrderDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        MX_Order__c tabletMxOrder
    ) {
        if (tabletMxOrder.Contact__r != null) {
            onboardingDetails.Tablet.OwnerFirstName = setFieldValueOnPayload(
                tabletMxOrder.Contact__r.FirstName
            );
            onboardingDetails.Tablet.OwnerLastName = setFieldValueOnPayload(
                tabletMxOrder.Contact__r.LastName
            );
        }
        onboardingDetails.Tablet.TrackingNumber = setFieldValueOnPayload(
            tabletMxOrder.Tracking_Number__c
        );
        onboardingDetails.Tablet.ShippingCarrier = setFieldValueOnPayload(
            tabletMxOrder.Shipping_Carrier__c
        );
        onboardingDetails.Tablet.ShippingStatus = setFieldValueOnPayload(
            tabletMxOrder.Shipment_Status__c
        );
        onboardingDetails.Tablet.TrackingStatus = setFieldValueOnPayload(
            tabletMxOrder.Shipment_Status__c
        );
        Address mxOrderShippingAddress = tabletMxOrder.Merchant_Address__c;
        if (mxOrderShippingAddress != null) {
            onboardingDetails.Tablet.ShippingAddress.AddressLine1 = setFieldValueOnPayload(
                mxOrderShippingAddress.Street
            );
            onboardingDetails.Tablet.ShippingAddress.AddressLine2 = setFieldValueOnPayload(
                mxOrderShippingAddress.PostalCode
            );
            onboardingDetails.Tablet.ShippingAddress.City = setFieldValueOnPayload(
                mxOrderShippingAddress.City
            );
            onboardingDetails.Tablet.ShippingAddress.State = setFieldValueOnPayload(
                mxOrderShippingAddress.State
            );
            onboardingDetails.Tablet.ShippingAddress.Country = setFieldValueOnPayload(
                mxOrderShippingAddress.Country
            );
        }
    }

    /**
     * @description It sets the Review and Triage status reason in the wrapper for creating payload
     * @param onboardingDetails
     * @param reviewAndTriageWorkStep
     */
    public void setReviewAndTriageStatusReason(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        WorkStep reviewAndTriageWorkStep
    ) {
        onboardingDetails.CaseDetailsWrapper.StatusReason = setFieldValueOnPayload(
            reviewAndTriageWorkStep.Status_Reason__c
        );
        onboardingDetails.BusinessVerification.StatusReason = setFieldValueOnPayload(
            reviewAndTriageWorkStep.Status_Reason_Details__c
        );
    }

    /**
     * @description It sets the Business Verification Status in the wrapper for creating payload
     * @param onboardingDetails
     * @param verificationStatus
     */
    public void setBusinessVerificationStatus(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        String verificationStatus
    ) {
        onboardingDetails.BusinessVerification.Status = setFieldValueOnPayload(verificationStatus);
    }

    /**
     * @description It sets the Business Verification document details in the wrapper for creating payload
     * @param onboardingDetails
     * @param mxFraudDocumentDetails
     */
    public void setBusinessVerificationDocumentDetails(
        OnboardingDetailsOutboundWrapper onboardingDetails,
        Mx_Fraud_Document__c mxFraudDocumentDetails
    ) {
        VerificationDocumentsWrapper documentDetails = new VerificationDocumentsWrapper();
        documentDetails.Title = setFieldValueOnPayload(mxFraudDocumentDetails.Document_Title__c);
        documentDetails.Version = setFieldValueOnPayload(
            mxFraudDocumentDetails.Document_Version__c
        );
        if (mxFraudDocumentDetails != null) {
            documentDetails.DocumentType = setFieldValueOnPayload(
                mxFraudDocumentDetails.Mx_Document_Type__c
            );
            documentDetails.Status = setFieldValueOnPayload(
                mxFraudDocumentDetails.Mx_Document_Verification_Status__c
            );
            documentDetails.Notes = setFieldValueOnPayload(
                mxFraudDocumentDetails.Mx_Document_Verification_Notes__c
            );
            documentDetails.CreatedDate = mxFraudDocumentDetails.CreatedDate;
            documentDetails.LastModifiedDate = mxFraudDocumentDetails.LastModifiedDate;
        }
        onboardingDetails.BusinessVerification.Documents.add(documentDetails);
    }

    /**
     * @description It returns the String value of the details to be sent on payload.
     * @param valueToSet
     * @return String
     */
    private String setFieldValueOnPayload(Object valueToSet) {
        return valueToSet == null ? '' : String.valueOf(valueToSet);
    }
}