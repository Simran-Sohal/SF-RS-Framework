/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Test class for handler class of REST Contract service
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
30-Oct-18   Simran Singh        
------------------------------------------------------------*/
@isTest(seeAllData=false)
private class RESTContract_Test {

    private class ContractRequest{
        private RESTContract contract;
    }
    
    @isTest
    private static void testPUTCall_NewFinancialAccount(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_NewFinancialAccount()');
        Contact testContact1 = RESTPartyTestHelper.getTestIndividualContact('Smith', '245318103465191');
        Contact testContact2 = RESTPartyTestHelper.getTestIndividualContact('Warne', '324328103465192');
        List<Contact> testContacts = new List<Contact>{testContact1, testContact2};
        insert testContacts;
        System.assert(testContact1.Id != null);
        System.assert(testContact2.Id != null);
        
        RESTContract ct = getContractPayload('0123456789', '123987');
        ct.related_parties.add(getContractRolePayload('245318103465191','Person', 'Client','Smith'));
        ct.related_parties.add(getContractRolePayload('324328103465192','Person', 'Client','Warne'));
        
        String accountId = ct.account_id;
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_ACCEPTED, statusCode);
        
        Financial_Account__c finnAccount = [SELECT Id FROM Financial_Account__c WHERE Account_ID__c = :accountId LIMIT 1];
        System.assertNotEquals(null, finnAccount);
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_NewFinancialAccount()');
    }
    
    @isTest
    private static void testPUTCall_ExistingFinancialAccount(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_ExistingFinancialAccount()');
        Account testAccount = RESTPartyTestHelper.getTestBusinessAccount('264573489738574', '647568473334');
        insert testAccount;
        System.assert(testAccount.Id != null);
        
        Contact testContact1 = RESTPartyTestHelper.getTestIndividualContact('Smith', '245318103465191');
        Contact testContact2 = RESTPartyTestHelper.getTestIndividualContact('Warne', '324328103465192');
        List<Contact> testContacts = new List<Contact>{testContact1, testContact2};
        insert testContacts;
        System.assert(testContact1.Id != null);
        System.assert(testContact2.Id != null);
        
        RESTContract ct = getContractPayload('0123456789', '123987');
        ct.related_parties.add(getContractRolePayload('264573489738574','Organisation', 'Referrer','Sample 101'));
        ct.related_parties.add(getContractRolePayload('245318103465191','Person', 'Client','Smith'));
        String accountId = ct.account_id;
        
        //create Financial account and Financial Account Role
        Financial_Account__c finAcc = TestDataGenerator.createTestFinancialAccounts('Test','MRB',1).get(0);
        finAcc.Account_ID__c            = ct.account_id;
        finAcc.Integration_Key__c       = ct.source_system + '_' + ct.account_id+ '_' + ct.account_type_value;
        finAcc.Account_Number__c        = ct.account_number;
        finAcc.BSB_Number__c            = ct.bsb_number;
        finAcc.Product_Source_System__c = ct.source_system;
        finAcc.Name                     = (ct.account_name).length() > 80 ? (ct.account_name).subString(0,80) : ct.account_name;
        finAcc.Account_Status__c        = ct.account_status;
        finAcc.Account_Type__c          = ct.account_type_value;
        finAcc.Open_Date__c             = ct.open_date;
        finAcc.Product_Type__c          = ct.product_type_value;
        finAcc.Product_Type_Code__c     = ct.product_type_code;
        finAcc.Is_External_Product__c   = ct.is_external_product;
        finAcc.External_Product_Name__c = ct.external_product_name;   
        insert finAcc;
        
        Financial_Account_Role__c faRole = TestDataGenerator.createTestFinancialAccountRoleContact(testContact2.id, finAcc.Id);
        faRole.Integration_Key__c     = finAcc.Integration_Key__c + '_' + '324328103465192' + '_' + 'AcctHolder';
        faRole.Relationship__c        = 'AcctHolder';
        faRole.Status__c              = 'Applied';                
        faRole.Email__c               = 'sample@sample.test';
        insert faRole;
        
        finAcc = [SELECT Id, Account_ID__c, (SELECT Id FROM Financial_Account_Roles__r) FROM Financial_Account__c WHERE Id = :finAcc.Id];
        System.assertEquals(accountId, finAcc.Account_ID__c);
        System.assertEquals(1, finAcc.Financial_Account_Roles__r.size());
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_ACCEPTED, statusCode);
        
        finAcc = [SELECT Id, Account_ID__c, (SELECT Id FROM Financial_Account_Roles__r) FROM Financial_Account__c WHERE Id = :finAcc.Id];
        System.assertEquals(accountId, finAcc.Account_ID__c);
        System.assertEquals(2, finAcc.Financial_Account_Roles__r.size());
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_ExistingFinancialAccount()');
    }

    @isTest
    private static void testPUTCall_NewFacility(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_NewFacility()');
        Contact testContact = RESTPartyTestHelper.getTestIndividualContact('Smith', '245318103465191');
        insert testContact;
        
        RESTContract ct = getContractPayload('0123456789', '123987');
        ct.account_type_value = 'Facility';
        ct.account_type_code = 'Facility_Account';
        ct.bsb_number = null;
        ct.source_system = 'SAP';
        ct.open_date = Date.today();
        ct.product_type_value = 'Facility';
        ct.product_type_code = '4462343476';
        
        ct.related_parties.add(getContractRolePayload('245318103465191','Person', 'Client','Smith'));
        
        String accountId = ct.account_id;
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_ACCEPTED, statusCode);
        
        Financial_Account__c finnAccount = [SELECT Id, RecordType.DeveloperName FROM Financial_Account__c WHERE Account_ID__c = :accountId LIMIT 1];
        System.assertNotEquals(null, finnAccount);
        System.assertEquals('Facility_Account', finnAccount.RecordType.DeveloperName);
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_NewFacility()');
    }

    @isTest
    private static void testPUTCall_NoPayload(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_NewFinancialAccount()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof('');
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_BAD_REQUEST, statusCode);
        
        String responseBody = testRes.responseBody.toString();
        System.assert(responseBody.containsIgnoreCase('Request body is blank'));
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_NoPayload()');
    }

    @isTest
    private static void testPUTCall_DummyPayload(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_DummyPayload()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof('{dummy:test}');
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_BAD_REQUEST, statusCode);
        
        String responseBody = testRes.responseBody.toString();
        System.assert(responseBody.containsIgnoreCase('Unable to parse the request payload'));
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_DummyPayload()');
    }

    @isTest
    private static void testPUTCall_InvalidPayload(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_InvalidPayload()');

        RESTContract ct = getContractPayload('0123456789', '123987');
        ct.account_id = null;
        ct.related_parties.add(getContractRolePayload(null,null,null,'Smith'));
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_BAD_REQUEST, statusCode);
        
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_InvalidPayload()');
    }

    @isTest
    private static void testPUTCall_WithoutContractRoles(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_WithoutContractRoles()');

        RESTContract ct = getContractPayload('0123456789', '123987');
        String accountId = ct.account_id;
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_BAD_REQUEST, statusCode);
        
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_WithoutContractRoles()');
    }

    @isTest
    private static void testPUTCall_PartyNotExists(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall_PartyNotExists()');

        RESTContract ct = getContractPayload('0123456789', '123987');
        ct.related_parties.add(getContractRolePayload('245318103465191','Person', 'Client','Smith'));
        ct.related_parties.add(getContractRolePayload('324328103465192','Person', 'Client','Warne'));
        
        String accountId = ct.account_id;
        
        ContractRequest req = new ContractRequest();
        req.contract = ct;
        String contractJSON = JSON.serialize(req);
        
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(contractJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_INTERNAL_ERROR, statusCode);
        
        List<Financial_Account__c> finnAccountList = [SELECT Id FROM Financial_Account__c WHERE Account_ID__c = :accountId LIMIT 1];
        System.assertEquals(1, finnAccountList.size());        

        List<Financial_Account_Role__c> finnAccountRoles = [SELECT Id FROM Financial_Account_Role__c WHERE Financial_Account__c = :finnAccountList.get(0).Id];
        System.assertEquals(0, finnAccountRoles.size());        
        
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall_PartyNotExists()');
    }

    @isTest
    private static void testGETCall_NotSupported(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testGETCall_NotSupported()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_GET;
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doGet();
        Test.stopTest();
        String responseBody = testRes.responseBody.toString();
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_NOT_ALLOWED, statusCode);
        System.assert(responseBody.containsIgnoreCase('Http request GET is not supported for this service'));
        System.debug(loggingLevel.ERROR, '***** End Test : testGETCall_NotSupported()');
    }

    @isTest
    private static void testPOSTCall_NotSupported(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPOSTCall_NotSupported()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_POST;
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPost();
        Test.stopTest();
        String responseBody = testRes.responseBody.toString();
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_NOT_ALLOWED, statusCode);
        System.assert(responseBody.containsIgnoreCase('Http request POST is not supported for this service'));
        System.debug(loggingLevel.ERROR, '***** End Test : testPOSTCall_NotSupported()');
    }

    @isTest
    private static void testDELETECall_NotSupported(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testDELETECall_NotSupported()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/contracts';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_DELETE;
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doDelete();
        Test.stopTest();
        String responseBody = testRes.responseBody.toString();
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_NOT_ALLOWED, statusCode);
        System.assert(responseBody.containsIgnoreCase('Http request DELETE is not supported for this service'));
        System.debug(loggingLevel.ERROR, '***** End Test : testDELETECall_NotSupported()');
    }
    
    /*
     * Helper methods
     */
    private static RESTContract getContractPayload(String accountNumber, String bsbNumber){
        RESTContract ct = new RESTContract();
        ct.account_Id = accountNumber + '-' + bsbNumber + '-AU-AUD';
        ct.account_name = 'Test Contract';
        ct.account_number = accountNumber;
        ct.account_status = 'Open';
        ct.account_type_value = 'Bank Account';
        ct.account_type_code = 'Bank Account';
        ct.bsb_number = bsbNumber;
        ct.source_system = 'SAP';
        ct.open_date = Date.today();
        ct.product_type_value = 'Macquarie Savings Account';
        ct.product_type_code = 'SV001MBLSAV001';
        ct.is_external_product = null;
        ct.external_product_name = 'Macquarie Savings Account';
        ct.settlement_date = null;
        ct.brand_code = 'MRBSales';
        ct.brand_value = 'MRB Sales';
        ct.related_parties = new List<RESTContract.RelatedParty>();
        return ct;
    }
    
    private static RESTContract.RelatedParty getContractRolePayload(String partyEnterpriseId, String partyType, String partySubType, String partyLastName){
        RESTContract.RelatedParty party = new RESTContract.RelatedParty();
        party.status = 'Applied';
        party.state = 'New South Wales';
        party.siebel_id = partyEnterpriseId;
        party.relationship = 'AcctHolder';
        party.post_code = '2000';
        party.party_type = partyType;
        party.party_sub_type = partySubType;
        party.party_name = partyLastName;
        party.party_last_name = partyLastName;
        party.mobile = '0411119999';
        party.enterprise_id = partyEnterpriseId;
        party.email = 'test@test.test';
        party.e_consent = null;
        party.country = 'Australia';
        party.city = 'Syndey';
        party.address_line_3 = null;
        party.address_line_2 = null;
        party.address_line_1 = '123 Kent Street';
        return party;
    }
    
}