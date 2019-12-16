@isTest
private without sharing class TAG_ContactFormWebService_mainTest {

	@isTest
	private static void testDoPost() {

		insert new Account( name = 'test', CompanyNumber__c = '960507878' );

		List<CustomOpportunity__c> CustomOpportunities = [SELECT Id FROM CustomOpportunity__c];
		System.assertEquals( 0, CustomOpportunities.size(), 'Size should be zero before' );

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/ContactForm';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueof( '{ "type":"REKRUTTERING_MED_TILRETTELEGGING","municipalityCode":"1111","organisationName":"Finstadtunet","organisationNumber":"960507878","firstName":"TestNavn","lastName":"TestEtternavn","email":"test@nav.no","phoneNo":"90080900" }' );
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		TAG_ContactFormWebService_main.doPost();
		Test.stopTest();


		CustomOpportunities = [SELECT Id, InquiryCategory__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.MobilePhone, Account__r.CompanyNumber__c FROM CustomOpportunity__c];
		System.assertEquals( 1, CustomOpportunities.size(), 'Size should be zero before' );

		System.assertEquals ( 'Rekruttering med tilrettelegging', CustomOpportunities[0].InquiryCategory__c, '"Type" should be "Rekruttering med tilrettelegging"' );
		System.assertEquals ( 'TestNavn', CustomOpportunities[0].Contact__r.FirstName, '"Contact__r.FirstName" should be "TestNavn"' );
		System.assertEquals ( 'TestEtternavn', CustomOpportunities[0].Contact__r.LastName, '"Contact__r.LastName" should be "TestEtternavn"' );
		System.assertEquals ( 'test@nav.no', CustomOpportunities[0].Contact__r.Email, '"Contact__r.Email" should be "test@nav.no"' );
		System.assertEquals ( '90080900', CustomOpportunities[0].Contact__r.MobilePhone, '"Contact__r.MobilePhone" should be "90080900"' );
		System.assertEquals ( '960507878', CustomOpportunities[0].Account__r.CompanyNumber__c, '"Account__r.CompanyNumber__c" should be "960507878"' );
	}
}