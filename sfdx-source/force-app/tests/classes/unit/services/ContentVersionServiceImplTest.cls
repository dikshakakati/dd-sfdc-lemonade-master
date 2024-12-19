/**
 * @author DoorDash
 * @date 07/26/2022
 * @description This is test class for ContentVersionServiceImpl class
 */
@isTest
public with sharing class ContentVersionServiceImplTest {
    /**
     * @description To test creation of Content Version from Contracts when file is uploaded.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFileIsUploadedThenCreateContentVersion() {

        Id contractId = Fake.generateId( Contract.class );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
                fflib_ISObjectUnitOfWork.class
        );
        String blobdata = 'Id,Type,Recordtype';
        String testFileName = 'test.csv';
        Application.UNITOFWORK.setMock(mockUOW);

        ContentVersionService.createContentVersion(blobdata , testFileName , contractId);

        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).commitWork();
        ( ( fflib_ISObjectUnitOfWork ) mocks.verify( mockUOW, 1 ) ).registerNew( fflib_Match.sObjectWith(
                                new Map<SObjectField,Object>{
                                    ContentVersion.Title => testFileName,
                                    ContentVersion.FirstPublishLocationId => contractId,
                                    ContentVersion.VersionData => Blob.valueOf(blobdata)
                                }
                )
            );


    }
}