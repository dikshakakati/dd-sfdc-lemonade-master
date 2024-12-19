/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Service class for StoresOnWorkPlanController related logic.
 */
public inherited sharing class StoresOnWorkPlansService {
    /**
     * @description To fetch unique stores from current WorkPlan.
     * @JIRA# LEM-1158
     * @param currentWorkPlanRecordId
     * @return StoresOnWorkPlanWrapper
     */
    public static StoresOnWorkPlanWrapper fetchStoresByWorkPlan(Id currentWorkPlanRecordId) {
        return service().fetchStoresByWorkPlan(currentWorkPlanRecordId);
    }

    /**
     * @description To fetch stores details when accountWrapper.
     * @JIRA# LEM-1158
     * @param accountWrapper
     * @return List<SectionWrapper>
     */
    public static List<SectionWrapper> fetchStoresData(String accountWrapper) {
        return service().fetchStoresData(accountWrapper);
    }

    /**
     * @description It creates instance of StoresOnWorkPlansServiceImpl class.
     * @return IStoresOnWorkPlansService - return instance of StoresOnWorkPlansServiceImpl
     */
    private static IStoresOnWorkPlansService service() {
        return (IStoresOnWorkPlansService) Application.Service.newInstance(
            IStoresOnWorkPlansService.class
        );
    }
}