/**
 * @author Deloitte
 * @date 05/31/2024
 * @description Service class for LeadConversionMapping related logic.
 */
public inherited sharing class LeadConversionMappingService {
    /**
     * @description It collects Lead to store Account conversion field mapping from
     * passed static resource file Blob.
     * @param leadMappingsCSV
     * @return String[]
     */
    public static String[] collectFields(Blob leadMappingsCSV) {
        return service().collectFields(leadMappingsCSV);
    }

    /**
     * @description It collects Account field values mappings from passed mappings
     * received from iterating over static resource file.
     * @param fieldMappings
     * @param objectName
     * @return Map<String, String>
     */
    public static Map<String, String> collectFieldValueMappings(
        List<String> fieldMappings,
        String objectName
    ) {
        return service().collectFieldValueMappings(fieldMappings, objectName);
    }

    /**
     * @description - Returns an instance of ILeadConversionMappingService.
     * @return ILeadConversionMappingService
     */
    private static ILeadConversionMappingService service() {
        return (ILeadConversionMappingService) Application.SERVICE.newInstance(
            ILeadConversionMappingService.class
        );
    }
}