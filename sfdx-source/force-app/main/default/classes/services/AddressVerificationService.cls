/**
 * @author Deloitte
 * @date   27/04/2022
 * @description This is the service interface for Address Verification and coverage check related logic
 */
public inherited sharing class AddressVerificationService {
    /**
     * @description Publish address verification platform event
     * @param recordsToVerifyAddress
     */
    public static void publishAddressVerificationEvent(List<SObject> recordsToVerifyAddress) {
        service().publishAddressVerificationEvent(recordsToVerifyAddress);
    }

    private static IAddressVerificationService service() {
        return (IAddressVerificationService) Application.Service.newInstance(
            IAddressVerificationService.class
        );
    }
}