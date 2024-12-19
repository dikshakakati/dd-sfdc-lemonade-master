/**
 * @author Deloitte
 * @date 05/16/2024
 * @description Service class for SSMO Lead Conversion related logic.
 */
public inherited sharing class SSMOLeadConversionService {
    /**
     * @description It creates instance of SSMOLeadConversionServiceImpl class.
     * @return ISSMOLeadConversionService
     */
    private static ISSMOLeadConversionService service() {
        return (ISSMOLeadConversionService) Application.Service.newInstance(
            ISSMOLeadConversionService.class
        );
    }

    /**
     * @description It is used to auto convert Leads received from
     * onboarding SSMO scenario by passed Inbound Ingestion Log Ids.
     * @param ingestionLogIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    public static void autoConvertLeads(Set<Id> ingestionLogIds,Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR) {
        service().autoConvertLeads(ingestionLogIds,payLoadWrapperByIngestionLogUUIDForContactAndACR);
    }
}