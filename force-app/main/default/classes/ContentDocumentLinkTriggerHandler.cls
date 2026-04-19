public without sharing class ContentDocumentLinkTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isAfter && Trigger.isInsert)
        {
            //上传客户签字版合同后更新合同是否已上传附件字段
            /*Set<Id> linkedEntityIdSet = new Set<Id>();
            List<Contracts__c> updateContractList=new List<Contracts__c>();
            for (ContentDocumentLink cdl : (List<ContentDocumentLink>)Trigger.new) {
			if (cdl.LinkedEntityId.getSobjectType() == Schema.Contracts__c.getSobjectType()){
				linkedEntityIdSet.add(cdl.LinkedEntityId);
			}
            }
            system.debug('linkedEntityIdSet=>'+linkedEntityIdSet);
            for (Contracts__c con : [SELECT Id  FROM Contracts__c WHERE Id IN: linkedEntityIdSet AND Is_Upload_Attachment__c=false]) 
            {
                Contracts__c updateContract=new Contracts__c();
                updateContract.Id=con.Id;
                updateContract.Is_Upload_Attachment__c=true;
                updateContractList.add(updateContract);
            }
            system.debug('updateContractList=>'+updateContractList);
            if(updateContractList.size()>0)
            {
                update updateContractList;
            }*/

            //上传客户签字版合同后更新订单是否已上传附件字段
            Set<Id> linkedEntityIdSet = new Set<Id>();
            Set<Id> linkedEntityAccIdSet = new Set<Id>();
            Set<Id> linkedEntityDeliveryNumSet = new Set<Id>();
            List<Order__c> updateOrderList=new List<Order__c>();
            List<Account> updateAccList=new List<Account>();
            List<DeliveryNumber__c> updateDeliveryNumList = new List<DeliveryNumber__c>();
            for (ContentDocumentLink cdl : (List<ContentDocumentLink>)Trigger.new) {
                if (cdl.LinkedEntityId.getSobjectType() == Schema.Order__c.getSobjectType()){
                    linkedEntityIdSet.add(cdl.LinkedEntityId);
                }
                if (cdl.LinkedEntityId.getSobjectType() == Schema.Account.getSobjectType()){
                    linkedEntityAccIdSet.add(cdl.LinkedEntityId);
                }
                if (cdl.LinkedEntityId.getSobjectType() == Schema.DeliveryNumber__c.getSobjectType()) {
                    linkedEntityDeliveryNumSet.add(cdl.LinkedEntityId);
                }
            }
            system.debug('linkedEntityIdSet=>'+linkedEntityIdSet);
            system.debug('linkedEntityAccIdSet=>'+linkedEntityAccIdSet);
            for (Order__c ord : [SELECT Id  FROM Order__c WHERE Id IN: linkedEntityIdSet AND Is_Upload_Attachment__c=false]) 
            {
                Order__c updateOrder=new Order__c();
                updateOrder.Id=ord.Id;
                updateOrder.Is_Upload_Attachment__c=true;
                updateOrderList.add(updateOrder);
            }
            system.debug('updateOrderList=>'+updateOrderList);
            if(updateOrderList.size()>0)
            {
                update updateOrderList;
            }
            for (Account acc : [SELECT Id  FROM Account WHERE Id IN: linkedEntityAccIdSet AND Is_Upload_Attachment__c=false]) 
            {
                Account updateAcc=new Account();
                updateAcc.Id=acc.Id;
                updateAcc.Is_Upload_Attachment__c=true;
                updateAccList.add(updateAcc);
            }
            system.debug('updateAccList=>'+updateAccList);
            if(updateAccList.size()>0)
            {
                update updateAccList;
            }
            for (DeliveryNumber__c dNum : [SELECT Id  FROM DeliveryNumber__c WHERE Id IN: linkedEntityDeliveryNumSet AND Is_Invoice_Uploaded__c=false]) {
                DeliveryNumber__c updateDeliveryNum=new DeliveryNumber__c();
                updateDeliveryNum.Id=dNum.Id;
                updateDeliveryNum.Is_Invoice_Uploaded__c=true;
                updateDeliveryNumList.add(updateDeliveryNum);
            }
            system.debug('updateDeliveryNumList=>'+updateDeliveryNumList);
            if(updateDeliveryNumList.size()>0)
            {
                update updateDeliveryNumList;
            }
        }

    }
}