/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Handler class to process Contracts (Financial Accounts)
                and Contract Roles (Financial Account Roles)
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
24-Oct-18   Simran Singh        
------------------------------------------------------------*/
public with sharing class RESTContractHandler{

    private List<String> errorList;
    private RESTContract sfContract;

    private Map<String,Account> enterpriseIDAccountMap;
    private Map<String,Contact> enterpriseIDContactMap;

    public RESTContractHandler(RESTContract pContract){
        sfContract = pContract;
        errorList = new List<String>();
    }

    public void addError(String errMsg){
        errorList.add(errMsg);
    }
    
    public Boolean hasErrors(){
        return (errorList.size() > 0);
    }
    
    public List<String> getErrors(){
        return errorList;
    }

    public void process(){
        populatePartyMaps();
        
        saveFinancialAccountAndRoles();
    }
    
    private void populatePartyMaps(){
        Set<String> accountEnterpriseIds = new Set<String>();
        Set<String> contactEnterpriseIds = new Set<String>();
        
        if (sfContract.related_parties != null && sfContract.related_parties.sizE() > 0){
            for (RESTContract.RelatedParty party : sfContract.related_parties){
                if (String.IsBlank(party.enterprise_id)) continue;
                
                if (party.party_type == RecordFinderConstants.ORGANISATION) {
                    accountEnterpriseIds.add(party.enterprise_id);
                }
                else if (party.party_type == RecordFinderConstants.PERSON) {
                    if (party.party_sub_type == RecordFinderConstants.CLIENT){
                        accountEnterpriseIds.add(party.enterprise_id);
                    }
                    contactEnterpriseIds.add(party.enterprise_id);
                }
            }
        }

        enterpriseIDAccountMap = new Map<String,Account>();
        enterpriseIDContactMap = new Map<String,Contact>();

        if (!accountEnterpriseIds.isEmpty()) {
            for (Account acc : [select id, Enterprise_ID__c from Account where Enterprise_ID__c IN :accountEnterpriseIds]) {
                enterpriseIDAccountMap.put(acc.Enterprise_ID__c, acc);
            }
        }
        
        if (! contactEnterpriseIds.isEmpty()) {
            for(Contact cntct : [select id, Enterprise_ID__c from Contact where Enterprise_ID__c IN :contactEnterpriseIds]) {
                enterpriseIDContactMap.put(cntct.Enterprise_ID__c, cntct);
            }
        }
    }

    private void saveFinancialAccountAndRoles(){
        String financialAccountKey = sfContract.source_system + '_' + sfContract.account_id+ '_' + sfContract.account_type_value;

        //For Facility - Need to copy Account ID to Account number field as this won't be populated
        if (String.isNotBlank(sfContract.account_type_value) && sfContract.account_type_value == RecordFinderConstants.RT_FACILITY) {
            sfContract.account_number = sfContract.account_id;
        }
        
        //SSingh - If the party does not exist in Salesforce then create the Financial Account without the missing parties.
        //         Save the error and create the Financial Account with valid related parties as Financial Account Roles.
        Financial_Account__c finAcc = new Financial_Account__c();
        finAcc.Account_ID__c            = sfContract.account_id;
        finAcc.Integration_Key__c       = financialAccountKey;
        finAcc.Account_Number__c        = sfContract.account_number;
        finAcc.BSB_Number__c            = sfContract.bsb_number;
        finAcc.Product_Source_System__c = sfContract.source_system;
        finAcc.Name                     = (sfContract.account_name).length() > 80 ? (sfContract.account_name).subString(0,80) : sfContract.account_name;
        finAcc.Account_Status__c        = sfContract.account_status;
        finAcc.Account_Type__c          = sfContract.account_type_value;
        finAcc.Open_Date__c             = sfContract.open_date;
        finAcc.Product_Type__c          = sfContract.product_type_value;
        finAcc.Product_Type_Code__c     = sfContract.product_type_code;
        finAcc.Is_External_Product__c   = sfContract.is_external_product;
        finAcc.External_Product_Name__c = sfContract.external_product_name;        
        
        List<Financial_Account_Role__c> finAccRoles = new List<Financial_Account_Role__c>();
        
        if (sfContract.related_parties != null && sfContract.related_parties.size() > 0){
            for (RESTContract.RelatedParty party : sfContract.related_parties){
                if (String.IsBlank(party.enterprise_id)) { continue; }

                if ((party.party_type == RecordFinderConstants.ORGANISATION && !enterpriseIDAccountMap.containsKey(party.enterprise_id)) 
                      || (party.party_type == RecordFinderConstants.PERSON && !enterpriseIDContactMap.containsKey(party.enterprise_id))){
                    addError('Unable to find a party with enterprise Id ' + party.enterprise_id + ' and party type ' + party.party_type);
                }
                else {
                    Financial_Account_Role__c faRole = new Financial_Account_Role__c();
                    faRole.Integration_Key__c     = financialAccountKey + '_' + party.enterprise_id + '_' + party.relationship;
                    faRole.Relationship__c        = party.relationship;
                    faRole.Status__c              = party.status;                
                    faRole.Financial_Account__r   = new Financial_Account__c(Integration_Key__c = financialAccountKey);             
                    faRole.Address_Line_1__c      = party.address_line_1;
                    faRole.Address_Line_2__c      = party.address_line_2;
                    faRole.Address_Line_3__c      = party.address_line_3;
                    faRole.City__c                = party.city;
                    faRole.State__c               = party.state;
                    faRole.PostCode__c            = party.post_code;
                    faRole.Country__c             = party.country;
                    faRole.Email__c               = party.email;
                    faRole.Mobile__c              = party.mobile;
                    faRole.e_Consent__c           = party.e_consent;                
    
                    if (party.party_type == RecordFinderConstants.ORGANISATION) {
                        faRole.Account__c = enterpriseIDAccountMap.get(party.enterprise_id).Id;
                    }
                    else if (party.party_type == RecordFinderConstants.PERSON) {
                        if (party.party_sub_type == RecordFinderConstants.CLIENT && enterpriseIDAccountMap.containsKey(party.enterprise_id)){
                            faRole.Account__c = enterpriseIDAccountMap.get(party.enterprise_id).Id;
                        }
                        faRole.Contact__c = enterpriseIDContactMap.get(party.enterprise_id).Id;
                    }
                    finAccRoles.add(faRole);
                }
            }
        }        

        //perform DMLs
        Savepoint sp = Database.SetSavePoint();
        
        //save financial accounts
        Database.UpsertResult saveFAResult = Database.upsert(finAcc, Schema.Financial_Account__c.Integration_Key__c, true);
        if (!saveFAResult.isSuccess()){
            addError(getErrorMessage(saveFAResult.getErrors()));
            return; 
        }
        System.debug(loggingLevel.DEBUG, 'Financial Account record saved successfully : ' + finAcc.ID);
        
        //save financial account roles
        Set<Id> successFARUpsertIds = new Set<Id>();
        Boolean hasDMLError = false;
        if (finAccRoles.size() > 0){
            Database.UpsertResult[] saveFARResult = Database.upsert(finAccRoles, Schema.Financial_Account_Role__c.Integration_Key__c, false);
            for(Integer i=0; i < saveFARResult.size(); i++){
                if (saveFARResult.get(i).isSuccess()){
                    successFARUpsertIds.add(finAccRoles.get(i).Id);
                }
                else {
                    hasDMLError = true;
                    addError(getErrorMessage(saveFARResult.get(i).getErrors()));
                }
            }
        }
        System.debug(loggingLevel.DEBUG, 'Financial Account Roles dml errors : ' + hasDMLError);
        
        if (hasDMLError){
            Database.rollback(sp);
        }
        else {
            //remove unwanted financial account roles
            List<Financial_Account_Role__c> finAccountRoleForDeletion = new List<Financial_Account_Role__c>();

            for(Financial_Account_Role__c faRole : [SELECT ID FROM Financial_Account_Role__c WHERE Financial_Account__r.Integration_Key__c = :finAcc.Integration_Key__c]){
                if(!successFARUpsertIds.contains(faRole.Id)){
                    finAccountRoleForDeletion.add(faRole);
                }
            }

            Database.delete(finAccountRoleForDeletion, false);
        }
    }
    
    private String getErrorMessage(Database.Error[] dbErrors){
        String errMsg;
        for(Database.Error err : dbErrors){
            errMsg = err.getMessage();
        }
        return errMsg;
    }
    
}