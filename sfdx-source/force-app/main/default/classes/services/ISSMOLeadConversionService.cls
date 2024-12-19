/**
 * @author Deloitte
 * @date 05/16/2024
 * @description Interface for service class of SSMO Lead conversion related logic.
 */
public interface ISSMOLeadConversionService {
    /**
     * @description It is used to auto convert Leads received from
     * onboarding SSMO scenario by passed Inbound Ingestion Log Ids.
     * @param ingestionLogIds
     * @param payLoadWrapperByIngestionLogUUIDForContactAndACR
     */
    void autoConvertLeads(Set<Id> ingestionLogIds,Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUIDForContactAndACR);
}