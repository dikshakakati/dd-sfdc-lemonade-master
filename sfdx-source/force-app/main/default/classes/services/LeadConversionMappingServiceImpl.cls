/**
 * @author Deloitte
 * @date 05/31/2024
 * @description Service implementation class for Lead Conversion mapping related logic.
 */
public inherited sharing class LeadConversionMappingServiceImpl implements ILeadConversionMappingService {
    private static final String COMMA = ',';
    private static final String FORWARDSLASH_R = '\r';
    private static final String FORWARDSLASH_N = '\n';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final String LOG_FIELD_MAPPING_ERROR = 'Lead to Account conversion field mapping is empty.';
    private static final String LOG_DOMAIN = 'Sales';

    /**
     * @description It collects Lead to store Account conversion field mapping from
     * passed static resource file Blob.
     * @param leadMappingsCSV
     * @return String[]
     */
    public String[] collectFields(Blob leadMappingsCSV) {
        String[] fieldMappings;
        if (leadMappingsCSV == null) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_FIELD_MAPPING_ERROR,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
            );
            return fieldMappings;
        }
        String csvString = leadMappingsCSV.toString();
        // Normalize line endings to Unix-style
        csvString = csvString.replace(FORWARDSLASH_R_N, FORWARDSLASH_N)
            .replace(FORWARDSLASH_R, FORWARDSLASH_N);
        fieldMappings = csvString.split(FORWARDSLASH_N);
        fieldMappings.remove(0);
        return fieldMappings;
    }

    /**
     * @description It collects Account field values mappings from passed mappings
     * received from iterating over static resource file.
     * @param fieldMappings
     * @param objectName
     * @return Map<String, String>
     */
    public Map<String, String> collectFieldValueMappings(
        List<String> fieldMappings,
        String objectName
    ) {
        List<String> fieldMappingSplits = new List<String>();
        Map<String, String> sObjectFieldToValue = new Map<String, String>();
        for (String eachFieldMapping : fieldMappings) {
            // Trim to remove any trailing carriage return character
            fieldMappingSplits = eachFieldMapping.trim().split(COMMA);
            if (fieldMappingSplits[0] == objectName) {
                sObjectFieldToValue.put(fieldMappingSplits[1], fieldMappingSplits[2]);
            }
        }
        return sObjectFieldToValue;
    }
}