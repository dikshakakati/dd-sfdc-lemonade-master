/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Controller class for viewEncryptedData lightning web component.
 */
public with sharing class ViewEncryptedDataController {
    /**
     * @description It fetches encrypted details using passed viewEncryptedDataWrapper
     * which consists of businessAccountId, componentLocation, recordId and workOrderId.
     * @JIRA# LEM-2255
     * @param viewEncryptedDataWrapper
     * @return List<EncryptedFieldWrapper>
     */
    @AuraEnabled
    public static List<EncryptedFieldWrapper> getEncryptedData(
        ViewEncryptedDataWrapper viewEncryptedDataWrapper
    ) {
        return ViewEncryptedDataService.getEncryptedData(viewEncryptedDataWrapper);
    }

    /**
     * @description It fires update on sObject associated with the passed recordId using the passed data.
     * @JIRA# LEM-2255
     * @param recordId
     * @param updatedEncryptedData
     */
    @AuraEnabled
    public static void updateEncryptedData(Id recordId, String updatedEncryptedData) {
        ViewEncryptedDataService.updateEncryptedData(recordId, updatedEncryptedData);
    }
}