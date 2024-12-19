/**
 * @description Test class for EncryptedValuesSelector class.
 */
@isTest(SeeAllData=false)
private with sharing class EncryptedValuesSelectorTest {
    private static final String AES_256 = 'AES-256';

    /**
     * @description To test getSObjectFieldList method on EncryptedValueSelector class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        EncryptedValuesSelector selector = new EncryptedValuesSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Encrypted_Value__c.Id,
                Encrypted_Value__c.Description__c,
                Encrypted_Value__c.Value__c
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assertEquals(
            Schema.Encrypted_Value__c.SObjectType,
            typeOfObj,
            'The object type must be Encrypted Value'
        );
    }

    /**
     * @description To test selection on Encrypted Value by the passed name.
     */
    @isTest
    private static void testWhenKeyNameIsPassedThenReturnEncryptedValueisReturned() {
        List<Encrypted_Value__c> encryptedValueListToInsert = new List<Encrypted_Value__c>{
            new Encrypted_Value__c(
                Description__c = 'Encrypted value in EncryptedValuesSelectorTest.',
                Value__c = '1223456788frtyh',
                Name = AES_256
            )
        };
        insert encryptedValueListToInsert;

        EncryptedValuesSelector encryptedValueTest = new EncryptedValuesSelector();
        List<Encrypted_Value__c> encryptedValueListForVerification = encryptedValueTest.selectByName(
            encryptedValueListToInsert[0].Name
        );
        Test.startTest();
        System.assertEquals(1, encryptedValueListForVerification.size(), 'Returns No Record');
        Test.stopTest();
    }
}