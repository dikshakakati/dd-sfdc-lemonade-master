/**
 * @author Deloitte
 * @date 07/22/2024
 * @description Service class for CassieId encryption related logic.
 */
public inherited sharing class CassieIdEncryptionService{
    /**
     * @description It encrypts the cassie email Id.
     * @param records
     * @param fieldNameToBeEncrypted
     * @param cassieFieldName
     * @return List<SObject>
     */
    public static List<SObject> encryptCassieId(
        List<SObject> records,
        String fieldNameToBeEncrypted,
        String cassieFieldName
    ) {
        return service().encryptCassieId(records, fieldNameToBeEncrypted, cassieFieldName);
    }

    /**
     * @description It creates an instance of CassieIdEncryptionService class.
     * @return ICassieIdEncryptionService
     */
    private static ICassieIdEncryptionService service() {
        return (ICassieIdEncryptionService) Application.SERVICE.newInstance(
            ICassieIdEncryptionService.class
        );
    }
}