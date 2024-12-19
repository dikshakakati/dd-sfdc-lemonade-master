/**
 * @author Deloitte
 * @date 27/04/2022
 * @description Trigger on Merchant Pop Up Responses
 */
trigger MerchantPopUpResponses on Merchant_Pop_Up_Response__c(
    after update,
    before insert,
    before update
) {
    fflib_SObjectDomain.triggerHandler(MerchantPopUpResponsesHandler.class);
}