/**
 * @description This is a service class ,which used to get SobjectDescribe details.
 * @author Deloitte
 * @date 19/04/2022
 */
public inherited sharing class SObjectDescribeService {
    /**
     * @description this method will return fields based on given data type and object.
     * @param sobj
     * @param displayType
     * @return Set<Schema.SObjectField>
     */
    public static Set<Schema.SObjectField> getFieldsByDisplayType(
        SObjectType sobj,
        Schema.DisplayType displayType
    ) {
        return service().getFieldsByDisplayType(sobj, displayType);
    }

    /**
     * @description calling newInstance for service class.
     * @return ISObjectDescribeService - returning interface.
     */
    private static ISObjectDescribeService service() {
        return (ISObjectDescribeService) Application.SERVICE.newInstance(
            ISObjectDescribeService.class
        );
    }
}