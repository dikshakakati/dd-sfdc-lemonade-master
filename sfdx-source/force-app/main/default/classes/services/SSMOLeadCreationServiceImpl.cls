/**
 * @author Deloitte
 * @date   05/16/2024
 * @description This is the service implementation class for Lead creation on SSMO fallout event
 */
public inherited sharing class SSMOLeadCreationServiceImpl implements ISSMOLeadCreationService {
    private static final String COMPLETED = 'Completed';
    private static final Integer LEAD_NO_OF_LOCATION = 1;
    private static final String LEAD_EMAIL_VERIFICATION_VALID = 'Valid';
    private static final String LEAD_EMAIL_VERIFICATION_INVALID = 'Invalid';
    private static final String LEAD_IN_COVERAGE = 'In Coverage';
    private static final String LEAD_NOT_IN_COVERAGE = 'Not In Coverage';
    private static final String LOG_UPSERT_LEAD_ACCOUNT = 'Upserting account on basis of payload failed';
    private static final String LOG_DOMAIN = 'SSMO';
    private static final String NAME_UNKNOWN = 'Unknown';
    private static final String LEAD_EMAIL_VERIFICATION_UNVERIFIED = 'Unverified';
    private static final String LEAD_STATUS_UNTOUCHED = 'Untouched';
    private static final String LEAD_STATUS_DISQUALIFIED = 'Disqualified';
    private static final String LEAD_STATUS_TRYING_TO_REACH = 'Trying to Reach';
    private static final String LEAD_STATUS_DM_FOUND = 'DM Found';
    private static final String LEAD_STATUS_NOT_INTERESTED_COOL_DOWN = 'Not Interested - Cool Down';
    private static final String LEAD_CREATION_FAILED_BUSINESS_ERROR_MESSAGE = 'Fallout SSMO Lead creation failed';
    private static final String LOG_SALES_DOMAIN = 'Sales';
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String SSMO_DROP_OFF = 'SSMO Drop Off';
    private static final Date TOMORROW = System.today().addDays(1);
    private static final String LOG_TASK_INSERT_FAILED = 'Creation on Task records failed';
    private static final String SUBMARKET_FAILED_BUSINESS_ERROR_MESSAGE = 'SubMarket creation failed';
    private static final String STATUS_VERIFIED = 'Verified';
    private static final Map<String, String> ORDER_PROTOCOL_MAPPING = SSMOFalloutWrapper.ORDER_PROTOCOL_MAPPING;
    private static final Map<String, String> LOCALE_LANGUAGE_MAPPING = SSMOFalloutWrapper.LOCALE_LANGUAGE_MAPPING;
    private static final Map<String, String> PRIMARY_VERTICAL_MAPPING = SSMOFalloutWrapper.PRIMARY_VERTICAL_MAPPING;
    private static final Map<String, String> UUID_TO_PACKAGE_TYPE_MAPPING = SSMOFalloutWrapper.UUID_TO_PACKAGE_TYPE_MAPPING;
    private static final Map<String, String> SELF_SERVE_STEP_MAPPING = SSMOFalloutWrapper.SELF_SERVE_STEP_MAPPING;
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String BUSINESS_ERROR_MESSAGE_TASK_CREATION = 'Task creation on Lead update is failed.';
    private static final Integer FIRSTNAME_LASTNAME_MAX_LENGTH = 40;

    /**
     * @description It is used to populate lead with Basic fields on basis of payload.
     * @param payLoad
     * @param leadToInsert
     * @param queueId
     * @return Lead
     */
    public Lead insertLead(SSMOFalloutWrapper payLoad, Lead leadToInsert, Id queueId) {
        String firstName = String.isNotEmpty(payload.ownerFirstName)
        ? ((payload.ownerFirstName).length() > FIRSTNAME_LASTNAME_MAX_LENGTH)
            ? (payload.ownerFirstName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH) : payload.ownerFirstName
        : NAME_UNKNOWN;
        String lastName = String.isNotEmpty(payload.ownerLastName)
        ? ((payload.ownerLastName).length() > FIRSTNAME_LASTNAME_MAX_LENGTH)
            ? (payload.ownerLastName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH) : payload.ownerLastName
        : NAME_UNKNOWN;
        leadToInsert.FirstName = firstName;
        leadToInsert.LastName = lastName;
        leadToInsert.Company = payload.storeName;
        leadToInsert.MobilePhone = payload.ownerPhone;
        leadToInsert.Email = payload.email;
        leadToInsert.NumberOfLocations__c = LEAD_NO_OF_LOCATION;
        leadToInsert.OwnerId = (queueId != null) ? queueId : null;
        leadToInsert.Package__c = UUID_TO_PACKAGE_TYPE_MAPPING.containsKey(
                payLoad.selectedPackageUuid
            )
            ? UUID_TO_PACKAGE_TYPE_MAPPING.get(payLoad.selectedPackageUuid)
            : '';
        leadToInsert.Unique_Id__c = payLoad.id;
        leadToInsert.Last_Inbound_Date_Time__c = payLoad.createdAt;
        return leadToInsert;
    }

    /**
     * @description It is used to populate lead with Additional fields on basis of payload.
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */

    public Lead updateLead(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        leadToUpdate = updateLeadFields(inputPayload, leadToUpdate);
        leadToUpdate = updateLeadAdditionalFields(inputPayload, leadToUpdate);
        return leadToUpdate;
    }
    /**
     * @description It is used to create new task on lead when the lead is in open status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    public void createTaskOnLeadAfterFallout(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    ) {
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        Set<Id> inboundIngestionLogIds = new Set<Id>();
        Lead oldLead = new Lead();
        for (Lead eachLead : leadsToBeUpdatedOnFallout) {
            oldLead = existingLeads.get(eachLead.Id);
            if (isLeadMatchingCriteriaForTaskCreation(eachLead, oldLead)) {
                inboundIngestionLogIds.add(eachLead.Inbound_Ingestion_Log__c);
                Task task = new Task(
                    WhoId = eachLead.Id,
                    Subject = SSMO_DROP_OFF,
                    Type = SSMO_DROP_OFF,
                    ActivityDate = TOMORROW,
                    OwnerID = eachLead.OwnerID
                );
                unitOfWork.registerNew(task);
            }
        }
        if (!leadsToBeUpdatedOnFallout.isEmpty()) {
            commitWork(
                unitOfWork,
                inboundIngestionLogIds,
                leadsToBeUpdatedOnFallout[0].SSMO_UUID__c,
                leadsToBeUpdatedOnFallout[0].Unique_Id__c
            );
        }
    }

    /**
     * @description It checks criteria whether the SSMO fallout scenario Lead is eligible for
     * task creation.
     * @param newLead
     * @param oldLead
     * @return Boolean
     */
    private Boolean isLeadMatchingCriteriaForTaskCreation(Lead newLead, Lead oldLead) {
        return (newLead.SSMO_UUID__c != null &&
        String.isEmpty(newLead.SSMO_Matching_Account_Id__c) &&
        (newLead.Status == LEAD_STATUS_UNTOUCHED ||
        newLead.Status == LEAD_STATUS_TRYING_TO_REACH ||
        newLead.Status == LEAD_STATUS_DM_FOUND) &&
        oldLead.Status != LEAD_STATUS_NOT_INTERESTED_COOL_DOWN &&
        oldLead.Status != LEAD_STATUS_DISQUALIFIED);
    }

    /**
     * @description A common method to commit unit of work.
     * @param unitOfWork
     * @param inboundIngestionLogIds
     * @param uuid
     * @param uniqueId
     */
    private static void commitWork(
        fflib_ISObjectUnitOfWork unitOfWork,
        Set<Id> inboundIngestionLogIds,
        String uuid,
        String uniqueId
    ) {
        List<Id> currentInboundIngestionLogIds = new List<Id>();
        currentInboundIngestionLogIds.addAll(inboundIngestionLogIds);
        try {
            unitOfWork.commitWork();
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                'Completed',
                '',
                '',
                ''
            );
        } catch (Exception e) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                'Failed',
                e.getMessage(),
                e.getStackTraceString(),
                BUSINESS_ERROR_MESSAGE_TASK_CREATION
            );
            IInboundIngestionLoggerEntry loggerEntry = InboundIngestionLoggerService.createInboundIngestionLog(
                LOG_SELF_SERVING_FALLOUT_SERVICE,
                LOG_SALES_DOMAIN,
                currentInboundIngestionLogIds[0],
                uuid,
                uniqueId
            );
            InboundIngestionLoggerService.logException(
                loggerEntry,
                e,
                LEAD_CREATION_FAILED_BUSINESS_ERROR_MESSAGE,
                '',
                new Set<String>{},
                e.getTypeName()
            );
        }
    }
    /**
     * @description It is used to populate lead with Additional fields on basis of payload.
     * @param leadsToBeUpdatedOnFallout
     */
    public void updateFieldsOnLeadAfterFallout(List<Lead> leadsToBeUpdatedOnFallout) {
        for (Lead eachLead : leadsToBeUpdatedOnFallout) {
            if (
                eachLead.Inbound_Ingestion_Log__c != null &&
                String.isEmpty(eachLead.SSMO_Matching_Account_Id__c) &&
                (eachLead.Status == LEAD_STATUS_NOT_INTERESTED_COOL_DOWN ||
                eachLead.Status == LEAD_STATUS_DISQUALIFIED)
            ) {
                eachLead.Status = LEAD_STATUS_UNTOUCHED;
            }
        }
    }

    /**
     * @description It is used to update additional Lead fields
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    private Lead updateLeadAdditionalFields(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        if (leadToUpdate.Coverage__c == LEAD_IN_COVERAGE) {
            leadToUpdate.Coverage_Start_Date__c = DateTime.now();
        }
        if (inputPayload.hasValidEmail != null) {
            leadToUpdate.EmailVerificationStatus__c = inputPayload.hasValidEmail
                ? LEAD_EMAIL_VERIFICATION_VALID
                : LEAD_EMAIL_VERIFICATION_INVALID;
        } else {
            leadToUpdate.EmailVerificationStatus__c = LEAD_EMAIL_VERIFICATION_UNVERIFIED;
        }
        leadToUpdate.PrimaryVertical__c = PRIMARY_VERTICAL_MAPPING.containsKey(
                inputPayload.verticalType
            )
            ? PRIMARY_VERTICAL_MAPPING.get(inputPayload.verticalType)
            : PRIMARY_VERTICAL_RX;
        if (inputPayload.selfServeStep != null && !String.isEmpty(inputPayload.selfServeStep)) {
            leadToUpdate.Self_Serve_Step__c = SELF_SERVE_STEP_MAPPING.containsKey(
                    inputPayload.selfServeStep
                )
                ? SELF_SERVE_STEP_MAPPING.get(inputPayload.selfServeStep)
                : '';
        }
        return leadToUpdate;
    }

    /**
     * @description It is used to update additional Lead fields
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    private Lead updateLeadFields(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        leadToUpdate = updateAddressVerificationLeadFields(inputPayload, leadToUpdate);
        leadToUpdate = updateLeadAddress(inputPayload, leadToUpdate);
        leadToUpdate.SSMO_UUID__c = inputPayload.sourceUniqueId;
        leadToUpdate.Unique_Id__c = inputPayload.id;
        leadToUpdate.Phone = String.isNotEmpty(inputPayload.businessPhone)
            ? String.valueOf(inputPayload.businessPhone)
            : leadToUpdate.Phone;
        leadToUpdate.Store_ID__c = (inputPayload.storeId != null)
            ? String.valueOf(inputPayload.storeId)
            : leadToUpdate.Store_ID__c;
        leadToUpdate.Business_Id__c = (inputPayload.businessId != null)
            ? String.valueOf(inputPayload.businessId)
            : leadToUpdate.Business_Id__c;
        leadToUpdate = updateOrderProtocolLeadFields(inputPayload, leadToUpdate);
        return leadToUpdate;
    }

    /**
     * @description It is to update the inbound ingestion logs to completed status on lead updation when in closed status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    public void updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    ) {
        Set<Id> inboundIngestionLogIds = new Set<Id>();
        Lead oldLead = new Lead();
        for (Lead eachLead : (List<Lead>) leadsToBeUpdatedOnFallout) {
            oldLead = existingLeads.get(eachLead.Id);
            if (eachLead.Inbound_Ingestion_Log__c != null && eachLead.SSMO_UUID__c != null) {
                if (
                    (oldLead.Status == LEAD_STATUS_NOT_INTERESTED_COOL_DOWN ||
                    oldLead.Status == LEAD_STATUS_DISQUALIFIED) &&
                    eachLead.Status == LEAD_STATUS_UNTOUCHED
                ) {
                    inboundIngestionLogIds.add(eachLead.Inbound_Ingestion_Log__c);
                }
            }
        }
        if (!inboundIngestionLogIds.isEmpty()) {
            InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
                inboundIngestionLogIds,
                COMPLETED,
                '',
                '',
                ''
            );
        }
    }
    /**
     * @description It is used to update the address in the Lead
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    private Lead updateLeadAddress(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        if (
            inputPayload.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED &&
            inputPayload.addressVerificationInfo?.validatedAddress != null
        ) {
            leadToUpdate.Address_ID__c = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.addressId;
            leadToUpdate.City = inputPayload?.addressVerificationInfo?.validatedAddress?.city;
            leadToUpdate.PostalCode = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.postalCode;
            leadToUpdate.country = inputPayload.addressVerificationInfo?.validatedAddress?.country;
            leadToUpdate.CountryCode = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.countryShortname;
            leadToUpdate.StateCode = inputPayload.addressVerificationInfo?.validatedAddress?.state;
            if (leadToUpdate.StateCode?.length() > 4) {
                leadToUpdate.StateCode = null;
                leadToUpdate.State = inputPayload.addressVerificationInfo?.validatedAddress?.state;
            }
            leadToUpdate = getStreetAddress(inputPayload, leadToUpdate);
            leadToUpdate.Time_Zone_Backend__c = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.timeZone;
        } else if (inputPayload.storeAddress != null) {
            leadToUpdate.City = inputPayload.storeAddress?.city;
            leadToUpdate.PostalCode = inputPayload.storeAddress?.postalCode;
            leadToUpdate.CountryCode = inputPayload.storeAddress?.country;
            leadToUpdate.StateCode = inputPayload.storeAddress?.state;
            if (leadToUpdate.StateCode?.length() > 4) {
                leadToUpdate.StateCode = null;
                leadToUpdate.State = inputPayload.storeAddress?.state;
            }
            leadToUpdate = getStreetAddress(inputPayload, leadToUpdate);
        }
        leadToUpdate.Raw_Address__c = getAddressInStringForamt(leadToUpdate);
        return leadToUpdate;
    }
    /**
     * @description It is used to update the street address in the Lead
     * @param inputPayload
     * @param leadToUpdate
     * @return String
     */
    private Lead getStreetAddress(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        String street;
        if (inputPayload.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED) {
            leadToUpdate.Street =
                (String.isNotBlank(
                        inputPayload.addressVerificationInfo?.validatedAddress?.addressLine1
                    )
                    ? inputPayload.addressVerificationInfo?.validatedAddress?.addressLine1
                    : '') +
                (String.isNotBlank(
                        inputPayload.addressVerificationInfo?.validatedAddress?.addressLine2
                    )
                    ? inputPayload.addressVerificationInfo?.validatedAddress?.addressLine2
                    : '');
        } else {
            leadToUpdate.Street =
                (String.isNotBlank(inputPayload.storeAddress?.addressLine1)
                    ? inputPayload.storeAddress?.addressLine1
                    : '') +
                (String.isNotBlank(inputPayload.storeAddress?.addressLine2)
                    ? inputPayload.storeAddress?.addressLine2
                    : '');
            if (
                (String.isBlank(inputPayload.storeAddress?.country)) &&
                (String.isNotBlank(inputPayload.storeAddress?.state))
            ) {
                leadToUpdate.Street = leadToUpdate.Street + ' ' + inputPayload.storeAddress?.state;
                leadToUpdate.State = null;
                leadToUpdate.StateCode = null;
            }
        }
        return leadToUpdate;
    }
    /**
     * @description It is used to get the Address in string format.
     * @param leadToUpdate
     * @return String
     */
    private String getAddressInStringForamt(Lead leadToUpdate) {
        List<String> rawAddress = new List<String>();
        List<String> address = new List<String>{
            leadToUpdate.Street,
            leadToUpdate.City,
            leadToUpdate.State,
            leadToUpdate.StateCode,
            leadToUpdate.Country,
            leadToUpdate.CountryCode,
            leadToUpdate.PostalCode
        };
        for (Integer iterator = 0; iterator < address.size(); iterator++) {
            if (String.isNotBlank(address[iterator])) {
                rawAddress.add(address[iterator]);
            }
        }
        return String.join(rawAddress, ', ');
    }

    /**
     * @description It is used to update Lead's Address Verification fields.
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    private Lead updateAddressVerificationLeadFields(
        SSMOFalloutWrapper inputPayload,
        Lead leadToUpdate
    ) {
        String verificationDate = inputPayload.addressVerificationInfo?.addressVerificationDate;
        leadToUpdate.Coverage__c = (String.isNotEmpty(
                inputPayload.addressVerificationInfo?.submarket?.id
            ))
            ? LEAD_IN_COVERAGE
            : LEAD_NOT_IN_COVERAGE;
        leadToUpdate.Last_Coverage_Check_Time__c = DateTime.now();
        leadToUpdate.Last_Inbound_Date_Time__c = inputPayload.createdAt;
        leadToUpdate.PreferredLanguage__c = LOCALE_LANGUAGE_MAPPING.containsKey(inputPayload.locale)
            ? LOCALE_LANGUAGE_MAPPING.get(inputPayload.locale)
            : leadToUpdate.PreferredLanguage__c;
        leadToUpdate.Starting_Point__c = String.isNotEmpty(
                inputPayload.addressVerificationInfo?.startingPoint?.startingPoint
            )
            ? inputPayload.addressVerificationInfo?.startingPoint?.startingPoint
            : leadToUpdate.Starting_Point__c;
        leadToUpdate.Starting_Point_Id__c = (inputPayload.addressVerificationInfo
                ?.startingPoint
                ?.id != null)
            ? inputPayload.addressVerificationInfo?.startingPoint?.id
            : leadToUpdate.Starting_Point_Id__c;
        leadToUpdate.Alcohol_Eligibility__c = String.isNotEmpty(
                inputPayload.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory
            )
            ? inputPayload.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory
            : leadToUpdate.Alcohol_Eligibility__c;
        leadToUpdate.Address_Verification_Status__c = String.isNotEmpty(
                inputPayload.addressVerificationInfo?.addressVerificationStatus
            )
            ? inputPayload.addressVerificationInfo?.addressVerificationStatus
            : leadToUpdate.Address_Verification_Status__c;
        leadToUpdate.Address_Verification_Date__c = (DateTime) Json.deserialize(
            '"' + verificationDate + '"',
            DateTime.class
        );
        leadToUpdate.Rejected_Reason__c = inputPayload.addressVerificationInfo?.rejectedReason;
        return leadToUpdate;
    }
    /**
     * @description It is used to update Lead's Order Protocol fields.
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    private Lead updateOrderProtocolLeadFields(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        leadToUpdate.Order_Protocol_Phone__c = String.isNotEmpty(inputPayload.orderProtocolPhone)
            ? String.valueOf(inputPayload.orderProtocolPhone)
            : leadToUpdate.Order_Protocol_Phone__c;
        String protocolValue = inputPayload.orderProtocol;
        leadToUpdate.Order_Protocol__c = ORDER_PROTOCOL_MAPPING.containsKey(protocolValue)
            ? ORDER_PROTOCOL_MAPPING.get(protocolValue)
            : leadToUpdate.Order_Protocol__c;
        leadToUpdate.Order_Protocol_Email__c = String.isNotEmpty(inputPayload.orderProtocolEmail)
            ? String.valueOf(inputPayload.orderProtocolEmail)
            : leadToUpdate.Order_Protocol_Email__c;
        leadToUpdate.Menu_URL__c = (inputPayload.menuLinks != null)
            ? String.join(inputPayload.menuLinks, ',')
            : leadToUpdate.Menu_URL__c;
        if (leadToUpdate.Email == null && inputPayload.email != null) {
            leadToUpdate.Email = inputPayload.email;
        }
        leadToUpdate.HoursOfOperation__c = String.isNotEmpty(inputPayload.storeHours)
            ? String.valueOf(inputPayload.storeHours)
            : leadToUpdate.HoursOfOperation__c;
        leadToUpdate.Provider_Type__c = String.isNotEmpty(inputPayload.orderProtocolPosProviderType)
            ? String.valueOf(inputPayload.orderProtocolPosProviderType)
            : leadToUpdate.Provider_Type__c;
        return leadToUpdate;
    }
}