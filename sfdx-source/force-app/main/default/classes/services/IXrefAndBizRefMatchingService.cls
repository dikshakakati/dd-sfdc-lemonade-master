/**
 * @author DoorDash
 * @date   02/06/2024
 * @description This is the service interface for matching bizref and xref
 */
public interface IXrefAndBizRefMatchingService {
    /**
     * @description LEM-12595 Get Business References by Matching Business Vertical
     * @param accountBusinessVerticals
     * @return businessRefMap
     */
    Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        Set<String> accountBusinessVerticals
    );

    /**
     * @description It gets Business References by matching Business Vertical Ids, Brand Names
     * and Currency ISO Codes from passed Store accounts.
     * @param storeAccounts
     * @return businessRefMap
     */
    Map<String, Business_Reference__c> getBusinessReferencesByMatchingKey(
        List<Account> storeAccounts
    );

    /**
     * @description LEM-12595 validate matching business ref exists for readiness check
     * @param storeAccounts
     * @return businessRefMap
     */
    Map<Id, String> findMatchingBizRefForReadinesCheck(List<Account> storeAccounts);
    /**
     * @description LEM-12595 run the mathcing logic to find the mathcing ref by key from account and external source
     * @param accObj
     * @param businessRefMap
     * @param eachExternSource
     * @return businessRefMap
     */
    Business_Reference__c matchTheBizRefWithAccountByExternalSource(
        Account accObj,
        Map<String, Business_Reference__c> businessRefMap,
        String eachExternSource
    );
    /**
     * @description LEM-4208, LEM-12595 Display error message when Business Reference not found
     * @param accObj
     * @param eachExternSource
     * @return String
     */
    String getBizRefMatchingErrorDisplayMessage(Account accObj, String eachExternSource);

    /**
     * @description LEM-17673 Get Business References by Matching External Id.
     * @param businessIds
     * @return businessRefMap
     */
    Map<String, Business_Reference__c> getBusinessReferencesByMatchingBusinessId(
        Set<String> businessIds
    );
}