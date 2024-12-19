/**
 * @author Deloitte
 * @date 05/31/2024
 * @description Interface for Lead Conversion mapping service.
 **/
public interface ILeadConversionMappingService {
    /**
     * @description It collects Lead to store Account conversion field mapping from
     * passed static resource file Blob.
     * @param leadMappingsCSV
     * @return String[]
     */
    String[] collectFields(Blob leadMappingsCSV);

    /**
     * @description It collects Account field values mappings from passed mappings
     * received from iterating over static resource file.
     * @param fieldMappings
     * @param objectName
     * @return Map<String, String>
     */
    Map<String, String> collectFieldValueMappings(List<String> fieldMappings, String objectName);
}