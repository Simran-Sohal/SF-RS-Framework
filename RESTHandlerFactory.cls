/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    This factory class provides the handler class for 
                the RESTful resource by fetching the information 
                from REST Handler Mapping custom metadtata type
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
08-May-18   Simran Singh        
------------------------------------------------------------*/
public class RESTHandlerFactory {

    public static RESTHandler getHandler(String pResourceURI){
        REST_Handler_Mapping__mdt handlerMapping = getHandlerMapping(pResourceURI);
        System.debug(loggingLevel.ERROR, '-- Handler mapping : ' + handlerMapping);
        
        if (handlerMapping == null){
            throw new RESTException(RESTConstants.SERVICE_HANDLER_NOT_FOUND);
        }
        
        Type classType = Type.forName(handlerMapping.Handler_Class_Name__c);
        System.debug(loggingLevel.ERROR, '-- Class Type : ' + classType);
            
        RESTHandler handler;
        if (classType != null){
            handler = (RESTHandler)classType.newInstance();
            handler.setBaseResourceURI(handlerMapping.Base_Resource_URI__c);
            handler.setHandlerClassName(handlerMapping.Handler_Class_Name__c);
            handler.setLoggingFlag(handlerMapping.Is_Logging_Enabled__c);
            handler.parseRequest();
        }
        
        return handler;
    }
    
    private static REST_Handler_Mapping__mdt getHandlerMapping(String pResourceURI){
        List<REST_Handler_Mapping__mdt> restHandlerMappings 
                                    = [SELECT Handler_Class_Name__c
                                            , Base_Resource_URI__c
                                            , Is_Logging_Enabled__c
                                         FROM REST_Handler_Mapping__mdt
                                        WHERE Is_Active__c = true];
                    
        if (restHandlerMappings.size() == 0) return null;
        
        REST_Handler_Mapping__mdt serviceHdlrMapping;
        for(REST_Handler_Mapping__mdt hdlrMapping : restHandlerMappings){
            if (pResourceURI.startsWithIgnoreCase(hdlrMapping.Base_Resource_URI__c)){
                serviceHdlrMapping = hdlrMapping;
            }
        }
        
        return serviceHdlrMapping;
    }
}