/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Test class for REST Framework related classes
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
25-Jun-18   Simran Singh        
------------------------------------------------------------*/
@isTest(seeAllData=false)
private class RESTHandler_Test {

    public class RESTTestHandler_V1 extends RESTHandlerBase{
        
        public RESTTestHandler_V1(){
            super();
        }
     
        public override void getRecords(){
            try{
                Map<String, String> metaInfo = new Map<String, String>();
                metaInfo.put('object_name','Test_Account__c');
                metaInfo.put('record_id','0001230000AbcdeXYZ');
            
                Map<String, String> testAcc = new Map<String, String>();
                testAcc.put('account_id', '0001230000AbcdeXYZ');
                testAcc.put('account_name', 'Test Account');
                testAcc.put('account_number', '12345');
                    
                Pagination pagn = new Pagination();
                pagn.pageOffset = 0;
                pagn.pageLimit = 1;
                pagn.pageSize  = 1;
                pagn.firstPage = 'FIRST';
                pagn.lastPage  = 'LAST';
                pagn.prevPage  = 'PREV';
                pagn.nextPage  = 'NEXT';
                    
                FieldViolation fieldViolation = new FieldViolation();
                fieldViolation.code = 'TEST';
                fieldViolation.fieldName = 'Id';
                fieldViolation.fieldPath = 'TEST';
                fieldViolation.description = 'Id field is not valid';
            
                ErrorDetails errDetails = new ErrorDetails();
                errDetails.fieldViolations = new List<FieldViolation>();
                errDetails.fieldViolations.add(fieldViolation);
                
                Error err = new Error();
                err.status = 'TEST';
                err.message = 'Test Error Message';
                err.resourceId = '12345';
                err.moreInfo = 'Test Error Message';
                err.details = errDetails;
                errors.add(err);
                   
                setResponseMetaAttribute(metaInfo);
                setResponseLinksAttribute(pagn);
                setResponseRootElement('test_account', testAcc);
                setResponse(RESTConstants.HTTP_OK);
            }
            catch (Exception e){
                addError(e);
                setResponse(RESTConstants.HTTP_INTERNAL_ERROR);
            }        
        }
        
        public override void putRecords(){
            invalidRequest();
        }
        public override void postRecords(){
            invalidRequest();
        }
        
        public override void deleteRecords(){
            try{
                throw new RESTException('Insufficient Access');
            }
            catch (Exception e){
                addError(e);
                setResponse(RESTConstants.HTTP_INTERNAL_ERROR);
            }        
        }

    }


    @isTest
    private static void testHandlerBaseMethods(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testHandlerBaseMethods()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/test/TEST:16:12345';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_GET;
        testReq.requestBody = null;
        
        testReq.headers.put(RESTConstants.HEADER_TRACE_ID, '9876543210');
        testReq.headers.put(RESTConstants.HEADER_SPAN_ID, '0123456789');
        testReq.headers.put(RESTConstants.HEADER_CONVERSATION_ID, '99999999');
                
        testReq.params.put(RESTConstants.PARAMETER_FILTER, 'null');
        testReq.params.put(RESTConstants.PARAMETER_OFFSET, '0');
        testReq.params.put(RESTConstants.PARAMETER_LIMIT, '1');
        testReq.params.put(RESTConstants.PARAMETER_SORT, 'name');
        testReq.params.put(RESTConstants.PARAMETER_FIELDS, 'id,name');
        testReq.params.put(RESTConstants.PARAMETER_VIEW, 'read');

        
        RestContext.request = testReq;
        RestContext.response= testRes;
    
        Test.startTest();
        RESTTestHandler_V1 testHandler = new RESTTestHandler_V1();
        testHandler.setBaseResourceURI('/v1/test');
        testHandler.setHandlerClassName('RESTTestHandler_V1');
        testHandler.setLoggingFlag(true);
        
        testHandler.parseRequest();
        System.assertEquals('null', testHandler.getFilter());
        System.assertEquals('name', testHandler.getSortBy());
        System.assertEquals('id,name', testHandler.getFields());
        System.assertEquals('read', testHandler.getView());
        System.assertEquals(0, testHandler.getOffset());
        System.assertEquals(1, testHandler.getLimit());
        
        System.assertEquals(true, testHandler.isResourceIdentifierValid());
        
        testHandler.doGet();
        
        Test.stopTest();

        System.assertEquals(true, testRes.headers.containsKey(RESTConstants.HEADER_TRACE_ID));
        System.assertEquals(true, testRes.headers.containsKey(RESTConstants.HEADER_SPAN_ID));
        System.assertEquals(true, testRes.headers.containsKey(RESTConstants.HEADER_CONVERSATION_ID));
        System.assertEquals(true, testRes.headers.containsKey(RESTConstants.HEADER_CONTENT_TYPE));
        System.assertEquals(true, testRes.headers.containsKey(RESTConstants.HEADER_MESSAGE_TIMESTAMP));
        
        System.assertEquals('9876543210', testRes.headers.get(RESTConstants.HEADER_TRACE_ID));
        System.assertEquals('0123456789', testRes.headers.get(RESTConstants.HEADER_SPAN_ID));
        System.assertEquals('99999999'  , testRes.headers.get(RESTConstants.HEADER_CONVERSATION_ID));
        
        String responseBody = testRes.responseBody.toString();
        System.debug(loggingLevel.ERROR, '*** Response : ' + responseBody);
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_OK, statusCode);
        System.debug(loggingLevel.ERROR, '***** End Test : testHandlerBaseMethods()');
    }

    @isTest
    private static void testHandlerException(){
        System.debug(loggingLevel.ERROR, '***** Start Test : testHandlerException()');
        RestRequest testReq = new RestRequest();
        RestResponse testRes = new RestResponse();
        
        testReq.requestURI = '/services/apexrest/onebfs/v1/test/TEST:16:12345';  //Request URL
        testReq.httpMethod = RESTConstants.HTTP_DELETE;
        testReq.requestBody = null;
        
        RestContext.request = testReq;
        RestContext.response= testRes;
    
        Test.startTest();
        RESTTestHandler_V1 testHandler = new RESTTestHandler_V1();
        testHandler.setBaseResourceURI('/v1/test');
        testHandler.setHandlerClassName('RESTTestHandler_V1');
        testHandler.setLoggingFlag(true);
        testHandler.parseRequest();
        testHandler.doDelete();
        
        Test.stopTest();

        String responseBody = testRes.responseBody.toString();
        System.debug(loggingLevel.ERROR, '*** Response : ' + responseBody);
        
        Integer statusCode = testRes.statusCode;
        System.assertEquals(RESTConstants.HTTP_INTERNAL_ERROR, statusCode);
        System.debug(loggingLevel.ERROR, '***** End Test : testHandlerException()');
    }    
}