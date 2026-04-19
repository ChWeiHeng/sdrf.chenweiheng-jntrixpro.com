/**************************************************************************************************
 * Name: BatchSendEmailToOrder
 * Object: Delivery_Note__c
 * Purpose: 如果Delivery_Note__c. Stock_Aging_Countdown__c = 5且Delivery_Note__c.Sent_Auto_issue_Consignment_Notification__c = FALSE, 发送邮件给到对应Order上记录的Email地址
 *          如果Delivery_Note__c. Stock_Aging_Countdown__c <= 0 且Delivery_Note__c.Auto_issue_Consignment __c = FALSE，自动创建ZARA类型订单及订单行记录。
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          zach            2025-07-08        Created               
***************************************************************************************************/
global without sharing class BatchSendEmailToOrder implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
    //组织邮件
    public static List<OrgWideEmailAddress> orgEmailList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'RBCRM'];
    public String errorMsg;
    public Datetime startTime;
    public Datetime endDateTime;
    public Boolean flag = TRUE;
    public Set<String> idSet = new Set<String>();
    public Boolean sendEmail = false;

    global BatchSendEmailToOrder(Boolean sendEmail){
        this.sendEmail = sendEmail;
    }

    global BatchSendEmailToOrder(Set<String> idSet,Boolean sendEmail){
        this.idSet = idSet;
        this.sendEmail = sendEmail;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        startTime = System.now();

        if(System.Label.BatchSendEmailEndDate <> '0'){
            List<String> endDateTimeList = System.Label.BatchSendEmailEndDate.split('-');
            endDateTime = DateTime.newInstance( Integer.valueOf(endDateTimeList[0]), 
                                            Integer.valueOf(endDateTimeList[1]),
                                            Integer.valueOf(endDateTimeList[2]),
                                            Integer.valueOf(endDateTimeList[3]),
                                            Integer.valueOf(endDateTimeList[4]),
                                            Integer.valueOf(endDateTimeList[5]));
        }else{
            endDateTime = System.now();
        }
        String sql;
        if(!idSet.isEmpty()) {
            sql = 'SELECT Id,Order_Item__c,Auto_ZARA_Issue_Quantity__c,Delivery_Quantity__c,Remain_Quantity__c,Order__c,Order__r.Customer__r.Email__c,Order__r.Customer__r.Name,Order__r.Stock_Aging_Limit__c,Delivery_Post_Date__c,Stock_Aging_Countdown__c,Order__r.Sales_Org__c,Order__r.Customer__r.Owner.Email,' + 
                    'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Name,Auto_issue_Consignment__c FROM Delivery_Note__c WHERE Order__r.Order_type__c = \'ZARB\' AND (Order__r.Sales_Org__c = \'5070\') AND Order__r.RecordType.DeveloperName = \'Model_C\' AND LastModifiedDate <= :endDateTime and Delivery_Post_Status__c = \'C\'';
        }else{
            sql = 'SELECT Id,Order_Item__c,Auto_ZARA_Issue_Quantity__c,Delivery_Quantity__c,Remain_Quantity__c,Order__c,Order__r.Customer__r.Email__c,Order__r.Customer__r.Name,Order__r.Stock_Aging_Limit__c,Delivery_Post_Date__c,Stock_Aging_Countdown__c,Order__r.Sales_Org__c,Order__r.Customer__r.Owner.Email,' + 
                    'Order_Item__r.Commodity__c,Order_Item__r.Commodity__r.Name,Auto_issue_Consignment__c FROM Delivery_Note__c WHERE Order__r.Order_type__c = \'ZARB\' AND (Order__r.Sales_Org__c = \'5130\') AND Order__r.RecordType.DeveloperName = \'Model_C\' AND LastModifiedDate <= :endDateTime and Delivery_Post_Status__c = \'C\'';
        }
        
        
        if(!idSet.isEmpty()){
            sql += ' AND Id IN :idSet';
        }
        return Database.getQueryLocator(sql); 
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchSendEmailToOrder(true));
    }
    
    global void execute(Database.BatchableContext BC,List<Delivery_Note__c> itemList){
        Savepoint sp = Database.setSavepoint();
        try{
            Utility.isBypassValidationRule = TRUE;
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            //product name
            Set<String> proIdSet = new Set<String>();
            for(Delivery_Note__c item : itemList){
                if(item.Remain_Quantity__c > 0 && item.Stock_Aging_Countdown__c != NULL && (Integer.valueOf(item.Stock_Aging_Countdown__c) == 10 || Integer.valueOf(item.Stock_Aging_Countdown__c) == 15)/* && String.isNotBlank(item.Order__r.Customer__r.Email__c)*/){
                    proIdSet.add(item.Order_Item__r.Commodity__c);
                }
            }

            System.debug('proIdSet >>> ' + proIdSet);
            //获取产品名称
            Map<String,List<String>> proNameMap = getProductName(proIdSet);
            for(Delivery_Note__c item : itemList){
                system.debug(item);
                //发送邮件
                if(item.Remain_Quantity__c > 0 && item.Stock_Aging_Countdown__c != NULL && (Integer.valueOf(item.Stock_Aging_Countdown__c) == 10 || Integer.valueOf(item.Stock_Aging_Countdown__c) == 15)/* && String.isNotBlank(item.Order__r.Customer__r.Email__c)*/){
                    emails.add(getOrderEmail(item,proNameMap));
                }
            }
            system.debug(emails);

            //自动生成ZARA

            //generateZaraData(itemList,false);

            //发送邮件
            if(sendEmail)Messaging.sendEmail(emails);
        }catch (Exception e) {
            Database.rollback(sp);
            flag = FALSE;
            errorMsg = e.getMessage()+';行数：'+e.getLineNumber();
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        Utility.setBatchInfo('BatchSendEmailToOrder', flag, startTime, errorMsg);
    }

    //自动生成ZARA
    public static void generateZaraData(List<Delivery_Note__c> itemList,Boolean isButton){
        Map<Id,Delivery_Note__c> noteMap = new Map<Id,Delivery_Note__c>(itemList);
        Map<String,Decimal> noteRemainMap = new Map<String,Decimal>();
        Map<String,List<String>> orderNoteMap = new Map<String,List<String>>();
        Map<String,String> itemNoteMap = new Map<String,String>();
        List<Delivery_Note__c> updateNoteList = new List<Delivery_Note__c>();

        for(Delivery_Note__c item : itemList){
            System.debug('Stock_Aging_Countdown__c >>> ' + item.Stock_Aging_Countdown__c);
            System.debug('Auto_issue_Consignment__c >>> ' + item.Auto_issue_Consignment__c);
            System.debug('Remain_Quantity__c >>> ' + item.Remain_Quantity__c);
            noteRemainMap.put(item.Id,item.Remain_Quantity__c);
            //自动转ZARB
            if(item.Remain_Quantity__c > 0){
                if((!isButton && item.Stock_Aging_Countdown__c != NULL && Integer.valueOf(item.Stock_Aging_Countdown__c) <= 0 && !item.Auto_issue_Consignment__c) ||
                    (isButton && item.Stock_Aging_Countdown__c != NULL && Integer.valueOf(item.Stock_Aging_Countdown__c) <= 0)){
                        if(!orderNoteMap.containsKey(item.Order__c)){
                            orderNoteMap.put(item.Order__c,new List<String>());
                        }
                        orderNoteMap.get(item.Order__c).add(item.Id);
                        itemNoteMap.put(item.Id,item.Order_Item__c);
                        item.Auto_issue_Consignment__c = TRUE;
                        item.Auto_ZARA_Issue_Quantity__c = (item.Auto_ZARA_Issue_Quantity__c ?? 0) + item.Remain_Quantity__c;
                        item.Issue_Quantity__c = item.Delivery_Quantity__c;
                        system.debug('item.Auto_ZARA_Issue_Quantity__c===='+item.Auto_ZARA_Issue_Quantity__c);
                        system.debug('item.Remain_Quantity__c===='+item.Remain_Quantity__c);
                        updateNoteList.add(item);
                }
            }

            //更新后台字段，作为手动按钮生成ZARA的显隐性条件;
            item.Stock_Aging_CountdownBatch__c = item.Stock_Aging_Countdown__c;
        }

        update itemList;

        System.debug('orderNoteMap ' + orderNoteMap.keySet());
        //生成ZARA和ZARA Item
        if(!orderNoteMap.isEmpty()){
            //Order
            List<String> orderIdSet = new List<String>(orderNoteMap.keySet());
            String orderSoql = Utility.getAllFieldSoql('Order__c') + ' WHERE Id IN:orderIdSet'; 
            Map<Id,Order__c> orderMap = new Map<Id,Order__c>((List<Order__c>)Database.query(orderSoql));
            //Order Item
            List<String> orderItemIdSet = itemNoteMap.values();
            String orderItemSoql = Utility.getAllFieldSoql('Order_Item__c') + ' WHERE Id IN :orderItemIdSet';
            Map<Id,Order_Item__c> orderItemMap = new Map<Id,Order_Item__c>((List<Order_Item__c>)Database.query(orderItemSoql));
            
            Map<String,Order__c> zaraDataMap = new Map<String,Order__c>();
            Map<String,List<Order_Item__c>> zaraItemMap = new Map<String,List<Order_Item__c>>();
            for(String orderid : orderNoteMap.keySet()){
                Order__c zarbOrder = orderMap.get(orderid);
                //create ZARA
                Order__c zaraOrder = zarbOrder.clone(FALSE,TRUE,FALSE,FALSE);
                zaraOrder.SAP_Order_Code__c = '';
                zaraOrder.Status__c = 'Draft';
                zaraOrder.Sync_Status__c = null;
                zaraOrder.Approve_Date__c = null;
                zaraOrder.Order_type__c = 'ZARA';
                zaraOrder.Source_Order__c = zarbOrder.Id;
                zaraOrder.DN_Post_Date__c = System.today();
                zaraOrder.SAP_Order__c = false;
                zaraOrder.Order_Reason__c = 'Z05';
                zaraDataMap.put(orderid,zaraOrder); 
                Integer index = 10;   
                for(String noteId : orderNoteMap.get(orderid)){
                    Order_Item__c zarbItem = orderItemMap.get(itemNoteMap.get(noteId));
                    //create ZARA Item    
                    Order_Item__c zar1Item = zarbItem.clone(FALSE,TRUE,FALSE,FALSE);
                    zar1Item.Depend_On_Item__c = zarbItem.Id;
                    zar1Item.Quantity__c = noteMap.get(noteId)?.Remain_Quantity__c;
                    zar1Item.DN_Post_Date__c = System.today();
                    zar1Item.IsCreate__c = TRUE;
                    zar1Item.Delivery_Note__c = noteId;
                    zar1Item.External_Id__c = '';
                    zar1Item.SAP_Item_Num__c = String.valueOf(index);
                    zar1Item.Delivery_Quantity__c = 0;
                    zar1Item.Delivery_Date__c = System.today();
                    if(zaraItemMap.containsKey(orderid)){
                        zaraItemMap.get(orderid).add(zar1Item);
                    }else{
                        zaraItemMap.put(orderid,new List<Order_Item__c>{zar1Item});
                    }
                    index++;
                }
            }
            insert zaraDataMap.values(); 
            system.debug('zaraDataMap.values()===='+zaraDataMap.values());
            
            //关联Order
            List<Order_Item__c> zaraItemList = new List<Order_Item__c>();
            for(String orderid : zaraItemMap.keySet()){
                for(Order_Item__c item : zaraItemMap.get(orderid)){
                    item.Order__c = zaraDataMap.get(orderid)?.Id;
                    zaraItemList.add(item);
                }    
            }
            insert zaraItemList;
            system.debug('zaraItemList===='+zaraItemList);
            system.debug('updateNoteList===='+updateNoteList);
            update updateNoteList;

            for(Order__c order : zaraDataMap.values()){
                order.Auto_issue_Consignment__c = TRUE;
            }
            update zaraDataMap.values();
            
            //测算成本
            Map<Id,Order_Item__c> itemMap = new Map<Id,Order_Item__c>(zaraItemList);
            if(!Test.isRunningTest()) {
            Utility.getUnitEstimateCost(itemMap.keySet());
            }
        }
    }

    
    //获取发货单上的产品名称
    public static Map<String,List<String>> getProductName(Set<String> proIdSet){
        //获取产品名称
        Map<String,List<String>> proNameMap = new Map<String,List<String>>();
        for(Product_Name__c pro : [SELECT Id,Product_Combo__c,Product__r.Name,(SELECT Id,Product_Name__r.Product__r.Name FROM Product_Combo_Item__r) FROM Product_Name__c WHERE Id IN:proIdSet]){
            if(pro.Product_Combo__c){
                proNameMap.put(pro.Id,new List<String>());
                for(Product_Name_Item__c item : pro.Product_Combo_Item__r){
                    if(String.isNotBlank(item.Product_Name__r.Product__r.Name)){
                        proNameMap.get(pro.Id).add(item.Product_Name__r.Product__r.Name);
                    }
                }
            }else{
                proNameMap.put(pro.Id,new List<String>{pro.Product__r.Name});
            }
        }
        return proNameMap;
    }
    
    //根据发货单创建邮件
    public static Messaging.SingleEmailMessage getOrderEmail(Delivery_Note__c item,Map<String,List<String>> proNameMap){
        //到期日期
        String expiredDate = '';
        if(item.Delivery_Post_Date__c!=NULL && item.Order__r.Stock_Aging_Limit__c!=NULL){
            expiredDate = String.valueOf(item.Delivery_Post_Date__c.addDays(Integer.valueOf(item.Order__r.Stock_Aging_Limit__c) + 2));
        }
        
        List<String> thHeadList = new List<String> {System.Label.Product_Names_Name,System.Label.Product_Name1,System.Label.Current_Aging_Period,System.Label.Expiry_Date,System.Label.Remain_Qty};
        Utility.Table currTable = getDefaultTable(thHeadList);
        if(proNameMap.containsKey(item.Order_Item__r.Commodity__c)){
            for(String productName : proNameMap.get(item.Order_Item__r.Commodity__c)){
                // 构建邮件表格的tr td内容
                Utility.TableTr tableTr = new Utility.TableTr();
                tableTr.tdMap.put(System.Label.Product_Names_Name,new Utility.TableTd(item.Order_Item__r.Commodity__r.Name));
                tableTr.tdMap.put(System.Label.Product_Name1,new Utility.TableTd(productName));
                tableTr.tdMap.put(System.Label.Current_Aging_Period,new Utility.TableTd(item.Order__r.Stock_Aging_Limit__c + ' days' ?? ''));
                tableTr.tdMap.put(System.Label.Expiry_Date,new Utility.TableTd(expiredDate));
                tableTr.tdMap.put(System.Label.Remain_Qty,new Utility.TableTd(item.Remain_Quantity__c!=NULL?String.valueOf(item.Remain_Quantity__c):''));
                currTable.tbody.trs.add(tableTr);
            }
        }
        
        //邮件内容
        /*String htmlbody = 'Dear&nbsp;&nbsp;' + (item.Order__r.Customer__r.Name ?? '') + '<br/>&nbsp;&nbsp;&nbsp;&nbsp;We would like to remind you' +
            ' that the following inventory items in your possession are approaching their aging expiry deadline and require immediate action:<br/><br/>';
        htmlbody += 'Affected Inventory:<br/>';
        htmlbody += Utility.getEmailTableHTML(currTable, thHeadList);
        htmlbody += '<br/>For questions or assistance, contact:&nbsp;&nbsp;' + Label.InventoryEmailContact + '<br/>Best regards';*/
        List<String> email5130List = new List<String>();
        List<String> email5070CCList = new List<String>();
        email5130List.add(item.Order__r.Customer__r.Owner.Email);
        email5130List.add(System.Label.Auto_ZARA_Email_CC_5130);
        
        email5070CCList.add(System.Label.Auto_ZARA_Email_CC);
        if(System.Label.Email_Admin_Config <> '0'){
            List<String> strList = System.Label.Email_Admin_Config.split(';');
            for(String str : strList){
                email5130List.add(str);                
            }
        }
        
        String body = Utility.getEmailTableHTML(currTable, thHeadList);
        //String htmlbody = String.format(System.Label.Auto_ZARA_Email1,new List<String>{(item.Order__r.Customer__r.Name ?? ''),body,item.Order__r.Sales_Org__c == '5070' ? System.Label.Auto_ZARA_Email_CC : System.Label.Auto_ZARA_Email_CC_5130});
        String htmlbody = String.format(System.Label.Auto_ZARA_Email1,new List<String>{(item.Order__r.Customer__r.Name ?? ''),body});
        //Messaging.SingleEmailMessage email = Utility.getSingleEmailMessage('Inventory Aging Expiry ' + expiredDate, new List<String>{item.Order__r.Customer__r.Email__c}, htmlbody,orgEmailList.isEmpty()?NULL:orgEmailList[0].Id,item.Order__r.Sales_Org__c == '5070' ? new List<String>{System.Label.Auto_ZARA_Email_CC} : email5130List);
        Messaging.SingleEmailMessage email = Utility.getSingleEmailMessage('Inventory Aging Expiry ' + expiredDate, new List<String>{item.Order__r.Customer__r.Owner.Email,item.Order__r.Customer__r.Email__c}, htmlbody,orgEmailList.isEmpty()?NULL:orgEmailList[0].Id,email5130List);
        return email;
    }
    
    /**
     * [getDefaultTable description]
     * @Author      zach
     * @DateTime    2020-07-22T14:31:47+0800
     * @Description 根据表头获取默认的Table
     * @return      [description]
     */
    public static Utility.Table getDefaultTable(List<String> thHeadList) {
        Utility.Table table = new Utility.Table();
        table.cssMap = new Map<String,String>{'border-collapse'=>'collapse','width'=>'100%'};
        table.thead.cssMap = new Map<String,String>{'background-color'=>'#deeaf6'};
        for(String thHead:thHeadList) {
            table.thead.tr.tdMap.put(thHead,new Utility.TableTd(thHead));
        }
        return table;
    }
}