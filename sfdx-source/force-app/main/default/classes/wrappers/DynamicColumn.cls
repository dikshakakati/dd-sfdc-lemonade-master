/**
 * @author Deloitte
 * @date 23/05/2022
 * @description Wrapper class for columns
 */
public class DynamicColumn {
    /**
     * @description Public field datatype property.
     */
    public String type { get; set; }

    /**
     * @description Public field name property.
     */
    public String fieldName { get; set; }

    /**
     * @description Public field label property.
     */
    public String label { get; set; }

    /**
     * @description Public field sort order property.
     */
    public Boolean sortable { get; set; }

    /**
     * @description Public default header actions on a column property.
     */
    public Boolean hideDefaultActions { get; set; }

    /**
     * @description Public field datatype property.
     */
    public TypeAttributes typeAttributes { get; set; }

    /**
     * @description Public field value property.
     */
    public String value { get; set; }

    /**
     * @description Public field api name property.
     */
    public String apiName { get; set; }

    /**
     * @description Inner class for columns
     */
    public class TypeAttributes {
        public Label label;
    }

    /**
     * @description Inner class for columns
     */
    public class Label {
        public String fieldName;
    }

    /**
     * @description Wrap Text property on column.
     */
    public Boolean wrapText { get; set; }
}