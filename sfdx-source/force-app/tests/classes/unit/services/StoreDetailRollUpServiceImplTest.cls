/**
 * @description Test class for StoreDetailRollUpServiceImpl
 * @author Deloitte
 * @date 08/13/2024
 */
@IsTest(SeeAllData=false)
public class StoreDetailRollUpServiceImplTest {
  private static final String ADDRESS_VERIFICATION_STATUS = 'Address Verification Status';
  private static final String ASSERT_MESSAGE_ADDRESS_VARIFICATION_STATUS_MISMATCH = 'Unexptec Result: Address Verification Status does not match';
  private static final String TEST_CITY = 'Texas';
  private static final String TEST_STATE_CODE = 'NY';
  private static final String TEST_COUNTRY_CODE = 'US';
  private static final String TEST_STREET = 'Street 12';
  private static final String VERIFIED = 'Verified';

  /**
   * @description To test publish Address verification status roll up event.
   */
  @IsTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenPublishAddressVerificationStatusRollUpEventsThenCheckTypeAndRecordId() {
    Id mxOnboardingLinkId = Fake.generateId(Mx_Onboarding_Link__c.class);
    Id storeDetailId = Fake.generateId(Mx_Onboarding_Link__c.class);
    Fake mxOnboardingLinkInstance = new Fake(Mx_Onboarding_Link__c.class)
      .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId);
    Store_Detail__c storeDetailRecord = (Store_Detail__c) new Fake(
        Store_Detail__c.class
      )
      .setField(Store_Detail__c.Id, storeDetailId)
      .setfield(Store_Detail__c.Mx_Onboarding_Link__c, mxOnboardingLinkId)
      .setfield(Store_Detail__c.Address__Street__s, TEST_STREET)
      .setfield(Store_Detail__c.Address__StateCode__s, TEST_STATE_CODE)
      .setfield(Store_Detail__c.Address__City__s, TEST_CITY)
      .setfield(Store_Detail__c.Address__CountryCode__s, TEST_COUNTRY_CODE)
      .setfield(Store_Detail__c.Address_Verification_Status__c, VERIFIED)
      .setParent('Mx_Onboarding_Link__r', mxOnboardingLinkInstance)
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    Application.UNITOFWORK.setMock(mockUOW);
    Test.startTest();
    StoreDetailRollUpService.publishAddressVerificationRollUpEvents(
      new List<Store_Detail__c>{ storeDetailRecord }
    );
    Test.stopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
      .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
      .registerPublishAfterSuccessTransaction(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            RollUpEvent__e.RecordId__c => storeDetailId,
            RollUpEvent__e.Type__c => ADDRESS_VERIFICATION_STATUS
          }
        )
      );
  }

  /**
   * @description To test roll up of Address Verification Status.
   */
  @IsTest
  private static void testWhenRollUpAddressVerificationStatusThenCalculateAddressVerificationStatus() {
    Id mxOnboardingLinkId = Fake.generateId(Mx_Onboarding_Link__c.class);
    Id storeDetailId1 = Fake.generateId(Mx_Onboarding_Link__c.class);
    Id storeDetailId2 = Fake.generateId(Mx_Onboarding_Link__c.class);
    Fake storeDetailRecord1 = new Fake(Store_Detail__c.class)
      .setField(Store_Detail__c.Id, storeDetailId1)
      .setfield(Store_Detail__c.Mx_Onboarding_Link__c, mxOnboardingLinkId)
      .setfield(Store_Detail__c.Address__Street__s, TEST_STREET)
      .setfield(Store_Detail__c.Address__StateCode__s, TEST_STATE_CODE)
      .setfield(Store_Detail__c.Address__City__s, TEST_CITY)
      .setfield(Store_Detail__c.Address__CountryCode__s, TEST_COUNTRY_CODE)
      .setfield(Store_Detail__c.Address_Verification_Status__c, VERIFIED);

    Fake storeDetailRecord2 = new Fake(Store_Detail__c.class)
      .setField(Store_Detail__c.Id, storeDetailId2)
      .setfield(Store_Detail__c.Mx_Onboarding_Link__c, mxOnboardingLinkId)
      .setfield(Store_Detail__c.Address__Street__s, TEST_STREET)
      .setfield(Store_Detail__c.Address__StateCode__s, TEST_STATE_CODE)
      .setfield(Store_Detail__c.Address__City__s, TEST_CITY)
      .setfield(Store_Detail__c.Address__CountryCode__s, TEST_COUNTRY_CODE)
      .setfield(Store_Detail__c.Address_Verification_Status__c, VERIFIED);

    Fake mxOnboardingLinkInstance = new Fake(Mx_Onboarding_Link__c.class)
      .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
      .setChildren(
        'Store_Details__r',
        new List<Fake>{ storeDetailRecord1, storeDetailRecord2 }
      );

    Mx_Onboarding_Link__c mxOnboardingLinkRecord = (Mx_Onboarding_Link__c) mxOnboardingLinkInstance.toSObject();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    IStoreDetailsSelector storeDetailsSelectorMock = (IStoreDetailsSelector) mocks.mock(
      IStoreDetailsSelector.class
    );
    IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
      IMxOnboardingLinksSelector.class
    );
    mocks.startStubbing();
    mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
      .thenReturn(Mx_Onboarding_Link__c.SObjectType);
    mocks.when(
        mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
          new Set<Id>{ mxOnboardingLinkId }
        )
      )
      .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkRecord });
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
    Application.SELECTOR.setMock(storeDetailsSelectorMock);
    Test.startTest();
    StoreDetailRollUpService.rollUpAddressVerificationStatus(
      new Set<Id>{ mxOnboardingLinkId }
    );
    Test.stopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    System.assertEquals(
      mxOnboardingLinkRecord.Address_Verification_Status__c,
      VERIFIED,
      VERIFIED
    );
  }
}
