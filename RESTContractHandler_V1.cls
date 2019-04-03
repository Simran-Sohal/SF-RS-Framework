/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Handler for Contract API version V1
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
22-Oct-18   Simran Singh        
------------------------------------------------------------*/
public class RESTContractHandler_V1 extends RESTHandlerBase{
 
    public class ContractRequest{
        public RESTContract contract;
    }
    
    public RESTContractHandler_V1(){
        super();
    }
 
    // Method to implement the logic for HTTP Put Request
    public override void putRecords(){
        ContractRequest ctRequest = new ContractRequest();
        
        if (String.isNotBlank(requestInfo.requestBodyJSON)){
            try{
                ctRequest = (ContractRequest)JSON.deserialize(requestInfo.requestBodyJSON, ContractRequest.class);
            } catch (Exception e){
                ctRequest = null;
                logMessage('-- Error when deserializing request body : ' + e.getMessage() + ' - ' + e.getStackTraceString());
            }
        }
        
        if (ctRequest == null || (ctRequest != null && ctRequest.contract == null)){
            addError(RESTConstants.INVALID_REQUEST, (String.isBlank(requestInfo.requestBodyJSON) ? 'Request body is blank' : 'Unable to parse the request payload'));
            setResponse(RESTConstants.HTTP_BAD_REQUEST);
            return;
        } 
        
        setMaskedRequest(getMaskedContractJSON(ctRequest.contract));
        
        //validate the request and if there are any errors add them to the error stack
        validateContract(ctRequest.contract);
        
        //in case of any validation error, return
        if (hasError){
            setResponse(RESTConstants.HTTP_BAD_REQUEST);
            return;
        }

        //handle the request and route it to the appropriate Contract handler
        Savepoint sp = Database.setSavepoint();
        try {
            processContract(ctRequest.contract);
        }
        catch (Exception e){
            Database.rollback(sp);
            addError(e);
        }

        setResponse((hasError ? RESTConstants.HTTP_INTERNAL_ERROR : RESTConstants.HTTP_ACCEPTED));
    }

    private void validateContract(RESTContract sfContract){
        //add conditions to validate the Contract record and add any errors to error stack
        if (String.isBlank(sfContract.account_id)){
            addError(RESTConstants.INVALID_REQUEST,'Account Id is blank.');
        }
        if (String.isBlank(sfContract.account_type_value)){
            addError(RESTConstants.INVALID_REQUEST,'Account Type is blank.');
        }
        if (sfContract.related_parties.size() == 0){
            addError(RESTConstants.INVALID_REQUEST,'The contract has no contract roles.');
        } 
        else {
            for (RESTContract.RelatedParty party : sfContract.related_parties){
                if (String.IsBlank(party.enterprise_id)){
                    addError(RESTConstants.INVALID_REQUEST,'Enterprise Id is blank for the related party.');
                }
                if (String.IsBlank(party.party_type)){
                    addError(RESTConstants.INVALID_REQUEST,'Party Type is blank for the related party.');
                }
                if (String.IsBlank(party.party_sub_type)){
                    addError(RESTConstants.INVALID_REQUEST,'Party Sub Type is blank for the related party.');
                }
            }
        }
    }

    private void processContract(RESTContract sfContract){
        List<String> errors = new List<String>();
        
        //process Contract
        RESTContractHandler ctHandler = new RESTContractHandler(sfContract);
        ctHandler.process();
        
        if (ctHandler.hasErrors()){ errors = ctHandler.getErrors(); }
    
        //if any errors are returned then add errors to the error stack 
        if (errors.size() > 0){
            for (String errMsg : errors){
                addError(RESTConstants.INTERNAL, errMsg);
            }
        }
    }
     
    // GET, POST, DELETE are not supported 
    public override void getRecords(){
        invalidRequest();
    }
    public override void postRecords(){
        invalidRequest();
    }
    public override void deleteRecords(){
        invalidRequest();
    }
    
    /* Method to mask the attributes in Contract record */
    private String getMaskedContractJSON(RESTContract sfContract){
        String sfContractJSON = JSON.serialize(sfContract);
        
        RESTContract maskedContract = (RESTContract)JSON.deserialize(sfContractJSON, RESTContract.class);
        //fields masked as per the following confluence document 
        //https://confluence.devtools.macquarie.com/display/SPS/OneBFS+Encrypted+Data
        if (maskedContract.related_parties != null && maskedContract.related_parties.sizE() > 0){
            for (RESTContract.RelatedParty party : maskedContract.related_parties){
                party.party_last_name = RESTConstants.MASKED_STRING;
                party.address_line_1 = RESTConstants.MASKED_STRING;
                party.address_line_2 = RESTConstants.MASKED_STRING;
                party.address_line_3 = RESTConstants.MASKED_STRING;
                party.city = RESTConstants.MASKED_STRING;
                party.state = RESTConstants.MASKED_STRING;
                party.post_code = RESTConstants.MASKED_STRING;
                party.country = RESTConstants.MASKED_STRING;
                party.email = RESTConstants.MASKED_STRING;
                party.mobile = RESTConstants.MASKED_STRING;
            }
        }
        
        return JSON.serializePretty(maskedContract);
    }
    
}