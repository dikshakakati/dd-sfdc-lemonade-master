/**
 * @author DoorDash
 * @date   09/26/2023
 * @description This is the service interface for retrieving the Business Friendly Error Message for a given Integration Error message
 */
public interface IGetBusinessFriendlyMessageService {
    /**
     * @description method to get the Provisioning related business friendly error message
     * @param provisioningMessage Provisioning Mesage for which we need to retrieve the Business Friendly Error Message
     * @param integrationType Integration Type for which this message belongs to
     * @return Business_Friendly_Mapping__mdt
     */
    Business_Friendly_Mapping__mdt getMessageDetails(String provisioningMessage, String integrationType);
}