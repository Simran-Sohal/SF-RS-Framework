/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Interface for the RESTful services handler
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
29-Mar-18   Simran Singh        Created for BSS-186
------------------------------------------------------------*/
public interface RESTHandler {
    /* Method to set and get the service base resource URI number */
    void setBaseResourceURI(String pBaseResourceURI);
    String getBaseResourceURI();

    /* Method to set and get the handler class name */
    void setHandlerClassName(String pClassName);
    String getHandlerClassName();

    /* Method to set and get the logging flag */
    void setLoggingFlag(Boolean pLoggingFlag);
    Boolean getLoggingFlag();

    /* Method must be implemented to parse the request */
    void parseRequest();

    /* This method must be implemented to handle the GET call */
    void doGet();

    /* This method must be implemented to handle the PUT call */
    void doPut();

    /* This method must be implemented to handle the POST call */
    void doPost();

    /* This method must be implemented to handle the DELETE call */
    void doDelete();
}