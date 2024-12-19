/**
 * @description : Interface to add reusable methods.
 * @author Deloitte
 * @date 19/04/2022
 */
public interface ISObjectDescribeService {
    /**
     * @description this method will return fields based on given data type and object.
     * @param sobj
     * @param displayType
     * @return Set<Schema.SObjectField>
     */
    Set<Schema.SObjectField> getFieldsByDisplayType(
        SObjectType sobj,
        Schema.DisplayType displayType
    );
}