/**
 * @description Utility for generating fake SObject records for unit testing
 * Provides easy api for setting record valid record ids and building complex relationship structures
 * @author Scott McClung
 * @date 3/9/2022
 */
public virtual class Fake {
    /**
     * @description Internal interface for the SObject elements being created
     */
    public interface INode {
        Map<String, Object> serialize();
    }

    /**
     * @description Returns a valid Id for the given SObjectType
     * @param sObjectType The type of SObject the Id should represent (e.g. Account.SObjectType, Contact.SObjectType)
     * @return Id The resulting SObject Id
     */
    public static Id generateId(Schema.SObjectType sObjectType) {
        return new IdGenerator().generate(sObjectType);
    }

    /**
     * @description Returns a valid Id for the given SObjectType
     * @param type The type of SObject the Id should represent (e.g. Account.class, Case.class)
     * @return Id The resulting SObject Id
     */
    public static Id generateId(System.Type type) {
        return new IdGenerator().generate(type);
    }

    /**
     * @description Internal counter for unique record ids
     */
    static Integer idCounter = 0;

    protected Type sObjectType;
    @TestVisible
    private INode[] nodes = new List<INode>{};

    /**
     * @description Constructs a Fake record based on the type of the SObject (e.g. new Fake(Account.class))
     * @param sObjectType The type of the SObject (e.g. Account.class, Case.class)
     */
    public Fake(Type sObjectType) {
        this.sObjectType = sObjectType;
    }

    /**
     * @description Constructs a Fake record based on the type of the SObject and a map of fields and their values
     * @param sObjectType The type of the SObject (e.g. Account.class, Case.class)
     * @param fields Map<SObjectField, Object> Map of fields and their values
     */
    public Fake(Type sObjectType, Map<Schema.SObjectField, Object> fields) {
        this(sObjectType);

        for (Schema.SObjectField field : fields.keySet()) {
            setField(field, fields.get(field));
        }
    }

    /**
     * @description Internal constructor
     * @param sObjectType Type of the SObject
     * @param nodes List<INode>
     */
    @TestVisible
    protected Fake(Type sObjectType, INode[] nodes) {
        this.sObjectType = sObjectType;
        this.nodes = nodes;
    }

    /**
     * @description Adds a valid Id to the record
     * @return Fake provides a fluent interface
     */
    public Fake setFakeId() {
        return setField(getSObjectField('Id'), generateId(getSObjectType()));
    }

    /**
     * @description Adds a valid Id field to the record (e.g. a parent relationship field) based on
     * the type of the SObject (e.g. Account.class)
     * @param field SObjectField relationship field that should be added with an Id value
     * @param type The Type of the SObject that the relationship refers to
     * @return Fake provides a fluent interface
     */
    public Fake setFakeId(Schema.SObjectField field, Type type) {
        return setFakeId(field, getSObjectType(type));
    }

    /**
     * @description Adds a valid Id field to the record (e.g. a parent relationship field) based on
     * the SObjectType of the SObject (e.g. Account.SObjectType)
     * @param field SObjectField relationship field that should be added with an Id value
     * @param sObjectType The SObjectType of the SObject that the relationship refers to
     * @return Fake provides a fluent interface
     */
    public Fake setFakeId(Schema.SObjectField field, Schema.SObjectType sObjectType) {
        return setField(field, generateId(sObjectType));
    }

    /**
     * @description Establishes the standard CreatedById, CreatedDate, LastModifiedById, and LastModifiedDate values
     * on the record.  The timestamps default to the current time.
     * @return Fake provides a fluent interface
     */
    public Fake setTimestamps() {
        return setTimestamps(Datetime.now(), generateId(User.SObjectType));
    }

    /**
     * @description Establishes the standard CreatedById, CreatedDate, LastModifiedById, and LastModifiedDate values
     * on the record.
     * @param dt Datetime value set in CreatedDate and LastModifiedDate
     * @return Fake provides a fluent interface
     */
    public Fake setTimestamps(Datetime dt) {
        return setTimestamps(dt, generateId(User.SObjectType));
    }

    /**
     * @description Establishes the standard CreatedById, CreatedDate, LastModifiedById, and LastModifiedDate values
     * on the record
     * @param dt Datetime value set in CreatedDate and LastModifiedDate
     * @param userId User id value set in CreatedById and LastModifiedById
     * @return Fake provides a fluent interface
     */
    public Fake setTimestamps(Datetime dt, Id userId) {
        return setField(getSObjectField('CreatedDate'), dt)
            .setField(getSObjectField('CreatedById'), userId)
            .setField(getSObjectField('LastModifiedDate'), dt)
            .setField(getSObjectField('LastModifiedById'), userId);
    }

    /**
     * @description
     * @param field SObjectField that will be set on the record
     * @param value The value set on the record for this field
     * @return Fake provides a fluent interface
     */
    public Fake setField(Schema.SObjectField field, Object value) {
        nodes.add(new FieldValuePairNode(field, value));
        return this;
    }

    /**
     * @description Defines a Fake instance as a parent record based on the relationship name provided
     * @param relationshipName The name of the relationship (e.g. Opportunity.Account would be 'Account')
     * @param fabricatedParent Instance of Fake that represents the parent record
     * @return Fake provides a fluent interface
     */
    public Fake setParent(String relationshipName, Fake fabricatedParent) {
        nodes.add(new ParentRelationshipNode(relationshipName, fabricatedParent));
        return this;
    }

    /**
     * @description Defines a list of Fake instances as children records based on the relationship name provided
     * @param relationshipName The name of the relationship (e.g. Opportunity.Account would be 'Account')
     * @param fabricatedChildren List<Fake> that contains the instance of Fake that represent the children records
     * @return Fake provides a fluent interface
     */
    public Fake setChildren(String relationshipName, Fake[] fabricatedChildren) {
        nodes.add(new ChildRelationshipNode(relationshipName, fabricatedChildren));
        return this;
    }

    /**
     * @description Converts the instance of Fake to an SObject
     * @return SObject record
     */
    public SObject toSObject() {
        return (SObject) JSON.deserialize(JSON.serialize(serialize()), sObjectType);
    }

    /**
     * @description Serializes the current instance of Fake
     * @return The serialized map of the Fake instance and its relationships
     */
    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();

        for (INode node : nodes) {
            fields.putAll(node.serialize());
        }

        return fields;
    }

    /**
     * @description Returns the SObjectType of the current instance of Fake
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        SObject obj = (SObject) sObjectType.newInstance();
        return obj.getSObjectType();
    }

    /**
     * @description Returns the SObjectType of a given Type value
     * @param type The Type value to evaluate
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType(Type type) {
        SObject obj = (SObject) type.newInstance();
        return obj.getSObjectType();
    }

    public Schema.SObjectField getSObjectField(String fieldAPIName) {
        Map<String, Schema.SObjectField> fieldMap = getSObjectType().getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldAPIName)) {
            throw new InvalidFieldException(
                'The ' +
                fieldAPIName +
                ' field does not exist on object type: ' +
                sObjectType.getName()
            );
        }
        return fieldMap.get(fieldAPIName);
    }

    /**
     * @description Represents a parent record of a Fake instance
     */
    @TestVisible
    class ParentRelationshipNode implements INode {
        private String fieldName;
        private Fake parent;

        public ParentRelationshipNode(String fieldName, Fake parent) {
            this.fieldName = fieldName;
            this.parent = parent;
        }

        public Map<String, Object> serialize() {
            return new Map<String, Object>{ fieldName => parent.serialize() };
        }
    }

    /**
     * @description Represents the children records of a Fake instance
     */
    @TestVisible
    class ChildRelationshipNode implements INode {
        private String fieldName;
        private Fake[] children;

        public ChildRelationshipNode(String fieldName, Fake[] children) {
            this.fieldName = fieldName;
            this.children = children;
        }

        public Map<String, Object> serialize() {
            List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();

            for (Fake child : children) {
                serializedChildren.add(child.serialize());
            }

            return new Map<String, Object>{
                fieldName => new Map<String, Object>{
                    'totalSize' => children.size(),
                    'done' => true,
                    'records' => serializedChildren
                }
            };
        }
    }

    /**
     * @description Represents the SObjectField and its value
     */
    @TestVisible
    class FieldValuePairNode implements INode {
        protected Schema.SObjectField field;
        protected Object value;

        public FieldValuePairNode(Schema.SObjectField field, Object value) {
            this.field = field;
            this.value = value;
        }

        public Map<String, Object> serialize() {
            return new Map<String, Object>{ field.getDescribe().getName() => value };
        }
    }

    /**
     * @description Functionality for generating valid ids
     */
    @TestVisible
    class IdGenerator {
        public Id generate(Schema.SObjectType sObjectType) {
            String strCounter = String.valueOf(++idCounter);
            String prefix = sObjectType.getDescribe().getKeyPrefix();
            return Id.valueOf(prefix + '0'.repeat(12 - strCounter.length()) + strCounter);
        }

        public Id generate(System.Type type) {
            SObject obj = (SObject) type.newInstance();
            return generate(obj.getSObjectType());
        }
    }

    /**
     * @description Exception type thrown if an SObjectField hasn't been defined in the org
     */
    public class InvalidFieldException extends Exception {
    }
}