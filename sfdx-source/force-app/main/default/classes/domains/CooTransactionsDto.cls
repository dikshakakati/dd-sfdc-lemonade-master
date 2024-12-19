/**
 * @author DoorDash
 * @date 05/03/2023
 * @description Dto class for processing coo same stores. payload receives in JSON format so this wrapper has been created.
 */
@SuppressWarnings('PMD.TooManyFields, PMD.FieldNamingConventions, PMD.UnusedPrivateField')
public inherited sharing class CooTransactionsDto {
    private static final String ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String ROLE_BUSINESS_ADMIN = 'Business Admin';
    private static Map<Id, CooTransaction> intIdToPayLoad;
    /**
     * @description Constructs a new CooTransactionsDto object.
     * @param intReq  The list of Integration_Request__c records.
     */
    public CooTransactionsDto(List<Integration_Request__c> intReq){
        intIdToPayLoad = new Map<Id, CooTransaction>();
        for(Integration_Request__c eachIr: intReq){
            CooTransaction cooPayload = (CooTransaction)JSON.deserialize(eachIr.Payload__c, CooTransaction.class);
            intIdToPayLoad.put(eachIr.Id, cooPayload);
        }
    }
     /**
     * @description Represents the CooTransaction class.
     */
    public class CooTransaction {
        private String coo_event_type;
        private String changeOfownershipStrategy;
        private StoreChangeOfOwnershipOnboarding storeChangeOfOwnershipOnboarding;
    }
    /**
     * @description Represents the StoreChangeOfOwnershipOnboarding class.
     */
    private class StoreChangeOfOwnershipOnboarding {
        private String onboarding_id;
        private String business_id;
        private String legal_business_name;
        private String store_id;
        private String store_name;
        private String scheduled_cutoff_time;
        private String new_owner_first_name;
        private String new_owner_last_name;
        private String new_owner_email;
        private String new_owner_phone;
        private String requester_user_id;
        private String new_user_id;
        private String old_user_id;
        private Boolean revoke_access;
        private Boolean create_new_business;
        private String approved_at;
        private String approval_status;
        private String onboarding_status;
        private String payment_account_id;
        private String pactsafe_activity_id;
        private String batch_request_id;
        private AdditionalFields additionalfields;
        private String business_address_id;
        private List<NewUser> new_user;
        private Address geo_address;
    }
    /**
     * @description Represents the Address class.
     */
    private class Address {
        private String street;
        private String city;
        private String postal_code;
        private String zipCode;
        private String countryShortname;
        private String administrativeAreaLevel1;
        private String country;
        private String state;
        private String owner_phone;
    }
    /**
     * @description Represents the AdditionalFields class.
     */
    private class AdditionalFields {
        private String notes;
        private String order_protocol;
        private String pos_provider_type_str;
        private Boolean is_franchise;
        private Boolean should_ship_tablet;
        //LEM-16130
        //private Address business_address;
        private Address legal_business_address;
        private String order_protocol_email;
        private String order_protocol_phone_number;
    }
     /**
     * @description Represents the NewUser class.
     */
    private class NewUser {
        private String email;
        private String first_name;
        private String last_name;
        private String phone;
        private String SSN;
    }
     /**
     * @description Retrieves the legal business name from the CooTransaction payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The legal business name.
     */
    public String getLegalBusinessName(Id intId){
        String businessName = getPayload(intId).storeChangeOfOwnershipOnboarding.legal_business_name;
        return String.isNotBlank(businessName) ? businessName: 'NONE' ;
    }
    /**
     * @description Retrieves the business address ID from the CooTransaction payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The business address ID.
     */
    public String getBusinessAddressId(Id intId){
        StoreChangeOfOwnershipOnboarding cooPayloadInfo = getPayload(intId).storeChangeOfOwnershipOnboarding;
        String addressId = String.isNotBlank(cooPayloadInfo.business_address_id) ? cooPayloadInfo.business_address_id : 'NONE';
        return addressId;
    }
    /**
     * @description Retrieves the legal business name, BillingStreet, BillingPostalCode from the CooTransaction payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return Account A new account for fuzzy match comparison.
     * @jira# LEM-16130
     */
    public Account getAccountForFuzzyMatch(Id intId){
        StoreChangeOfOwnershipOnboarding cooPayloadInfo = getPayload(intId).storeChangeOfOwnershipOnboarding;
        Address legalBusinessAddress = cooPayloadInfo.additionalfields.legal_business_address;
        Account acct = new Account();
        acct.Name = getLegalBusinessName(intId);
        acct.BillingStreet = legalBusinessAddress.street;
        acct.BillingPostalCode = legalBusinessAddress.postal_code;
        return acct;
    }
    /**
     * @description Retrieves the pactsafe Id from payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The pactSafeId.
     */
    public String getContractId(Id intId){
        String contractId = getPayload(intId).storeChangeOfOwnershipOnboarding.pactsafe_activity_id;
        return String.isNotBlank(contractId) ? contractId: '' ;
    }
     /**
     * @description Retrieves the OrderProtocol from payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The orderProtocol.
     */
    public String getOrderProtocol(Id intId){
        String orderProtocol = getPayload(intId).storeChangeOfOwnershipOnboarding.additionalfields.order_protocol;
        return String.isNotBlank(orderProtocol) ? orderProtocol: '' ;
    }
     /**
     * @description Retrieves the POS Provider Type from payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The posProviderType.
     */
    public String getPOSProviderType(Id intId){
        String posProviderType = getPayload(intId).storeChangeOfOwnershipOnboarding.additionalfields.pos_provider_type_str;
        return String.isNotBlank(posProviderType) ? posProviderType: '' ;
    }
     /**
     * @description Retrieves the Order protocol email from payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The orderProtocolEmail.
     */
    public String getOrderProtocolEmail(Id intId){
        String orderProtocolEmail = getPayload(intId).storeChangeOfOwnershipOnboarding.additionalfields.order_protocol_email;
        return String.isNotBlank(orderProtocolEmail) ? orderProtocolEmail: '' ;
    }
     /**
     * @description Retrieves the Order Protocol Phone Number from payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return String The orderProtocolPhoneNumber.
     */
    public String getOrderprotocolPhoneNumber(Id intId){
        String orderProtocolPhoneNumber = getPayload(intId).storeChangeOfOwnershipOnboarding.additionalfields.order_protocol_phone_number;
        return String.isNotBlank(orderProtocolPhoneNumber) ? orderProtocolPhoneNumber: '' ;
    }
     /**
     * @description Checks if the business is a franchise based on the CooTransaction payload.
     * @param intId  The Id of the Integration_Request__c record.
     * @return Boolean True if it is a franchise, false otherwise.
     */
    public Boolean isFranchise(Id intId){
        return getPayload(intId).storeChangeOfOwnershipOnboarding.additionalfields.is_franchise;
    }
     /**
     * @description Retrieves the payload for the given Integration_Request__c record Id.
     * @param intId  The Id of the Integration_Request__c record.
     * @return CooTransaction The corresponding CooTransaction payload.
     */
    private CooTransaction getPayload(Id intId){
        return intIdToPayLoad.get(intId);
    }
     /**
     * @description Serializes the business contact information based on the Integration_Request__c record and account Id.
     * @param intId  The Id of the Integration_Request__c record.
     * @param actId  The Id of the Account record.
     * @return String The serialized business contact information.
     */
    public String serializeBusinessContact(Id intId, Id actId){
        StoreChangeOfOwnershipOnboarding cooInfo = getPayload(intId).storeChangeOfOwnershipOnboarding;
        ContactDto.contactInfo conInfo = new ContactDto.contactInfo();
        conInfo.FirstName = cooInfo.new_owner_first_name;
        conInfo.LastName = cooInfo.new_owner_last_name;
        conInfo.Email = cooInfo.new_owner_email;
        conInfo.Phone = cooInfo.new_owner_phone;
        conInfo.accountIdToRoles = new Map<String, String>{actId => ROLE_DECISION_MAKER};
        return JSON.serialize(conInfo);
    }
     /**
     * @description Serializes the new user contact information based on the Integration_Request__c record and account Id.
     * @param intId  The Id of the Integration_Request__c record.
     * @param actId  The Id of the Account record.
     * @return String The serialized new user contact information.
     */
    public String serializeNewUserContact(Id intId, Id actId){
        StoreChangeOfOwnershipOnboarding cooPayloadInfo = getPayload(intId).storeChangeOfOwnershipOnboarding;
        return cooPayloadInfo.new_user != null && cooPayloadInfo.new_user.size() > 0 ? serializeNewUserContact(cooPayloadInfo.new_user[0], actId) : null;
    }
    /**
     * @description Serializes the new user contact information based on the NewUser object and account Id.
     * @param newUser  The NewUser object.
     * @param actId The Id of the Account record.
     * @return String  The serialized new user contact information.
     */
    private String serializeNewUserContact(NewUser newUser, Id actId){
        ContactDto.contactInfo conInfo = new ContactDto.contactInfo();
        conInfo.firstName = checkForNulls(newUser.first_name);
        conInfo.lastName = checkForNulls(newUser.last_name);
        conInfo.email = checkForNulls(newUser.email);
        conInfo.phone = checkForNulls(newUser.phone);
        conInfo.accountIdToRoles = new Map<String, String>{actId => ROLE_DECISION_MAKER};
        return JSON.serialize(conInfo);
    }
    /**
     * @description Retrieves and sets the address details for the Account record based on the CooTransaction payload.
     * @param act  The Account record.
     * @param intId The Id of the Integration_Request__c record.
     * @return  Account The updated Account record.
     */
    public Account getAddressDetails(Account act, Id intId){
        StoreChangeOfOwnershipOnboarding cooPayloadInfo = getPayload(intId).storeChangeOfOwnershipOnboarding;
        Address businessAddress = cooPayloadInfo.geo_address;
        if(businessAddress == null){
            return act;
        }
        act.BillingStreet = businessAddress.street;
        act.BillingCity = businessAddress.city;
        act.BillingPostalCode = businessAddress.zipCode;
        act.BillingCountryCode = String.isNotBlank(businessAddress.countryShortname)
            ? businessAddress.countryShortname.toUpperCase() : '';
        act.BillingStateCode = String.isNotBlank(businessAddress.administrativeAreaLevel1)
            ? businessAddress.administrativeAreaLevel1 .toUpperCase() : '';
        act.phone = cooPayloadInfo.new_owner_phone;
        return act;
    }
    private String checkForNulls(String value){
        return String.isNotBlank(value) ? value : '';
    }
}