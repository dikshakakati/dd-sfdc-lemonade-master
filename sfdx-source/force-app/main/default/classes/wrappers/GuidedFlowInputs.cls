/**
 * @author Deloitte
 * @date 04/30/2024
 * @description It is used for sending information needed for Creation of Mx Order from Guided Flow.
 */
public with sharing class GuidedFlowInputs {
    @InvocableVariable
    public Id workOrderId;
    @InvocableVariable
    public String typeOfRequest;
    @InvocableVariable
    public String productBundleName;
    @InvocableVariable
    public String tabletIMEI;
    @InvocableVariable
    public String printerIMEI;
    @InvocableVariable
    public Id contactId;
    @InvocableVariable
    public Id accountId;
    @InvocableVariable
    public String shippingStateCode;
    @InvocableVariable
    public String shippingCountryCode;
    @InvocableVariable
    public String shippingCity;
    @InvocableVariable
    public String shippingStreet;
    @InvocableVariable
    public String shippingPostalCode;
    @InvocableVariable
    public WorkOrder workOrder;
    @InvocableVariable
    public String replacementReason;
    @InvocableVariable
    public String reasonForReturn;
    @InvocableVariable
    public String returnComponent;
}
