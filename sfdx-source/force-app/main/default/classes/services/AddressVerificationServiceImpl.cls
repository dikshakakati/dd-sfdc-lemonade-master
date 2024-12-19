/**
 * @author Deloitte
 * @date   14/03/2022
 * @description This is the service implementation class for Account roll up related logic
 */
public inherited sharing class AddressVerificationServiceImpl implements IAddressVerificationService {
    private static final List<String> ACCOUNT_ADDRESS_WITH_CODE = new List<String>{
        'BillingStreet',
        'BillingCity',
        'BillingStateCode',
        'BillingPostalCode',
        'BillingCountryCode'
    };
    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static final String STORE_DEATIL_OBJECT_NAME = 'Store_Detail__c';
    private static final String LEAD_OBJECT_NAME = 'Lead';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Address_Verification_Status__c';
    private static final String ACCOUNT_UNIQUE_IDENTIFIER = 'Unique_Identifier__c';
    private static final String LEAD_UNIQUE_IDENTIFIER = 'SSMO_UUID__c';
    private static final String COVERAGE = 'Coverage__c';
    private enum ObjectTypes {
        ACCOUNT,
        LEAD,
        STORE_DETAIL
    }
    private static final Map<String, ObjectTypes> OBJECT_NAME_TO_OBJECT_TYPES = new Map<String, ObjectTypes>{
        ACCOUNT_OBJECT_NAME => ObjectTypes.ACCOUNT,
        LEAD_OBJECT_NAME => ObjectTypes.LEAD,
        STORE_DEATIL_OBJECT_NAME => ObjectTypes.STORE_DETAIL
    };

    private static final List<String> LEAD_ADDRESS_WITH_CODE = new List<String>{
        'Street',
        'City',
        'StateCode',
        'PostalCode',
        'CountryCode'
    };
    private static final List<String> STORE_DETAIL_ADDRESS_FIELDS = new List<String>{
        'Address__Street__s',
        'Address__City__s',
        'Address__StateCode__s',
        'Address__PostalCode__s',
        'Address__CountryCode__s'
    };
    private static final String LOG_SERVICE = 'Address Verification Service';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String RECORD_ID = 'Id';
    private static final String RECORD_TYPE_ID = 'RecordTypeId';
    private static final Map<Id, Schema.RecordTypeInfo> RECTTYPE_MAP = Schema.SObjectType.Account.getRecordTypeInfosById();
    private static final String STATUS_UNVERIFIED = 'Unverified';

    /**
     * @description It is used to publish the platform event for address verification.
     * @param recordsToVerifyAddress
     */
    public void publishAddressVerificationEvent(List<SObject> recordsToVerifyAddress) {
        List<SObject> unverifiedRecords = new List<SObject>(
            getUnverifiedRecords(recordsToVerifyAddress)
        );
        if (unverifiedRecords.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        GeoServiceEvent__e geoServiceEvent = new GeoServiceEvent__e();
        geoServiceEvent.Payload__c = getPayloadJSONString(recordsToVerifyAddress);
        uow.registerPublishAfterSuccessTransaction(geoServiceEvent);
        commitWork(uow);
    }

    /**
     * @description get JSON string for Address payload
     * @param recordsToVerifyAddress
     * @return jsonGen.getAsString()
     */
    private String getPayloadJsonString(List<SObject> recordsToVerifyAddress) {
        List<Address> addresses = new List<Address>();
        for (SObject eachObject : recordsToVerifyAddress) {
            addresses.add(new Address(eachObject));
        }
        return JSON.serialize(addresses);
    }

    /**
     * @author Deloitte
     * @date   06/05/2022
     * @description Inner class AddressVerificationServiceImpl.Address
     */
    public class Address {
        /**
         * @description String Id
         */
        public String id { get; private set; }
        /**
         * @description String RecordType
         */
        public String recordType { get; private set; }
        /**
         * @description String Address
         */
        public String address { get; private set; }
        /**
         * @description String objectName
         */
        public String objectName { get; private set; }
        /**
         * @description Address Object
         * @param eachRecord
         */
        public Address(SObject eachRecord) {
            id = eachRecord?.Id;
            List<String> addressFields = new List<String>();

            if (eachRecord.getSObjectType().getDescribe().getName() == ACCOUNT_OBJECT_NAME) {
                recordType = RECTTYPE_MAP.get((Id) eachRecord.get(RECORD_TYPE_ID))?.getName();
                addressFields = ACCOUNT_ADDRESS_WITH_CODE;
            } else if (
                eachRecord.getSObjectType().getDescribe().getName() == STORE_DEATIL_OBJECT_NAME
            ) {
                addressFields = STORE_DETAIL_ADDRESS_FIELDS;
            } else {
                addressFields = LEAD_ADDRESS_WITH_CODE;
            }
            objectName = eachRecord.getSObjectType().getDescribe().getName();
            // Build the address string dynamically using SObject class methods
            List<String> addressParts = new List<String>{
                (String) eachRecord.get(addressFields[0]),
                (String) eachRecord.get(addressFields[1]),
                (String) eachRecord.get(addressFields[2]),
                (String) eachRecord.get(addressFields[3]),
                (String) eachRecord.get(addressFields[4])
            };
            address = String.join(addressParts, ', ');
        }
    }

    /**
     * @description To get unverified sObject records.
     * @param recordsToVerifyAddress
     * @return unverifiedSObjects
     */
    private List<SObject> getUnverifiedRecords(List<SObject> recordsToVerifyAddress) {
        List<SObject> unverifiedSObjects = new List<SObject>();
        SObject unverifiedRecord;
        for (SObject obj : recordsToVerifyAddress) {
            // Check if the necessary address fields are populated and the verification status is unverified
            switch on
                OBJECT_NAME_TO_OBJECT_TYPES.get(obj.getSObjectType().getDescribe().getName()) {
                when ACCOUNT {
                    unverifiedRecord = checkUnverifiedRecords(obj, ACCOUNT_ADDRESS_WITH_CODE, ACCOUNT_UNIQUE_IDENTIFIER);
                    if(unverifiedRecord != null){
                        unverifiedSObjects.add(unverifiedRecord);
                    }
                }
                when LEAD {
                    unverifiedRecord = checkUnverifiedRecords(obj, LEAD_ADDRESS_WITH_CODE, LEAD_UNIQUE_IDENTIFIER);
                    if(unverifiedRecord != null){
                        unverifiedSObjects.add(unverifiedRecord);
                    }
                }
                when STORE_DETAIL {
                    unverifiedRecord = checkUnverifiedRecords(obj, STORE_DETAIL_ADDRESS_FIELDS, null);
                    if(unverifiedRecord != null){
                        unverifiedSObjects.add(unverifiedRecord);
                    }
                }
            }
        }
        return unverifiedSObjects;
    }
    /**
     * @description To check unverified sObject records.
     * @param obj
     * @param addressFields
     * @param uniqueIdentifier
     * @return SObject
     */
    private SObject checkUnverifiedRecords(SObject obj, List<String> addressFields, String uniqueIdentifier) {
        if (
            checkAddressFields(obj, addressFields) &&
            (obj.getSObjectType().getDescribe().getName() == STORE_DEATIL_OBJECT_NAME ||
            String.valueOf(obj.get(ADDRESS_VERIFICATION_STATUS)) == STATUS_UNVERIFIED  ||
            (String.isNotBlank(String.valueOf(obj.get(uniqueIdentifier))) &&
             String.valueOf(obj.get(COVERAGE)) == null)
            )
        ) {
            return obj;
        }
        return null;
    }

    /**
     * @description To check if Address fields are not null
     * @param obj
     * @param addressFields
     * @return Boolean
     */
    private Boolean checkAddressFields(SObject obj, List<String> addressFields) {
        if (
            obj.get(addressFields[0]) != null ||
            obj.get(addressFields[1]) != null ||
            obj.get(addressFields[2]) != null ||
            obj.get(addressFields[3]) != null ||
            obj.get(addressFields[4]) != null
        ) {
            return true;
        }
        return false;
    }
    /**
     * @description It is used to check the address fields are blank or not
     * @param addressFields
     * @param objRecord
     * @param uniqueIdentifier
     * @return boolean,
     */
    private boolean checkAddressFields(
        List<String> addressFields,
        Sobject objRecord,
        String uniqueIdentifier
    ) {
        return (objRecord.get(addressFields[0]) != null ||
            objRecord.get(addressFields[1]) != null ||
            objRecord.get(addressFields[2]) != null ||
            objRecord.get(addressFields[3]) != null ||
            objRecord.get(addressFields[4]) != null) &&
            (String.valueOf(objRecord.get(ADDRESS_VERIFICATION_STATUS)) == STATUS_UNVERIFIED ||
            String.valueof(objRecord.get(uniqueIdentifier)) != null);
    }
    /**
     * @description Commit method
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }

    /**
     * @description this method is invoked from a flow to get the address in JSON format for sending it to the Geo Service Platform even as a paylod
     * @param  addressRequests - this list will contain the account object
     * @return List<AddressResponse> - account info and address details will be returned in the JSON format.
     */
    @InvocableMethod(
        label='Get Address Json Payload'
        description='Get the JSON Payload for sending the Address as a payload in Platform Event'
    )
    public static List<AddressResponse> getPayloadJsonString(List<AddressRequest> addressRequests) {
        List<Address> lstAddresses = new List<Address>();
        List<Account> accountsToVerifyAddress = new List<Account>();
        accountsToVerifyAddress.add(addressRequests.get(0).account);
        for (Account objAccount : accountsToVerifyAddress) {
            lstAddresses.add(new Address(objAccount));
        }
        AddressResponse resp = new AddressResponse();
        resp.jsonString = JSON.serialize(lstAddresses);
        return new List<AddressResponse>{ resp };
    }

    /**
     * @author Doordash
     * @date   08/01/2023
     * @description Inner class for AddressVerificationServiceImpl - this is used for the flow inputs
     */
    public class AddressRequest {
        @InvocableVariable
        public Account account;
    }

    /**
     * @author Doordash
     * @date   08/01/2023
     * @description Inner class for AddressVerificationServiceImpl - this is used for the flow outputs
     */
    public class AddressResponse {
        @InvocableVariable
        public string jsonString;
    }
}