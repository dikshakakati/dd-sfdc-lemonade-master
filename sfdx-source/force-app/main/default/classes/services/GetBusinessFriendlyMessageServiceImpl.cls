/**
 * @author DoorDash
 * @date 09/27/2023
 * @description Service class for returning Business friendly Messages.
 */
public inherited sharing class GetBusinessFriendlyMessageServiceImpl implements IGetBusinessFriendlyMessageService{
     /**
     * @description Used to return Business friendly Messages for a given integration message
     * @param provisioningMessage
     * @param integrationType
     * @return Business_Friendly_Mapping__mdt
     */
    public Business_Friendly_Mapping__mdt getMessageDetails(
        String provisioningMessage,
        String integrationType
    ) {
        Business_Friendly_Mapping__mdt businessFriendlyMapping;
        if (String.isBlank(provisioningMessage)) {
            return businessFriendlyMapping;
        }
        List<Business_Friendly_Mapping__mdt> messagesMapping = BusinessFriendlyMappingSelector.newInstance()
            .selectByIntegrationType(integrationType);
        for (Business_Friendly_Mapping__mdt mapping : messagesMapping) {
            if (provisioningMessage?.containsIgnoreCase(mapping.Integration_Key_String__c)) {
                businessFriendlyMapping = mapping;
                break;
            }
        }
        return businessFriendlyMapping;
    }
}