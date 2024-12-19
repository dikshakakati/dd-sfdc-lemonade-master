/**
 * @author Deloitte
 * @date 07/22/2024
 * @description Interface of service class for Cassie Id encryption related logic.
 */
public interface ICassieIdEncryptionService {
    /**
     * @description It encrypts the cassie email Id.
     * @param records
     * @param fieldNameToBeEncrypted
     * @param cassieFieldName
     * @return List<SObject>
     */
    List<SObject> encryptCassieId(
        List<SObject> records,
        String fieldNameToBeEncrypted,
        String cassieFieldName
    );
}