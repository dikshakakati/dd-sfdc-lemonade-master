/**
 * @author CriticalRiver
 * @date Sep 20, 2024
 *
 * @description Class for getting picklist values and dependent picklist values
*/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class PicklistUtil {

    public static final Map<String, Schema.SObjectType> SOBJECT_TYPES = Schema.getGlobalDescribe();

    /**
     * @description Wrapper class with AuraEnabled fields
     */
    public class PicklistOption {
        /**
         * @description : Label of the picklist Value
         * return String
         */
        @AuraEnabled public String label { get; set; }

        /**
         * @description : Value of the picklist selcted
         * return String
         */
        @AuraEnabled public String value { get; set; }

        /**
         * @description : Boolean of the value
         * return Boolean
         */
        @AuraEnabled public Boolean selected {get; set;}
        /**
         * @description Default Constructor
         * @param  label - label of picklist
         * @param  value - value of picklist
         */
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
        /**
         * @description Second Constructor
         * @param  label - label of picklist
         * @param  value - value of picklist
         * @param  selected - pre-selected picklist option
         */
        public PicklistOption(String label, String value,Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }

    /**
     * @description Get picklist Option in a format which can be easily read in LWC/Aura components
     * @param objectName - Sobject name containing field
     * @param fieldList - comma separated list of fields
     * @return Map<string, List<PicklistOption>> - Picklist option for each field
     */
    @AuraEnabled(cacheable=true)
    public static Map<string, List<PicklistOption>> getPicklistOptions(string objectName, string fieldList) {
        Map<string, List<PicklistOption>> pickListVals = new Map<string, List<PicklistOption>>();

        Map<String, Schema.SObjectField> fieldMap = SOBJECT_TYPES.get(objectName).getDescribe().fields.getMap();

        for (string fieldName : fieldList.split(DdConstants.DELIMITER_COMMA)){
            List<PicklistOption> options = new List<PicklistOption> ();
            for ( PicklistEntry entry : fieldMap.get(fieldName).getDescribe().getPicklistValues()) {
                options.add(new PicklistOption( entry.getLabel(),entry.getValue()));
            }
            if (!options.isEmpty()){
                pickListVals.put(fieldName, options);
            }
        }
        return pickListVals;
    }

    /**
     * @author CriticalRiver
     * @date Sep 20, 2024
     * @description Class to set the values of the Valid for
    */
    public class PickListInfo {
        public String validFor;
    }
    /**
     * @description Get picklist Option in a format which can be easily read in LWC/Aura components
     * @param objectName - Sobject name containing field
     * @param controllingField - parent field
     * @param dependentField - child field
     * @return  Map<String, List<String>> - Map<Parent Picklist Value, List<Child Picklist Values>>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getDependentPicklistValues(String objectName, String controllingField, String dependentField) {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Map<String,Schema.SObjectType> objGlobalMap = SOBJECT_TYPES;
        if (!objGlobalMap.containsKey(objectName)){
            return controllingInfo;
        }

        Map<String, Schema.SObjectField> objFieldMap = objGlobalMap.get(objectName).getDescribe().fields.getMap();

        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return controllingInfo;
        }

        Schema.DescribeFieldResult controllingFieldInfo = objFieldMap.get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = objFieldMap.get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);

            PicklistInfo info = (PicklistInfo) JSON.deserialize(jsonString, PicklistInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            Integer baseCount = 0;

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;

                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel())
                        .add(currDependentValue.getLabel());
                }
                if ((val & 1) == 1){
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel())
                        .add(currDependentValue.getLabel());
                }

                baseCount += 4;
            }
        }
        return controllingInfo;
    }
}