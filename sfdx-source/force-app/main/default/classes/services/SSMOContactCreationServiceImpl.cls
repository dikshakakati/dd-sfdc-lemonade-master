/**
 * @author Deloitte
 * @date   05/17/2024
 * @description It is the service implementation class for Contact creation on SSMO fallout event.
 */

public inherited sharing class SSMOContactCreationServiceImpl implements ISSMOContactCreationService {
    private static final String CONTACT_STATUS_UNTOUCHED = 'Untouched';
    private static final String CONTACT_SOURCE = 'get.doordash.com';
    private static final Integer CONTACT_NO_OF_LOCATION = 1;
    private static final String CONTACT_EMAIL_VERIFICATION_INVALID = 'Invalid';
    private static final String CONTACT_EMAIL_VERIFICATION_VALID = 'Valid';
    private static final String CONTACT_IN_COVERAGE = 'In Coverage';
    private static final String CONTACT_NOT_IN_COVERAGE = 'Not In Coverage';
    private static final String CONTACT_ADDRESS_VERIFICATION_REJECTED = 'Rejected';
    private static final String CONTACT_NAME_UNKNOWN = 'Unknown';
    private static final String CONTACT_EVENT_TYPE_FALLOUT = 'Fallout Event';
    private static final String LOG_SALES_DOMAIN = 'Sales';
    private static final String LOG_SELF_SERVING_FALLOUT_SERVICE = 'selfserviceFalloutService';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String STATUS_VERIFIED = 'Verified';
    private static final String STATUS_UNVERIFIED = 'Unverified';
    private static final Map<String, String> ORDER_PROTOCOL_MAPPING = SSMOFalloutWrapper.ORDER_PROTOCOL_MAPPING;
    private static final Map<String, String> LOCALE_LANGUAGE_MAPPING = SSMOFalloutWrapper.LOCALE_LANGUAGE_MAPPING;
    private static final Map<String, String> PRIMARY_VERTICAL_MAPPING = SSMOFalloutWrapper.PRIMARY_VERTICAL_MAPPING;
    private static final Map<String, String> SELF_SERVE_STEP_MAPPING = SSMOFalloutWrapper.SELF_SERVE_STEP_MAPPING;
    private static final Integer HOURS_OF_OPERATION_MAX_LENGTH = 255;
    private static final Integer FIRSTNAME_LASTNAME_MAX_LENGTH = 40;

    /**
     * @description It is used to populate contact with Basic fields on basis of payload.
     * @param payLoad
     * @param contactToInsert
     * @return Contact
     */
    public Contact insertContactSSMO(SSMOFalloutWrapper payLoad, Contact contactToInsert) {
        contactToInsert.AccountId = contactToInsert.SSMO_Business_Account_Id__c;
        contactToInsert.Unique_Identifier__c = payload.sourceUniqueId;
        contactToInsert.Company__c = payload.storeName;
        contactToInsert.FirstName = (String.isNotEmpty(payload.ownerFirstName) && (payload.ownerFirstName).length() > FIRSTNAME_LASTNAME_MAX_LENGTH)
                         ? (payload.ownerFirstName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH)
                         : payload.ownerFirstName;
        contactToInsert.LastName = (String.isNotEmpty(payload.ownerLastName) && (payload.ownerLastName).length() > FIRSTNAME_LASTNAME_MAX_LENGTH)
                         ? (payload.ownerLastName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH)
                         : payload.ownerLastName;
        contactToInsert.MobilePhone = payload.ownerPhone;
        contactToInsert.Email = payload.email;
        contactToInsert.Event_Type__c = CONTACT_EVENT_TYPE_FALLOUT;
        contactToInsert.Primary_Vertical__c = PRIMARY_VERTICAL_RX;
        contactToInsert.Unique_Id__c = payload.id;
        return contactToInsert;
    }

    /**
     * @description It is used to populate Contact with fields on basis of payload.
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    public Contact updateContactSSMO(SSMOFalloutWrapper inputPayload, Contact contactForUpdate) {
        contactForUpdate.SSMO_Matching_Account_Id__c = getMatchingAccountId(inputPayload);
        if (contactForUpdate.Order_Protocol__c == null && inputPayload.orderProtocol != null) {
            String protocolValue = inputPayload.orderProtocol;
            contactForUpdate.Order_Protocol__c = ORDER_PROTOCOL_MAPPING.containsKey(protocolValue)
                ? ORDER_PROTOCOL_MAPPING.get(protocolValue)
                : null;
        }
        contactForUpdate = updateAddressVerification(inputPayload, contactForUpdate);
        contactForUpdate = updatePrimaryFields(inputPayload, contactForUpdate);
        contactForUpdate = updateNameFields(inputPayload, contactForUpdate);
        contactForUpdate = updateOrderProtocolFields(inputPayload, contactForUpdate);
        contactForUpdate = overrideFields(inputPayload, contactForUpdate);
        contactForUpdate = updateEmailVerification(inputPayload, contactForUpdate);
        contactForUpdate = updateStoreInformation(inputPayload, contactForUpdate);
        if (contactForUpdate.MailingAddress == null) {
            contactForUpdate = updateMailingAddress(inputPayload, contactForUpdate);
        }
        contactForUpdate.Unique_Identifier__c = inputPayload.sourceUniqueId;
        return contactForUpdate;
    }

    /**
     * @description It is used to update the mailing address in the contact
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateMailingAddress(
        SSMOFalloutWrapper inputPayload,
        Contact contactForUpdate
    ) {
        if (
            inputPayload.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED &&
            inputPayload.addressVerificationInfo?.validatedAddress != null
        ) {
            contactForUpdate.MailingCity = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.city;
            contactForUpdate.MailingPostalCode = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.postalCode;
            contactForUpdate.MailingCountry = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.country;
            contactForUpdate.MailingCountryCode = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.countryShortname;
            contactForUpdate.MailingStateCode = inputPayload.addressVerificationInfo
                ?.validatedAddress
                ?.state;
            if (contactForUpdate.MailingStateCode?.length() > 4) {
                contactForUpdate.MailingStateCode = null;
                contactForUpdate.MailingState = inputPayload.addressVerificationInfo
                    ?.validatedAddress
                    ?.state;
            }
            contactForUpdate = getStreetAddress(inputPayload, contactForUpdate);
        } else if (inputPayload.storeAddress != null) {
            contactForUpdate.MailingCity = inputPayload.storeAddress?.city;
            contactForUpdate.MailingPostalCode = inputPayload.storeAddress?.postalCode;
            contactForUpdate.MailingCountryCode = inputPayload.storeAddress?.country;
            contactForUpdate.MailingStateCode = inputPayload.storeAddress?.state;
            if (contactForUpdate.MailingStateCode?.length() > 4) {
                contactForUpdate.MailingStateCode = null;
                contactForUpdate.MailingState = inputPayload.storeAddress?.state;
            }
            contactForUpdate = getStreetAddress(inputPayload, contactForUpdate);
        }
        return contactForUpdate;
    }

    /**
     * @description It is used to override the contact fields
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact overrideFields(SSMOFalloutWrapper inputPayload, Contact contactForUpdate) {
        contactForUpdate.Unique_Identifier__c = inputPayload.sourceUniqueId;
        contactForUpdate.Coverage__c = (String.isNotEmpty(
                inputPayload.addressVerificationInfo?.submarket?.id
            ))
            ? CONTACT_IN_COVERAGE
            : CONTACT_NOT_IN_COVERAGE;
        if (contactForUpdate.Coverage__c == CONTACT_IN_COVERAGE) {
            contactForUpdate.Came_into_Coverage__c = DateTime.now();
        }
        contactForUpdate.Last_Coverage_Check_Time__c = DateTime.now();
        contactForUpdate.Alcohol_Eligibility__c = inputPayload.addressVerificationInfo
            ?.alcoholRules
            ?.alcoholAllowanceCategory;
        if (String.isNotEmpty(inputPayload.addressVerificationInfo?.startingPoint?.startingPoint)) {
            contactForUpdate.Starting_Point__c = inputPayload.addressVerificationInfo?.startingPoint?.startingPoint;
        }
        if (inputPayload.addressVerificationInfo?.startingPoint?.id != null) {
            contactForUpdate.Starting_Point_ID__c = inputPayload.addressVerificationInfo?.startingPoint?.id;
        }
        if (String.isNotEmpty(inputPayload.addressVerificationInfo?.validatedAddress?.addressId)) {
            contactForUpdate.Address_ID__c = inputPayload.addressVerificationInfo?.validatedAddress?.addressId;
        }
        if (String.isNotEmpty(inputPayload.addressVerificationInfo?.rejectedReason)) {
            contactForUpdate.Address_Rejection_Reason__c = inputPayload.addressVerificationInfo?.rejectedReason;
        }
        return contactForUpdate;
    }

    /**
     * @description This method will update contact order protocol fields
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateOrderProtocolFields(
        SSMOFalloutWrapper inputPayload,
        Contact contactForUpdate
    ) {
        contactForUpdate.Order_Protocol_Phone__c = (inputPayload.orderProtocolPhone != null &&
            !String.isEmpty(inputPayload.orderProtocolPhone))
            ? inputPayload.orderProtocolPhone
            : contactForUpdate.Order_Protocol_Phone__c;
        contactForUpdate.Order_Protocol_Email__c = (inputPayload.orderProtocolEmail != null &&
            !String.isEmpty(inputPayload.orderProtocolEmail))
            ? inputPayload.orderProtocolEmail
            : contactForUpdate.Order_Protocol_Email__c;
        contactForUpdate.POS_System__c = (inputPayload.orderProtocolPosProviderType != null &&
            !String.isEmpty(inputPayload.orderProtocolPosProviderType))
            ? inputPayload.orderProtocolPosProviderType
            : contactForUpdate.POS_System__c;
        contactForUpdate.Menu_URL__c = (contactForUpdate.Menu_URL__c == null &&
            inputPayload.menuLinks != null)
            ? String.join(inputPayload.menuLinks, ',')
            : contactForUpdate.Menu_URL__c;
        return contactForUpdate;
    }

    /**
     * @description It is used to update contact store information
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateStoreInformation(
        SSMOFalloutWrapper inputPayload,
        Contact contactForUpdate
    ) {
        contactForUpdate.Business_Id__c = (contactForUpdate.Business_Id__c == null &&
            inputPayload.businessId != null)
            ? String.valueOf(inputPayload.businessId)
            : contactForUpdate.Business_Id__c;
        contactForUpdate.Store_Id__c = (contactForUpdate.Store_Id__c == null &&
            inputPayload.storeId != null)
            ? String.valueOf(inputPayload.storeId)
            : contactForUpdate.Store_Id__c;
            contactForUpdate.Hours_of_Operation__c = (contactForUpdate.Hours_of_Operation__c == null &&
            inputPayload.storeHours != null)
            ? ((inputPayload.storeHours).length() > HOURS_OF_OPERATION_MAX_LENGTH)
            	? (inputPayload.storeHours).substring(0, HOURS_OF_OPERATION_MAX_LENGTH) : inputPayload.storeHours
            : contactForUpdate.Hours_of_Operation__c;
        return contactForUpdate;

    }

    /**
     * @description It is used to update primary details of the contact
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updatePrimaryFields(SSMOFalloutWrapper inputPayload, Contact contactForUpdate) {
        if (contactForUpdate.Phone == null && inputPayload.businessPhone != null) {
            contactForUpdate.Phone = inputPayload.businessPhone;
        }
        if (contactForUpdate.Email == null && inputPayload.email != null) {
            contactForUpdate.Email = inputPayload.email;
        }
        if (contactForUpdate.Preferred_Language__c == null && inputPayload.locale != null) {
            contactForUpdate.Preferred_Language__c = LOCALE_LANGUAGE_MAPPING.containsKey(
                    inputPayload.locale
                )
                ? LOCALE_LANGUAGE_MAPPING.get(inputPayload.locale)
                : null;
        }
        return contactForUpdate;
    }

    /**
     * @description It is used to update Contact name fields
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateNameFields(SSMOFalloutWrapper inputPayload, Contact contactForUpdate) {
        if (String.isEmpty(contactForUpdate.FirstName)) {
            contactForUpdate.FirstName = (inputPayload.ownerFirstName != null &&
                !String.isEmpty(inputPayload.ownerFirstName))
                ? inputPayload.ownerFirstName
                : CONTACT_NAME_UNKNOWN;
        }
        if (String.isEmpty(contactForUpdate.LastName)) {
            contactForUpdate.LastName = (inputPayload.ownerLastName != null &&
                !String.isEmpty(inputPayload.ownerLastName))
                ? inputPayload.ownerLastName
                : CONTACT_NAME_UNKNOWN;
        }
        return contactForUpdate;
    }

    /**
     * @description It is used to update contact's address verification details
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateAddressVerification(
        SSMOFalloutWrapper inputPayload,
        Contact contactForUpdate
    ) {
        String verificationDate;
        if (inputPayload.addressVerificationInfo != null) {
            contactForUpdate.Address_Verification_Status__c = (String.isNotEmpty(
                    inputPayload.addressVerificationInfo?.rejectedReason
                ))
                ? CONTACT_ADDRESS_VERIFICATION_REJECTED
                : inputPayload.addressVerificationInfo?.addressVerificationStatus;
            verificationDate = inputPayload.addressVerificationInfo?.addressVerificationDate;
            contactForUpdate.Address_Verification_Date__c = (String.isNotEmpty(verificationDate))
                ? ((DateTime) Json.deserialize('"' + verificationDate + '"', DateTime.class))
                : null;
        } else {
            contactForUpdate.Address_Verification_Status__c = STATUS_UNVERIFIED;
        }
        if (inputPayload.selfServeStep != null && !String.isEmpty(inputPayload.selfServeStep)) {
            contactForUpdate.Self_Serve_Step__c = SELF_SERVE_STEP_MAPPING.containsKey(
                    inputPayload.selfServeStep
                )
                ? SELF_SERVE_STEP_MAPPING.get(inputPayload.selfServeStep)
                : '';
        }
        return contactForUpdate;
    }

    /**
     * @description It is used to update contact email vertification status and primary vertical
     * @param inputPayload
     * @param contactForUpdate
     * @return Contact
     */
    private Contact updateEmailVerification(
        SSMOFalloutWrapper inputPayload,
        Contact contactForUpdate
    ) {
        if (inputPayload.hasValidEmail != null) {
            contactForUpdate.Email_Verification_Status__c = inputPayload.hasValidEmail
                ? CONTACT_EMAIL_VERIFICATION_VALID
                : CONTACT_EMAIL_VERIFICATION_INVALID;
        } else {
            contactForUpdate.Email_Verification_Status__c = CONTACT_EMAIL_VERIFICATION_INVALID;
        }
        contactForUpdate.Primary_Vertical__c = PRIMARY_VERTICAL_MAPPING.containsKey(
                inputPayload.verticalType
            )
            ? PRIMARY_VERTICAL_MAPPING.get(inputPayload.verticalType)
            : PRIMARY_VERTICAL_RX;
        return contactForUpdate;
    }

    /**
     * @description It is used get the matching Account Id from Payload.
     * @param falloutWrapper
     * @return String
     */
    private String getMatchingAccountId(SSMOFalloutWrapper falloutWrapper) {
        String matchingAccountId;
        if (
            !falloutWrapper?.matchedRecords?.account.isEmpty() &&
            String.isNotEmpty(falloutWrapper?.matchedRecords?.account[0]?.Id)
        ) {
            matchingAccountId = falloutWrapper.matchedRecords.account[0].Id;
        }
        return String.isNotEmpty(matchingAccountId) ? matchingAccountId : '';
    }
    /**
     * @description It is used to update the street address in the Contact
     * @param inputPayload
     * @param contactForUpdate
     * @return String
     */
    private Contact getStreetAddress(SSMOFalloutWrapper inputPayload, Contact contactForUpdate) {
        if (inputPayload.addressVerificationInfo?.addressVerificationStatus == STATUS_VERIFIED) {
            contactForUpdate.MailingStreet =
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
            contactForUpdate.MailingStreet =
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
                contactForUpdate.MailingStreet =
                    contactForUpdate.MailingStreet +
                    ' ' +
                    inputPayload.storeAddress?.state;
                contactForUpdate.MailingState = null;
                contactForUpdate.MailingStateCode = null;
            }
        }
        return contactForUpdate;
    }
}