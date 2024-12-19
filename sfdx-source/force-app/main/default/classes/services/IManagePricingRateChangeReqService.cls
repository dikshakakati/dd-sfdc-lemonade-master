/**
 * @author Deloitte
 * @date 08/18/2023
 * @description Interface of service class for Rate Change Request creation related logic.
 */
public interface IManagePricingRateChangeReqService {
    /**
     * @description Creates a Rate change request and Subscription rate change records
     * @param managePricingWrapper
     * @return Id
     */
    Id createRateChangeRequest(ManagePricingWrapper managePricingWrapper);
}