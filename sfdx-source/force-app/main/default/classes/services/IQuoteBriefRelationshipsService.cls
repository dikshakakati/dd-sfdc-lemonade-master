/**
 * @author Deloitte
 * @date 03/27/2023
 * @description Interface for service class of Quote Brief Relationship related logic.
 */
public interface IQuoteBriefRelationshipsService {
    /**
     * @description It is used to create Quote Brief Relationships based on a brief to quote
     * mapping.
     * @param briefsToQuoteIds
     * @param briefsToCampaign
     */
    void createQuoteBriefRelationshipsWithBriefToQuoteMapping(
        Map<Id, Set<Id>> briefsToQuoteIds,
        Map<Id, String> briefsToCampaign
    );
}