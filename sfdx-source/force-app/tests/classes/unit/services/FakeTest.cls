/**
 * @description Tests for the Fake utility
 * @author Scott McClung
 * @date 3/9/2022
 * Suppressed warnings since test class contains multiple PMD issues.
 */
@isTest
@SuppressWarnings(
    'PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexDoc, PMD.MethodNamingConventions, PMD.UnusedLocalVariable'
)
private class FakeTest {
    @isTest
    private static void constructor_expectFieldsSet() {
        Map<Schema.SObjectField, Object> accountFields = new Map<SObjectField, Object>{
            Account.Id => 'Id-1',
            Account.Name => 'Foo'
        };

        Fake fakeAccount = new Fake(Account.class, accountFields);
        System.assertEquals(accountFields.size(), fakeAccount.nodes.size());
    }

    @isTest
    private static void toSObject_expectSpecifiedSObjectType() {
        SObject obj = new Fake(Account.class).toSObject();
        System.assert(obj instanceof Account);
    }

    @isTest
    private static void toSObject_expectBuildInvokedOnNodes() {
        FakeNodeStub node1 = new FakeNodeStub();
        FakeNodeStub node2 = new FakeNodeStub();
        SObject obj = new Fake(Account.class, new List<Fake.INode>{ node1, node2 }).toSObject();
        System.assert(node1.serializeInvoked);
        System.assert(node2.serializeInvoked);
    }

    @isTest
    private static void toSObject_expectProperties() {
        Map<String, Object> fields = new Map<String, Object>{ 'Id' => 'id-1', 'Name' => 'Foo' };
        FakeNodeStub node = new FakeNodeStub(fields);
        SObject obj = new Fake(Account.class, new List<Fake.INode>{ node }).toSObject();
        System.assertEquals(fields.get('Id'), obj.Id);
        System.assertEquals(fields.get('Name'), obj.get('Name'));
    }

    @isTest
    private static void setField_expectFieldAddedToNodes() {
        Fake fakeSObject = new Fake(Account.class);
        fakeSObject.setField(Account.Id, 'Id-1');
        System.assertEquals(1, fakeSObject.nodes.size());
    }

    @isTest
    private static void setParent_expectFieldAddedToNodes() {
        Fake fakeSObject = new Fake(Opportunity.class);
        fakeSObject.setParent('Account', new Fake(Account.class));
        System.assertEquals(1, fakeSObject.nodes.size());
    }

    @isTest
    private static void setChildren_expectFieldAdded() {
        Fake fakeSObject = new Fake(Account.class);
        fakeSObject.setChildren('Opportunities', new List<Fake>{});
        System.assertEquals(1, fakeSObject.nodes.size());
    }

    @isTest
    static void itShouldReturnSObjectType() {
        Fake fakeSObject = new Fake(Account.class);
        System.assertEquals(User.SObjectType, fakeSObject.getSObjectType(User.class));
    }

    @isTest
    static void itShouldReturnSObjectTypeOfInstanceType() {
        Fake fakeSObject = new Fake(Account.class);
        System.assertEquals(Account.SObjectType, fakeSObject.getSObjectType());
    }

    @isTest
    static void itShouldReturnSObjectFieldType() {
        Fake fakeSObject = new Fake(Account.class);
        Schema.SObjectField idField = Account.Id.getDescribe().getSobjectField();
        System.assertEquals(idField, fakeSObject.getSObjectField('Id'));
    }

    @isTest
    static void itShouldSetTheIdFieldOfTheCurrentSObject() {
        Account acct = (Account) new Fake(Account.class).setFakeId().toSObject();

        String strId = (String) acct.Id;

        System.assertEquals(18, strId.length());
        System.assertEquals('001', strId.left(3));
        System.assertEquals('AAA', strId.right(3));
        System.assertEquals('000000000001', strId.mid(3, 12));
    }

    @isTest
    static void itShouldSetTheIdOnARelationshipFieldUsingGenericType() {
        Account acct = (Account) new Fake(Account.class)
            .setFakeId(Account.OwnerId, User.class)
            .toSObject();

        String strId = (String) acct.OwnerId;

        System.assertEquals(18, strId.length());
        System.assertEquals('005', strId.left(3));
        System.assertEquals('AAA', strId.right(3));
        System.assertEquals('000000000001', strId.mid(3, 12));
    }

    @isTest
    static void itShouldSetTheIdOnARelationshipFieldUsingSObjectType() {
        Account acct = (Account) new Fake(Account.class)
            .setFakeId(Account.OwnerId, User.SObjectType)
            .toSObject();

        String strId = (String) acct.OwnerId;

        System.assertEquals(18, strId.length());
        System.assertEquals('005', strId.left(3));
        System.assertEquals('AAA', strId.right(3));
        System.assertEquals('000000000001', strId.mid(3, 12));
    }

    @isTest
    static void itShouldSetTimestampFields() {
        Account acct = (Account) new Fake(Account.class).setTimestamps().toSObject();

        String strCreatedById = (String) acct.CreatedById;
        String strModifiedById = (String) acct.LastModifiedById;

        System.assertEquals('005', strCreatedById.left(3));
        System.assertEquals('005', strModifiedById.left(3));
        System.assertEquals(Datetime.now().date(), acct.CreatedDate.date());
        System.assertEquals(Datetime.now().date(), acct.LastModifiedDate.date());
        System.assertEquals(Datetime.now().hour(), acct.CreatedDate.hour());
        System.assertEquals(Datetime.now().hour(), acct.LastModifiedDate.hour());
    }

    @isTest
    static void itShouldSetTimestampFieldsToSpecifiedDate() {
        Account acct = (Account) new Fake(Account.class)
            .setTimestamps(Datetime.now().addDays(-1))
            .toSObject();

        String strCreatedById = (String) acct.CreatedById;
        String strModifiedById = (String) acct.LastModifiedById;

        System.assertEquals('005', strCreatedById.left(3));
        System.assertEquals('005', strModifiedById.left(3));
        System.assertEquals(Datetime.now().addDays(-1).date(), acct.CreatedDate.date());
        System.assertEquals(Datetime.now().addDays(-1).date(), acct.LastModifiedDate.date());
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    ////////////////////        Child Relationship Node Tests      ///////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void build_expectSerializeInvokedOnChildren() {
        FakeStub child1 = new FakeStub(Account.class);
        FakeStub child2 = new FakeStub(Account.class);
        Fake.ChildRelationshipNode node = new Fake.ChildRelationshipNode(
            'Accounts__r',
            new List<Fake>{ child1, child2 }
        );

        node.serialize();

        System.assert(child1.serializeInvoked);
        System.assert(child2.serializeInvoked);
    }

    @isTest
    private static void build_expectDoneMapKey() {
        Fake.ChildRelationshipNode node = new Fake.ChildRelationshipNode(
            'Accounts__r',
            new List<Fake>()
        );

        Map<String, Object> builtNode = node.serialize();

        System.assert(((Map<String, Object>) builtNode.get('Accounts__r')).containsKey('done'));
        System.assert((Boolean) ((Map<String, Object>) builtNode.get('Accounts__r')).get('done'));
    }

    @isTest
    private static void build_expectTotalSizeMapKey() {
        Fake.ChildRelationshipNode node = new Fake.ChildRelationshipNode(
            'Accounts__r',
            new List<FakeStub>{ new FakeStub(Account.class), new FakeStub(Account.class) }
        );

        Map<String, Object> builtNode = node.serialize();

        System.assert(
            ((Map<String, Object>) builtNode.get('Accounts__r')).containsKey('totalSize')
        );
        System.assertEquals(
            2,
            ((Map<String, Object>) builtNode.get('Accounts__r')).get('totalSize')
        );
    }

    @isTest
    private static void build_expectSerializedChildrenMap() {
        FakeStub child1 = new FakeStub(Account.class, new Map<String, Object>{ 'Name' => 'Foo-1' });
        FakeStub child2 = new FakeStub(Account.class, new Map<String, Object>{ 'Name' => 'Foo-2' });
        Fake.ChildRelationshipNode node = new Fake.ChildRelationshipNode(
            'Accounts__r',
            new List<Fake>{ child1, child2 }
        );

        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();
        serializedChildren.add(child1.serialize());
        serializedChildren.add(child2.serialize());

        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(
            serializedChildren,
            ((Map<String, Object>) builtNode.get('Accounts__r')).get('records')
        );
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    ////////////////////        Parent Relationship Node Tests      //////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void build_expectSerializeInvokedOnParent() {
        FakeStub fabricatedParent = new FakeStub(Account.class);
        Fake.ParentRelationshipNode node = new Fake.ParentRelationshipNode(
            'Account__r',
            fabricatedParent
        );

        node.serialize();

        System.assert(fabricatedParent.serializeInvoked);
    }

    @isTest
    private static void build_expectSerializedParentMap() {
        FakeStub fabricatedParent = new FakeStub(
            Account.class,
            new Map<String, Object>{ 'Name' => 'Foo' }
        );
        Fake.ParentRelationshipNode node = new Fake.ParentRelationshipNode(
            'Account__r',
            fabricatedParent
        );

        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(
            new Map<String, Object>{ 'Account__r' => fabricatedParent.serialize() },
            builtNode
        );
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    /////////////////////        Field Value Pair Node Tests      ////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    @isTest
    private static void build_expectMap() {
        Fake.FieldValuePairNode node = new Fake.FieldValuePairNode(Account.Name, 'Foo');
        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(new Map<String, Object>{ 'Name' => 'Foo' }, builtNode);
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////        Id Generator Tests      ///////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    @isTest
    static void idShouldGenerateAn18CharAccountId() {
        String id = (String) new Fake.IdGenerator().generate(Account.SObjectType);
        System.assertEquals(18, id.length());
        System.assertEquals('001', id.left(3));
        System.assertEquals('AAA', id.right(3));
        System.assertEquals('000000000001', id.mid(3, 12));
    }

    @isTest
    static void itShouldIncrement() {
        String id1 = (String) new Fake.IdGenerator().generate(Account.SObjectType);
        String id2 = (String) new Fake.IdGenerator().generate(Contact.SObjectType);
        String id3 = (String) Fake.generateId(User.SObjectType);
        System.assertEquals('000000000001', id1.mid(3, 12));
        System.assertEquals('000000000002', id2.mid(3, 12));
        System.assertEquals('000000000003', id3.mid(3, 12));
    }

    @isTest
    static void itShouldUseTheCorrectSObjectPrefix() {
        String id1 = (String) new Fake.IdGenerator().generate(Account.SObjectType);
        String id2 = (String) new Fake.IdGenerator().generate(Contact.SObjectType);
        String id3 = (String) Fake.generateId(User.SObjectType);
        System.assertEquals('001', id1.left(3));
        System.assertEquals('003', id2.left(3));
        System.assertEquals('005', id3.left(3));
    }

    @isTest
    static void itShouldAcceptGenericTypes() {
        String id = (String) Fake.generateId(Account.class);
        System.assertEquals(18, id.length());
        System.assertEquals('001', id.left(3));
        System.assertEquals('AAA', id.right(3));
        System.assertEquals('000000000001', id.mid(3, 12));
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////        Test Stubs      ///////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

    public class FakeStub extends Fake {
        private Map<String, Object> serializedMap;
        @TestVisible
        private Boolean serializeInvoked = false;

        public FakeStub(Type sType) {
            super(sType);
            this.serializedMap = new Map<String, Object>();
        }

        public FakeStub(Type sType, Map<String, Object> serializedMap) {
            super(sType);
            this.serializedMap = serializedMap;
        }

        public override Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedMap;
        }
    }

    public class FakeNodeStub implements Fake.INode {
        public Boolean serializeInvoked = false;
        public Map<String, Object> serializedNode;

        public FakeNodeStub() {
            serializedNode = new Map<String, Object>();
        }

        public FakeNodeStub(Map<String, Object> serializedNode) {
            this.serializedNode = serializedNode;
        }

        public Map<String, Object> serialize() {
            serializeInvoked = true;
            return serializedNode;
        }
    }
}