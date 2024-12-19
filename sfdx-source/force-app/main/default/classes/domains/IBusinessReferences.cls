/**
 * @description Interface to add Business Reference domain class methods
 */
public interface IBusinessReferences extends fflib_ISObjects {
    /**
     * @description This method is used to create a unique identifier using multiple fields
     */
    void validateUniqueness();
    /**
     * @description update Integration Message
     */
    void updateIntegrationMessage();

    /**
     * @description It is used to update 'Mastered In Figment' field when the Account related
     * to the associated Brand has Segment = "SMB" and Primary Vertical != "Rx".
     * @param triggerContext
     */
    void updateMasteredInFigment(String triggerContext);

    /**
     * @description update Process Request Flow if All External Ids Created
     */
    void updateProcessRequestFlowifAllExternalIdsCreated();

    /**
     * @description update Integration Message Linking Biz Id and BG ID
     * @param externalIdValue
     * @param message
     * @param status
     */
    void updateIntegrationMessageLinkingBizIdandBGID(String externalIdValue, String message, String status);

    /**
     * @description It is used to set Brand on Business References.
     * @param businessRefToBrandId
     */
    void setBrandOnBusinessReference(Map<Id, Id> businessRefToBrandId);
}