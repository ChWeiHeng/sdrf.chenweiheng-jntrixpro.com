global without sharing class SetDataBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String query;
    public Integer index;
    global SetDataBatch(Integer index) {
        this.index = index;
        if (index==1) {
            this.query = 'SELECT Id,Billing_Num__c,Billing_Status__c FROM Billing__c';
        }else{
            this.query = 'SELECT Id,Invoice_Number__c FROM Account_Receivable__c';
        }
        
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> orderList) {
        if (this.index==1) {
            List<Billing__c> udpateB = new List<Billing__c>();
            List<Invoice__c> udpateI = new List<Invoice__c>();
            List<Billing__c> bList = (List<Billing__c>)orderList;
            for (Billing__c b : bList) {
                Invoice__c inv = new Invoice__c();
                inv.External_Id__c = b.Billing_Num__c;
                b.Invoice__r = inv;
                udpateB.add(b);

                // if (b.Billing_Status__c=='E') {
                //     Invoice__c ui = new Invoice__c();
                //     ui.External_Id__c = b.Billing_Num__c;
                //     ui.Invoice_Status__c = 'E';
                //     udpateI.add(ui);
                // }
            }

            if (udpateI.size()>0) {
                Database.upsert(udpateI,Invoice__c.fields.External_Id__c, true);
            }

            if (udpateB.size()>0) {
                update udpateB;
            }
        }
        
        if (this.index==2) {
            List<Account_Receivable__c> udpatea = new List<Account_Receivable__c>();
            List<Account_Receivable__c> bList = (List<Account_Receivable__c>)orderList;
            for (Account_Receivable__c b : bList) {
                if (b.Invoice_Number__c == null) {
                    continue;
                }
                Invoice__c inv = new Invoice__c();
                inv.External_Id__c = b.Invoice_Number__c;
                b.Invoice__r = inv;
                udpatea.add(b);
            }
            if (udpatea.size()>0) {
                update udpatea;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        Integer i = this.index+1;
        if (i<=2) {
            Database.executeBatch(new SetDataBatch(i));
        }
    }
}