/*------------------------------------------------------------
Author:         Simran Singh
Company:        
Description:    Request Payload for Contract Service REST API
Test Class:
History
<Date>      <Authors Name>      <Brief Description of Change>
22-Oct-18   Simran Singh        
------------------------------------------------------------*/
public class RESTContract{

    public String account_Id {get; set;}
    public String account_name {get; set;}
    public String account_number {get; set;}
    public String account_status {get; set;}
    public String account_type_code {get; set;}
    public String account_type_value {get; set;}
    public String bsb_number {get; set;}
    public String source_system {get; set;}
    public Date   open_date {get; set;}
    public String product_type_code {get; set;}
    public String product_type_value {get; set;}
    public String is_external_product {get; set;}
    public String external_product_name {get; set;}
    public Date   settlement_date {get; set;}
    public String brand_code {get; set;}
    public String brand_value {get; set;}
    
    public List<RelatedParty> related_parties {get; set;}

    public class RelatedParty{
        public String enterprise_id {get; set;}
        public String party_type {get; set;}
        public String party_sub_type {get; set;}
        public String relationship {get; set;}
        public String party_last_name {get; set;}
        public String party_name {get; set;}
        public String siebel_id {get; set;}
        public String status {get; set;}
        public String address_line_1 {get; set;}
        public String address_line_2 {get; set;}
        public String address_line_3 {get; set;}   
        public String city {get; set;}
        public String state {get; set;}
        public String post_code {get; set;}
        public String country {get; set;}
        public String email {get; set;}
        public String mobile {get; set;}
        public String e_consent {get; set;}
    }
    
}