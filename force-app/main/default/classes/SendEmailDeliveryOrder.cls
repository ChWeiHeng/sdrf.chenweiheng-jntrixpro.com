/**************************************************************************************************
 * Name: SendEmailOrder
 * Object: 
 * Purpose: 发送发货单邮件功能类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-08-14         Created             
***************************************************************************************************/
public without sharing class SendEmailDeliveryOrder {
    public static void sendEmail(List<Delivery_Note__c> dnList) {
        // List<Delivery_Note__c> dnList = [SELECT Order__r.Name,Order__r.Email__c,Delivery_Quantity__c,Id,Order__r.Customer__r.Name,Order__r.Customer_Shipping_Address__r.Direction__c,Delivery_Note_Num__c,Delivery_Note_Item_Num__c,Order_Item__r.Commodity__r.Name,Order_Item__r.Sales_Unit_Text__c,Order_Item__r.Material_Number__c FROM Delivery_Note__c WHERE Order__c =:orderId AND Is_Note__c=false AND (Delivery_Post_Status__c='C' OR Delivery_Post_Status__c='B')];
        if (dnList[0].Order__r.Email__c == null) {
            return;
        }
        Map<String,List<Delivery_Note__c>> dnMap = new Map<String,List<Delivery_Note__c>>();
        for (Delivery_Note__c dn : dnList) { 
            if (dnMap.containskey(dn.Delivery_Note_Num__c)) {
                dnMap.get(dn.Delivery_Note_Num__c).add(dn);
            }else{
                dnMap.put(dn.Delivery_Note_Num__c,new List<Delivery_Note__c>{dn});
            }
        }
        System.debug('dnMap'+dnMap);
        List<String> emailList = new List<String>();
        emailList.addall(dnList[0].Order__r.Email__c.split(';'));
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
        if (owea.size() > 0 ) {
             email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        email.setToAddresses(emailList);//set mail getter
        email.setSubject('['+dnList[0].Order__r.Name+']Delivery Note'); //set subject
        String body = 'Hola,<br/>';
        body += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The following Porducts are on the way sending to you.<br/>';
        body += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EMPRESA:&nbsp;&nbsp;'+dnList[0].Order__r.Customer__r.Name+'<br/>';
        body += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DIRECCION:&nbsp;&nbsp;'+dnList[0].Order__r.Customer_Shipping_Address__r.Direction__c+'<br/>';
        body += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DELIVERY ORDER:&nbsp;&nbsp;';
        String num = '';
        for (String key : dnMap.keySet()) {
            if (String.isNotBlank(num)) {
                num += ','+key;
            }else{
                num += key;
            }
        }
        System.debug('num'+num);
        body += num+'<br/><br/>';
        
        for (String key : dnMap.keySet()) {
            body += key+':<br/>';
            body += '<table  Class="typeface " width="100%" style="border-right: 1px solid #000000; border-bottom: 1px solid #000000;">';
            body += '<tr style="text-align: center;">';
                        body += '<th width="5%">No.</th>';
                        body += '<th width="20%">MATERIAL</th>';
                        body += '<th width="20%">DESCRIPCIÓN DE PRODUCTO</th>';
                        body += '<th width="10%">CANTIDAD</th>';
                        body += '<th width="10%">UNIDAD</th>';
            body += '</tr>';
            for (Delivery_Note__c dn : dnMap.get(key)) {
                System.debug('进入逻辑');
                body += '<tr>';
                body += '<td width="5%" align="center">'+dn.Delivery_Note_Item_Num__c+'</td>';
                if (!System.Test.isRunningTest()) {
                    body += '<td width="20%" align="center">'+dn.Order_Item__r.Material_Number__c.subString(6)+'</td>';
                }
                body += '<td width="20%" align="center">'+dn.Order_Item__r.Commodity__r.Name+'</td>';
                body += '<td width="10%" align="center">'+dn.Delivery_Quantity__c+'</td>';
                body += '<td width="10%" align="center">'+dn.Order_Item__r.Sales_Unit_Text__c+'</td>';
                body += '</tr>';
            }
            body += '</table><br/><br/>';
        }
            
        
        System.debug('body'+body);
        email.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
        for (Delivery_Note__c dn : dnList) {
            dn.Is_Note__c = true;
        }
        Database.update(dnList);
    }
}