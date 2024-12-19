/**
 * @author Deloitte
 * @description Interface to add Selector class methods.
 */
public interface IEncryptedValuesSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting encrypted value associated with the passed key name.
     * @param encryptedValueName
     * @return List<Encrypted_Value__c>
     */
    List<Encrypted_Value__c> selectByName(String encryptedValueName);
}