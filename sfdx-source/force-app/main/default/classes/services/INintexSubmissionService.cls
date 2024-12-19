/**
 * @author DoorDash
 * @date   08/21/2022
 * @description This is the service interface for Nintex Use Cases related logic
 */

public interface INintexSubmissionService {

    /**
     * @description method to process opportunities based on Nintex UseCase,
     * @param opportunities list of IOpportunities
     */
    void submitOpportunities(IOpportunities opportunities);
}