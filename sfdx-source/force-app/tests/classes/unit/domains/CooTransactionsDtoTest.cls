/**
 * @author DoorDash
 * @date 06/02/2023
 * @description test class for CooTransactionsDto
 */
@isTest
public class CooTransactionsDtoTest {
    private static final String IR_BATCH_ID = 'Batch001';
    private static final String IR_STATUS_PENDING = 'Pending';
    private static final String IR_PRODUCT_STATUS_CREATED = 'created';
    @isTest
    static void testWhenCooPayloadReceivedThenReturnNecessaryResultsForMethods(){
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            payload__c = mockPayloadData()
        );
        CooTransactionsDto dto = new CooTransactionsDto(new List<integration_request__c>{integrationRequest});
        System.assertEquals('Test Business', dto.getLegalBusinessName(intId), 'LegalName not matching');
        System.assertEquals('Activity001', dto.getContractId(intId), 'contract Id not matching');
        System.assertEquals('Address001', dto.getBusinessAddressId(intId), 'Business Address not matching');
        System.assertEquals(false, dto.isFranchise(intId), 'isFranshise is not matching');
    }
    
    @isTest
    static void testWhenCooPayloadReceivedThenSerializeBusinessContact(){
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            payload__c = mockPayloadData()
        );
        Id actId = fflib_IDGenerator.generate(Account.SObjectType);
        CooTransactionsDto dto = new CooTransactionsDto(new List<integration_request__c>{integrationRequest});
        String serializedContact = dto.serializeBusinessContact(intId, actId);
        ContactDto.contactInfo deserializedContact = (ContactDto.contactInfo)JSON.deserialize(serializedContact, ContactDto.contactInfo.class);
        System.assertEquals('John', deserializedContact.FirstName, 'FirstName not matching');
        System.assertEquals('Doe', deserializedContact.LastName, 'Last Name not matching');
        System.assertEquals('john.doe@example.com', deserializedContact.Email,'Emai not matching' );
    }
    @isTest
    static void testWhenCooPayloadReceivedThenSerializeNewUserContact(){
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            payload__c = mockPayloadData()
        );
        Id actId = fflib_IDGenerator.generate(Account.SObjectType);
        CooTransactionsDto dto = new CooTransactionsDto(new List<integration_request__c>{integrationRequest});
        String serializedContact = dto.serializeNewUserContact(intId, actId);
        ContactDto.contactInfo deserializedContact = (ContactDto.contactInfo)JSON.deserialize(serializedContact, ContactDto.contactInfo.class);
        System.assertEquals('James', deserializedContact.FirstName, 'FirstName not matching');
        System.assertEquals('two', deserializedContact.LastName, 'Last Name not matching');
        System.assertEquals('newuser@example.com', deserializedContact.Email, 'Emai not matching' );
    }
     @isTest
    static void testWhenCooPayloadReceivedThenGetAccountAddressDetails(){
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            payload__c = mockPayloadData()
        );
        Id actId = fflib_IDGenerator.generate(Account.SObjectType);
        CooTransactionsDto dto = new CooTransactionsDto(new List<integration_request__c>{integrationRequest});
        Account act = dto.getAddressDetails(new Account(Id = actId), intId);
        System.assertEquals('TX', act.BillingStateCode, 'state not matching');
        System.assertEquals('US', act.BillingCountryCode, 'country not matching');
    }
     /**
     * @description Creates a mock coo payload
     * @return  A json payload.
     */
    public static String mockPayloadData(){
           return '{' +
            '"coo_event_type": "COO Event",' +
            '"changeOfownershipStrategy": "Change Ownership Strategy",' +
            '"storeChangeOfOwnershipOnboarding": {' +
            '"onboarding_id": "Onboarding001",' +
            '"business_id": "Business001",' +
            '"legal_business_name": "Test Business",' +
            '"store_id": "Store001",' +
            '"store_name": "Test Store",' +
            '"scheduled_cutoff_time": "2023-05-30 09:00:00",' +
            '"new_owner_first_name": "John",' +
            '"new_owner_last_name": "Doe",' +
            '"new_owner_email": "john.doe@example.com",' +
            '"new_owner_phone": "1234567890",' +
            '"requester_user_id": "User001",' +
            '"new_user_id": "User002",' +
            '"old_user_id": "User003",' +
            '"revoke_access": false,' +
            '"create_new_business": true,' +
            '"approved_at": "2023-05-30 10:00:00",' +
            '"approval_status": "",'+
            '"onboarding_status": "",'+
            '"payment_account_id": "Account001",' +
            '"pactsafe_activity_id": "Activity001",' +
            '"batch_request_id": "Batch001",' +
            '"additionalfields": {' +
            '"notes": "Test notes",' +
            '"order_protocol": "",' +
            '"pos_provider_type": "",' +
            '"is_franchise": false,' +
            '"should_ship_tablet": true,' +
            '"legal_business_address": {' +
            '"street": "123 Main St",' +
            '"city": "Test City",' +
            '"postal_code": "12345",' +
            '"country": "US",' +
            '"state": "TX",' +
            '"owner_phone": "1234567890"' +
            '}' +
            '},' +
            '"new_user": [' +
            '{"email": "newuser@example.com",' +
            '"first_name": "James",' +
            '"last_name": "two",' +
            '"phone": "9876543210",' +
            '"SSN": "123-45-6789"}'+
            '],'+
            '"business_address_id": "Address001",' +
            '"geo_address": {'+
            '"street": "12006 corsicana",'+
            '"city": "Manor",'+
            '"zipCode": "78653",'+
            '"countryShortname": "US",'+
            '"administrativeAreaLevel1": "TX"'+
            '}'+
            '}' +
        '}';
   }
}