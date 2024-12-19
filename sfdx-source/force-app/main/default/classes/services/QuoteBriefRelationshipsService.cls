/**
 * @author Deloitte
 * @date 03/27/2023
 * @description Service class for Quote Brief Relationship related logic.
 */
public inherited sharing class QuoteBriefRelationshipsService {
    /**
     * @description It is used to create Quote Brief Relationships based on a brief to quote
     * mapping.
     * @param briefsToQuoteIds
     * @param briefsToCampaign
     */
    public static void createQuoteBriefRelationshipsWithBriefToQuoteMapping(
        Map<Id, Set<Id>> briefsToQuoteIds,
        Map<Id, String> briefsToCampaign
    ) {
        service()
            .createQuoteBriefRelationshipsWithBriefToQuoteMapping(
                briefsToQuoteIds,
                briefsToCampaign
            );
    }

    /**
     * @description This method is used to create an instance of QuoteBriefRelationshipsService class.
     * @return IQuoteBriefRelationshipsService - return instance of QuoteBriefRelationshipsServiceImpl.
     */
    private static IQuoteBriefRelationshipsService service() {
        return (IQuoteBriefRelationshipsService) Application.Service.newInstance(
            IQuoteBriefRelationshipsService.class
        );
    }
}