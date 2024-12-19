/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Service class for ViewEncryptedDataController related logic.
 */
public inherited sharing class ViewEncryptedDataService {
    /**
     * @description It fetches encrypted details using passed viewEncryptedDataWrapper
     * which consists of businessAccountId, componentLocation, recordId and workOrderId.
     * @JIRA# LEM-2255
     * @param viewEncryptedDataWrapper
     * @return List<EncryptedFieldWrapper>
     */
    public static List<EncryptedFieldWrapper> getEncryptedData(
        ViewEncryptedDataWrapper viewEncryptedDataWrapper
    ) {
        return service().getEncryptedData(viewEncryptedDataWrapper);
    }

    /**
     * @description It fires update on sObject associated with the passed recordId using the passed data.
     * @JIRA# LEM-2255
     * @param recordId
     * @param updatedEncryptedData
     */
    public static void updateEncryptedData(Id recordId, String updatedEncryptedData) {
        service().updateEncryptedData(recordId, updatedEncryptedData);
    }

    /**
     * @description It creates instance of ViewEncryptedDataServiceImpl class.
     * @return IViewEncryptedDataService - return instance of ViewEncryptedDataServiceImpl
     */
    private static IViewEncryptedDataService service() {
        return (IViewEncryptedDataService) Application.Service.newInstance(
            IViewEncryptedDataService.class
        );
    }
}