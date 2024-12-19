/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Interface for service class of ViewEncryptedData controller related logic.
 */
public interface IViewEncryptedDataService {
    /**
     * @description It fetches encrypted details using passed viewEncryptedDataWrapper
     * which consists of businessAccountId, componentLocation, recordId and workOrderId.
     * @param viewEncryptedDataWrapper
     * @return List<EncryptedFieldWrapper>
     */
    List<EncryptedFieldWrapper> getEncryptedData(ViewEncryptedDataWrapper viewEncryptedDataWrapper);

    /**
     * @description It fires update on sObject associated with the passed recordId using the passed data.
     * @param recordId
     * @param updatedEncryptedData
     */
    void updateEncryptedData(Id recordId, String updatedEncryptedData);
}