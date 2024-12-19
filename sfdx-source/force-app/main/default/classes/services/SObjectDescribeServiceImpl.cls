/**
 * @description : Interface to add reusable methods.
 * @author Deloitte
 * @date 19/04/2022
 */
public inherited sharing class SObjectDescribeServiceImpl implements ISObjectDescribeService {
    /**
     * @description this method will return fields based on given data type and object.
     * @param sobj
     * @param displayType
     * @return Set<Schema.SObjectField>
     */
    public Set<Schema.SObjectField> getFieldsByDisplayType(
        SObjectType sobj,
        Schema.DisplayType displayType
    ) {
        Map<String, Schema.SObjectField> mapFieldList = sobj.getDescribe().fields.getMap();
        Set<Schema.SObjectField> sObjectFields = new Set<Schema.SObjectField>();

        for (Schema.SObjectField field : mapFieldList.values()) {
            if (field.getDescribe().getType() == displayType) {
                sObjectFields.add(field);
            }
        }
        return sObjectFields;
    }
}