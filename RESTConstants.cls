/*------------------------------------------------------------
Author:         Simran Singh
Company:        UST Gobal
Description:    Class to keep all the constants related to REST APIs
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
29-Mar-18   Simran Singh        Created for BSS-186
------------------------------------------------------------*/
public class RESTConstants {
    
    //constants for HTTP Methods
    public static final String HTTP_GET    = 'GET';
    public static final String HTTP_PUT    = 'PUT';
    public static final String HTTP_POST   = 'POST';
    public static final String HTTP_DELETE = 'DELETE';
    
    //constants for header attributes
    public static final String HEADER_CONTENT_TYPE      = 'Content-Type';
    public static final String HEADER_LOCATION          = 'Location';
    public static final String HEADER_TRACE_ID          = 'mgl-trace-id';
    public static final String HEADER_SPAN_ID           = 'mgl-span-id';
    public static final String HEADER_CONVERSATION_ID   = 'mgl-conversation-id';
    public static final String HEADER_MESSAGE_TIMESTAMP = 'mgl-message-timestamp';
    public static final String HEADER_ENTERPRISE_ID     = 'mgl-enterprise-id';

    //constants for resource URL key and subresource
    public static final String RESOURCE_IDENTIFIER     = 'RESOURCE_IDENTIFIER';
    public static final String SUB_RESOURCE            = 'SUB_RESOURCE';
    public static final String SUB_RESOURCE_IDENTIFIER = 'SUB_RESOURCE_IDENTIFIER';

    //constants for http status codes
    public static final Integer HTTP_OK                  = 200;
    public static final Integer HTTP_CREATED             = 201;
    public static final Integer HTTP_ACCEPTED            = 202;
    public static final Integer HTTP_NO_CONTENT          = 204;
    public static final Integer HTTP_BAD_REQUEST         = 400;
    public static final Integer HTTP_UNAUTHORIZED        = 401;
    public static final Integer HTTP_FORBIDDEN           = 403;
    public static final Integer HTTP_NOT_FOUND           = 404;
    public static final Integer HTTP_NOT_ALLOWED         = 405;
    public static final Integer HTTP_CONFLICT            = 409;
    public static final Integer HTTP_PRECONDITION_FAILED = 412;
    public static final Integer HTTP_TOO_MANY_REQUESTS   = 429;
    public static final Integer HTTP_INTERNAL_ERROR      = 500;
    public static final Integer HTTP_UNAVAILABLE         = 503;

    //Error Statuses
    public static final String INVALID_REQUEST     = 'INVALID_REQUEST';
    public static final String INVALID_PARAMETER   = 'INVALID_PARAMETER';
    public static final String UNAUTHENTICATED     = 'UNAUTHENTICATED';
    public static final String UNAUTHORIZED        = 'UNAUTHORIZED';
    public static final String NOT_FOUND           = 'NOT_FOUND';
    public static final String NOT_ALLOWED         = 'NOT_ALLOWED';
    public static final String ALREADY_EXISTS      = 'ALREADY_EXISTS';
    public static final String PRECONDITION_FAILED = 'PRECONDITION_FAILED';
    public static final String RESOURCE_EXHAUSTED  = 'RESOURCE_EXHAUSTED';
    public static final String INTERNAL            = 'INTERNAL';
    public static final String UNAVAILABLE         = 'UNAVAILABLE';

    //Error Messages
    public static final String SERVICE_HANDLER_NOT_FOUND          = 'Unable to find the handler for this service.';
    public static final String REQUEST_NOT_SUPPORTED              = 'Http request {0} is not supported for this service.';
    public static final String INVALID_END_POINT                  = 'Invalid end point.';
    public static final String AUTHORIZATION_IDENTIFIER_NOT_FOUND = 'Unable to find the identifier for authorization.';
    public static final String CONTACT_NOT_FOUND_FOR_ID           = 'Unable to find a contact for the identifier.';
    public static final String RECORD_NOT_FOUND                   = 'Unable to find the record.';
    public static final String RESOURCE_IDENTIFIER_BLANK          = 'Resource Identifier is blank.';
    public static final String RESOURCE_IDENTIFIER_INVALID        = 'Resource Identifier is not valid.';
    public static final String RESOURCE_TYPE_INVALID              = 'Resource Type is not valid.';
    public static final String SOURCE_SYSTEM_ID_INVALID           = 'Source System Id is not valid for Salesforce.';
    
    //Reserved query parameters
    public static final String PARAMETER_FILTER = 'filter';
    public static final String PARAMETER_OFFSET = 'offset';
    public static final String PARAMETER_LIMIT  = 'limit';
    public static final String PARAMETER_SORT   = 'sort';
    public static final String PARAMETER_FIELDS = 'fields';
    public static final String PARAMETER_VIEW   = 'view';
    
    //Constants
    public static final String  BLANK = '';
    public static final String  MASKED_STRING = 'xxxx';
    public static final Date    MASKED_DATE   = null;
    public static final Integer MAXIMUM_OFFSET_VALUE = 2000;
    public static final Integer MAXIMUM_LIMIT_VALUE  = 1000;

    //Salesforce system ID
    public static final String  SFDC_SOURCE_SYSTEM_ID = '16';

    //Reserved request body attributes
    public static final String REQUEST_ATTRIBUTE_META = 'meta';

    //Reserved response body attributes
    public static final String RESPONSE_ATTRIBUTE_META   = 'meta';
    public static final String RESPONSE_ATTRIBUTE_LINKS  = 'links';
    public static final String RESPONSE_ATTRIBUTE_ERRORS = 'errors';
    
}