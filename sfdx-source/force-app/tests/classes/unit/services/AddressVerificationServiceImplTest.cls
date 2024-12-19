/**
 * @description This is test class for AddressVerificationServiceImplTest
 * @author Deloitte
 * @date 29/04/2022
 */

 @IsTest(SeeAllData=false)
 public class AddressVerificationServiceImplTest {
     private static final String BUSINESS_ACCOUNT_NAME = 'Los Pinchos de mi Abuela';
     private static final String CITY = 'City1';
     private static final String COUNTRY_CODE = 'US';
     private static final String STATE_CODE = 'NY';
     private static final String STREET = 'Test Street1';
     private static final String VERIFIED = 'Verified';
     private static final String UNVERIFIED = 'Unverified';
     private static final String TEST_CITY = 'Texas';
     private static final String TEST_STREET = 'Street12';
     private static final String PAYLOAD_STRING1 = '[{"recordType":null,"objectName":"Store_Detail__c","id":"';
     private static final String PAYLOAD_STRING2 = '","address":"Street12, Texas, NY, 12675, US"},{"recordType":null,"objectName":"Store_Detail__c","id":"';
     private static final String PAYLOAD_STRING3 = '","address":"Street12, Texas, NY, 12675, US"}]';
     private static final String POSTAL_CODE = '12675';
     private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
         .get('Business')
         .getRecordTypeId();
     private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
         .get('Store')
         .getRecordTypeId();
     private static final String UNIQUE_IDENTIFER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';

     /**
      * @description To test method call on geo service event insert.
      */
     @IsTest
     @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
     private static void testWhenPublishAddressVerificationEventThenCheckAddressPayload() {
         Id accRecordTypeBus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get('Business')
             .getRecordTypeId();
         Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get('Store')
             .getRecordTypeId();
         Id accRecordTypeCP = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get('Channel_Partner')
             .getRecordTypeId();

         Account[] newAccounts = new List<Account>{
             new Account(
                 Id = fflib_IDGenerator.generate(Account.SObjectType),
                 Name = 'Account 1',
                 RecordTypeId = accRecordTypeBus,
                 BillingStreet = 'Test Street1',
                 BillingStateCode = 'NY',
                 BillingCity = 'City1',
                 BillingCountryCode = 'US',
                 BillingPostalCode = POSTAL_CODE,
                 Address_Verification_Status__c = 'Unverified',
                 Unique_Identifier__c = UNIQUE_IDENTIFER
             ),
             new Account(
                 Id = fflib_IDGenerator.generate(Account.SObjectType),
                 Name = 'Test 2',
                 RecordTypeId = accRecordTypeStore,
                 BillingStreet = 'Test Street2',
                 BillingStateCode = 'NY',
                 BillingCity = 'City2',
                 BillingCountryCode = 'US',
                 BillingPostalCode = POSTAL_CODE,
                 Address_Verification_Status__c = 'Unverified',
                 Unique_Identifier__c = UNIQUE_IDENTIFER
             ),
             new Account(
                 Id = fflib_IDGenerator.generate(Account.SObjectType),
                 Name = 'Test 3',
                 RecordTypeId = accRecordTypeCP,
                 BillingStreet = 'Test Street3',
                 BillingStateCode = 'NY',
                 BillingCity = 'City3',
                 BillingCountryCode = 'US',
                 Address_Verification_Status__c = 'Verified'
             )
         };
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
             fflib_ISObjectUnitOfWork.class
         );
         Application.UNITOFWORK.setMock(mockUOW);

         AddressVerificationService.publishAddressVerificationEvent(newAccounts);

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
             .registerPublishAfterSuccessTransaction(
                 fflib_Match.sObjectWith(
                     new Map<SObjectField, Object>{
                         GeoServiceEvent__e.Payload__c => '[{"recordType":"Business","objectName":"Account","id":"' +
                         newAccounts[0].Id +
                         +'","address":"Test Street1, City1, NY, , US"},{"recordType":"Store","objectName":"Account","id":"' +
                         newAccounts[1].Id +
                         '","address":"Test Street2, City2, NY, , US"},{"recordType":"Channel Partner","objectName":"Account","id":"' +
                         newAccounts[2].Id +
                         '","address":"Test Street3, City3, NY, , US"}]'
                     }
                 )
             );
     }

     /**
      * @description It is used to test method call on geo service event insert for Account via ssmo.
      */
     @isTest
     @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
     private static void testWhenPublishAddressVerificationEventForAccountPubLishedThenCheckAddressPayload() {
         List<Account> newAccounts = new List<Account>{
             new Account(
                 Id = fflib_IDGenerator.generate(Account.SObjectType),
                 Name = BUSINESS_ACCOUNT_NAME,
                 RecordTypeId = BUSINESS_RECORD_TYPE_ID,
                 BillingStreet = STREET,
                 BillingStateCode = STATE_CODE,
                 BillingCity = CITY,
                 BillingCountryCode = COUNTRY_CODE,
                 Address_Verification_Status__c = UNVERIFIED,
                 Unique_Identifier__c = UNIQUE_IDENTIFER
             )
         };
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
             fflib_ISObjectUnitOfWork.class
         );
         Application.UNITOFWORK.setMock(mockUOW);

         AddressVerificationService.publishAddressVerificationEvent(newAccounts);

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
             .registerPublishAfterSuccessTransaction(
                 fflib_Match.sObjectWith(
                     new Map<SObjectField, Object>{
                         GeoServiceEvent__e.Payload__c => '[{"recordType":"Business","objectName":"Account","id":"' +
                         newAccounts[0].Id +
                         +'","address":"Test Street1, City1, NY, 12675, US"}]'
                     }
                 )
             );
     }

     /**
      * @description To test method call on geo service event insert for Lead.
      */
     @IsTest
     @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
     private static void testWhenPublishAddressVerificationEventForLeadThenCheckAddressPayload() {
         Lead[] newLeads = new List<Lead>{
             new Lead(
                 Id = fflib_IDGenerator.generate(Lead.SObjectType),
                 FirstName = 'Mc Donald',
                 Street = 'Street 12',
                 StateCode = 'NY',
                 City = 'Texas',
                 CountryCode = 'US',
                 Address_Verification_Status__c = 'Unverified',
                 PostalCode = POSTAL_CODE,
                 SSMO_UUID__c = UNIQUE_IDENTIFER
             ),
             new Lead(
                 Id = fflib_IDGenerator.generate(Lead.SObjectType),
                 FirstName = 'Pizza Hut',
                 Street = 'Street 15',
                 StateCode = 'NY',
                 City = 'Texas',
                 CountryCode = 'US',
                 Address_Verification_Status__c = 'Unverified',
                 PostalCode = POSTAL_CODE,
                 SSMO_UUID__c = UNIQUE_IDENTIFER
             )
         };
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
             fflib_ISObjectUnitOfWork.class
         );
         Application.UNITOFWORK.setMock(mockUOW);

         AddressVerificationService.publishAddressVerificationEvent(newLeads);

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(
                 fflib_Match.sObjectWith(
                     new Map<SObjectField, Object>{
                         GeoServiceEvent__e.Payload__c => '[{"recordType":null,"objectName":"Lead","id":"' +
                         newLeads[0].Id +
                         +'","address":"Street 12, Texas, NY, 12675, US"},{"recordType":null,"objectName":"Lead","id":"' +
                         newLeads[1].Id +
                         '","address":"Street 15, Texas, NY, 12675, US"}]'
                     }
                 )
             );
     }

     /**
      * @description To test method call on geo service event insert for Store Detail.
      */
     @isTest
     @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
     private static void testWhenAddressVerificationEventPublishedForStoreDetailThenCheckAddressPayload() {
         Store_Detail__c[] storeDetails = new List<Store_Detail__c>{
             new Store_Detail__c(
                 Id = fflib_IDGenerator.generate(Store_Detail__c.SObjectType),
                 Address__Street__s = TEST_STREET,
                 Address__StateCode__s = STATE_CODE,
                 Address__City__s = TEST_CITY,
                 Address__CountryCode__s = COUNTRY_CODE,
                 Address_Verification_Status__c = UNVERIFIED,
                 Address__PostalCode__s = POSTAL_CODE
             ),
             new Store_Detail__c(
                 Id = fflib_IDGenerator.generate(Store_Detail__c.SObjectType),
                 Address__Street__s = TEST_STREET,
                 Address__StateCode__s = STATE_CODE,
                 Address__City__s = TEST_CITY,
                 Address__CountryCode__s = COUNTRY_CODE,
                 Address_Verification_Status__c = UNVERIFIED,
                 Address__PostalCode__s = POSTAL_CODE
             )
         };
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
             fflib_ISObjectUnitOfWork.class
         );
         Application.UNITOFWORK.setMock(mockUOW);

         Test.startTest();
         AddressVerificationService.publishAddressVerificationEvent(storeDetails);
         Test.stopTest();

         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
             .registerPublishAfterSuccessTransaction(
                 fflib_Match.sObjectWith(
                     new Map<SObjectField, Object>{
                         GeoServiceEvent__e.Payload__c => PAYLOAD_STRING1 +
                         storeDetails[0].Id +
                         +PAYLOAD_STRING2 +
                         storeDetails[1].Id +
                         PAYLOAD_STRING3
                     }
                 )
             );
     }

     /**
      * @description To test method call on geo service event insert when no records are passed
      */
     @IsTest
     @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
     private static void testWhenEmptyUnverifiedAccountsThenNoEventCommitted() {
         Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get('Channel_Partner')
             .getRecordTypeId();
         Id accountId = Fake.generateId(Account.class);

         Account[] newAccounts = new List<Account>{
             new Account(
                 Id = accountId,
                 Name = 'Test 1',
                 RecordTypeId = accRecordType,
                 BillingStreet = 'Test Street2',
                 Address_Verification_Status__c = 'Verified'
             )
         };
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
             fflib_ISObjectUnitOfWork.class
         );
         Application.UNITOFWORK.setMock(mockUOW);

         AddressVerificationService.publishAddressVerificationEvent(newAccounts);
         ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
     }

     @isTest
     private static void testWhenFlowAccountsPassedThenReturnJsonPayload() {
         Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
             .get('Store')
             .getRecordTypeId();
         Id accountId = Fake.generateId(Account.class);
         String street = '12345 Street';
         String city = 'test-city';
         String state = 'TX';
         String zip = '78717';
         String country = 'US';
         Account accnt = new Account(
             Id = accountId,
             recordtypeid = accRecordType,
             BillingStreet = street,
             BillingCity = city,
             BillingStateCode = state,
             BillingPostalCode = zip,
             BillingCountryCode = country
         );
         AddressVerificationServiceImpl.AddressRequest addressReq = new AddressVerificationServiceImpl.AddressRequest();
         addressReq.account = accnt;
         List<AddressVerificationServiceImpl.AddressResponse> resp = AddressVerificationServiceImpl.getPayloadJsonString(
             new List<AddressVerificationServiceImpl.AddressRequest>{ addressReq }
         );
         String jsonStr = resp[0].jsonString;
         List<object> jsonList = (List<object>) JSON.deserializeUntyped(jsonStr);
         Map<String, object> jsonMap = (Map<String, object>) jsonList[0];
         String retAccountId = String.valueof(jsonMap.get('id'));
         System.assertEquals(
             String.valueOf(accountId),
             retAccountId,
             'AccountId is not returned as expected'
         );
     }
 }