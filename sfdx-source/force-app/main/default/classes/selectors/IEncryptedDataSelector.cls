/**
 * @author Deloitte
 * @date 02/08/2022
 * @description Interface used for dynamically calling selector class
 * for fetching the encrypted data. It needs to be implemented by every selector class
 * that will be used to fetch the encrypted data.
 */
public interface IEncryptedDataSelector {
    /**
     * @description It is used to get the encrypted data stored in the passed fields
     * by the passed sObjectIds.
     * @param fieldSet
     * @param sobjectIds
     * @return List<SObject>
     */
    List<SObject> selectEncryptedData(Schema.FieldSet fieldSet, Set<Id> sobjectIds);
}