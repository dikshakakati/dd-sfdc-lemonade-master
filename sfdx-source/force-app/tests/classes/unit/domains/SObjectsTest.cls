/**
 * @author Scott McClung
 * @date 2023/02/16
 * @description Unit tests for SObjects class
 */

@IsTest( IsParallel=true )
private class SObjectsTest {
    @IsTest
    static void testWhenCallingSizeThenItShouldReturnTheNumberOfRecordsInTheDomainCollection() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        Integer expectedSize = records.getRecords().size();
        Integer actualSize = records.size();
        // Assert
        System.assertEquals( expectedSize, actualSize,
            'Expected ' + expectedSize + ' records.  Received: ' + actualSize + ' Records: ' + records );
    }

    @IsTest
    static void testWhenCallingSizeOnEmptyDomainClassThenItShouldReturnZero() {
        // Arrange
        SuperHeroes records = getEmptySuperHeroesDomain();
        // Act
        Integer actualSize = records.size();
        // Assert
        System.assertEquals( 0, actualSize,
            'Expected 0 records.  Received: ' + actualSize + ' Records: ' + records );
    }

    @IsTest
    static void testWhenCallingGetStringFieldValuesThenItShouldReturnAListOfStringValuesFromTheGivenField() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        String[] expectedAssistants = new String[]{
            'Alexa', 'Google Voice', 'Siri', '  '
        };
        // Act
        String[] actualAssistants = records.getStringField( Contact.AssistantName );
        // Assert
        System.assertEquals( expectedAssistants.size(), actualAssistants.size(),
            'Expected ' + expectedAssistants + ' but received ' + actualAssistants );
        for( String assistant : expectedAssistants ) {
            System.assert( actualAssistants.contains( assistant ),
                'Expected results to include: ' + assistant + '.  Received: ' + actualAssistants );
        }
    }

    @IsTest
    static void testWhenCallingGetIdFieldValuesThenItShouldReturnASetOfIdValuesFromTheGivenIdField() {
        // Arrange
        Id accountId1 = Fake.generateId( Account.class );
        Id accountId2 = Fake.generateId( Account.class );
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AccountId, accountId1 )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AccountId, accountId2 )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        Set<Id> results = domain.getIdField( Contact.AccountId );
        // Assert
        Set<Id> expectedResults = new Set<Id>{ accountId1, accountId2 };
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assertEquals( expectedResults, results, 'Expected the set to contain ' + expectedResults + ' Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetIdFieldValuesThenItShouldReturnASetOfIdValuesFromTheGivenStringField() {
        // Arrange
        Id accountId1 = Fake.generateId( Account.class );
        Id accountId2 = Fake.generateId( Account.class );
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, accountId1 )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, accountId2 )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        Set<Id> results = domain.getIdField( Contact.AssistantName );
        // Assert
        Set<Id> expectedResults = new Set<Id>{ accountId1, accountId2 };
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assertEquals( expectedResults, results, 'Expected the set to contain ' + expectedResults + ' Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetIdFieldValuesOnIncompatibleFieldThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Birthdate, Date.today() )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getIdField( Contact.Birthdate );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid id' ),
                'Expected an invalid id error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }

    @IsTest
    static void testWhenCallingGetDateFieldValuesThenItShouldReturnAListOfDateValuesFromTheGivenField() {
        // Arrange
        Date today = Date.today();
        Date tomorrow = Date.today().addDays( 1 );
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Birthdate, today )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Birthdate, tomorrow )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        List<Date> results = domain.getDateField( Contact.Birthdate );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( today ), 'Expected the results to contains ' + today + ' Received: ' + results );
        System.assert( results.contains( tomorrow ), 'Expected the results to contains ' + tomorrow + ' Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetDateFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getDateField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid date' ),
                'Expected an invalid date error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }

    @IsTest
    static void testWhenCallingGetDatetimeFieldValuesThenItShouldReturnAListOfDatetimeValuesFromTheGivenField() {
        // Arrange
        Datetime today = Datetime.now();
        Datetime yesterday = Datetime.now().addDays( -1 );

        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.LastModifiedDate, today )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.LastModifiedDate, yesterday )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        List<Datetime> results = domain.getDatetimeField( Contact.LastModifiedDate );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( today ), 'Expected the results to contains ' + today + ' Received: ' + results );
        System.assert( results.contains( yesterday ), 'Expected the results to contains ' + yesterday + ' Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetDatetimeFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getDatetimeField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid date/time' ),
                'Expected an invalid date/time error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }

    @IsTest
    static void testWhenCallingGetDecimalFieldValuesThenItShouldReturnAListOfDecimalValuesFromTheGivenField() {
        // Arrange
        Decimal lat = 1.23;
        Decimal lon = 9.87;
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lat )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lon )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        List<Decimal> results = domain.getDecimalField( Contact.MailingLatitude );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( (Decimal) lat ), 'Expected results to be ' + lat + '. Received: ' + results );
        System.assert( results.contains( (Decimal) lon ), 'Expected results to be ' + lon + '. Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetDecimalFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getDecimalField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid conversion' ),
                'Expected an invalid conversion error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }

    @IsTest
    static void testWhenCallingGetDoubleFieldValuesThenItShouldReturnAListOfDoubleValuesFromTheGivenField() {
        // Arrange
        Double lat = 1.23;
        Double lon = 9.87;
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lat )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lon )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        List<Double> results = domain.getDoubleField( Contact.MailingLatitude );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( (Double) lat ), 'Expected results to be ' + lat + '. Received: ' + results );
        System.assert( results.contains( (Double) lon ), 'Expected results to be ' + lon + '. Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetDoubleFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getDoubleField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid conversion' ),
                'Expected an invalid conversion error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }

    @IsTest
    static void testWhenCallingGetIntegerFieldValuesThenItShouldReturnAListOfIntegerValuesFromTheGivenField() {
        // Arrange
        Decimal lat = 1.23;
        Decimal lon = 9.87;
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lat )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.MailingLatitude, lon )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .toSObject()
            }
        );
        // Act
        List<Integer> results = domain.getIntegerField( Contact.MailingLatitude );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( Integer.valueOf( lat ) ), 'Expected results to be ' + Integer.valueOf( lat ) + '. Received: ' + results );
        System.assert( results.contains( Integer.valueOf( lon ) ), 'Expected results to be ' + Integer.valueOf( lon ) + '. Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetIntegerFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getIntegerField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid integer' ),
                'Expected an invalid integer error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }


    @IsTest
    static void testWhenCallingGetLongFieldValuesThenItShouldReturnAListOfLongValuesFromTheGivenField() {
        // Arrange

        Long smb = 100;
        Long ent = 15000;
        SuperHeroes domain = new SuperHeroes(
            new Account[]{
                (Account) new Fake( Account.class )
                    .setField( Account.NumberOfEmployees, smb )
                    .toSObject(),
                (Account) new Fake( Account.class )
                    .setField( Account.NumberOfEmployees, ent )
                    .toSObject(),
                (Account) new Fake( Account.class )
                    .toSObject()
            }, Account.SObjectType
        );
        // Act
        List<Long> results = domain.getLongField( Account.NumberOfEmployees );
        // Assert
        System.assertEquals( 2, results.size(), 'Expected the results to contain 2 values, received ' + results.size() );
        System.assert( results.contains( (Long) smb ), 'Expected results to be ' + smb + '. Received: ' + results );
        System.assert( results.contains( (Long) ent ), 'Expected results to be ' + ent + '. Received: ' + results );
    }

    @IsTest
    static void testWhenCallingGetLongFieldValuesOnIncompatibleValueThenItShouldThrowSystemTypeException() {
        // Arrange
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.AssistantName, Fake.generateId( Account.class ) )
                    .toSObject()
            }
        );
        // Act
        try {
            domain.getLongField( Contact.AssistantName );
            System.assert( false, 'Expected a System.TypeException to be thrown but did not catch one.' );
        } catch( System.TypeException e ) {
            System.assert( e.getMessage().containsIgnoreCase( 'invalid conversion' ),
                'Expected an invalid long error message. Received: ' + e.getMessage() );
        } catch( Exception e ) {
            System.assert( false,
                'Expected a System.TypeException to be thrown but received: ' + e.getTypeName() + '. ErrorMessage: ' + e.getMessage() );
        }
    }


    @IsTest
    static void testWhenCallingGetSObjectsByIdFieldThenItShouldReturnAMapOfRecordsGroupedByTheGivenField() {
        // Arrange
        Id contactId1 = Fake.generateId( Contact.class );
        Id contactId2 = Fake.generateId( Contact.class );
        Id contactId3 = Fake.generateId( Contact.class );
        SuperHeroes domain = new SuperHeroes(
            new Contact[]{
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Id, contactId1 )
                    .setField( Contact.LastName, 'Superman' )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Id, contactId2 )
                    .setField( Contact.LastName, 'Wonder Woman' )
                    .toSObject(),
                (Contact) new Fake( Contact.class )
                    .setField( Contact.Id, contactId3 )
                    .setField( Contact.LastName, 'Batman' )
                    .toSObject()
            }
        );
        // Act
        Map<Id, SObject> mapRecordsById = domain.getByIdField( Contact.Id );
        // Assert
        String lastNameContact1 = (String) mapRecordsById.get( contactId1 ).get( 'LastName' );
        String lastNameContact2 = (String) mapRecordsById.get( contactId2 ).get( 'LastName' );
        String lastNameContact3 = (String) mapRecordsById.get( contactId3 ).get( 'LastName' );
        System.assertEquals( 'Superman', lastNameContact1, 'Expected the LastName value to be "Superman" Received:' + lastNameContact1 );
        System.assertEquals( 'Wonder Woman', lastNameContact2, 'Expected the LastName value to be "Wonder Woman" Received:' + lastNameContact2 );
        System.assertEquals( 'Batman', lastNameContact3, 'Expected the LastName value to be "Batman" Received:' + lastNameContact3 );
    }



    @IsTest
    static void testWhenCallingGetRecordsWithAnyNullFieldValuesWithMultipleFieldsThenItShouldReturnListOfRecordsHavingANullValueInAnyOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert(
                record.get( 'LastName' ) == null || record.get( 'FirstName' ) == null,
                'Expected FirstName or LastName to be null.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAnyNullFieldValuesWithASingleFieldThenItShouldReturnListOfRecordsHavingANullValueInAnyOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNull( new Set<SObjectField>{ Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert( record.get( 'FirstName' ) == null,
                'Expected FirstName to be null.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAnyNullFieldValuesOnEmptyDomainThenItShouldReturnAnEmptyDomain() {
        // Arrange
        SuperHeroes records = getEmptySuperHeroesDomain();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 0, filteredRecords.getRecords().size(),
            'Expected 0 results. Received: ' + filteredRecords.getRecords() );
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAllNullFieldValuesWithMultipleFieldsThenItShouldReturnListOfRecordsHavingANullValueInAllOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 1, filteredRecords.getRecords().size(),
            'Expected 1 result. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert(
                record.get( 'LastName' ) == null && record.get( 'FirstName' ) == null,
                'Expected FirstName and LastName to be null.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAllNullFieldValuesWithASingleFieldThenItShouldReturnListOfRecordsHavingANullValueInAllOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNull( new Set<SObjectField>{ Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert(
                record.get( 'FirstName' ) == null,
                'Expected FirstName to be null.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAllNullFieldValuesOnEmptyDomainThenItShouldReturnAnEmptyDomain() {
        // Arrange
        SuperHeroes records = getEmptySuperHeroesDomain();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 0, filteredRecords.getRecords().size(),
            'Expected 0 results. Received: ' + filteredRecords.getRecords() );
    }

    @IsTest
    static void testWhenCallingRecordsWithAllNotNullFieldValuesWithMultipleFieldsThenItShouldReturnListofRecordsNotHavingANullValueInAllOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNotNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert(
                record.get( 'LastName' ) != null && record.get( 'FirstName' ) != null,
                'Expected FirstName and LastName to both have values.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingRecordsWithAllNotNullFieldValuesWithSingleFieldThenItShouldReturnListofRecordsNotHavingANullValueInAllOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNotNull( new Set<SObjectField>{ Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert( record.get( 'FirstName' ) != null,
                'Expected FirstName to have values.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAllNotNullFieldValuesOnEmptyDomainThenItShouldReturnAnEmptyDomain() {
        // Arrange
        SuperHeroes records = getEmptySuperHeroesDomain();
        // Act
        SuperHeroes filteredRecords =
            records.whereAllNotNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 0, filteredRecords.getRecords().size(),
            'Expected 0 results. Received: ' + filteredRecords.getRecords() );
    }

    @IsTest
    static void testWhenCallingRecordsWithAnyNotNullFieldValuesWithMultipleFieldsThenItShouldReturnListofRecordsNotHavingANullValueInAnyOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNotNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 5, filteredRecords.getRecords().size(),
            'Expected 5 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert(
                record.get( 'LastName' ) != null || record.get( 'FirstName' ) != null,
                'Expected FirstName or LastName to have a value.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingRecordsWithAnyNotNullFieldValuesWithASingleFieldsThenItShouldReturnListofRecordsNotHavingANullValueInAnyOfTheGivenFields() {
        // Arrange
        SuperHeroes records = getSuperHeroes();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNotNull( new Set<SObjectField>{ Contact.FirstName } );
        // Assert
        System.assertEquals( 3, filteredRecords.getRecords().size(),
            'Expected 3 results. Received: ' + filteredRecords.getRecords() );
        for( SObject record : filteredRecords.getRecords() ) {
            System.assert( record.get( 'FirstName' ) != null,
                'Expected FirstName to have a value.  Received: ' + record );
        }
    }

    @IsTest
    static void testWhenCallingGetRecordsWithAnyNotNullFieldValuesOnEmptyDomainThenItShouldReturnAnEmptyDomain() {
        // Arrange
        SuperHeroes records = getEmptySuperHeroesDomain();
        // Act
        SuperHeroes filteredRecords =
            records.whereAnyNotNull( new Set<SObjectField>{ Contact.LastName, Contact.FirstName } );
        // Assert
        System.assertEquals( 0, filteredRecords.getRecords().size(),
            'Expected 0 results. Received: ' + filteredRecords.getRecords() );
    }


    private static SuperHeroes getSuperHeroes() {
        Id accountId1 = Fake.generateId( Account.class );
        Id accountId2 = Fake.generateId( Account.class );
        return new SuperHeroes(
            new SObject[]{
                new Fake( Contact.class )
                    .setField( Contact.LastName, 'Smith' )
                    .setField( Contact.FirstName, 'Smith' )
                    .setField( Contact.AssistantName, 'Alexa' )
                    .setField( Contact.Birthdate, Date.today() )
                    .setField( Contact.AccountId, accountId1 )
                    .toSObject(),
                new Fake( Contact.class )
                    .setField( Contact.LastName, 'Smith' )
                    .setField( Contact.AssistantName, 'Google Voice' )
                    .setField( Contact.Birthdate, Date.today() )
                    .setField( Contact.AccountId, accountId2 )
                    .toSObject(),
                new Fake( Contact.class )
                    .setField( Contact.LastName, 'Smith' )
                    .setField( Contact.FirstName, '   ' )
                    .setField( Contact.AssistantName, 'Siri' )
                    .setField( Contact.Birthdate, Date.today() )
                    .setField( Contact.AccountId, accountId1 )
                    .toSObject(),
                new Fake( Contact.class )
                    .setField( Contact.LastName, 'Smith' )
                    .setField( Contact.FirstName, '' )
                    .setField( Contact.AssistantName, '  ' )
                    .setField( Contact.Birthdate, Date.today() )
                    .setField( Contact.AccountId, accountId2 )
                    .toSObject(),
                new Fake( Contact.class )
                    .setField( Contact.LastName, '' )
                    .toSObject(),
                new Fake( Contact.class ).toSObject()
            }
        );
    }

    private static SuperHeroes getEmptySuperHeroesDomain() {
        return new SuperHeroes( new Contact[]{} );
    }


    private class SuperHeroes extends SObjects {
        /**
         * @description Test domain class constructor
         * @param records
         */
        public SuperHeroes( List<SObject> records ) {
            super( records, Contact.SObjectType );
        }

        /**
         * @description Test domain class constructor
         * @param records
         * @param sObjectType
         */
        public SuperHeroes( List<SObject> records, SObjectType sObjectType ) {
            super( records, sObjectType );
        }

        /**
         * @description Returns collection of records with a null value in ANY of the given fields
         * @param fields
         * @return Instance of Superheroes domain collection
         */
        public SuperHeroes whereAnyNull( Set<Schema.SObjectField> fields ) {
            return new SuperHeroes(
                getRecordsWithAnyNullFieldValues( fields )
            );
        }

        /**
         * @description Returns collection of records with a null value in ALL of the given fields
         * @param fields
         * @return Instance of Superheroes domain collection
         */
        public SuperHeroes whereAllNull( Set<Schema.SObjectField> fields ) {
            return new SuperHeroes(
                getRecordsWithAllNullFieldValues( fields )
            );
        }

        /**
         * @description Returns collection of records with a value in at least one of the given fields
         * @param fields
         * @return Instance of Superheroes domain collection
         */
        public SuperHeroes whereAnyNotNull( Set<Schema.SObjectField> fields ) {
            return new SuperHeroes(
                getRecordsWithAnyNotNullFieldValues( fields )
            );
        }

        /**
         * @description Returns collection of records with a value in ALL of the given fields
         * @param fields
         * @return Instance of Superheroes domain collection
         */
        public SuperHeroes whereAllNotNull( Set<Schema.SObjectField> fields ) {
            return new SuperHeroes(
                getRecordsWithAllNotNullFieldValues( fields )
            );
        }

        /**
         * @description Returns a collection of values in the given field as a list of strings
         * @param field
         * @return Collection of Strings
         */
        public String[] getStringField( SObjectField field ) {
            return getStringFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a set of Ids
         * @param field
         * @return Set of Ids
         */
        public Set<Id> getIdField( SObjectField field ) {
            return getIdFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of dates
         * @param field
         * @return Collection of Dates
         */
        public Date[] getDateField( SObjectField field ) {
            return getDateFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of timestamps
         * @param field
         * @return Collection of timestamps
         */
        public Datetime[] getDatetimeField( SObjectField field ) {
            return getDatetimeFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of decimal values
         * @param field
         * @return Collection of Decimal values
         */
        public Decimal[] getDecimalField( SObjectField field ) {
            return getDecimalFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of double values
         * @param field
         * @return Collection of Double values
         */
        public Double[] getDoubleField( SObjectField field ) {
            return getDoubleFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of integer values
         * @param field
         * @return Collection of integers
         */
        public Integer[] getIntegerField( SObjectField field ) {
            return getIntegerFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field as a list of long values
         * @param field
         * @return Collection of long values
         */
        public Long[] getLongField( SObjectField field ) {
            return getLongFieldValues( field );
        }

        /**
         * @description Returns a collection of values in the given field mapped by record id
         * @param field
         * @return Map of given field by record id
         */
        public Map<Id, SObject> getByIdField( SObjectField field ) {
            return getSObjectsByIdField( field );
        }
    }
}