/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Test class for RESTRequestController
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
28-Jun-18   Simran Singh        
------------------------------------------------------------*/
@isTest
private class RESTRequestController_Test{

    @isTest
    private static void testGETCall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testGETCall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/parties';  //Request URL
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
        System.debug(loggingLevel.ERROR, '***** End Test : testGETCall()');
    }

    @isTest
    private static void testPOSTCall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPOSTCall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/parties';  //Request URL
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
        System.debug(loggingLevel.ERROR, '***** End Test : testPOSTCall()');
    }

    @isTest
    private static void testPUTCall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testPUTCall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        String partyJSON = RESTPartyTestHelper.getTestPartyJSON('4543265587', RESTPartyConstants.PARTY_TYPE_ORGANISATION, RESTPartyConstants.PARTY_SUB_TYPE_CLIENT_CO);
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/parties';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_PUT;
        testReq.requestBody = Blob.valueof(partyJSON);
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        RESTRequestController.doPut();
        Test.stopTest();
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_ACCEPTED, statusCode);
        System.debug(loggingLevel.ERROR, '***** End Test : testPUTCall()');
    }

    @isTest
    private static void testDELETECall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testDELETECall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/parties';  //Request URL
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
        System.debug(loggingLevel.ERROR, '***** End Test : testDELETECall()');
    }

    @isTest
    private static void testUnidentifiedURICall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testUnidentifiedURICall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/unidentified';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_GET;
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        Boolean hasError = false;
        try{
            RESTRequestController.doGet();
        } catch (Exception e) {
            System.debug(loggingLevel.ERROR, 'Exception : ' + e.getMessage());
            hasError = true;
        }
        Test.stopTest();

        System.assertEquals(true, hasError);
        System.debug(loggingLevel.ERROR, '***** End Test : testUnidentifiedURICall()');
    }

    @isTest
    private static void testBlankURICall(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testBlankURICall()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs';  //no URL after onebfs
        testReq.httpMethod = RESTConstants.HTTP_GET;
        
        RestContext.request = testReq;
        RestContext.response= testRes;

        Test.startTest();
        Boolean hasError = false;
        try{
            RESTRequestController.doGet();
        } catch (Exception e) {
            System.debug(loggingLevel.ERROR, 'Exception : ' + e.getMessage());
            hasError = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, hasError);
        System.debug(loggingLevel.ERROR, '***** End Test : testBlankURICall()');
    }

}