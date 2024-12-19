/**
 * @author DoorDash
 * @date   02/06/2024
 * @description This is the service class for matching bizref and xref
 */
public inherited sharing class XrefAndBizRefMatchingService {
    /**
     * @description LEM-12595 Get Business References by Matching Business Vertical
     * @param accountBusinessVerticals
     * @return businessRefMap
     */
    public static Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        Set<String> accountBusinessVerticals
    ) {
        return service().getBusinessReferencesByMatchingKey(accountBusinessVerticals);
    }

    /**
     * @description It gets Business References by matching Business Vertical Ids, Brand Names
     * and Currency ISO Codes from passed Store accounts.
     * @JIRA# LEM-15747
     * @param storeAccounts
     * @return businessRefMap
     */
    public static Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        List<Account> storeAccounts
    ) {
        return service().getBusinessReferencesByMatchingKey(storeAccounts);
    }

    /**
     * @description LEM-12595 validate matching business ref exists for readiness check
     * @param storeAccounts
     * @return businessRefMap
     */
    public static Map<Id, String> findMatchingBizRefForReadinesCheck(List<Account> storeAccounts) {
        return service().findMatchingBizRefForReadinesCheck(storeAccounts);
    }
    /**
     * @description LEM-12595 run the mathcing logic to find the mathcing ref by key from account and external source
     * @param accObj
     * @param businessRefMap
     * @param eachExternSource
     * @return businessRefMap
     */
    public static Business_Reference__c matchTheBizRefWithAccountByExternalSource(
        Account accObj,
        Map<String, Business_Reference__c> businessRefMap,
        String eachExternSource
    ) {
        return service()
            .matchTheBizRefWithAccountByExternalSource(accObj, businessRefMap, eachExternSource);
    }
    /**
     * @description LEM-4208, LEM-12595 Display error message when Business Reference not found
     * @param accObj
     * @param eachExternSource
     * @return String
     */
    public static String getBizRefMatchingErrorDisplayMessage(
        Account accObj,
        String eachExternSource
    ) {
        return service().getBizRefMatchingErrorDisplayMessage(accObj, eachExternSource);
    }
    private static IXrefAndBizRefMatchingService service() {
        return (IXrefAndBizRefMatchingService) Application.Service.newInstance(
            IXrefAndBizRefMatchingService.class
        );
    }

    /**
     * @description LEM-17673 Get Business References by Matching External Id.
     * @param businessIds
     * @return businessRefMap
     */
    public static Map<String, Business_Reference__c> getBusinessReferencesByMatchingBusinessId(
        Set<String> businessIds
    ) {
        return service().getBusinessReferencesByMatchingBusinessId(businessIds);
    }
}