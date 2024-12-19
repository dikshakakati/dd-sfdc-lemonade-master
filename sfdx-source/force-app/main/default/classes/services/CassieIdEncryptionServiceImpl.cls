/**
 * @author Deloitte
 * @date 07/22/2024
 * @description Service implementation class for CassieId encryption related logic.
 */
public inherited sharing class CassieIdEncryptionServiceImpl implements ICassieIdEncryptionService {
    private static final String EMAIL_PREFERENCES_ENCRYPTION_KEY = 'Email_Preferences_Encryption_Key';
    private static final String EMAIL_PREFERENCES_PERSONA = 'Email_Preferences_Persona';
    private static final String ALGORITHM_NAME = 'AES256';
    private static String encryprionKey;
    private static String persona;
    static {
        encryprionKey = String.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EMAIL_PREFERENCES_ENCRYPTION_KEY)
                .Configuration_Value__c
        );
        persona = String.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(EMAIL_PREFERENCES_PERSONA)
                .Configuration_Value__c
        );
    }

    /**
     * @description It encrypts the cassie email Id.
     * @param records
     * @param fieldNameToBeEncrypted
     * @param cassieFieldName
     * @return List<SObject>
     */
    public List<SObject> encryptCassieId(
        List<SObject> records,
        String fieldNameToBeEncrypted,
        String cassieFieldName
    ) {
        List<SObject> recordsToUpdate = new List<SObject>();
        String textToBeEncrypted;
        String algorithmName = ALGORITHM_NAME;
        Blob key = EncodingUtil.base64Decode(encryprionKey);
        Blob encryptedValue;
        String tobeEncryptedFieldValue;
        for (SObject eachRecord : records) {
            //Get Value to be encrypted
            tobeEncryptedFieldValue = '';
            Object fieldValue = eachRecord.get(fieldNameToBeEncrypted);
            if (fieldValue != null) {
                tobeEncryptedFieldValue = String.valueOf(fieldValue);
            }

            if (!String.isEmpty(tobeEncryptedFieldValue)) {
                textToBeEncrypted = 'Email=' + tobeEncryptedFieldValue + '&Persona=' + persona;
                encryptedValue = Crypto.encryptWithManagedIV(
                    algorithmName,
                    key,
                    Blob.valueOf(textToBeEncrypted)
                );
                //Set encrypted value to the record
                eachRecord.put(cassieFieldName, EncodingUtil.base64Encode(encryptedValue));
                recordsToUpdate.add(eachRecord);
            }
        }
        return recordsToUpdate;
    }
}