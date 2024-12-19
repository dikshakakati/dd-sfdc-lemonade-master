/**
 * @author Deloitte
 * @date   27/04/2022
 * @description This is the service interface for Address Verification and coverage check related logic
 */
public interface IAddressVerificationService {
    /**
     * @description Publish address verification platform event
     * @param accountsToVerifyAddress
     */
    void publishAddressVerificationEvent(List<SObject> accountsToVerifyAddress);
}