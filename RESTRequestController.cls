/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    REST Request Controller. This class will route all 
                the requests to /onebfs/* to the appropriate handler
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
08-Jun-18   Simran Singh
------------------------------------------------------------*/
@RestResource(urlMapping='/onebfs/*')
global class RESTRequestController {
    private static final String BASE_PATH = '/onebfs';
    
    @HttpGet
    global static void doGet(){
        getServiceHandler().doGet();
    }
    
    @HttpPut
    global static void doPut(){
        getServiceHandler().doPut();
    }
    
    @HttpPost
    global static void doPost(){
        getServiceHandler().doPost();
    }

    @HttpDelete
    global static void doDelete(){
        getServiceHandler().doDelete();
    }

    private static RESTHandler getServiceHandler(){
        String resourceURI;
        if (String.IsNotBlank(RestContext.request.requestURI)){
            resourceURI = RestContext.request.requestURI.substringAfter(BASE_PATH); //gets the URI after /onebfs
        }
        System.debug(loggingLevel.ERROR, '-- resourceURI : ' + resourceURI);

        if (String.IsBlank(resourceURI)){
            throw new RESTException(RESTConstants.INVALID_END_POINT);
        }
        
        RESTHandler serviceHdlr = RESTHandlerFactory.getHandler(resourceURI);
        return serviceHdlr;
    }

}