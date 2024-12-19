/**
 * @author Deloitte
 * @date 27/04/2022
 * @description SectionWrapper for storesOnWorkPlan lightning web component.
 */
public class SectionWrapper {
    @AuraEnabled
    public Boolean isSupportedObject;
    @AuraEnabled
    public Integer sequence;
    @AuraEnabled
    public String sectionName;
    @AuraEnabled
    public Boolean showSectionHeader;
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String objectName;
    @auraEnabled
    public List<String> fields;
    @AuraEnabled
    public Boolean showEncrytedData;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param sequence
     * @param sectionName
     * @param recordId
     * @param objectName
     * @param fields
     */
    public SectionWrapper(
        Integer sequence,
        String sectionName,
        String recordId,
        String objectName,
        List<String> fields
    ) {
        this.sequence = sequence;
        this.sectionName = sectionName;
        this.showSectionHeader = true;
        this.showEncrytedData = false;
        this.recordId = recordId;
        this.objectName = objectName;
        this.fields = fields != null && !fields.isEmpty() ? fields : new List<String>();
    }
}