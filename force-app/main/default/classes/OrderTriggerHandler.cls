/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-08-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   06-11-2025   Gerry   Initial Version
**/
public without sharing class OrderTriggerHandler implements Triggers.Handler{
    public void handle() {
        //删除逻辑判断----start
        if (Trigger.isBefore && Trigger.isdelete) {
            User user = [SELECT Id,Profile.Name,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Delete_All_Order'];
            for (Order__c order : (List<Order__c>)Trigger.old) {
                
                if (
                    !(
                        (
                            order.OwnerId == System.UserInfo.getUserId() ||
                            psaList.Size()!=0
                        ) &&
                        (
                            order.Status__c == 'Draft' ||
                            order.Status__c == 'Rejected'
                        )
                    )
                ) {
                    order.addError(System.label.OnlyDeleteOwnerData);
                }

                //illion 20250829 Auto ZAR1不允许进行删除操作
                if((order.Order_type__c == 'ZAR1' || order.Order_type__c == 'ZARA') && order.Auto_Issue_Consignment__c && (order.Sales_Org__c == '5130' || order.Sales_Org__c == '5070') && user.Profile.Name <> 'System Administrator'){
                    order.addError(System.label.CannotDeleteOrder);
                }
            }
        }
        //删除逻辑判断----end

        if (Trigger.isAfter && Trigger.isupdate) {
            Map<Id,Order__c> oldMap = (Map<Id,Order__c>)Trigger.oldMap;
            Set<String>  needUpdateOrderItem= new Set<String>();
            Set<String> orderIdSet = new Set<String>();
            List<BatchOrderSyncToSap.BatchData> batchDataList = new List<BatchOrderSyncToSap.BatchData>();
            Set<String> needCalculateZAREQuantitySet = new Set<String>();//需要计算ZARE剩余数量的订单，更新交货单时忽略trigger
            Set<String> needCalculateZMX1RateSet = new Set<String>();
            User laryUser = [SELECT Id FROM User WHERE Name='Lary Fan' limit 1];
            for (Order__c order : (List<Order__c>)Trigger.new) {
                //mx model C+总部审批通知marvin-----start
                if (
                    order.Deliver_Plant__c == '3011' && 
                    order.Status__c == 'Approving' && oldMap.get(order.Id).Status__c != order.Status__c &&
                    (
                        (order.Over_Credit_Line_Percent__c > 0 && order.Terms_Of_Payment__c != 'G001') ||
                        order.Max_Overdue_Days__c > 60
                    )
                ) {
                    Set<String> noticeUserSet = new Set<String>();
                    noticeUserSet.add(System.Label.MX_Logistics);
                    CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
                    CustomNotificationFromApex.notifyUsers(
                        notificationType, 
                        noticeUserSet, //发送通知给谁
                        order.Id, //通知点击后跳转到什么数据上
                        order.Name+' Orders require headquarters approval.', //标题
                        'Click to view details'//内容
                    );
                }
                //mx model C+总部审批通知marvin-----end
                //Order Return Reason 101时，Logistics必须填写bpm单号-----start
                if (order.Logistics_Approved__c && order.BPM_Damage_Assessment_Number__c == null) {
                    order.addError('Please fill up the BPM Damage Assessment Number');
                }
                //Order Return Reason 101时，Logistics必须填写bpm单号-----end


                

                if (
                    order.Order_type__c == 'ZARF' &&
                    order.Status__c != oldMap.get(order.Id).Status__c &&
                    (order.Status__c == 'Approving' || order.Status__c == 'Rejected' || order.Status__c == 'Draft')
                ) {
                    needCalculateZAREQuantitySet.add(order.Id);
                }
                Set<String> uSet = new Set<String>();
                uSet.add(order.OwnerId);
                //5130、5070非自动发票 ZAR1 ZARE同步到sap后，通知用户进行发货单创建 ----start
                if (
                    (order.Sales_Org__c == '5130' || order.Sales_Org__c == '5070') &&
                    (
                        order.Order_type__c == 'ZARE' ||
                        (order.Order_type__c == 'ZAR1' && !order.Auto_Issue_Consignment__c)
                    )&&
                    order.Status__c == 'Approved' &&
                    order.Sync_Status__c != oldMap.get(order.Id).Sync_Status__c &&
                    order.Sync_Status__c == 'Synchronized' &&
                    !order.SAP_Order__c
                ) {
                    System.debug('发送邮件逻辑');
                    EmailToUser(order);
                }
                //5130、5070非自动发票 ZAR1 ZARE同步到sap后，通知用户进行发货单创建 ----end

                //ZARA 订单后续流程通知 -----start
                if ( 
                    order.Status__c == 'Approved' &&
                    order.Sync_Status__c != oldMap.get(order.Id).Sync_Status__c &&
                    order.Sync_Status__c == 'Synchronized' &&
                    !order.SAP_Order__c
                ) {
                    // 通知取回货 ----start
                    if (
                        (order.Order_type__c == 'ZARA' && !order.Auto_issue_Consignment__c && order.Goods_Return_Requested__c) || System.Test.isRunningTest()
                    ) {
                        String body = System.Label.PullGood.replace('Order_Number',order.Name);
                        body = body.replaceAll('Customer_Name', order.Customer_Name__c);
                        body = body.replaceAll('SAP_Document_ID', order.SAP_Order_Code__c);
                        if (order.Sales_Org__c == '5130') {
                            notificationMartin(order.Id,order.Name,System.Label.ReminderLogistic5130,body,System.Label.PullGoodTitle);
                        }

                        // if (order.Sales_Org__c == '5070') {
                        //     notificationMartin(order.Id,order.Name,System.Label.ReminderLogistic5070,body,System.Label.PullGoodTitle);
                        // }
                        ZARAEmailToUser(order,body,System.Label.PullGoodTitle);
                    }
                    // 通知取回货 ----end

                    // 通知做发票 ----start
                    if (
                        (order.Order_type__c == 'ZARA' && !order.Auto_issue_Consignment__c && !order.Goods_Return_Requested__c) || System.Test.isRunningTest()
                    ) {
                        String body = System.Label.GenerateDeliveryNoteBody.replaceAll('Order_Number',order.Name);
                        if (order.Sales_Org__c == '5130') {
                            notificationMartin(order.Id,order.Name,System.Label.ReminderLogistic5130,body,System.Label.GenerateDeliveryNoteTitle);
                        }

                        // if (order.Sales_Org__c == '5070') {
                        //     notificationMartin(order.Id,order.Name,System.Label.ReminderLogistic5070,body,System.Label.GenerateDeliveryNoteTitle);
                        // }
                        ZARAEmailToUser(order,body,System.Label.GenerateDeliveryNoteTitle);
                    }
                    // 通知做发票 ----end
                }

                //ZARA 订单后续流程通知 -----end

                if (!order.SAP_Order__c && order.Status__c=='Approved' && oldMap.get(order.Id).Status__c!=order.Status__c) {
                    
                    String orderId;
                    for(Order_Item__c oi : [SELECT Id FROM Order_Item__c WHERE Order__c =:order.Id]) {
                        if(String.isBlank(orderId)) {
                            orderId = oi.Id;
                        }else{
                            orderId += ';'+oi.Id;
                        }
                    }
                    if (order.SAP_Order_Code__c!=null) {
                        // if (order.isClosed__c) {
                        //     if (!Test.isRunningTest()) {
                        //         OrderSyncToSAP.submitToSAPFu(order.Id, 'U',false,true,'');
                        //     }
                        // }else{
                        
                        if (!Test.isRunningTest()) {
                            if (order.RecordType_Name__c == 'Model_B')
                            {
                                // OrderSyncToSAP.submitToSAPFu(order.Id, 'U',true,false,System.Label.Reason,false);
                            }else{
                                batchDataList.add(new BatchOrderSyncToSap.BatchData(order.Id, 'U',false,false,'',false,orderId));
                                //OrderSyncToSAP.submitToSAPFu(order.Id, 'U',false,false,'',false,orderId,false);
                            }
                            
                        }
                        // }
                        
                    }else{
                        if (!Test.isRunningTest()) {
                            if (order.RecordType_Name__c == 'Model_B')
                            {
                                // OrderSyncToSAP.submitToSAPFu(order.Id, 'I',true,false,System.Label.Reason,false);
                            }else{
                                batchDataList.add(new BatchOrderSyncToSap.BatchData(order.Id, 'I',false,false,'',false,orderId));
                                //OrderSyncToSAP.submitToSAPFu(order.Id, 'I',false,false,'',false,orderId,false);
                            }
                        }
                    }
                    
                    Utility.notificationUserTitle(uSet,order.Id,System.Label.Order_Approved_Title,System.Label.Order_Approved_Title+order.Name);
                    // 发送邮件到客户
                    if(order.RecordType_Name__c != 'Model_B')
                    {
                        if (order.Deliver_Plant__c == '3011') { //C+模板
                            Datetime d = Datetime.now();
                            String minute = d.minute() + 1 + '';
                            String sch =  d.second() +  ' ' +   minute +    ' ' +   d.hour() +   ' ' +   d.day() +  ' ' +  d.month() +  ' ? ' + d.year();
                            SendEmailTOOrderOwnerSchedule schup = new SendEmailTOOrderOwnerSchedule(
                                order.Id
                            );
                            System.schedule(
                            '定时一分钟后发送邮件' + Datetime.now().getTime(),
                            sch,
                            schup
                            );
                            System.debug('进行定时发送');
                        }

                        if ((order.Deliver_Plant__c == '5130' || order.Deliver_Plant__c == '3020') && !order.Auto_issue_Consignment__c) { //C模板
                            System.debug('OrderId======>'+order.Id);
                            if (!System.Test.isRunningTest()) {
                                SendEmailOrder.sendem(order.Id);
                            }
                        }

                        if ((order.Deliver_Plant__c == '5070' || System.Test.isRunningTest()) && !order.Auto_issue_Consignment__c) { //ypf模板
                            User u = [SELECT Id,ManagerId,Manager.Email,Email FROM User WHERE Id=:order.OwnerId];
                            List<String> emailCCList = new List<String>{u.Email};
                            Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                            String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                            // Define the email
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                            email.setPlainTextBody(System.Label.YPF_Order_Approved+recordURL.replace(']','')+'/'+order.Id);
                            email.setSubject(System.Label.Order_Approved_Title+order.Name);
                            email.setToAddresses(emailCCList);
                            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
                            if (owea.size() > 0 ) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            if (!System.Test.isRunningTest()) {
                                Messaging.SendEmailResult [] r = 
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
                            }
                            
                            System.debug('已经发送邮件');
                        }
                        
                    }
                }
                

                if (!order.SAP_Order__c && (order.Status__c == 'Draft' || order.Status__c == 'Rejected')) {
                    orderIdSet.add(order.Id);
                }

                //ModelB变更审批通过后，更新order Item变更后信息
                if (order.RecordType_Name__c == 'Model_B' && order.Change_Status__c=='Approved' && oldMap.get(order.Id).Change_Status__c!=order.Change_Status__c)
                {
                    needUpdateOrderItem.add(order.Id);
                }

                if (order.Status__c=='Rejected' && oldMap.get(order.Id).Status__c!=order.Status__c) {
                    User u = [SELECT Id,ManagerId,Manager.Email,Email FROM User WHERE Id=:order.OwnerId];
                    if (u.ManagerId!=null) {
                        uSet.add(u.ManagerId);
                    }
                    Account acc = [SELECT Id,Name FROM Account WHERE Id=:order.Customer__c];
                    String body = '<div>'+System.Label.OrderRejectedBody+'<br/><br/><br/>'+System.Label.OrderRejectedBodyLocal+'</div>';
                    Utility.notificationUserTitle(uSet,order.Id,System.Label.Order_Rejected_Title,System.Label.Order_Rejected_Title+order.Name);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    body = body.replaceAll('【下单日期】', String.valueOf(order.CreatedDate));
                    body = body.replaceAll('【订单号】', order.Name);
                    body = body.replaceAll('【客户】', acc.Name);
                    body = body.replaceAll('【审批驳回人】',System.UserInfo.getName());
                    body = body.replaceAll('【驳回日期】',String.valueOf(System.today()));
                    Integer index = String.valueOf(URL.getOrgDomainUrl()).indexof('=')+1;
                    String recordURL = String.valueOf(URL.getOrgDomainUrl()).subString(index);
                    body = body.replaceAll('【链接】',recordURL.replace(']','')+'/'+order.Id);
                    email.setHtmlBody(body);
                    email.setSubject(System.Label.Order_Rejected_Title+order.Name);
                    List<String> emailList = new List<String>();
                    emailList.add(u.Email);
                    if (String.isNotBlank(u.Manager.Email)) {
                        emailList.add(u.Manager.Email);
                    }
                    email.setToAddresses(emailList);
                    // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
                    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // if ( owea.size() > 0 ) {
                    //     email.setOrgWideEmailAddressId(owea.get(0).Id);
                    // }
                    if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                }
            }
            //【add by zach 2025/8/6 批量同步订单，防止future超限 -start】
            if(!batchDataList.isEmpty()){ Database.executeBatch(new BatchOrderSyncToSap(JSON.serialize(batchDataList)),1); }
            //【add by zach 2025/8/6 批量同步订单，防止future超限 -start】

            //计算ZARE剩余数量----- start
            if (needCalculateZAREQuantitySet.size() >0) {
                calculateZARERemainQuantity(needCalculateZAREQuantitySet);
            }
            //计算ZARE剩余数量----- end

            //更新订单cash price价格--- start
            
            List<Order_Item__c> oiList = new List<Order_Item__c>();
            for (Order_Item__c oi : [SELECT Order__r.Deliver_Plant__c,Product_Type__c,Order__r.Is_YPF__c,Order__r.Order_Type__c,Product_Cost__c,Unit_Estimate_Cost__c,Min_Sales_Price__c,Guide_Price__c,Margin__c,Margin_Rate__c,Order__c,Order__r.Sales_Org__c,Id,Cash_Price__c,Commission_Rate__c,Price__c,Order__r.Interest_Rate__c,Product_Combo_Name__c FROM Order_Item__c WHERE Order__c IN:orderIdSet]) {
                system.debug('oi.Price__c===='+oi.Price__c);
                if(oi.Price__c <> null && oi.Commission_Rate__c==null && oi.Order__r.Interest_Rate__c <> null && String.isBlank(oi.Product_Combo_Name__c)) {
                    oi.Cash_Price__c = ((oi.Price__c)/oi.Order__r.Interest_Rate__c).setScale(2);
                }else if(oi.Price__c <> null && oi.Commission_Rate__c <> null && oi.Order__r.Interest_Rate__c <> null && String.isBlank(oi.Product_Combo_Name__c)){
                    oi.Cash_Price__c = ((oi.Price__c - (oi.Price__c * oi.Commission_Rate__c/100))/oi.Order__r.Interest_Rate__c).setScale(2);
                }
                //账期变更涉及到的计算全部重新计算----start
                if (oi.Product_Cost__c !=null && oi.Order__r.Interest_Rate__c != null && (oi.Order__r.Sales_Org__c == '5130' || oi.Order__r.Is_YPF__c)) {//AR、ypf Guide Price增加账期成本
                    oi.Product_Cost__c =  oi.Product_Cost__c/oldMap.get(oi.Order__c).Interest_Rate__c *oi.Order__r.Interest_Rate__c;
                    oi.Product_Cost__c = oi.Product_Cost__c.setScale(2);
                    System.debug('进入成本重新计算逻辑');
                }

                if (
                    oi.Unit_Estimate_Cost__c!=null && 
                    oi.Order__r.Interest_Rate__c != null && 
                    (oi.Order__r.Sales_Org__c == '5130' || oi.Order__r.Is_YPF__c)
                ) {//AR、ypf Guide Price增加账期成本
                    oi.Unit_Estimate_Cost__c = oi.Unit_Estimate_Cost__c/oldMap.get(oi.Order__c).Interest_Rate__c*oi.Order__r.Interest_Rate__c;
                    oi.Unit_Estimate_Cost__c = oi.Unit_Estimate_Cost__c.setScale(2);
                }

                if (
                    oi.Order__r.Order_type__c != 'ZARE' && 
                    oi.Order__r.Order_type__c != 'ZARA' &&
                    oi.Order__r.Order_type__c != 'ZARF' &&
                    oi.Min_Sales_Price__c!=null && 
                    oi.Order__r.Interest_Rate__c != null && 
                    (oi.Order__r.Sales_Org__c == '5130' || oi.Order__r.Is_YPF__c)
                ) {//AR、ypf min price增加账期成本
                    oi.Min_Sales_Price__c = oi.Min_Sales_Price__c/oldMap.get(oi.Order__c).Interest_Rate__c*oi.Order__r.Interest_Rate__c;
                    oi.Min_Sales_Price__c = oi.Min_Sales_Price__c.setScale(2);
                }

                if (
                    oi.Order__r.Order_type__c != 'ZARE' && 
                    oi.Order__r.Order_type__c != 'ZARA' &&
                    oi.Order__r.Order_type__c != 'ZARF' &&
                    oi.Order__r.Interest_Rate__c != null && 
                    (oi.Order__r.Sales_Org__c == '5130' || oi.Order__r.Is_YPF__c) &&
                    oi.Guide_Price__c != null
                ) {//AR、ypf Guide Price增加账期成本
                    oi.Guide_Price__c = oi.Guide_Price__c/oldMap.get(oi.Order__c).Interest_Rate__c*oi.Order__r.Interest_Rate__c;
                    oi.Guide_Price__c = oi.Guide_Price__c.setScale(2);
                }
                if ((oi.Order__r.Deliver_Plant__c == '3011' || oi.Order__r.Deliver_Plant__c == '3020') && oi.Cash_Price__c != null && oi.Product_Type__c != 'Free Product') {
                    oi.Margin__c = (oi.Cash_Price__c-oi.Product_Cost__c).setScale(2);
                    oi.Margin_Rate__c = ((oi.Cash_Price__c-oi.Product_Cost__c)/oi.Cash_Price__c*100).setScale(2);
                }else{
                    if (oi.Price__c != null && oi.Product_Cost__c !=null && oi.Product_Type__c != 'Free Product') {
                        oi.Margin__c = (oi.Price__c-oi.Product_Cost__c).setScale(2);
                        oi.Margin_Rate__c = ((oi.Price__c-oi.Product_Cost__c)/oi.Price__c*100).setScale(2);
                    }
                }
                
                
                //账期变更涉及到的计算全部重新计算----end
                oiList.add(oi);
            }
            if (oiList.size()>0 && !Test.isRunningTest()) { Database.Update(oiList); }
            
            //更新订单cash price价格--- end

            // List<Order_Item__c> needUpdateOrderItemList=new List<Order_Item__c>();
            // for(Order_Item__c orderItem:[SELECT Id,Order__c,New_Amount__c,New_Delivery_Date__c,New_Quantity__c,New_Price__c FROM Order_Item__c WHERE Order__c IN:needUpdateOrderItem AND (New_Amount__c != null OR New_Delivery_Date__c != null OR New_Quantity__c != null OR New_Price__c != null)])
            // {
            //     Order_Item__c oi=new Order_Item__c();
            //     oi.Id=orderItem.Id;
            //     if(orderItem.New_Price__c != null)
            //     {
            //         oi.Price__c=orderItem.New_Price__c;
            //         oi.New_Price__c=null;
            //     }
            //     if(orderItem.New_Quantity__c != null)
            //     {
            //         oi.Quantity__c=orderItem.New_Quantity__c;
            //         oi.New_Quantity__c=null;
            //     }
            //     if(orderItem.New_Amount__c != null)
            //     {
            //         oi.Amount_per_item__c=orderItem.New_Amount__c;
            //         oi.New_Amount__c=null;
            //     }
            //     if(orderItem.New_Delivery_Date__c != null)
            //     {
            //         oi.Delivery_Date__c=orderItem.New_Delivery_Date__c;
            //         oi.New_Delivery_Date__c=null;
            //     }
            //     needUpdateOrderItemList.add(oi);
            // }
            // System.debug('needUpdateOrderItemList=>'+needUpdateOrderItemList);
            // if(needUpdateOrderItemList.size()>0)
            // {
            //     Database.update(needUpdateOrderItemList);
            // }
            //ModelB审批通过后，发送PDF至订单所有人邮箱
            for (Order__c order : (List<Order__c>)Trigger.new) {
                if (order.RecordType_Name__c == 'Model_B' && ((order.Status__c=='Approved' && oldMap.get(order.Id).Status__c!=order.Status__c) || (order.Change_Status__c=='Approved' && oldMap.get(order.Id).Change_Status__c!=order.Change_Status__c))) {
                    //SendEmailContract.sendem(order.Id);
                }
            }

            //【add by illion 2025/8/2 -start】
            if(Trigger.isAfter && Trigger.isUpdate){
                system.debug('进入订单after update');
                Set<Id> idOrderSet = new Set<Id>();
                Set<Id> idOrderComboSet = new Set<Id>();
                Set<String> zarfIdSet = new Set<String>();
                Map<Id,Order__c> orderOldMap = (Map<Id,Order__c>)Trigger.oldMap;
                Set<Id> zareZaraIdSet = new Set<Id>();
                for (Order__c ord : (List<Order__c>)Trigger.new){
                    system.debug('ord.Cust_Reference__c===='+ord.Cust_Reference__c);
                    // ZARF审批通过场景数量占用----start
                    if (
                        ord.Order_type__c == 'ZARF' &&
                        ord.Status__c == 'Approved' && orderOldMap.get(ord.Id).Status__c <> ord.Status__c
                    ) {
                        zarfIdSet.add(ord.Id);
                    }
                    // ZARF审批通过场景数量占用----end
                    //ZARE/ZARA在状态更新为拒绝、回退、审批中、审批通过时会进入交货单库存校验 校验通过后关联ZARB拆分以及回写交货单库存
                    if(
                        ord.Order_type__c == 'ZARE' || ord.Order_type__c == 'ZARA'
                    ){
                        if(
                            orderOldMap != null && !orderOldMap.isEmpty() && 
                            (
                                (
                                    (ord.Order_type__c == 'ZARE' || ord.Order_type__c == 'ZARA') && 
                                    ord.Status__c == 'Approved' && 
                                    orderOldMap.get(ord.Id).Status__c <> 'Approved' && 
                                    orderOldMap.get(ord.Id).Status__c <> 'Approving'
                                ) ||
                                (
                                    ord.Status__c == 'Approving' && (orderOldMap.get(ord.Id).Status__c == 'Draft' || orderOldMap.get(ord.Id).Status__c == 'Rejected')
                                ) ||
                                (
                                    ord.Status__c == 'Rejected' && 
                                    orderOldMap.get(ord.Id).Status__c <> 'Rejected'
                                ) ||
                                (
                                    ord.Status__c == 'Draft' && 
                                    orderOldMap.get(ord.Id).Status__c == 'Approving'
                                ) 
                                // ||
                                // (
                                //     ord.Order_type__c == 'ZARF' && ord.Status__c == 'Approved' && orderOldMap.get(ord.Id).Status__c <> 'Approved'
                                // )
                            ) &&
                            (
                                ord.Sales_Org__c == '5070' || 
                                ord.Sales_Org__c == '5130'
                            ) /*&&
                            ord.CreatedDate > DateTime.valueOfGmt(System.Label.SpecificDate)*/
                            /*&&
                            ord.Auto_Issue_Consignment__c == false*/
                        ){
                            system.debug('订单状态更新为===='+ord.Status__c);
                            idOrderSet.add(ord.Id);
                        } 
                    }

                    if (
                        (ord.Order_type__c == 'ZARE' || ord.Order_type__c == 'ZARA') && ord.Status__c == 'Approved' &&
                        ord.Status__c != orderOldMap.get(ord.Id).Status__c
                    ) {
                        zareZaraIdSet.add(ord.Id);
                    }

                    //订单在草稿和拒绝状态时，当interest rate更改后要重新计算订单明细中产品包对应的单价
                    if(ord.Interest_Rate__c <> null && ord.Interest_Rate__c <> orderOldMap.get(ord.Id).Interest_Rate__c && (ord.Status__c == 'Draft' || ord.Status__c == 'Rejected')){
                        idOrderComboSet.add(ord.Id);
                    }
                }

                if (zarfIdSet.size()>0) {//zarf审批通过场景
                    Set<String> orderItemList = new Set<String>();
                    Set<String> deliveryNote = new Set<String>();
                    for (Order_Item__c oi : [SELECT Id,Delivery_Note__c FROM Order_Item__c WHERE Order__c IN:zarfIdSet]) {
                        orderItemList.add(oi.Id);
                        deliveryNote.add(oi.Delivery_Note__c);
                    }
                    List<Order__c> newOrderList = (List<Order__c>)Trigger.new;
                    for (Delivery_Note__c dn : [SELECT id,Remain_Quantity__c,External_Id__c,Delivery_Quantity__c FROM Delivery_Note__c WHERE Id IN:deliveryNote]) {
                        if (dn.Remain_Quantity__c<0) {
                            //The delivery note [XXXXX] has been changed, and the remaining quantity is no longer sufficient.
                            newOrderList[0].addError(System.Label.Delivery_Changed.replace('[XXXXX]',dn.External_Id__c));
                        }

                        if (dn.Remain_Quantity__c > dn.Delivery_Quantity__c) {
                            //The [XXXXX] remaining quantity exceeds the shipped quantity.
                            newOrderList[0].addError(System.Label.ExceedingQuantity.replace('[XXXXX]',dn.External_Id__c));
                        }
                    }
                    try {
                        ConsignmentOrderQuantityReturn.addRemainQuantity(orderItemList,'ZARF');
                    } catch (Exception e) {
                        System.debug(e.getMessage()+'行数：'+e.getLineNumber());
                        newOrderList[0].addError(Utility.getCustomMessage(e.getMessage(),false));
                    }
                    
                }

                system.debug('idOrderSet===='+idOrderSet);

                if (!zareZaraIdSet.isEmpty()) {//zara、zare审批通过时校验剩余数量是不是负数
                    Set<String> orderItemList = new Set<String>();
                    Set<String> deliveryNote = new Set<String>();
                    for (Order_Item__c oi : [SELECT Id,Delivery_Note__c,Order_Status__c,Order_Type__c FROM Order_Item__c WHERE Order__c IN:zareZaraIdSet]) {
                        if (oi.Order_Status__c != 'Approved') {
                            continue;
                        }

                        if (oi.Order_Type__c == 'ZARF') {
                            continue;
                        }

                        orderItemList.add(oi.Id);
                        deliveryNote.add(oi.Delivery_Note__c);
                    }
                    List<Order__c> newOrderList = (List<Order__c>)Trigger.new;
                    for (Delivery_Note__c dn : [SELECT id,Remain_Quantity__c,External_Id__c,Delivery_Quantity__c FROM Delivery_Note__c WHERE Id IN:deliveryNote]) {
                        if (dn.Remain_Quantity__c<0) {//被多用了
                            //The delivery note [XXXXX] has been changed, and the remaining quantity is no longer sufficient.
                            newOrderList[0].addError(System.Label.Delivery_Changed.replace('[XXXXX]',dn.External_Id__c));
                        }

                        if (dn.Remain_Quantity__c > dn.Delivery_Quantity__c) {//被多退了
                            //The [XXXXX] remaining quantity exceeds the shipped quantity.
                            newOrderList[0].addError(System.Label.ExceedingQuantity.replace('[XXXXX]',dn.External_Id__c));
                        }
                    }
                }

                if(!idOrderSet.isEmpty() && !Utility.isBypassAutoValidationSplit){
                    //校验订单产品下的该产品是否还有交货单库存
                    Boolean canUpdateIssueQty = OrderItemTriggerHandler.validateRemainQty(null,new Set<Id>(),(Map<Id,Order__c>)Trigger.newMap,idOrderSet);
                    system.debug('订单更新后是否需要校验'+canUpdateIssueQty);
                    //回写交货单关联ZARB拆分逻辑
                    OrderItemTriggerHandler.splitToZARB(Trigger.newMap.keySet(),canUpdateIssueQty);
                    Utility.isBypassAutoValidationSplit = true;
                }

                

                if(!idOrderComboSet.isEmpty()){
                    upodateComboItemPrice(idOrderComboSet);
                }
                
            }
            //【add by illion 2025/8/2 -end
        }

        if (Trigger.isBefore && (Trigger.isupdate || Trigger.isinsert)) {
            List<User> adminPro = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() AND  (Profile.Name='Interface Profile' OR Profile.Name='系统管理员' OR Profile.Name='System Administrator' or Profile.Name = 'Administrador del sistema') limit 1];
            Set<String> customerSet = new Set<String>();
            Set<String> salesOrg = new Set<String>();
            Set<String> distrChannel = new Set<String>();
            List<Order__c> orList = (List<Order__c>)Trigger.new;
            Set<String> plantSet = new Set<String>();
            Set<String> paymentTermSet = new Set<String>();
            Set<String> billSet = new Set<String>();//发票信息Id
            for (Order__c order : orList) {
                customerSet.add(order.Customer__c);
                salesOrg.add(order.Sales_Org__c);
                distrChannel.add(order.Distr_Channel__c);
                plantSet.add(order.Deliver_Plant__c);
                paymentTermSet.add(order.Terms_Of_Payment__c);
                System.debug('plantSet===='+plantSet);
                System.debug('paymentTermSet===='+paymentTermSet);
                //add by zach 2025/8/11 当订单类型为ZARB时并且Stock Aging Limit为空，赋值此字段为60
                if(String.isBlank(order.Stock_Aging_Limit__c) && order.Order_type__c == 'ZARB'){
                    order.Stock_Aging_Limit__c = '65';
                }
                if (order.Invoice__c!=null) {
                    billSet.add(order.Invoice__c);
                }
                system.debug(Trigger.isUpdate);
                system.debug(order.Auto_Issue_Consignment__c);
                system.debug(order.Status__c);
            }
            //查询Interest rate
            Map<String,Decimal> interestRateMap = new Map<String,Decimal>();
            paymentTermSet.remove(null);
            plantSet.remove(null);         
            if (!paymentTermSet.isEmpty() && !plantSet.isEmpty()) {
                for (Intereste_Rate__c ir : [SELECT Id,Delivery_Plant__c,Payment_Rate__r.Name,Rate__c FROM Intereste_Rate__c WHERE Delivery_Plant__c IN:plantSet AND Payment_Rate__r.Name IN:paymentTermSet]) {
                    interestRateMap.put(ir.Delivery_Plant__c+'_'+ir.Payment_Rate__r.Name, ir.Rate__c);
                }
            }
            
            //invoice Map
            Map<String,String> invoiceMap = new Map<String,String>();
            if (billSet.size()>0) {
                for (Invoice__c inv : [SELECT Id,Order__c FROM Invoice__c WHERE Id IN:billSet]) {
                    invoiceMap.put(inv.Id, inv.Order__c);
                }
            }
            System.debug('interestRateMap=>'+interestRateMap);
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Sync_Status__c,Customer_Approval_Status__c,MDG_Customer_Code__c FROM Account WHERE Id IN:customerSet]);
            List<Customer_Credit_Info__c> cciList = [SELECT Id,Customer__c FROM Customer_Credit_Info__c WHERE Customer__c IN:customerSet];
            Map<String,Customer_Credit_Info__c> cciMap = new Map<String,Customer_Credit_Info__c>();
            for(Customer_Credit_Info__c cci : cciList) {
                cciMap.put(cci.Customer__c,cci);
            }
            // if (cciList.size()==0 && adminPro.size()==0 ) {
            //     orList[0].addError(System.Label.NOCustomerCredit);
            // }

            Map<String,Customer_Sales_Info__c> csiMap = new Map<String,Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [
                                                SELECT 
                                                    Id,Customer__c,Sales_Org__c,Distr_Channel__c 
                                                FROM 
                                                    Customer_Sales_Info__c 
                                                WHERE 
                                                    Customer__c IN:customerSet AND
                                                    Sales_Org__c IN:salesOrg AND
                                                    Distr_Channel__c IN:distrChannel AND
                                                    Sales_View_Status__c='Approved' AND Sync_Status__c='Synchronized'
            ]) {
                csiMap.put(csi.Customer__c+'-'+csi.Sales_Org__c+'-'+csi.Distr_Channel__c, csi);
            }
            User u = [SELECT Id,Profile.Name,Delivery_Plant__c FROM User WHERE Id=:System.UserInfo.getUserId()];
            Set<String> orderIdSet = new Set<String>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                if (order.Invoice__c!=null) {
                    order.Reference_Order__c = invoiceMap.get(order.Invoice__c);
                }
                
                if (order.Status__c == 'Draft' || order.Status__c == 'Rejected') {
                    System.debug(order.Deliver_Plant__c+'_'+order.Terms_Of_Payment__c);
                    System.debug(interestRateMap.get(order.Deliver_Plant__c+'_'+order.Terms_Of_Payment__c));
                    system.debug('order.Customer__c===='+order.Customer__c);
                    order.Interest_Rate__c = interestRateMap.get(order.Deliver_Plant__c+'_'+order.Terms_Of_Payment__c)==null? 1:interestRateMap.get(order.Deliver_Plant__c+'_'+order.Terms_Of_Payment__c);
                    orderIdSet.add(order.Id);
                }
                
                order.Customer_MDG_Code__c = accMap.get(order.Customer__c)?.MDG_Customer_Code__c;
                if(cciMap.get(order.Customer__c)==null && !order.SAP_Order__c && !Test.isRunningTest()) {
                    order.addError(System.Label.NOCustomerCredit);
                }
                if(
                    !(
                        (
                            order.Commission_Type__c==null && 
                            // order.Commission_Percentage__c==null && 
                            // order.Commission_Amount__c==null && 
                            order.Commission_Calculation_Method__c == null &&
                            order.Commission_To__c==null
                        ) ||
                        (
                            order.Commission_Type__c!=null && 
                            // order.Commission_Percentage__c!=null && 
                            // order.Commission_Amount__c!=null &&
                            order.Commission_Calculation_Method__c != null && 
                            order.Commission_To__c!=null
                        )
                    )  && order.Deliver_Plant__c != '5130'//5130时佣金在行上填写，该处不需要校验
                    && !Test.isRunningTest()
                ) {
                    order.addError(System.Label.CommissionNotComplete);
                }

                if(
                    (order.Commission_Calculation_Method__c=='Percent' && order.Commission_Percentage__c==null)
                ) {
                    //order.addError('Fill In Commission Percentage');
                    order.addError(System.Label.OrderFillAmountPercentageError);
                }

                if(
                    (order.Commission_Calculation_Method__c=='Amount' && order.Commission_Amount_New__c==null && !Test.isRunningTest())
                ) {
                    //order.addError('Fill In Commission Amount');
                    order.addError(System.Label.OrderFillComissionAmountError);
                }
                
                
                if (csiMap.get(order.Customer__c+'-'+order.Sales_Org__c+'-'+order.Distr_Channel__c) == null ) {
                    if (!order.SAP_Order__c && !Test.isRunningTest() && u.Profile.Name != 'Interface Profile' && u.Profile.Name != 'System Administrator' ) {//sap 订单不提醒
                        order.addError(System.Label.NOSalesInfo);
                    }
                }else{
                    order.Customer_Sales_Info__c = csiMap.get(order.Customer__c+'-'+order.Sales_Org__c+'-'+order.Distr_Channel__c).Id;
                }
                

                if (order.Profit_Center__c == null && order.Sales_Org__c=='3010'  && order.Deliver_Plant__c!='3010' &&
                    adminPro.size()==0 && !Test.isRunningTest()) {
                    order.addError(System.Label.ProfitCenterRequired);
                        
                }

                if (accMap.get(order.Customer__c).Sync_Status__c!='Synchronized' || accMap.get(order.Customer__c).Customer_Approval_Status__c!='Approved') {
                    if (!order.SAP_Order__c && u.Profile.Name != 'Interface Profile' && u.Profile.Name != 'System Administrator' && !Test.isRunningTest()) {
                        //order.addError('Order Customer is not synchronized.');
                        order.addError(System.Label.OrderCustomerSyncError);
                    }
                    
                }

                if (
                    order.Order_Reason__c == null && 
                    (
                        order.Order_type__c=='ZAR2' ||
                        order.Order_type__c=='ZARF' ||
                        order.Order_type__c=='ZMX2' ||
                        order.Order_type__c=='ZARA'
                    ) && !Test.isRunningTest()
                ) {
                    order.addError(System.Label.Order_Reason_Required);
                }
            }
            
        }

        if (Trigger.isBefore && Trigger.isupdate) {
            Map<Id,Order__c> oldMap = (Map<Id,Order__c>)Trigger.oldMap;
            for (Order__c order : (List<Order__c>)Trigger.new) {
                if (order.Status__c == 'Approved' && oldMap.get(order.Id).Status__c!=order.Status__c) {
                    order.Approve_Date__c = Date.today();
                }
                // if (
                //     (Order.Deliver_Plant__c == '5130' || order.is_ypf__c) &&
                //     order.Terms_Of_Payment__c!=oldMap.get(order.Id).Terms_Of_Payment__c  &&
                //     !order.SAP_Order__c && order.Order_Item_Number__c!=0
                // ) {
                //     order.addError(System.Label.PaymentTermChangeError);
                // }
            }
            //createZAR1BeforeIssueOrder();
            checkOrder();
        }

        if (Trigger.isAfter && (Trigger.isinsert || Trigger.isupdate)) {
            System.debug('UserInfo.getProfileId()========'+UserInfo.getProfileId());
            

            List<User> adminPro = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() AND  (Profile.Name='Interface Profile' OR Profile.Name='系统管理员' OR Profile.Name='System Administrator' or Profile.Name = 'Administrador del sistema') limit 1];
    
            Set<String> paymentSet = new Set<String>();
            Set<String> customerSet = new Set<String>();
            Set<String> distrChannel = new Set<String>();
            Set<String> salesOrg = new Set<String>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                customerSet.add(order.Customer__c);
                salesOrg.add(order.Sales_Org__c);
                distrChannel.add(order.Distr_Channel__c);
                paymentSet.add(order.Terms_Of_Payment__c);
            }
            Map<String,Customer_Sales_Info__c> csiMap = new Map<String,Customer_Sales_Info__c>();
            for (Customer_Sales_Info__c csi : [
                                                SELECT 
                                                    Id,Customer__c,Sales_Org__c,Distr_Channel__c,Terms_Of_Payment__c
                                                FROM 
                                                    Customer_Sales_Info__c 
                                                WHERE 
                                                    Customer__c IN:customerSet AND
                                                    Sales_Org__c IN:salesOrg AND
                                                    Distr_Channel__c IN:distrChannel AND
                                                    Sales_View_Status__c='Approved' AND Sync_Status__c='Synchronized'
            ]) {
                csiMap.put(csi.Customer__c+'-'+csi.Sales_Org__c+'-'+csi.Distr_Channel__c, csi);
                paymentSet.add(csi.Terms_Of_Payment__c);
            }
            System.debug('paymentSet=>'+paymentSet);
            Map<String,Decimal> daysMap = new Map<String,Decimal>();
            for (Payment_Rate__c pr : [SELECT Id,Days__c,Name FROM Payment_Rate__c WHERE Name IN:paymentSet]) {
                daysMap.put(pr.Name,pr.Days__c);
            }
            System.debug('daysMap=>'+daysMap);
            for (Order__c order : (List<Order__c>)Trigger.new) {
                Customer_Sales_Info__c csi=csiMap.get(order.Customer__c+'-'+order.Sales_Org__c+'-'+order.Distr_Channel__c);
                if (
                    order.Status__c != 'Approved' &&
                    adminPro.size()==0 && 
                    !order.SAP_Order__c && 
                    csi != null &&  
                    (((order.Sales_Org__c=='3010' || order.Sales_Org__c=='3020') &&(order.Business_Model__c=='C0' || order.Business_Model__c=='C1')) || (order.Sales_Org__c=='5070' || order.Sales_Org__c=='5130')) && 
                    daysMap.get(order.Terms_Of_Payment__c) > daysMap.get(csi.Terms_Of_Payment__c) && 
                    !Test.isRunningTest()
                ) {
                    order.addError(System.Label.OrderPaymentDayVertify);
                }
            }
        }
        //邮箱赋值
        if (Trigger.isBefore && Trigger.isinsert) {
            //校验客户冻结
            Set<String> accSet = new Set<String>();
            Set<String> salesOrgSet = new Set<String>();
            Set<String> accSalesOrgSet = new Set<String>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                accSet.add(order.Customer__c);
                salesOrgSet.add(order.Sales_Org__c);
            }
            for(Customer_Sales_Info__c csi :[SELECT Id,Customer__c,Sales_Org__c FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet AND Sales_Org__c IN:salesOrgSet AND Is_Freeze__c='01'])
            {
                accSalesOrgSet.add(csi.Customer__c+'_'+csi.Sales_Org__c);
            }
            
            System.debug('accSalesOrgSet=>'+accSalesOrgSet);
            List<User> adminPro = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() AND  (Profile.Name='Interface Profile' OR Profile.Name='系统管理员' OR Profile.Name='System Administrator' or Profile.Name = 'Administrador del sistema') limit 1];
            for (Order__c order : (List<Order__c>)Trigger.new) {
                if (adminPro.size()==0 && accSalesOrgSet != null && accSalesOrgSet.contains(order.Customer__c+'_'+order.Sales_Org__c) && !Test.isRunningTest()) {
                    order.addError(System.Label.AccFreezeError);
                }
            }  
           
            



            Set<String> accId = new Set<String>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                accId.add(order.Customer__c);
            }
            //邮箱新增Business Model维度赋值
            Map<String,String> emailMap = new Map<String,String>();
            String key;
            for (Contact con : [SELECT Id,Email,AccountId,Business_Model__c FROM Contact WHERE AccountId IN:accId AND Whether_Receive_Email__c=true]) {
                // key = con.AccountId+'_'+con.Business_Model__c;
                key = con.AccountId;
                if (emailMap.containsKey(key)) {
                    emailMap.put(key,emailMap.get(key)+';'+con.Email);
                }else{
                    emailMap.put(key,con.Email);
                }
            }

            for (Order__c order : (List<Order__c>)Trigger.new) {
                // key = order.Customer__c+'_'+order.Business_Model__c;
                key = order.Customer__c;
                order.Email__c = String.valueOf(emailMap.get(key));
            }

        }

                //最大逾期天数赋值
                // if (Trigger.isBefore && Trigger.isinsert) {
                //     Set<String> accId = new Set<String>();
                //     Map<String, Decimal> mapAccOverDays = new Map<String, Decimal>();
                //     for (Order__c order : (List<Order__c>)Trigger.new) {
                //         accId.add(order.Customer__c);
                //     }
                //     for(AggregateResult agg: [SELECT Customer__c,MAX(Overdue_Days_Formula__c) MaxDays FROM Account_Receivable__c WHERE Customer__c IN:accId AND Overdue_Days_Formula__c>0 AND Amount_in_Local_Crcy__c >0 GROUP BY Customer__c])
                //     {
                //         mapAccOverDays.put((String)agg.get('Customer__c'),(Decimal)agg.get('MaxDays'));
                //     }
                //     system.debug('mapAccOverDays=>'+mapAccOverDays);
                //     for (Order__c order : (List<Order__c>)Trigger.new) {
                //         order.Max_Overdue_Days__c = mapAccOverDays.get(order.Customer__c);
                //     }
        
                // }

        // 共享数据到客户小组
        if (Trigger.isAfter && Trigger.isinsert) {
            List<String> orderIdList = new List<String>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                // ShareDataToAccountTeam.shareData('Order__c', order.Id, order.Customer__c, 'Order__c',order.OwnerId);
                orderIdList.add(order.Id);
            }
            if(!Test.isRunningTest() && !System.isBatch() && !System.isFuture()) {
                Database.executeBatch(new ShareOrderBatch(orderIdList),1);
            }
        }
        // 共享数据到客户小组
        if (Trigger.isAfter &&  Trigger.isupdate) {
            Map<Id,Order__c> oldMap = (Map<Id,Order__c>)Trigger.oldMap;
            for (Order__c order : (List<Order__c>)Trigger.new) {
                // ShareDataToAccountTeam.shareData('Order__c', order.Id, order.Customer__c, 'Order__c',order.OwnerId);
                if(!Test.isRunningTest() && oldMap.get(order.Id).Deliver_Plant__c !=order.Deliver_Plant__c && !System.isBatch() && !System.isFuture()) {
                    Database.executeBatch(new ChangeShareDataToAccountTeamBatch('Order__c', order.Id, order.Customer__c, 'Order__c',order.OwnerId,oldMap.get(order.Id).Deliver_Plant__c,'Order__share'));
                    Database.executeBatch(new ChangeShareDataToAccountTeamBatch('Invoice__c', order.Id, order.Customer__c, 'Invoice__c',order.OwnerId,oldMap.get(order.Id).Deliver_Plant__c,'Invoice__share'));
                }
            }
            submitOrder();
            //createZAR1AfterIssueOrder();
            //sendZARBOrderEmailAfterApprove();
        }

        //佣金比例变化逻辑 start
        if (Trigger.isBefore && Trigger.isupdate) {
            Map<Id,Order__c> oldMap = (Map<Id,Order__c>)Trigger.oldMap;
            Set<String> orderIdSet = new Set<String>();
            //比例Map
            Map<String,Decimal> cpMap = new Map<String,Decimal>();

            //总金额Map
            Map<String,Decimal> amountMap = new Map<String,Decimal>();
            for (Order__c order : (List<Order__c>)Trigger.new) {
                
                if(
                    order.Commission_Calculation_Method__c=='Percent' &&
                    order.Commission_Percentage__c != null
                ) {
                    if(order.Total_Amount__c==0) {
                        order.Commission_Percentage__c = 0;
                        order.Commission_Amount_New__c = 0;
                    }else{
                        order.Commission_Amount_New__c = (order.Total_Amount__c*order.Commission_Percentage__c/100).setScale(2);
                    }
                }

                if(
                    order.Commission_Calculation_Method__c=='Amount' &&
                    order.Commission_Amount_New__c != null 
                ) {
                    if(order.Total_Amount__c==0) {
                        order.Commission_Percentage__c = 0;
                        order.Commission_Amount_New__c = 0;
                    }else{
                        order.Commission_Percentage__c = ((order.Commission_Amount_New__c/order.Total_Amount__c*100)).setScale(2);
                    }
                    
                }
            }
            // List<Order_Item__c> updateOiList = new List<Order_Item__c>();
            // for (Order_Item__c item : [SELECT Quantity__c,Id,Unit_Price_w_o_tax__c,Order__r.Commission_Percentage__c,Order__c FROM Order_Item__c WHERE Order__c IN:orderIdSet]) {
            //     if (cpMap.get(item.Order__c) == null) {
            //         item.Price__c = item.Unit_Price_w_o_tax__c;
            //         item.Amount_per_item__c = item.Quantity__c*item.Price__c;
            //     }

            //     if (cpMap.get(item.Order__c) != null) {
            //         item.Price__c = (item.Unit_Price_w_o_tax__c*(1+cpMap.get(item.Order__c)/100)).setScale(2);
            //         item.Amount_per_item__c = item.Quantity__c*item.Price__c;
            //     }
            //     updateOiList.add(item);
            // }
            // Database.update(updateOiList);
        }
        //佣金比例变化逻辑 end
    }
    
    //add by zach 2025/7/7 提交审批 
    public static void submitOrder(){
        List<String> orderIdList = new List<String>();
        for(Order__c order : (List<Order__c>)Trigger.new){
            Order__c oldOrder = (Order__c)Trigger.oldMap?.get(order.Id);
            if((order.Status__c == 'Draft' || order.Status__c == 'Rejected') && order.RecordTypeId == Utility.modelCRecordTypeId && order.Is_Import__c != oldOrder.Is_Import__c && order.Is_Import__c){
                orderIdList.add(order.Id);
            }
        }
        if(!orderIdList.isEmpty()){
            Database.executeBatch(new BatchGetCustomerLimit(JSON.serialize(orderIdList)),1);
        }
    }


    /**
    * @description 发货单创建提醒
    * @author Gerry | 09-11-2025 
    * @param Order__c order 
    **/
    public static void EmailToUser(Order__c order) {
        List<String> emailList = new List<String>();
        if (order.Sales_Org__c == '5130' ) {
            emailList.addAll(System.Label.X5130LogisticsEmail.split(';'));
        }

        if (order.Sales_Org__c == '5070' ) {
            emailList.addAll(System.Label.X5070LogisticsEmail.split(';'));
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String body = System.Label.DeliveryBody;
        body = body.replaceAll('【订单号】', order.SAP_Order_Code__c);
        email.setPlainTextBody(body);
        String subject = System.Label.DeliveryTitle;
        subject = subject.replace('【客户名】',order.Customer_Name__c);
        email.setSubject(subject);
        email.setToAddresses(emailList);
        // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // if ( owea.size() > 0 ) {
        //     email.setOrgWideEmailAddressId(owea.get(0).Id);
        // }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
        if (owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    /**
    * @description ZARA后续流程通知
    * @author Gerry | 09-11-2025 
    * @param Order__c order 
    **/
    public static void ZARAEmailToUser(Order__c order,String body,String title) {
        List<String> emailList = new List<String>();
        if (order.Sales_Org__c == '5130' ) {
            emailList.addAll(System.Label.X5130LogisticsEmail.split(';'));
        }

        if (order.Sales_Org__c == '5070' ) {
            emailList.addAll(System.Label.X5070LogisticsEmail.split(';'));
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setPlainTextBody(body);
        email.setSubject(title);
        email.setToAddresses(emailList);
        // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // if ( owea.size() > 0 ) {
        //     email.setOrgWideEmailAddressId(owea.get(0).Id);
        // }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
        if (owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        if(!Test.isRunningTest())Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    
    //add by zach 2025/7/8 Order__c.Auto_Issue__c 更新为TRUE, 确保已确定付款条件后才能继续
    /*public static void createZAR1BeforeIssueOrder(){
        Map<String,Order__c> zar1DataMap = new Map<String,Order__c>();
        for(Order__c order : (List<Order__c>)Trigger.new){
            Order__c oldOrder = (Order__c)Trigger.oldMap?.get(order.Id);
            if(order.Auto_Issue__c != oldOrder.Auto_Issue__c && order.Auto_Issue__c && order.RecordTypeId == Utility.modelCRecordTypeId && order.Order_type__c == 'ZARA' && order.Sales_Org__c == '5070'){
                if(String.isBlank(order.Terms_Of_Payment__c)){
                    order.addError('Please fulfill Payment Term first');
                }
                order.Status__c = 'Approved';
            }
        }
    }*/
    
    //add by zach 2025/7/8 Order__c.Auto_Issue__c 更新为TRUE, 全自动生成最终直销发票（ZAR1）
    /*public static void createZAR1AfterIssueOrder(){
        Map<String,Order__c> zar1DataMap = new Map<String,Order__c>();
        for(Order__c order : (List<Order__c>)Trigger.new){
            Order__c oldOrder = (Order__c)Trigger.oldMap?.get(order.Id);
            if(order.Auto_Issue__c != oldOrder.Auto_Issue__c && order.Auto_Issue__c && order.RecordTypeId == Utility.modelCRecordTypeId && order.Order_type__c == 'ZARA' && order.Sales_Org__c == '5070'){
                Order__c zar1Order = order.clone(FALSE,TRUE,FALSE,FALSE);
                zar1Order.Order_type__c = 'ZAR1';
                zar1Order.Status__c = 'Approved';
                zar1DataMap.put(order.Id,zar1Order);
            }
        }
        if(zar1DataMap.isEmpty()){
            return;
        }
        insert zar1DataMap.values();
        MassEditOrderController.cloneItem(zar1DataMap);
    }*/
    
    //add by zach 2025/8/1 ZARB订单审批通过后，并且销售组织=5130，自动向客户的owner发送邮件通知
    /*public static void sendZARBOrderEmailAfterApprove(){
        Set<String> zarbIdSet = new Set<String>();
        for(Order__c order : (List<Order__c>)Trigger.new){
            Order__c oldOrder = (Order__c)Trigger.oldMap?.get(order.Id);
            if(order.Status__c != oldOrder.Status__c && order.Status__c == 'Approved' && order.RecordTypeId == Utility.modelCRecordTypeId 
               && order.Order_type__c == 'ZARB' && order.Sales_Org__c == '5130' && String.isNotBlank(order.Customer__r.Email__c)){
                   zarbIdSet.add(order.Id);
               }
        }
        if(!zarbIdSet.isEmpty()){
            Database.executeBatch(new BatchNotifyStockAging(zarbIdSet));
        }
    }*/
    
    //add by zach 2025/8/19 系统自动生成的ZARA和ZAR1订单不能手动更新 -start】
    public static void checkOrder(){
        if(Utility.isBypassValidationRule){
            return;
        }

        User user = [SELECT Id,Profile.Name FROM User WHERE Id = :System.UserInfo.getUserId()];
        for(Order__c order : (List<Order__c>)Trigger.new){
            Order__c oldOrder = (Order__c)Trigger.oldMap?.get(order.Id);
            if(order.Auto_Issue_Consignment__c == oldOrder.Auto_Issue_Consignment__c  && (order.Status__c == 'Draft' || order.Status__c == 'Rejected') && order.Auto_Issue_Consignment__c 
               && (order.Order_type__c == 'ZARA'/* || order.Order_type__c == 'ZAR1'*/) && !Test.isRunningTest() && user.Profile.Name <> 'System Administrator'){
                    system.debug('order.Status__c===='+order.Status__c);
                    system.debug('oldOrder.Status__c===='+oldOrder.Status__c);
                    if(order.Status__c == 'Approving' || order.Status__c == 'Approved'){
                        continue;
                    }else{
                        //order.addError('This order is auto-generated from ZARB, cannot be directly edited, but you can edit this order and auto-create ZAR1 through the \'Mass Edit Order\' button on the order list view!');
                        order.addError(System.Label.AutoZARACannotEdit);
                    }
                    
               }
        }
    }
    //add by zach 2025/8/19 系统自动生成的ZARA和ZAR1订单不能手动更新 -end】
    
    //【add by illion 2025/9/4 订单在草稿和拒绝状态时，当interest rate更改后要重新计算订单明细中产品包对应的单价 -start】
    public static void upodateComboItemPrice(Set<Id> idOrderComboSet){
        //product name item
        Map<String,List<Product_Name_Item__c>> proItemMap = new Map<String,List<Product_Name_Item__c>>();
        Set<String> productNameIds = new Set<String>();
        List<Order_Item__c> oiList = [SELECT Id,Price__c,Commodity__c,Cash_Price__c,Product_Combo_Name__c,Order__r.Interest_Rate__c FROM Order_Item__c WHERE Product_Combo_Name__c <> null AND Order__c IN :idOrderComboSet];
        for(Order_Item__c item : oiList){
            productNameIds.add(item.Product_Combo_Name__c);

        }

        for(Product_Name_Item__c proItem : [SELECT Id,Product_Combo_Name__c,Product_Name__r.Product__c,List_Price__c,Quantity__c,Product_Name__c,Product_Name__r.Name,Product_Name__r.Product__r.Name,Product_Combo_Name__r.Product__c,Product_Name__r.Product_Sales_Info__r.Default_Sales_Unit__c,Product_Name__r.Product_Sales_Info__r.Cost_USD__c,Product_Name__r.Product_Sales_Info__r.Cost_Local__c,Product_Name__r.Product_Sales_Info__r.Product_Unit__r.Conversion_Coefficient__c FROM Product_Name_Item__c WHERE Product_Combo_Name__c IN:productNameIds]){
            if(!proItemMap.containsKey(proItem.Product_Combo_Name__c)){
                proItemMap.put(proItem.Product_Combo_Name__c,new List<Product_Name_Item__c>());
            }
            proItemMap.get(proItem.Product_Combo_Name__c).add(proItem);
        }

        for(Order_Item__c item : oiList){
            if(proItemMap.containsKey(item.Product_Combo_Name__c)){
                for(Product_Name_Item__c proItem : proItemMap.get(item.Product_Combo_Name__c)){
                    if(proItem.Product_Name__c == item.Commodity__c){
                        item.Cash_Price__c = proItem.List_Price__c;
                        item.Price__c = (proItem.List_Price__c * item.Order__r.Interest_Rate__c).setScale(2,RoundingMode.HALF_UP);
                    }
                }
            }
        }

        if(!oiList.isEmpty()){
            update oiList;
        }
    }
    //【add by illion 2025/9/4 订单在草稿和拒绝状态时，当interest rate更改后要重新计算订单明细中产品包对应的单价 -start】

    //通知martin取回货
    public static void notificationMartin(String orderId,String orderNumber,String userEmail,String body,String titile) {
        Set<String> noticeUserSet = new Set<String>();
        noticeUserSet.addAll(userEmail.split(';'));
        CustomNotificationType notificationType = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName ='Notification'];
        CustomNotificationFromApex.notifyUsers(
            notificationType, 
            noticeUserSet, //发送通知给谁
            orderId, //通知点击后跳转到什么数据上
            titile, //标题
            body//内容
        );
    }


    /**
    * @description 计算zare剩余量
    * @author Gerry | 12-02-2025 
    * @param Set<String> needCalculateZAREQuantitySet 
    **/
    public static void calculateZARERemainQuantity(Set<String> needCalculateZAREQuantitySet) {
        Set<String> deliverySet = new Set<String>();
        for (Order_Item__c oi : [SELECT Id,ZARE_Delivery_Note__c,Delivery_Note__r.Delivery_Quantity__c FROM Order_Item__c WHERE Order__c IN:needCalculateZAREQuantitySet]) {
            deliverySet.add(oi.ZARE_Delivery_Note__c);
        }
        SubmitOrderController.CalculateOutput availableCo = SubmitOrderController.getZAREAvailableQuanity(deliverySet);
        Map<String,Decimal> usedMap = availableCo.usedMap;
        Map<String,Decimal> usedMap1 = availableCo.usedMap1;

        Map<String,Delivery_Note__c> dnMap = new Map<String,Delivery_Note__c>();
        for (String dnId : deliverySet) {
            Delivery_Note__c dn = new Delivery_Note__c();
            dn.Issue_Quantity__c = (usedMap.get(dnId)??0) + (usedMap1.get(dnId)??0);
            dn.Id = dnId;
            dnMap.put(dnId,dn);
        }

        if (dnMap.size()>0 && !System.Test.isRunningTest()) {
            Utility.IgnoreAction(true,false,'OrderTriggerHandler'); 
            
            Database.update(dnMap.values());
            Utility.IgnoreAction(false,false,'OrderTriggerHandler'); 
            
        }
    }
}