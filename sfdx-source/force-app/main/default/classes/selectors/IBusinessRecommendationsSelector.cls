/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Interface to add Selector class methods.
 */
public interface IBusinessRecommendationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get the Business Recommendations by the passed business account Ids.
     * @param businessAccountIds
     * @return List<Recommendation_Business__x>
     */
    List<Recommendation_Business__x> selectBusinessRecommendationsByBusinessAccountIds(List<String> businessAccountIds);
}