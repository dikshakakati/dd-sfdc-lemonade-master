/**
 * @author Deloitte
 * @date 10/04/2022
 * @description It is used for sending details from viewEncryptedData
 * lightning web component to service layer.
 */
public class ViewEncryptedDataWrapper {
    /**
     * @description getter/setter for businessAccountId variable.
     */
    @AuraEnabled
    public Id businessAccountId { get; set; }
    /**
     * @description getter/setter for componentLocation variable.
     */
    @AuraEnabled
    public String componentLocation { get; set; }
    /**
     * @description getter/setter for paymentRecordIds variable.
     */
    @AuraEnabled
    public String paymentRecordIds { get; set; }
    /**
     * @description getter/setter for recordId variable.
     */
    @AuraEnabled
    public Id recordId { get; set; }
    /**
     * @description getter/setter for workOrderId variable.
     */
    @AuraEnabled
    public Id workOrderId { get; set; }
}