/**
 * @author Doordash
 * @date 09/27/2023
 * @description Service class for GetBusinessFriendlyMessageService logic.
 */
public with sharing class GetBusinessFriendlyMessageService {
    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param provisioningMessage
     * @param integrationType
     * @return Business_Friendly_Mapping__mdt
     */
    public static Business_Friendly_Mapping__mdt getMessageDetails(String provisioningMessage, String integrationType) {
        return service().getMessageDetails(provisioningMessage, integrationType);
    }

    /**
     * @description This method is used to create an instance of IGetBusinessFriendlyMessageService class.
     * @return IGetBusinessFriendlyMessageService - return instance of GetBusinessFriendlyMessageServiceImpl
     */
    private static IGetBusinessFriendlyMessageService service() {
        return (IGetBusinessFriendlyMessageService) Application.Service.newInstance(IGetBusinessFriendlyMessageService.class);
    }
}