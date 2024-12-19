/**
 * @description used to  build a OAuth1 request given a generic set of parameters
 */
@isTest(SeeAllData=false)
public without sharing class OAuth1RequestGeneratorTest {
    @isTest
    static void testWhenPaymentAccountIdThenGenerateValidContentBody() {
        Contact con = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            Email = 'randomJoe@domain.com'
        );
        Payment_Account__c pa = new Payment_Account__c(
            Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
            Address_Line_1__c = 'any street 0909',
            Postal_Code__c = '94808',
            Country__c = 'United States',
            Billing_Contact_Name__c = con.Id,
            Billing_Contact_Name__r = con,
            Currency__c = 'USD',
            Bill_To_Company_Name__c = 'any inc',
            State__c = 'theState',
            Payment_Terms__c = 'Net 30',
            City__c = 'Golden City'
        );

        List<OAuth_Config__c> dataMap = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Address_Line_1__c',
                Value__c = 'address.addr1'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Postal_Code__c',
                Value__c = 'address.zip'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Country_Code_Alpha_2__c',
                Value__c = 'address.country'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Billing_Contact_Email__c',
                Value__c = 'email'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Subsidiary__c',
                Value__c = 'subsidiaryId'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Currency__c',
                Value__c = 'currencyId'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Bill_To_Company_Name__c',
                Value__c = 'company_name'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'State__c',
                Value__c = 'address.state'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Payment_Terms__c',
                Value__c = 'term_id'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'City__c',
                Value__c = 'address.city'
            )
        };

        List<OAuth_Config__c> headers = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'realm',
                Value__c = '',
                Encrypted_Value__c = 'therealm',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'oauth_signature',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_signature_method',
                Value__c = 'HMAC-SHA256',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'consumerSecret',
                Value__c = '',
                Encrypted_Value__c = 'theconsumersecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_timestamp',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'method',
                Value__c = 'POST',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_consumer_key',
                Value__c = '',
                Encrypted_Value__c = 'theoauthconsumerkey',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'tokenSecret',
                Value__c = '',
                Encrypted_Value__c = 'thetokensecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = '1.0',
                Value__c = 'oauth_version',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_token',
                Value__c = '',
                Encrypted_Value__c = 'theoauthtoken',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'authorization',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'content_type',
                Value__c = 'application/json',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'oauth_nonce',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'url',
                Value__c = 'https://3938860-sb4.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=592&deploy=1',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOAuth1ConfigsSelector configSelectorMock = (IOAuth1ConfigsSelector) mocks.mock(
            IOAuth1ConfigsSelector.class
        );
        IPaymentAccountsSelector paSelectorMock = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(paSelectorMock.sObjectType()).thenReturn(Payment_Account__c.SObjectType);
        mocks.when(paSelectorMock.selectPaymentAccountByIdForNetsuiteIntegration(pa.Id))
            .thenReturn(pa);
        mocks.when(configSelectorMock.sObjectType()).thenReturn(OAuth_Config__c.SObjectType);
        mocks.when(configSelectorMock.getNetsuiteIntegrationDatamap()).thenReturn(dataMap);
        mocks.when(configSelectorMock.getNetsuiteIntegrationHeaders()).thenReturn(headers);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(paSelectorMock);
        Application.SELECTOR.setMock(configSelectorMock);

        HttpRequest req;
        Test.startTest();
        req = OAuth1RequestGenerator.generateRequest(
            'Payment Account',
            pa.Id,
            'Payment_Account__c'
        );
        Test.stopTest();
        Map<String, Object> deserializedBody = (Map<String, Object>) JSON.deserializeUntyped(
            req.getBody()
        );
        system.assert(deserializedBody.containsKey('company_name'), 'Expected true');
        system.assert(deserializedBody.containsKey('email'), 'Expected true');
        system.assert(deserializedBody.containsKey('currencyId'), 'Expected true');
        system.assert(deserializedBody.containsKey('subsidiaryId'), 'Expected true');
        system.assert(deserializedBody.containsKey('term_id'), 'Expected true');
        system.assert(deserializedBody.containsKey('address'), 'Expected true');
        system.assert(deserializedBody.get('company_name') == 'any inc', 'Expected true');
        system.assertEquals(
            'https://3938860-sb4.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=592&deploy=1',
            req.getEndpoint(),
            'Expected true'
        );
    }
}