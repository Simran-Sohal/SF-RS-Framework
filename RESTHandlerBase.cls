/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Base class for RESTful services handler that
                implements the RESTHandler interface and provide
                common methods
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
29-Mar-18   Simran Singh        Created for BSS-186
14-Jun-18   Simran Singh        Modified to implement front controller changes
30-Aug-18   Simran Singh        Fixed the logging issue
------------------------------------------------------------*/
public abstract with sharing class RESTHandlerBase implements RESTHandler{

    /* REST Request Infomation class */
    public class RequestInfo {
        public Map<String, String> requestHeaderMap;
        public Map<String, String> requestParamsMap;
        public String httpRequestMethod;
        public String requestBodyJSON;
        public ResourceURLInfo resourceURLInfo;
            
        public RequestInfo() {
            requestHeaderMap  = new Map<String, String>();
            requestParamsMap  = new Map<String, String>();
            requestBodyJSON   = RESTConstants.BLANK;
            httpRequestMethod = RESTConstants.BLANK;
            resourceURLInfo   = new ResourceURLInfo();
        }
    }
    
    /* Resource URL Info class */
    public class ResourceURLInfo {
        public ResourceIdentifier resourceIdentifier;
        public String subResourceType;
        public String subResourceId;
    }

    /* Resource Identifier class */
    public class ResourceIdentifier {
        public String resourceType;
        public String resourceId;
        public String sourceSystemId;
    }
    
    /* Error structure classes */
    public class Error {
        public String status        {get; set;}
        public String message       {get; set;}
        public String moreInfo      {get; set;}
        public String resourceId    {get; set;}
        public ErrorDetails details {get; set;}
    }
    
    public class ErrorDetails{
        public List<FieldViolation> fieldViolations {get;set;}
    }
    
    public class FieldViolation{
        public String code        {get; set;}
        public String fieldName   {get; set;}
        public String fieldPath   {get; set;}
        public String description {get; set;}
    }
    
    /* 
     * Pagination class for Links attribute of response 
     * added page prefix and suffix because few name (like offset, limit) are reserved in Salesforce
     */
    public class Pagination{
        public Integer pageOffset {get;set;}
        public Integer pageLimit  {get;set;}
        public Integer pageSize   {get;set;}
        public String  firstPage  {get;set;}
        public String  lastPage   {get;set;}
        public String  prevPage   {get;set;}
        public String  nextPage   {get;set;}
    }

    public RestRequest request     {get; set;}
    public RequestInfo requestInfo {get; set;}
    public RestResponse response   {get; set;}
    
    public Boolean hasError {get; set;}
    protected List<Error> errors {get; set;}
    protected Long callTime;
    
    public RESTHandlerBase(){
        callTime = System.currentTimeMillis();
        System.debug(loggingLevel.DEBUG, callTime);
        request = RestContext.request;
        response = RestContext.response;
        
        clearErrorStack();
        logMessage('-- Base init...');
    }

    //class memeber variables to keep API configuration details
    private String  handlerClassName;
    private String  baseResourceURI;
    private Boolean isLoggingEnabled;

    /* 
     * Interface methods to set and get the Base resource URI for the API
     */
    public void setBaseResourceURI(String pBaseResourceURI){
        baseResourceURI = pBaseResourceURI;
        logMessage('-- Base Resource URI : ' + baseResourceURI);
    }
    public String getBaseResourceURI(){
        return baseResourceURI;
    }
    
    /* 
     * Interface methods to set and get the handler class name for the API.
     */
    public void setHandlerClassName(String pClassName){
        handlerClassName = pClassName;
        logMessage('-- Handler Class Name : ' + handlerClassName);
    }
    public String getHandlerClassName(){
        return handlerClassName;
    }

    /* 
     * Interface methods to set and get the logging flag
     */
    public void setLoggingFlag(Boolean pLoggingFlag){
        isLoggingEnabled = pLoggingFlag;
        logMessage('-- Logging Flag : ' + String.valueOf(isLoggingEnabled));
    }
    public Boolean getLoggingFlag(){
        return isLoggingEnabled;
    }
    
    /* Variables to store the masked request and response payload */
    private String maskedRequest;
    private String maskedResponse;
    
    /* Methods to set and get the masked request */
    public void setMaskedRequest(String maskedReq){
        maskedRequest = maskedReq;
    }
    public String getMaskedRequest(){
        maskedRequest = String.IsBlank(maskedRequest) ? RESTConstants.BLANK : maskedRequest;
        return maskedRequest;
    }

    /* Methods to set and get the masked response */
    public void setMaskedResponse(String maskedResp){
        maskedResponse = maskedResp;
    }
    public String getMaskedResponse(){
        maskedResponse = String.IsBlank(maskedResponse) ? RESTConstants.BLANK : maskedResponse;
        if (hasError && String.isBlank(maskedResponse)){
            maskedResponse = getResponseBodyJSON();
        }
        
        return maskedResponse;
    }
    
    //reserved query parameters
    private String  filterValue = RESTConstants.BLANK;
    private String  sortByValue = RESTConstants.BLANK;
    private String  fieldsValue = RESTConstants.BLANK;
    private String  viewValue   = RESTConstants.BLANK;
    private Integer offsetValue;
    private Integer limitValue;

    /* 
     * Interface method to parse the request and populate RequestInfo
     */
    public void parseRequest() {
        requestInfo = new RequestInfo();
        requestInfo.requestHeaderMap  = request.headers;
        requestInfo.requestParamsMap  = request.params;
        requestInfo.httpRequestMethod = request.httpMethod;
        
        //set the request body JSON string
        //Note : The service handler class must implement the logic to parse this JSON to an appropriate object
        if (request.requestBody != null){
            requestInfo.requestBodyJSON = request.requestBody.toString();
        }

        //set the request resource URL information
        if(String.isNotBlank(request.requestURI) && String.isNotBlank(getBaseResourceURI())){
            requestInfo.resourceURLInfo = getResourceURLInfo(request.requestURI, getBaseResourceURI());
        } 

        //set reversed query parameters
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_FILTER)){
            setFilter(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_FILTER));
        }
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_OFFSET)){
            setOffset(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_OFFSET));
        }
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_LIMIT)){
            setLimit(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_LIMIT));
        }
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_SORT)){
            setSortBy(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_SORT));
        }
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_FIELDS)){
            setFields(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_FIELDS));
        }
        if (requestInfo.requestParamsMap.containsKey(RESTConstants.PARAMETER_VIEW)){
            setView(requestInfo.requestParamsMap.get(RESTConstants.PARAMETER_VIEW));
        }
        
        //logMessage('-- Request Info : ' + String.valueOf(requestInfo));
    }

    /* Methods to set the reserved query parameters */
    private void setFilter(String pFilter){
        filterValue = pFilter;
    }
    private void setSortBy(String pSortBy){
        sortByValue = pSortBy;
    }
    private void setFields(String pFields){
        fieldsValue = pFields;
    }
    private void setView(String pView){
        viewValue = pView;
    }
    private void setOffset(String pOffset){
        if (pOffset.isNumeric()){
            offsetValue = Integer.valueOf(pOffset);
            offsetValue = (offsetValue > RESTConstants.MAXIMUM_OFFSET_VALUE ? RESTConstants.MAXIMUM_OFFSET_VALUE : offsetValue);
        }
    }
    private void setLimit(String pLimit){
        if (pLimit.isNumeric()){
            limitValue = Integer.valueOf(pLimit);
            limitValue = (limitValue > RESTConstants.MAXIMUM_LIMIT_VALUE ? RESTConstants.MAXIMUM_LIMIT_VALUE : limitValue);
        }
    }

    /* Methods to get the reserved query parameters */
    @testVisible
    protected String getFilter(){
        return filterValue;
    }
    @testVisible
    protected String getSortBy(){
        return sortByValue;
    }
    @testVisible
    protected String getFields(){
        return fieldsValue;
    }
    @testVisible
    protected String getView(){
        return viewValue;
    }
    @testVisible
    protected Integer getOffset(){
        return offsetValue;
    }
    @testVisible
    protected Integer getLimit(){
        return limitValue;
    }
    
    /* Abstract methods to be defined in all derived classes */
    public abstract void getRecords();
    public abstract void postRecords();
    public abstract void putRecords();
    public abstract void deleteRecords();
    
    /* Methods for Http Requests */
    //GET
    public void doGet(){
        getRecords();
        createLogs();
        System.debug(loggingLevel.ERROR, '-- Response : ' + response);
    }

    //POST
    public void doPost(){
        postRecords();
        createLogs();
        System.debug(loggingLevel.ERROR, '-- Response : ' + response);
    }

    //PUT
    public void doPut(){
        putRecords();
        createLogs();
        System.debug(loggingLevel.ERROR, '-- Response : ' + response);
    }

    //DELETE
    public void doDelete(){
        deleteRecords();
        createLogs();
        System.debug(loggingLevel.ERROR, '-- Response : ' + response);
    }
    
    private void createLogs(){
        if (hasError){
            createApplicationLog();
        }
        
        if (getLoggingFlag()){
            createWebserviceLog();
        }
    }
    
    public void invalidRequest(){
        addError(RESTConstants.INVALID_REQUEST, String.format(RESTConstants.REQUEST_NOT_SUPPORTED, new String[]{requestInfo.httpRequestMethod}));
        setResponse(RESTConstants.HTTP_NOT_ALLOWED);
    }
    
    public void clearErrorStack(){
        errors = new List<Error>();
        hasError = false;
    }
    
    /* 
     * Methods for validate the resource identifier
     */
    public Boolean isResourceIdentifierValid(){
        Boolean isValid = true;
        
        //resource identifier should not null
        if (requestInfo.resourceURLInfo.resourceIdentifier == null){
            addError(RESTConstants.INVALID_REQUEST, RESTConstants.RESOURCE_IDENTIFIER_BLANK);
            isValid = false;
        }
        
        //all the attributes of the resource identifiers must be populated
        if (requestInfo.resourceURLInfo.resourceIdentifier != null
               && (String.IsBlank(requestInfo.resourceURLInfo.resourceIdentifier.resourceType) 
                    || String.IsBlank(requestInfo.resourceURLInfo.resourceIdentifier.sourceSystemId) 
                        || String.IsBlank(requestInfo.resourceURLInfo.resourceIdentifier.resourceId))){
            addError(RESTConstants.INVALID_PARAMETER, RESTConstants.RESOURCE_IDENTIFIER_INVALID);
            isValid = false;
        }
        
        //source system Id must match with the Salesforce source system Id
        if (requestInfo.resourceURLInfo.resourceIdentifier != null 
                && String.IsNotBlank(requestInfo.resourceURLInfo.resourceIdentifier.sourceSystemId) 
                    && requestInfo.resourceURLInfo.resourceIdentifier.sourceSystemId != RESTConstants.SFDC_SOURCE_SYSTEM_ID){
            addError(RESTConstants.INVALID_PARAMETER, RESTConstants.SOURCE_SYSTEM_ID_INVALID);
            isValid = false;
        }
        
        return isValid;
    }
    
    /* Error handling methods */
    private Error getError(String pErrStatus, String pErrMsg, String pResourceId, String pMoreInfo, ErrorDetails pErrDetail){
        Error err = new Error();
        err.status = pErrStatus;
        err.message = pErrMsg;
        err.resourceId = pResourceId;
        err.moreInfo = pMoreInfo;
        if (pErrDetail != null){
            err.details = pErrDetail;
        }
        return err;    
    }

    /* handle exceptions */
    public void addError(Exception pException) {
        logMessage('-- Exception : ' + pException.getMessage() + ' - ' + pException.getStackTraceString());
        Error err = getError(RESTConstants.INTERNAL, pException.getMessage(), null, null, null);
        errors.add(err);
        ApplicationLogUtility.logError(getHandlerClassName(), requestInfo.httpRequestMethod, pException, err.message, err.resourceId, '', getMaskedRequest(), err.status, 0);
        hasError = true;
    }

    /* handle user-defined errors */
    public void addError(String pErrStatus, String pErrMsg) {
        addError(pErrStatus, pErrMsg, null);
    }
    public void addError(String pErrStatus, String pErrMsg, String pResourceId) {
        addError(pErrStatus, pErrMsg, pResourceId, null, null);
    }
    public void addError(String pErrStatus, String pErrMsg, String pResourceId, String pMoreInfo, ErrorDetails pErrDetail) {
        Error err = getError(pErrStatus, pErrMsg, pResourceId, pMoreInfo, pErrDetail);
        logMessage('-- Error : ' + String.valueof(err));
        errors.add(err);
        ApplicationLogUtility.logError(getHandlerClassName(), requestInfo.httpRequestMethod, null, err.message, err.resourceId, '', getMaskedRequest(), err.status, 0);
        hasError = true;
    }

    //map to keep the response attributes
    private Map<String, Object> responseBodyMap = new Map<String, Object>();
    //variable to store the name of the root elemnt of the response 
    private String responseRootElementName;
    
    /* Methods to set the response body attributes */
    public void setResponseMetaAttribute(Object pMetaObj){
        if (pMetaObj != null){
            responseBodyMap.put(RESTConstants.RESPONSE_ATTRIBUTE_META, pMetaObj);
        }
    }

    public void setResponseLinksAttribute(Pagination pPaginationObj){
        if (pPaginationObj != null){
            responseBodyMap.put(RESTConstants.RESPONSE_ATTRIBUTE_LINKS, pPaginationObj);
        }
    }

    public void setResponseRootElement(String pRootElementName, Object pRootElementObj){
        if (String.IsNotBlank(pRootElementName) && pRootElementObj != null){
            responseRootElementName = pRootElementName;
            responseBodyMap.put(responseRootElementName, pRootElementObj);
        }
    }

    /* Methods to set the response headers, body and status */
    public void setResponse(Integer pStatusCode){
        if (response == null) return;
        
        setResponseHeaders();
        String responseBodyJSON = getResponseBodyJSON();
        if (String.isNotBlank(responseBodyJSON)){
            response.responseBody = Blob.valueOf(responseBodyJSON);
        }

        response.statusCode = pStatusCode;
        //logMessage('-- Response : ' + response);
    }

    private void setResponseHeaders(){
        /* 
         * Refer the usage of Custom HTTP headers at the following link
         * https://confluence.internal.macquarie.com/display/SOA/OASP+HTTP+Headers+v2#OASPHTTPHeadersv2-CustomHttpHeaders
         */
        response.addHeader(RESTConstants.HEADER_CONTENT_TYPE, 'application/json');
        response.addHeader(RESTConstants.HEADER_MESSAGE_TIMESTAMP, getUTCCurrentTimestamp());
        
        if (requestInfo.requestHeaderMap.containsKey(RESTConstants.HEADER_TRACE_ID)){
            response.addHeader(RESTConstants.HEADER_TRACE_ID, requestInfo.requestHeaderMap.get(RESTConstants.HEADER_TRACE_ID));
        } else {
            //if not passed in request, set with new value
            response.addHeader(RESTConstants.HEADER_TRACE_ID, getTraceId());
        }

        if (requestInfo.requestHeaderMap.containsKey(RESTConstants.HEADER_SPAN_ID)){
            response.addHeader(RESTConstants.HEADER_SPAN_ID, requestInfo.requestHeaderMap.get(RESTConstants.HEADER_SPAN_ID));
        } else {
            //if not passed in request, set with new value
            response.addHeader(RESTConstants.HEADER_SPAN_ID, getSpanId());
        }

        if (requestInfo.requestHeaderMap.containsKey(RESTConstants.HEADER_CONVERSATION_ID)){
            response.addHeader(RESTConstants.HEADER_CONVERSATION_ID, requestInfo.requestHeaderMap.get(RESTConstants.HEADER_CONVERSATION_ID));
        }
    }

    private String getResponseBodyJSON(){
        String responseBodyJSON;
        if (responseBodyMap.size() > 0 || errors.size() > 0){
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            
            //meta attribute
            if (responseBodyMap.containsKey(RESTConstants.RESPONSE_ATTRIBUTE_META)){
                jsonGen.writeObjectField(RESTConstants.RESPONSE_ATTRIBUTE_META, responseBodyMap.get(RESTConstants.RESPONSE_ATTRIBUTE_META));
            }

            //links attribute
            if (responseBodyMap.containsKey(RESTConstants.RESPONSE_ATTRIBUTE_LINKS)){
                Pagination pagination = (Pagination) responseBodyMap.get(RESTConstants.RESPONSE_ATTRIBUTE_LINKS);
                jsonGen.writeFieldName(RESTConstants.RESPONSE_ATTRIBUTE_LINKS);
                jsonGen.writeStartObject(); //start links object
                
                jsonGen.writeFieldName('pagination');
                jsonGen.writeStartObject(); //start pagination object
                
                jsonGen.writeNumberField('offset', pagination.pageOffset);
                jsonGen.writeNumberField('limit', pagination.pageLimit);
                jsonGen.writeStringField('first', pagination.firstPage);
                jsonGen.writeStringField('last', pagination.lastPage);
                if (String.IsNotBlank(pagination.prevPage)){
                    jsonGen.writeStringField('prev', pagination.prevPage);
                }
                if (String.IsNotBlank(pagination.nextPage)){
                    jsonGen.writeStringField('next', pagination.nextPage);
                }
                if (pagination.pageSize != null){
                    jsonGen.writeNumberField('size', pagination.pageSize);
                }
                
                jsonGen.writeEndObject(); //end pagination object
                jsonGen.writeEndObject(); //end links object
            }
            
            //if there are errors in error list then return only errors
            if (errors.size() > 0){
                jsonGen.writeFieldName(RESTConstants.RESPONSE_ATTRIBUTE_ERRORS);
                jsonGen.writeStartArray();
                
                for(Error err : errors){
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('status', err.status);
                    jsonGen.writeStringField('message', err.message);
                    if (String.isNotBlank(err.resourceId)){
                        jsonGen.writeStringField('resource_id', err.resourceId);
                    }
                    if (String.isNotBlank(err.moreInfo)){
                        jsonGen.writeStringField('more_info', err.moreInfo);
                    }
                    if (err.details != null){
                        if (err.details.fieldViolations != null && err.details.fieldViolations.size() > 0){
                            jsonGen.writeFieldName('details');
                            jsonGen.writeStartObject();
                            
                            jsonGen.writeFieldName('field_violations');
                            jsonGen.writeStartArray();
                            for(FieldViolation fieldErr : err.details.fieldViolations){
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('description', fieldErr.description);
                                if (String.isNotBlank(fieldErr.code)){
                                    jsonGen.writeStringField('code', fieldErr.code);
                                }
                                if (String.isNotBlank(fieldErr.fieldName)){
                                    jsonGen.writeStringField('field_name', fieldErr.fieldName);
                                }
                                if (String.isNotBlank(fieldErr.fieldPath)){
                                    jsonGen.writeStringField('field_path', fieldErr.fieldPath);
                                }
                                jsonGen.writeEndObject();
                            }
                            jsonGen.writeEndArray();
                            
                            jsonGen.writeEndObject();
                        }
                    }
                    jsonGen.writeEndObject();
                }
                jsonGen.writeEndArray();
            } 
            //if there are no errors and root element is set then add the root element to response body JSON
            else {
                if (String.IsNotBlank(responseRootElementName)){
                    if (responseBodyMap.containsKey(responseRootElementName)){
                        jsonGen.writeObjectField(responseRootElementName, responseBodyMap.get(responseRootElementName));
                    }                  
                } 
            }
            
            jsonGen.writeEndObject();
            responseBodyJSON = jsonGen.getAsString();
        }
        //logMessage('-- Response Body JSON : ' + responseBodyJSON);
        return responseBodyJSON;
    }
    
    /* Method to set the Location header attribute in the response */
    public void setLocationHeader(String pLocation){
        if (response != null && String.IsNotBlank(pLocation)){
            response.addHeader(RESTConstants.HEADER_LOCATION, pLocation);
        }
    }
    
    /* Method to get the string for the current date and time in UTC timezone */
    public static String getUTCCurrentTimestamp(){
        String utcDate = System.now().format('yyyy-MM-dd','UTC');
        String utcTime = System.now().format('hh:mm:ss','UTC');
        String utcTimestamp = utcDate + 'T' + utcTime + 'Z';
        return utcTimestamp;
    }
    
    /* Method to get 128bit UUID for trace Id */
    public static String getTraceId(){
        Blob blobKey = Crypto.GenerateAESKey(128);
        String encodedHex = EncodingUtil.ConvertTohex(blobKey);
        String traceId = encodedHex.SubString(0,8)+ '-' + encodedHex.SubString(8,12) + '-' + encodedHex.SubString(12,16) + '-' + encodedHex.SubString(16,20) + '-' + encodedHex.substring(20);
        return traceId;
    }

    /* Method to get the 64bit UUID for span Id */
    public static String getSpanId(){
        Blob blobKey = Crypto.GenerateAESKey(128);
        String encodedHex = EncodingUtil.ConvertTohex(blobKey);
        String spanId = (encodedHex.length() > 16 ? encodedHex.SubString(0,16) : encodedHex);
        return spanId;
    }

    /* Method to prepare a resource index to its value map */
    private static ResourceURLInfo getResourceURLInfo(String pRequestURI, String pBaseResourceURI){
        pBaseResourceURI = sanitizeBaseResourceURI(pBaseResourceURI);
        String extendedResourceURI = pRequestURI.substringAfter(pBaseResourceURI);
        
        Map<Integer, String> resourceIndexValueMap = new Map<Integer, String>();
        
        if (String.isNotBlank(extendedResourceURI) && extendedResourceURI.startsWith('/')){
            Integer resourceIdx = 0;
            while(extendedResourceURI.length() > 0){
                extendedResourceURI = extendedResourceURI.substringAfter('/');
                String resourceVal = extendedResourceURI.substringBefore('/');
                    
                if (String.isNotBlank(resourceVal)){
                    resourceIndexValueMap.put(resourceIdx, resourceVal);
                    resourceIdx++;
                    if (resourceIdx > 2) break;
                }
                    
                extendedResourceURI = extendedResourceURI.substringAfter(resourceVal);
            }
        } 
        
        ResourceURLInfo resourceURLInfo = new ResourceURLInfo();
        if(resourceIndexValueMap.containsKey(0)){
            resourceURLInfo.resourceIdentifier = getResourceIdentifier(resourceIndexValueMap.get(0));
        }
        if(resourceIndexValueMap.containsKey(1)){
            resourceURLInfo.subResourceType = resourceIndexValueMap.get(1);
        }
        if(resourceIndexValueMap.containsKey(2)){
            resourceURLInfo.subResourceId = resourceIndexValueMap.get(2);
        }
        
        return resourceURLInfo;
    }
    
    /* Method to populate the ResourceIdentifier structure details */
    private static ResourceIdentifier getResourceIdentifier(String pResourceIdString){
        if (String.IsBlank(pResourceIdString)) return null;
        
        //Resource Identifier string must be in TYPE:SOURCE_SYSTEM:ID format
        List<String> resourceIdentifiers = pResourceIdString.split(':');
        
        ResourceIdentifier rsrcIdentifier = new ResourceIdentifier();
        Integer index = 0;
        
        for(String identifier : resourceIdentifiers){
            if (index == 0)
                rsrcIdentifier.resourceType = identifier;
            else if (index == 1)
                rsrcIdentifier.sourceSystemId = identifier;
            else if (index == 2)
                rsrcIdentifier.resourceId = identifier;

            index++;
        }
        
        return rsrcIdentifier;
    }
    
    /* Method to sanitize the base resource by removing any additional blank spaces and last back-slash */
    private static String sanitizeBaseResourceURI(String pBaseResourceURI){
        if (String.IsBlank(pBaseResourceURI)) return RESTConstants.BLANK;
        
        pBaseResourceURI = pBaseResourceURI.trim();
        if (pBaseResourceURI.endsWith('/')){
            pBaseResourceURI = pBaseResourceURI.substringBeforeLast('/');
        }
        
        return pBaseResourceURI;
    }

    public void logMessage(String pMsg){
        System.debug(loggingLevel.ERROR, pMsg);
    }
    
    private void createApplicationLog(){
        ApplicationLogUtility.commitLog(); 
    }

    private void createWebserviceLog(){
        callTime = System.currentTimeMillis() - callTime;
        
        WebServiceLogUtility.logService(String.valueOf(requestInfo.resourceURLInfo)
                                      , getMaskedRequest()
                                      , requestInfo.httpRequestMethod
                                      , getMaskedResponse()
                                      , response.statusCode
                                      , getBaseResourceURI()
                                      , (response.headers != null) ? String.valueOf(response.headers) : RESTConstants.BLANK
                                      , String.valueOf(requestInfo.requestHeaderMap)
                                      , callTime);
                                      
        WebServiceLogUtility.commitLog();
    }
    
}