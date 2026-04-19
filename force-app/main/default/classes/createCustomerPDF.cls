/**
 * @description       : 
 * @author            : Niko
 * @group             : 
 * @last modified on  : 03-02-2026
 * @last modified by  : Niko
**/
public with sharing class createCustomerPDF {
    // Supplier Information
    public String supplierAddress { get; set; }
    public String supplierPostalAddress { get; set; }
    public String supplierPhone { get; set; }
    public String supplierEmail { get; set; }
    public String facsimile { get; set; }
    public String website { get; set; }

    // Applicant Info
    public Account customer;
    public String companyName { get; set; }
    public String tradeName { get; set; }
    public String abn { get; set; }
    public String acn { get; set; }
    public String phoneNum { get; set; }
    public String orderEmail { get; set; }
    public String postalAddr { get; set; }
    public String oprAddr { get; set; }
    public String customerType { get; set; }
    public String startDate { get; set; }

    // Financial Information
    public Decimal creditRequired { get; set; }
    
    // Representatives
    public List<Contact> representatives { get; set; }
    public String req1Name { get; set; }
    public String req2Name { get; set; }
    public String req3Name { get; set; }
    public String req1Address { get; set; }
    public String req2Address { get; set; }
    public String req3Address { get; set; }
    public String req1Position { get; set; }
    public String req2Position { get; set; }
    public String req3Position { get; set; }
    public String req1Email { get; set; }
    public String req2Email { get; set; }
    public String req3Email { get; set; }
    public String req1Phone { get; set; }
    public String req2Phone { get; set; }
    public String req3Phone { get; set; }

    // bank info
    public String branch { get; set; }
    public String bsb { get; set; }

    //trading reference
    public List<Trading_Reference__c> tradingRef { get; set; }
 
    // Constructor
    public createCustomerPDF() {
        initializeSupplierInfo();
        setApplicantInfo();
        setRepresentative();
        setBankInfo();
        setTradeRef();
    }

    private void initializeSupplierInfo() {
        // Set default supplier information
        supplierAddress = '5.08 12 Century Circuit, Norwest NSW 2153';
        supplierPostalAddress = 'PO Box 6506, Norwest NSW 2153';
        supplierPhone = '+61 2 8123 0170';
        supplierEmail = 'admin@rainbowagro.com.au';
        facsimile = '+61 2 8123 0171';
        website = 'www.rainbowagro.com/au/';
    }

    public void setApplicantInfo() {
        customer = [
            SELECT
                Name, Tax_Number__c,ACN_No__c,Phone,Accounts_Email__c,House_Number__c,
                Street__c,District__c,City__c,Province_State__c,Country__c,Postal_Code__c,
                Operating_Address__c,Customer_Type__c,Date_Business_Started__c
            FROM
                Account
            WHERE
                Id = :ApexPages.currentPage().getParameters().get('id')
        ];
        companyName = customer.Name == null ? '' : customer.Name;
        abn = customer.Tax_Number__c == null ? '' : customer.Tax_Number__c;
        acn = customer.ACN_No__c == null ? '' : customer.ACN_No__c;
        phoneNum = customer.Phone == null ? '' : customer.Phone;
        orderEmail = customer.Accounts_Email__c == null ? '' : customer.Accounts_Email__c;
        postalAddr = combinePostalAddress();
        oprAddr = customer.Operating_Address__c == null ? '' : customer.Operating_Address__c;
        customerType = customer.Customer_Type__c == null ? '' : customer.Customer_Type__c;
        startDate = customer.Date_Business_Started__c == null ? '' : customer.Date_Business_Started__c.format();
    }

    public String combinePostalAddress() {
        String province = '';
        String country = '';
        if (customer.Province_State__c != null && customer.Country__c != null) {
            Country_Province_Master_Data__c p = [ SELECT Name FROM Country_Province_Master_Data__c WHERE Id = :customer.Province_State__c LIMIT 1];
            Country_Province_Master_Data__c c = [ SELECT Name FROM Country_Province_Master_Data__c WHERE Id = :customer.Country__c LIMIT 1];
            province = p.Name;
            country = c.Name;
        }
        if (customer.House_Number__c != null && customer.Street__c != null && customer.District__c != null && customer.City__c != null && customer.Postal_Code__c != null) {
            return customer.House_Number__c + ' ' + customer.Street__c + ', ' + customer.District__c + ', ' + customer.City__c + ', ' + province + ' ' + country + ', ' + customer.Postal_Code__c;
        }
        return '';
    }

    public void setRepresentative() {
        representatives = [
            SELECT
                Name,Address__c,Position__c,Email,Phone
            FROM
                Contact
            WHERE
                AccountId = :ApexPages.currentPage().getParameters().get('id') LIMIT 3
        ];
        if (representatives.size() > 0) {
            req1Name = representatives.get(0).Name;
            req1Address = representatives.get(0).Address__c;
            req1Position = representatives.get(0).Position__c;
            req1Email = representatives.get(0).Email;
            req1Phone = representatives.get(0).Phone;
        }
        if (representatives.size() > 1) {
            req2Name = representatives.get(1).Name;
            req2Address = representatives.get(1).Address__c;
            req2Position = representatives.get(1).Position__c;
            req2Email = representatives.get(1).Email;
            req2Phone = representatives.get(1).Phone;
        }
        if (representatives.size() > 2) {
            req3Name = representatives.get(2).Name;
            req3Address = representatives.get(2).Address__c;
            req3Position = representatives.get(2).Position__c;
            req3Email = representatives.get(2).Email;
            req3Phone = representatives.get(2).Phone;
        }
    }

    public void setBankInfo() {
        customer = [
            SELECT
                Bank_Name__c,Branch__c,BSB__c,Account_Number__c
            FROM
                Account
            WHERE
                Id = :ApexPages.currentPage().getParameters().get('id')
        ];
        branch = customer.Bank_Name__c==null ? '' : customer.Bank_Name__c + '/' + customer.Branch__c==null ? '' : customer.Branch__c;
        bsb = customer.BSB__c==null ? '' : customer.BSB__c + '/' + customer.Account_Number__c==null ? '' : customer.Account_Number__c;
    }

    public void setTradeRef() {
        tradingRef = [
            SELECT
                Name,Accounts_Email_Address__c,State__c,Telephone__c
            FROM
                Trading_Reference__c
            WHERE
                Customer__c = :customer.id
        ];
    }
}