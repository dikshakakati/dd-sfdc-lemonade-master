/**
 * @author Deloitte
 * @date 05/16/2024
 * @description It is used to handle and insert the payload data into the 'Payload' field
 * on 'Inbound Ingestion Log' record for different event types.
 */
public inherited sharing class IngestionPayloadHandlerServiceImpl implements IIngestionPayloadHandlerService {
    private static final String COLON_SEPERATOR = ':';
    private static final String CREATED_AT_KEY = 'createdAt';
    private static final String FALLOUT_EVENT = 'Fallout event';
    private static final String FALLOUT_UUID_KEY = 'sourceUniqueId';
    private static final String ADDITIONAL_STORE_KEY = 'isAdditionalStore';
    private static final String JSON_ARRAY_IDENTIFIER = '[';
    private static final String JSON_NON_ARRAY_IDENTIFIER = '{';
    private static final String MX_PORTAL_NSE_EVENT = 'Mx Portal New Store Expansion';
    private static final String MX_PORTAL_SOURCE = 'Mx Portal';
    private static final String COMMA_SEPARATOR = ', ';
    private static final String DATETIME_SEPARATOR = 'T';
    private static final String ONBOARDING_UUID_KEY = 'uuid';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String STORE_KEY = 'store';
    private static final String TEST_EXCEPTION_MESSAGE = 'SSMO Payload Handler Test Exception';
    private static final String TEST_EXCEPTION_PAYLOAD = 'Test_Exception';
    private static final String UNDERSCORE_SEPARATOR = '_';
    private static final String UNIQUE_ID_KEY = 'id';
    private enum EventTypes {
        FALLOUT_EVENT,
        ONBOARDING_EVENT
    }

    private static final Map<String, EventTypes> EVENTTYPEMAPPINGS = new Map<String, EventTypes>{
        FALLOUT_EVENT => EventTypes.FALLOUT_EVENT,
        ONBOARDING_EVENT => EventTypes.ONBOARDING_EVENT
    };
    private Map<String, Object> jsonKeyToValue = new Map<String, Object>();
    private static final String VERIFIED = 'Verified';
    private static final String LOG_SERVICE = 'Ingestion Payload Handler Service';
    private static final String LOG_DOMAIN = 'SSMO';

    /**
     * @description It is used to insert the JSON payload data into the 'Payload' field
     * on 'Inbound Ingestion Log' record.
     * @JIRA# LEM-14648
     * @param eventType
     * @param payload
     * @param source
     */

    public void insertInboundIngestionLogs(String eventType, String payload, String source) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        String uuid;
        String uniqueId;
        Map<String, Id> uuidToParentInboundIngestionLogId = getParentInboundIngestionLogsByUniqueIdentifiers(
            payload,
            eventType
        );
        if (payload.startsWith(JSON_ARRAY_IDENTIFIER)) {
            for (Object eachJSONPayload : (List<Object>) JSON.deserializeUntyped(payload)) {
                throwcustomValidationException(eventType, JSON.serialize(eachJSONPayload), source);
                jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(
                    JSON.serialize(eachJSONPayload)
                );
                uuid = fetchUUID(eventType, jsonKeyToValue);
                uniqueId = fetchUniqueId(jsonKeyToValue);
                uow.registerNew(
                    createInboundIngestionLog(
                        eventType,
                        String.isBlank(uniqueId) ? uuid : uuid + UNDERSCORE_SEPARATOR + uniqueId,
                        JSON.serialize(eachJSONPayload),
                        source,
                        uuidToParentInboundIngestionLogId.get(uuid)
                    )
                );
            }
        } else if (payload.startsWith(JSON_NON_ARRAY_IDENTIFIER)) {
            Object untypedJSON = (Object) JSON.deserializeUntyped(payload);
            throwcustomValidationException(eventType, payload, source);
            jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(payload);
            uuid = fetchUUID(eventType, jsonKeyToValue);
            uniqueId = fetchUniqueId(jsonKeyToValue);
            uow.registerNew(
                createInboundIngestionLog(
                    eventType,
                    String.isBlank(uniqueId) ? uuid : uuid + UNDERSCORE_SEPARATOR + uniqueId,
                    JSON.serialize(untypedJSON),
                    source,
                    uuidToParentInboundIngestionLogId.get(uuid)
                )
            );
        }
        if (Test.isRunningTest() && payload == TEST_EXCEPTION_PAYLOAD) {
            throw new StringException(TEST_EXCEPTION_MESSAGE);
        }
        commitWork(uow);
    }

    /**
     * @description It is used to get the existing inbound ingestion log by unique identifers.
     * @param eventType
     * @param uniqueIdentifier
     * @param payload
     * @param source
     * @param parentRecordId
     * @return Inbound_Ingestion_Log__c
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    private Inbound_Ingestion_Log__c createInboundIngestionLog(
        String eventType,
        String uniqueIdentifier,
        String payload,
        String source,
        Id parentRecordId
    ) {
        String storePayload = JSON.serialize(jsonKeyToValue.get(STORE_KEY));
        Map<String, Object> storeValue = (Map<String, Object>) JSON.deserializeUntyped(
            storePayload
        );
        return new Inbound_Ingestion_Log__c(
            Integration_Type__c = (eventType == ONBOARDING_EVENT &&
                source != SOURCE_RESSMO &&
                (Boolean) storeValue.get(ADDITIONAL_STORE_KEY) == true)
                ? MX_PORTAL_NSE_EVENT
                : eventType,
            UUID__c = uniqueIdentifier.contains(UNDERSCORE_SEPARATOR)
                ? uniqueIdentifier.split(UNDERSCORE_SEPARATOR)[0]
                : uniqueIdentifier,
            Unique_Id__c = uniqueIdentifier.contains(UNDERSCORE_SEPARATOR)
                ? uniqueIdentifier.split(UNDERSCORE_SEPARATOR)[1]
                : null,
            Created_Date_Time__c = fetchCreatedDateTime(eventType) != null
                ? DateTime.valueOf(
                      fetchCreatedDateTime(eventType)?.replace(DATETIME_SEPARATOR, ' ')
                  )
                : null,
            Payload__c = payload,
            Source__c = (eventType == ONBOARDING_EVENT &&
                source != SOURCE_RESSMO &&
                (Boolean) storeValue.get(ADDITIONAL_STORE_KEY) == true)
                ? MX_PORTAL_SOURCE
                : source,
            Parent_Log__c = parentRecordId
        );
    }

    /**
     * @description It is used to fetch the Created date time from the Fallout payload.
     * @param eventType
     * @return String
     */
    private String fetchCreatedDateTime(String eventType) {
        return eventType == FALLOUT_EVENT ? (String) jsonKeyToValue.get(CREATED_AT_KEY) : null;
    }

    /**
     * @description It is used to fetch the UUID from the Fallout payload
     * @param eventType
     * @param jsonKeyToValue
     * @return String
     */
    private static String fetchUUID(String eventType, Map<String, Object> jsonKeyToValue) {
        return eventType == FALLOUT_EVENT
            ? (String) jsonKeyToValue.get(FALLOUT_UUID_KEY)
            : (String) jsonKeyToValue.get(ONBOARDING_UUID_KEY);
    }

    private static String fetchUniqueId(Map<String, Object> jsonKeyToValue) {
        return (String) jsonKeyToValue.get(UNIQUE_ID_KEY);
    }

    /**
     * @description It is used to get the existing inbound ingestion log by unique identifers.
     * @param inboundIngestionPayload
     * @param eventType
     * @return Map<String, String>
     */
    private Map<String, Id> getParentInboundIngestionLogsByUniqueIdentifiers(
        String inboundIngestionPayload,
        String eventType
    ) {
        Set<String> uniqueIdentifers = new Set<String>();
        Map<String, Id> parentIngestionLogsByUUID = new Map<String, Id>();
        if (
            !String.isEmpty(inboundIngestionPayload) &&
            inboundIngestionPayload.startsWith(JSON_ARRAY_IDENTIFIER)
        ) {
            for (
                Object eachJSONPayload : (List<Object>) JSON.deserializeUntyped(
                    inboundIngestionPayload
                )
            ) {
                jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(
                    JSON.serialize(eachJSONPayload)
                );
                uniqueIdentifers.add(fetchUUID(eventType, jsonKeyToValue));
            }
        } else if (
            !String.isEmpty(inboundIngestionPayload) &&
            inboundIngestionPayload.startsWith(JSON_NON_ARRAY_IDENTIFIER)
        ) {
            jsonKeyToValue = (Map<String, Object>) JSON.deserializeUntyped(inboundIngestionPayload);

            uniqueIdentifers.add(fetchUUID(eventType, jsonKeyToValue));
        }
        if (uniqueIdentifers.isEmpty()) {
            return null;
        }

        for (
            Inbound_Ingestion_Log__c eachInboundIngestionLog : InboundIngestionLogsSelector.newInstance()
                .selectInboundIngestionLogsByUniqueIdentifiers(
                    new Set<String>{ FALLOUT_EVENT },
                    uniqueIdentifers
                )
        ) {
            parentIngestionLogsByUUID.put(
                eachInboundIngestionLog.UUID__c,
                eachInboundIngestionLog.Id
            );
        }
        return parentIngestionLogsByUUID;
    }
    /**
     * @description It is used to throw the custom validation exception back to mulesoft.
     * @param eventType
     * @param payload
     * @param source
     */
    private void throwcustomValidationException(String eventType, String payload, String source) {
        if (String.isNotBlank(validateIngestionPayload(eventType, payload, source))) {
            throw new StringException(validateIngestionPayload(eventType, payload, source));
        }
    }

    /**
     * @description It is used to validate the ingestion payload and return back to mulesoft if there is any exception.
     * @param eventType
     * @param inboundIngestionPayload
     * @param source
     * @return Map<String, String>
     */
    private String validateIngestionPayload(
        String eventType,
        String inboundIngestionPayload,
        String source
    ) {
        if (source != SOURCE_SSMO) {
            return null;
        }
        Object address;
        String email;
        String errorMessage = '';
        String name;
        String addressVerificationStatus;
        Boolean storeAddressIsPresent = false;
        SSMOFalloutWrapper parsedFalloutPayload;
        InstantIngestionPayloadParser parsedOnboardingPayload;
        String uniqueIdentifier;
        switch on EVENTTYPEMAPPINGS.get(eventType) {
            when FALLOUT_EVENT {
                parsedFalloutPayload = (SSMOFalloutWrapper) System.JSON.deserialize(
                    inboundIngestionPayload,
                    SSMOFalloutWrapper.class
                );
                addressVerificationStatus = parsedFalloutPayload.addressVerificationInfo?.addressVerificationStatus;
                address = parsedFalloutPayload.addressVerificationInfo?.validatedAddress;
                email = parsedFalloutPayload?.email;
                name = parsedFalloutPayload?.storeName;
                uniqueIdentifier = parsedFalloutPayload?.sourceUniqueId;
                storeAddressIsPresent = checkForStoreAddressDetailsForFallout(parsedFalloutPayload);
            }
            when ONBOARDING_EVENT {
                parsedOnboardingPayload = (InstantIngestionPayloadParser) System.JSON.deserialize(
                    inboundIngestionPayload,
                    InstantIngestionPayloadParser.class
                );
                addressVerificationStatus = parsedOnboardingPayload.store?.addressVerificationInfo?.addressVerificationStatus;
                address = parsedOnboardingPayload.store?.addressVerificationInfo?.validatedAddress;
                email = parsedOnboardingPayload?.merchantOwner?.email;
                name = parsedOnboardingPayload?.business?.name;
                uniqueIdentifier = parsedOnboardingPayload?.uuid;
                storeAddressIsPresent = checkForStoreAddressDetailsForOnboarding(parsedOnboardingPayload);
            }
        }
        if (String.isBlank(uniqueIdentifier)) {
            errorMessage +=
                System.label.InboundIngestionLog_UUID_Missing_ErrorMessage + COMMA_SEPARATOR;
        }
        if (String.isBlank(email)) {
            errorMessage +=
                System.label.InboundIngestionLog_Email_Missing_ErrorMessage + COMMA_SEPARATOR;
        }
        if (String.isBlank(name)) {
            errorMessage +=
                System.label.InboundIngestionLog_Name_Missing_ErrorMessage + COMMA_SEPARATOR;
        }
        errorMessage = validateAddressDetails(addressVerificationStatus, address, storeAddressIsPresent, errorMessage);
        return String.isNotBlank(errorMessage)
            ? uniqueIdentifier + COLON_SEPERATOR + errorMessage.removeEnd(COMMA_SEPARATOR)
            : null;
    }
    /**
     * @description It is used to validate ingestion payload for address details.
     * @param addressVerificationStatus
     * @param address
     * @param storeAddressIsPresent
     * @param errorMessage
     * @return String
     */
    private String validateAddressDetails(String addressVerificationStatus, Object address, Boolean storeAddressIsPresent, String errorMessage) {
        if (addressVerificationStatus == VERIFIED && address == null){
            errorMessage +=
                System.label.InboundIngestionLog_Address_Missing_ErrorMessage + COMMA_SEPARATOR;
        }
        else if(address == null && !storeAddressIsPresent){
            errorMessage +=
                System.label.InboundIngestionLog_Address_Missing_ErrorMessage + COMMA_SEPARATOR;
        }
        return errorMessage;
    }
    /**
     * @description It is used to validate if Store address is present for Onboarding Payload.
     * @param parsedPayload
     * @return Boolean
     * Removed the state address check as for onbaording event they are looking for State valure from Validate address Block.
     */
    private Boolean checkForStoreAddressDetailsForOnboarding(InstantIngestionPayloadParser parsedPayload) {
        String street;
        String city;
        String state;
        String country;
        String postalCode;
        Boolean storeAddressIsPresent = false;
        street = parsedPayload.store?.street;
        city = parsedPayload.store?.city;
        state = parsedPayload.store?.state;
        country = parsedPayload.store?.country;
        postalCode = parsedPayload.store?.postalCode;
        if(String.isNotBlank(street) || String.isNotBlank(city) || String.isNotBlank(country) || String.isNotBlank(postalCode)){
            storeAddressIsPresent = true;
        }
        return storeAddressIsPresent;
    }
    /**
     * @description It is used to validate if Store address is present for Fallout Payload.
     * @param parsedPayload
     * @return Boolean
     */
    private Boolean checkForStoreAddressDetailsForFallout(SSMOFalloutWrapper parsedPayload) {
        String street;
        String city;
        String state;
        String country;
        String postalCode;
        Boolean storeAddressIsPresent = false;
        street = parsedPayload.storeAddress?.addressLine1;
        city = parsedPayload.storeAddress?.city;
        state = parsedPayload.storeAddress?.state;
        country = parsedPayload.storeAddress?.country;
        postalCode = parsedPayload.storeAddress?.postalCode;
        if(String.isNotBlank(street) || String.isNotBlank(city) || String.isNotBlank(state) || String.isNotBlank(country) || String.isNotBlank(postalCode)){
            storeAddressIsPresent = true;
        }
        return storeAddressIsPresent;
    }
    /**
     * @description It is a common method to commit unit of work.
     * @JIRA# LEM-19303
     * @param uow
     */
    private static void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }
}