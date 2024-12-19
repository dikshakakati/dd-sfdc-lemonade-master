/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Interface for service class of StoresOnWorkPlan controller related logic.
 */
public interface IStoresOnWorkPlansService {
    /**
     * @description To fetch unique stores from current WorkPlan.
     * @param currentWorkPlanRecordId
     * @return StoresOnWorkPlanWrapper
     */
    StoresOnWorkPlanWrapper fetchStoresByWorkPlan(Id currentWorkPlanRecordId);

    /**
     * @description To fetch stores details when accountWrapper is passed.
     * @param accountWrapper
     * @return List<SectionWrapper>
     */
    List<SectionWrapper> fetchStoresData(String accountWrapper);
}