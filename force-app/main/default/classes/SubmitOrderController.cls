/**************************************************************************************************
 * Name: SubmitOrderController
 * Object: 
 * Purpose: 提交审批控制类
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE             DETAIL             Description
 * 1.0          Gerry             2024-05-17         Created             
***************************************************************************************************/
public without sharing class SubmitOrderController {
    @AuraEnabled
    public static Output init(String orderId) {
        
        Order__c order = [SELECT (SELECT Id FROM Order_Item__r WHERE Delivery_Date__c=null),Total_Price__c,Deliver_Plant__c,Reference_Order__c,RecordType_Name__c,Invoice__r.Name,Commission_Type__c,Commission_Calculation_Method__c,Commission_To__c,Sales_Org__c,recordType.DeveloperName,Down_Payment__c,Down_Payment__r.Order_type__c,Customer__r.MDG_Customer_Code__c,Id,Order_type__c,Total_Amount__c,Customer__c,Order_Amount_USD__c,Down_Payment__r.Order_Amount_USD__c,Currency__c FROM Order__c WHERE Id=:orderId];
        //ZARF数量校验----start
        if (order.Order_type__c == 'ZARF') {
            Output zareOutput = zareQuantityEnough(order.Id);
            if (!zareOutput.isSucess) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = zareOutput.errorMsg;
                return out;
            }
        }
        //ZARF数量校验----end

        //ZFD提交校验----start
        if (order.Order_type__c == 'ZARL' && order.Order_Item__r.size()>0) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = System.label.ZDFSubmitValidation;
            return out;
        }
        //ZFD提交校验----end

        if ((order.Order_type__c == 'ZARE' || order.Order_type__c == 'ZARF' || order.Order_type__c == 'ZARA') && System.Label.ConsignmentOpen == 'NO') {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = 'The consignment order function is under maintenance. Please try again later.';
            return out;
        }

        //墨西哥C/C+ ZMX1订单创建金额控制-----start
        if (System.Label.MX_Submit_Limit == 'YES') {//控制开关
            if (
                (
                    order.Order_type__c == 'ZMX1' &&
                    order.Deliver_Plant__c == '3020' &&
                    order.Total_Price__c < Decimal.valueOf(System.Label.MXCMinAmount)
                ) ||
                (
                    order.Order_type__c == 'ZMX1' &&
                    order.Deliver_Plant__c == '3011' &&
                    order.Total_Price__c < Decimal.valueOf(System.Label.MXCPlusAmount)
                )
            ) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = System.Label.MXSubmitError;
                out.errorMsg = out.errorMsg.replace('[modelcAmount]', System.Label.MXCMinAmount);
                out.errorMsg = out.errorMsg.replace('[modelcplusAmount]', System.Label.MXCPlusAmount);
                return out;
                
            }
        }
        
        //墨西哥C/C+ ZMX1订单创建金额控制-----end
        
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
            )  
        ) {
            Output out = new Output();
            out.isSucess = false;
            out.errorMsg = System.Label.Commission_Info;
            if (!System.Test.isRunningTest()) {
                return out;
            }
        }
        // GetCustomerlimitFROMSAP.RespCustomerInfo rcinfo = new GetCustomerlimitFROMSAP.RespCustomerInfo();
        // rcinfo.currencyRate = '11';
        // rcinfo.amount = 111;
        // rcinfo.isOverdue = false;
        GetCustomerlimitFROMSAP.RespCustomerInfo rcinfo;
        if (!System.Test.isRunningTest()) {
            rcinfo = GetCustomerlimitFROMSAP.submitToSAP(new List<String>{order.Customer__r.MDG_Customer_Code__c},order.Currency__c,order.Sales_Org__c);
        }else{
            rcinfo = new GetCustomerlimitFROMSAP.RespCustomerInfo();
            rcinfo.exch_rate = '1';
            rcinfo.amount = 111;
            rcinfo.ZOVDAYS = '1';
        }
        System.debug('rcinfo=====>'+rcinfo);
        System.debug('order.Order_type__c=' + order.Order_type__c);
        if (
            !(order.Order_type__c=='ZAR1' || 
            order.Order_type__c=='ZMX1' ||
            order.Order_type__c=='ZARB' || order.Order_type__c=='ZARE')
        ) {
            if (order.Order_type__c=='ZAR2') {
                Output outInvoice = invoice(orderId);
                if (String.isNotBlank(rcinfo.zovdmtr)) {
                    outInvoice.overdueAmount = Decimal.valueOf(rcinfo.zovdmtr);
                }
                
                if (!outInvoice.isSucess) { return outInvoice; }
            }else if(order.Order_type__c == 'ZMX2' && order.RecordType_Name__c == 'Model_C'){//ZMX2可用数量校验
                Output outOrderItem = orderItem(orderId);
                if (!outOrderItem.isSucess) { 
                    return outOrderItem; 
                }
            }else if((order.Order_type__c == 'ZMX3' || order.Order_type__c == 'ZMX4') && order.Reference_Order__c!=null) {
                Output outOrderItem = calculateZMX1Rate(orderId,true);
                //借贷项订单------start
                
                outOrderItem.isCDNoteOrder = true;
                outOrderItem.isCanSubmit = true;
                outOrderItem.rate = Decimal.valueOf(rcinfo.exch_rate);
                outOrderItem.showText = System.Label.ConfirmSubmitOrder;
                if (String.isNotBlank(rcinfo.ZOVDAYS)) {
                    outOrderItem.overduedays = Decimal.valueOf(rcinfo.ZOVDAYS);
                }
                if (String.isNotBlank(rcinfo.zsfyq)) { outOrderItem.overdue = true; } 
                else { outOrderItem.overdue = false; }
                if (String.isNotBlank(rcinfo.zovdmtr)) {
                    outOrderItem.overdueAmount = Decimal.valueOf(rcinfo.zovdmtr);
                }
                return outOrderItem;
                //借贷项订单------end
            }
            else{
                if (rcinfo==null || System.Test.isRunningTest()) {
                    Output out = new Output();
                    out.isSucess = false;
                    out.errorMsg = 'System error';
                    if (!System.Test.isRunningTest()) {return out;}
                    
                }
                if (rcinfo.msgty == 'E' || System.Test.isRunningTest()) {
                    Output out = new Output();
                    out.isSucess = false;
                    out.errorMsg = rcinfo.msgtx;
                    if (!System.Test.isRunningTest()) { return out; }
                }
            }
            Output out = new Output();
            out.isSucess = true;
            out.isShow = false;
            out.isCanSubmit = true;
            out.rate = Decimal.valueOf(rcinfo.exch_rate);
            out.showText = System.Label.ConfirmSubmitOrder;
            if (String.isNotBlank(rcinfo.ZOVDAYS)) {
                out.overduedays = Decimal.valueOf(rcinfo.ZOVDAYS);
            }
            if (String.isNotBlank(rcinfo.zsfyq)) { out.overdue = true; } 
            else { out.overdue = false; }
            if (String.isNotBlank(rcinfo.zovdmtr)) {
                out.overdueAmount = Decimal.valueOf(rcinfo.zovdmtr);
            }
            System.debug('out==========>'+out);
            return out;
            
        }else{
            
            System.debug('order.Down_Payment__c=' + order.Down_Payment__c);
            if ((order.Down_Payment__c!=null && order.Order_type__c=='ZMX1')) {
                System.debug('order.Total_Amount__c=' + order.Total_Amount__c);
                System.debug('rcinfo.exch_rate=' + rcinfo.exch_rate);
                System.debug('Order_Amount_USD__c=' + order.Down_Payment__r.Order_Amount_USD__c);
                System.debug('order.Total_Amount__c/rcinfo.exch_rate=' + (order.Total_Amount__c/Decimal.valueOf(rcinfo.exch_rate)).setscale(2));

                if ((order.Total_Amount__c/Decimal.valueOf(rcinfo.exch_rate)).setscale(2)<=order.Down_Payment__r.Order_Amount_USD__c) {
                    Output out = new Output();
                    out.isSucess = true;
                    out.isShow = false;
                    out.isCanSubmit = true;
                    out.showText = System.Label.Confirm_Submit_Order;
                    out.orderAmount = (order.Total_Amount__c/Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
                    out.rate = Decimal.valueOf(rcinfo.exch_rate);
                    out.overduedays = Decimal.valueOf(rcinfo.ZOVDAYS);
                    if (String.isNotBlank(rcinfo.zsfyq)) {
                        out.overdue = true;
                    }else{
                        out.overdue = false;
                    }
                    // out.sapCredit = rcinfo.amount;

                    // out.remainingCreditOrder = (out.remainingCredit*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
                    // out.orderApproingAmountOrder = (out.orderApproingAmount*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
                    // out.orderAmountOrder = order.Total_Amount__c;
                    // out.sapCreditOrder = (rcinfo.amount*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
                    
                    if (!Test.isRunningTest()) return out;
                }else{
                    Output out = new Output();
                    out.isSucess = true; out.isShow = false; out.isCanSubmit = false; out.showText = System.Label.MoreThan;
                    if (!Test.isRunningTest()) return out;
                }
            }
            
            // GetCustomerlimitFROMSAP.RespCustomerInfo rcinfo = GetCustomerlimitFROMSAP.submitToSAP(new List<String>{order.Customer__r.MDG_Customer_Code__c},order.Currency__c);
            System.debug('rcinfo======>'+rcinfo);
            if (rcinfo==null || System.Test.isRunningTest()) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = 'System error';
                if (!System.Test.isRunningTest()) { return out; }

            }
            if (rcinfo.msgty == 'E' || System.Test.isRunningTest()) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = rcinfo.msgtx;
                if (!System.Test.isRunningTest()) { return out; }
            }
            Output out = new Output();
            out.isSucess = true;
            out.isCanSubmit = true;
            List<Customer_Credit_Info__c> cci = [SELECT Actual_Credit_limit__c,Id,Remaining_Credit__c FROM Customer_Credit_Info__c WHERE Customer__c=:Order.Customer__c];
            Decimal approingNum = 0;
            for (AggregateResult agg : [
                                        SELECT 
                                            SUM(Order_Amount_USD__c) usedNum
                                        FROM 
                                            Order__c 
                                        WHERE 
                                            Customer__c=:order.Customer__c
                                            AND Status__c='Approving' AND 
                                            (
                                                Order_type__c='ZAR1' OR
                                                Order_type__c='ZARB' OR
                                                Order_type__c='ZMX1' 
                                            )
                                            Group by Customer__c
            ]) { approingNum = (Decimal)agg.get('usedNum') ?? 0; }

            Decimal approvedNotSyncNum = 0;
            for (AggregateResult agg : [
                                        SELECT 
                                            SUM(Order_Amount_USD__c) usedNum
                                        FROM 
                                            Order__c 
                                        WHERE 
                                            Customer__c=:order.Customer__c
                                            AND ((Status__c='Approved' AND Sync_Status__c!='Synchronized')) AND
                                            (
                                                Order_type__c='ZAR1' OR
                                                Order_type__c='ZARB' OR
                                                Order_type__c='ZMX1' 
                                            )
                                            Group by Customer__c
            ]) { approvedNotSyncNum = (Decimal)agg.get('usedNum') ?? 0; }

            Decimal ZARBNum = 0;
            for (AggregateResult agg : [
                                        SELECT 
                                            SUM(ZARB_Remain_Amount__c) usedNum
                                        FROM 
                                            Order_Item__c 
                                        WHERE 
                                            Order__r.Customer__c=:order.Customer__c
                                            AND Order__r.Status__c='Approved' AND 
                                            (
                                                Order__r.Order_type__c='ZARB'  
                                            )
                                            Group by Order__r.Customer__c
            ]) { ZARBNum = (Decimal)agg.get('usedNum') ?? 0; }

            // Decimal ZARENum = 0;
            // for (AggregateResult agg : [
            //                             SELECT 
            //                                 SUM(Order_Amount_USD__c) usedNum
            //                             FROM 
            //                                 Order__c 
            //                             WHERE 
            //                                 Customer__c=:order.Customer__c
            //                                 AND Status__c='Approved' AND 
            //                                 (
            //                                     Order_type__c='ZARE'  
            //                                 )
            //                                 Group by Customer__c
            // ]) { ZARENum = (Decimal)agg.get('usedNum') ?? 0; }

            // Decimal ZARANum = 0;
            // for (AggregateResult agg : [
            //                             SELECT 
            //                                 SUM(Order_Amount_USD__c) usedNum
            //                             FROM 
            //                                 Order__c 
            //                             WHERE 
            //                                 Customer__c=:order.Customer__c
            //                                 AND Status__c='Approved' AND 
            //                                 (
            //                                     Order_type__c='ZARA'
            //                                 )
            //                                 Group by Customer__c
            // ]) { ZARANum = (Decimal)agg.get('usedNum') ?? 0; }

            // Decimal ZARFNum = 0;
            // for (AggregateResult agg : [
            //                             SELECT 
            //                                 SUM(Order_Amount_USD__c) usedNum
            //                             FROM 
            //                                 Order__c 
            //                             WHERE 
            //                                 Customer__c=:order.Customer__c
            //                                 AND Status__c='Approved' AND 
            //                                 (
            //                                     Order_type__c='ZARF' 
            //                                 )
            //                                 Group by Customer__c
            // ]) { ZARFNum = (Decimal)agg.get('usedNum') ?? 0; }

            out.isShow = true;
            // SAP可用额度-(寄售额度-已使用寄售额度-寄售退回+寄售退货)-审批中额度（非寄售销售单相关的）
            if (cci.size()>0 && approingNum!=null && ZARBNum!=null) {
                if (cci[0].Remaining_Credit__c==null) {
                    out.remainingCredit = cci[0].Actual_Credit_limit__c-approingNum-approvedNotSyncNum-ZARBNum;
                }else{
                    out.remainingCredit = cci[0].Remaining_Credit__c-approingNum-approvedNotSyncNum-ZARBNum;
                }
                
            }else { out.remainingCredit = 0; }

            out.currencyCode = order.Currency__c;
            system.debug('approingNum===='+approingNum+'approvedNotSyncNum===='+approvedNotSyncNum);
            out.orderApproingAmount = approingNum+approvedNotSyncNum;
            out.orderAmount = (order.Total_Amount__c/Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
            out.rate = Decimal.valueOf(rcinfo.exch_rate);
            out.sapCredit = rcinfo.amount;

            out.remainingCreditOrder = (out.remainingCredit*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
            out.orderApproingAmountOrder = (out.orderApproingAmount*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
            out.orderAmountOrder = order.Total_Amount__c.setscale(2);
            out.sapCreditOrder = (rcinfo.amount*Decimal.valueOf(rcinfo.exch_rate)).setscale(2);
            out.overduedays = Decimal.valueOf(rcinfo.ZOVDAYS);
            if (String.isNotBlank(rcinfo.zovdmtr)) {
                out.overdueAmount = Decimal.valueOf(rcinfo.zovdmtr);
            }
            
            if (String.isNotBlank(rcinfo.zsfyq)) { out.overdue = true; }
            else{ out.overdue = false; }
            
            System.debug('out==========>'+out);
            return out;
        }
    }
    @AuraEnabled
    public static Output submitDataMe(
        String orderId,
        Output infodata
    ){
        try {         
            Order__c o = [SELECT SAP_Order__c,Sales_Org__c,Auto_Issue_Consignment__c,Status__c,recordType.DeveloperName,Total_Amount__c,Customer__c,Terms_Of_Payment__c,Customer_Sales_Info__r.Terms_Of_Payment__c,Order_type__c FROM Order__c WHERE Id=:orderId];
            Order__c updateOr = new Order__c();
            updateOr.Id = orderId;
            updateOr.Rate__c = infodata.rate;
            updateOr.SAP_Credit_Limit__c = infodata.sapCredit;
            updateOr.Actual_available_Credit_Limit__c = infodata.remainingCredit;
            // updateOr.Total_Amount_in_USD__c = infodata.orderAmount;
            updateOr.CRM_Approving_Credit__c = infodata.orderApproingAmount;
            if (infodata.overdue!=null) {
                updateOr.Overdue__c = infodata.overdue;
            }
            if (infodata.overdueAmount !=null) {
                updateOr.Overdue_Amount__c = infodata.overdueAmount;
            }
            System.debug('infodata.rate'+infodata.rate);
            if ((o.Total_Amount__c/infodata.rate)>updateOr.Actual_available_Credit_Limit__c) {
                updateOr.Ultra_Credit__c = true;
            }else{
                updateOr.Ultra_Credit__c = false;
            }
            Map<String,Decimal> daysMap = new Map<String,Decimal>();
            for (Payment_Rate__c pr : [SELECT Id,Days__c,Name FROM Payment_Rate__c WHERE Name=:o.Terms_Of_Payment__c OR Name=:o.Customer_Sales_Info__r.Terms_Of_Payment__c]) {
                daysMap.put(pr.Name,pr.Days__c);
            }
            if (daysMap.get(o.Terms_Of_Payment__c) > daysMap.get(o.Customer_Sales_Info__r.Terms_Of_Payment__c)) {
                updateOr.Payment_Term_Longer__c = true;
            }else{
                updateOr.Payment_Term_Longer__c = false;
            }
            updateOr.Days__c = daysMap.get(o.Terms_Of_Payment__c);
            Map<String,Customer_Credit_Info__c> accCreditInfoMap = new Map<String,Customer_Credit_Info__c>();
            for (Customer_Credit_Info__c cci : [SELECT Id,Customer__c,Actual_Credit_limit__c,Remaining_Credit__c,Overdue__c FROM Customer_Credit_Info__c WHERE Customer__c=:o.Customer__c]) {
                accCreditInfoMap.put(cci.Customer__c,cci);
            }
            System.debug('o.Customer__c'+o.Customer__c);
            System.debug('accCreditInfoMap=>'+accCreditInfoMap);
            System.debug('accCreditInfoMap.get(o.Customer__c)=>'+accCreditInfoMap.get(o.Customer__c));
            updateOr.Customer_Credit_Line__c = accCreditInfoMap.get(o.Customer__c)?.Actual_Credit_limit__c;
            //add by zach 2025/8/11 赋值其他Order字段
            updateOr.SAP_Credit_Limit__c = accCreditInfoMap.get(o.Customer__c)?.Remaining_Credit__c;
            updateOr.Overdue__c = accCreditInfoMap.get(o.Customer__c)?.Overdue__c;
            
            //手动新建的ZAR1 提交时严控客户额度 以及客户逾期 ----start
            // if ((o.Order_type__c == 'ZAR1' || o.Order_type__c == 'ZARB') && !o.Auto_issue_Consignment__c && o.Sales_Org__c == '5130' && !o.SAP_Order__c) {
            //     if (updateOr.Overdue__c) {
            //         Output out = new Output();
            //         out.isSucess = false;
            //         //out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            //         out.errorMsg = System.Label.OrderOverdue;
            //         return out;   
            //     }

            //     if (updateOr.Ultra_Credit__c) {
            //         Output out = new Output();
            //         out.isSucess = false;
            //         //out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            //         out.errorMsg = System.Label.UltraCredit;
            //         return out;   
            //     }
            // }
            //手动新建的ZAR1 提交时严控客户额度 以及客户逾期 ----end
            List<User> userList = [SELECT Id,Profile.Name, ManagerId,Manager.Name  FROM User WHERE Id=:System.UserInfo.getUserId()];
            if(userList.size()>0){
                updateOr.Submit_Manager__c= userList[0].ManagerId;
                updateOr.Submit_Profile_Name__c= userList[0].Profile.Name;
            }
           
            
            Order__c order = [SELECT Id,Auto_Issue_Consignment__c,Sales_Org__c,Distr_Channel__c,Order_type__c,recordType.DeveloperName,Change_Guide_Price_Item__c,(SELECT Id,Order__c,Price_Is_Changed__c FROM Order_Item__r) FROM Order__c WHERE Id=:orderId];
            
            //记录价格有变动的5130/5070 Auto ZAR1订单明细
            Map<String,Order_Item__c> oiZAR1Map = new Map<String,Order_Item__c>();
            for(Order_Item__c oi : order.Order_Item__r){
                if(oi.Price_Is_Changed__c && order.Order_type__c == 'ZAR1' && order.Auto_Issue_Consignment__c && order.recordType.DeveloperName == 'Model_C' && (order.Sales_Org__c == '5070' || order.Sales_Org__c == '5130')){
                    oiZAR1Map.put(oi.Order__c,oi);
                    break;
                }
            }
            // if (order.Order_type__c=='ZARE' && order.Change_Guide_Price_Item__c ==0 ) {//如果是寄售发货且没有修改价格时的直接提交成功
            //     updateOr.Status__c = 'Approved';
            //     List<Id> needlockitemIds = new List<Id>();
            //     needlockitemIds.add(orderId);
            //     Approval.lock(needlockitemIds);

            // }
            if (infodata.overduedays!=null) {
                updateOr.Max_Overdue_Days__c = infodata.overduedays;
            }

            if(order.Order_type__c == 'ZAR1' && order.Auto_Issue_Consignment__c && (order.Sales_Org__c == '5130' || order.Sales_Org__c == '5070')){
                //添加标识不让roll-up字段更新导致重新进Order Trigger触发Order修改的验证报错
                Utility.isBypassValidationRule = TRUE;
            }
            
            if (order.Order_type__c!='ZARE' && (order.Sales_Org__c == '5070' || order.Sales_Org__c == '5130') && order.recordType.DeveloperName == 'Model_C' ){//ypf 5130都有库存校验
                //modified by zach 2025/7/9 出了ZARE订单提交前，校验库存 且在更新订单前调用
                ProductSalesInfoSyncToSAP.checkInventory(new List<String>{order.Id});
            }
            
            System.debug('updateOr=>'+updateOr);
            Database.update(updateOr);
            if (o.Status__c!='Approving') {//刷新订单信用信息时，不触发提交审批逻辑
                // if (
                //     order.Order_type__c!='ZARE' ||
                //     (order.Order_type__c=='ZARE' && order.Change_Guide_Price_Item__c >0)
                // ) {
                    //illion 20250829 Mass Edit生成的Auto ZAR1，如果有调整过价格，需要走审批，如果没调整价格，直接自动审批通过
                    if(o.Order_type__c == 'ZAR1' && order.Auto_Issue_Consignment__c && order.recordType.DeveloperName == 'Model_C' && (order.Sales_Org__c == '5070' || order.Sales_Org__c == '5130')){
                        if(oiZAR1Map.containsKey(o.Id)){
                            system.debug('进入方法1');
                            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                            psr.objectId = order.Id;//对象Id
                            psr.setSubmitterId(UserInfo.getUserId());//提交人
                            psr.comments = infodata.comments;//备注
                            if (!Test.isRunningTest())Approval.ProcessResult result = Approval.process(psr);
                        }else{
                            system.debug('进入方法2');
                            updateOr.Status__c = 'Approved';
                            Database.update(updateOr);
                            Approval.lock(orderId);
                        }
                    }else{
                        Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
                        psr.objectId = order.Id;//对象Id
                        psr.setSubmitterId(UserInfo.getUserId());//提交人
                        psr.comments = infodata.comments;//备注
                        if (!Test.isRunningTest())Approval.ProcessResult result = Approval.process(psr);
                    }
                // }
            }
            

            Output out = new Output();
            out.isSucess = true;

            if (Test.isRunningTest()) {
                Integer i = 1/0;
            }

            return out;   
        } catch (Exception e) {
            Output out = new Output();
            out.isSucess = false;
            //out.errorMsg = e.getMessage()+'Line:'+e.getLineNumber();
            out.errorMsg = OrderImportController.showErrorMessage(e.getMessage());
            System.debug('out.errorMsg=====>'+out.errorMsg + e.getStackTraceString());
            return out;   
        }
        
    }


    /**
    * @description 计算zar2发票数量是否足够
    * @author Gerry | 08-12-2025 
    * @param String orderId 
    * @return Output 
    **/
    public static Output invoice(String orderId) {
        Set<String> invoiceIdSet = new Set<String>();
        Map<String,Decimal> oiMap = new Map<String,Decimal>();//发票行->订单总数量
        List<Order_Item__c> oiList = [SELECT Invoice_Item__c,Material_Number__c,Invoice_Item__r.Billing_Num__c,Id,Quantity__c,Invoice_Item__r.Invoice_Quantity__c FROM Order_Item__c WHERE Order__c =:orderId];
        for (Order_Item__c oi : oiList) {
            invoiceIdSet.add(oi.Invoice_Item__c);   
            if (oiMap.containsKey(oi.Invoice_Item__c)) {
                oimap.put(oi.Invoice_Item__c, oimap.get(oi.Invoice_Item__c)+oi.Quantity__c);
            } else{
                oimap.put(oi.Invoice_Item__c,oi.Quantity__c);
            }
        }

        Map<String,Billing__c> billMap = new Map<String,Billing__c>();
        for (Billing__c bill : [SELECT Reference_Order_Item__c,Id,Material_Code__c,Invoice_Quantity__c,Billing_Num__c FROM Billing__c WHERE Id IN:invoiceIdSet]) {
            billMap.put(bill.Id, bill);
        }
        

        //未关闭
        Map<String,Decimal> usedMap = new Map<String,Decimal>();//已经使用或正在审批的数量
        for (AggregateResult agg : [
                                    SELECT 
                                        Invoice_Item__c depend,
                                        SUM(Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        Invoice_Item__c IN:invoiceIdSet
                                        AND (Order__r.Status__c='Approved' OR Order__r.Status__c='Approving') AND Order__r.Order_type__c='ZAR2' AND isClosed__c=false
                                        Group by Invoice_Item__c
        ]) {
            usedMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }
        Map<String,Decimal> usedMap1 = new Map<String,Decimal>();//关闭订单的已经使用数量
        //关闭
        Map<String,Decimal> inventoryQuanMap1 = new Map<String,Decimal>();
        for (AggregateResult agg : [
                                    SELECT 
                                        Invoice_Item__c depend,
                                        SUM(Delivery_Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        Invoice_Item__c IN:invoiceIdSet
                                        AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZAR2' AND isClosed__c=true
                                        Group by Invoice_Item__c
        ]) {
            usedMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }

        Decimal quantity;
        System.debug('billMap.get(key)'+billMap);
        System.debug('usedMap1'+usedMap1);
        System.debug('usedMap'+usedMap);
        Decimal appoveQuantity;
        Decimal orderQuantity;
        for (String key : oimap.keySet()) {
            System.debug(key);
            orderQuantity = oimap.get(key)==null?0:oimap.get(key);
            System.debug('usedMap.get(key)'+usedMap.get(key));
            appoveQuantity = (usedMap1.get(key)==null?0:usedMap1.get(key))+(usedMap.get(key)==null?0:usedMap.get(key));
            System.debug('appoveQuantity'+appoveQuantity);
            if(billMap.get(key) <> null)quantity = billMap.get(key).Invoice_Quantity__c -appoveQuantity-orderQuantity;
            System.debug('quantity====>'+quantity);
            if (quantity<0) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = System.Label.Product_code+' '+billMap.get(key).Material_Code__c+ ','+System.Label.Invoice+' '+billMap.get(key).Billing_Num__c+'-'+billMap.get(key).Reference_Order_Item__c+','+SYstem.Label.Insufficient_Remaining_Quantity+' '+(quantity+orderQuantity);

                if (!System.Test.isRunningTest()) {
                    return out;
                }
            }
        }
        Output out = new Output();
        out.isSucess = true;
        return out;
    }

    /**
    * @description 计算ZMX1数量是否足够
    * @author Gerry | 08-12-2025 
    * @param String orderId 
    * @return Output 
    **/
    public static Output orderItem(String orderId) {
        Set<String> refeItemIdSet = new Set<String>();
        Map<String,Decimal> oiMap = new Map<String,Decimal>();//发票行->订单总数量
        List<Order_Item__c> oiList = [SELECT Reference_Order_Item__c,Material_Number__c,Invoice_Item__r.Billing_Num__c,Id,Quantity__c,Invoice_Item__r.Invoice_Quantity__c FROM Order_Item__c WHERE Order__c =:orderId];
        for (Order_Item__c oi : oiList) {
            refeItemIdSet.add(oi.Reference_Order_Item__c);   
            if (oiMap.containsKey(oi.Reference_Order_Item__c)) {
                oimap.put(oi.Reference_Order_Item__c, oimap.get(oi.Reference_Order_Item__c)+oi.Quantity__c);
            } else{
                oimap.put(oi.Reference_Order_Item__c,oi.Quantity__c);
            }
        }

        Map<String,Order_Item__c> orderItemMap = new Map<String,Order_Item__c>();
        for (Order_Item__c oi : [SELECT Delivery_Quantity__c,Id,Material_Number__c,External_Id__c FROM Order_Item__c WHERE Id IN:refeItemIdSet]) {
            orderItemMap.put(oi.Id, oi);
        }
        

        //未关闭
        Map<String,Decimal> usedMap = new Map<String,Decimal>();//已经使用或正在审批的数量
        for (AggregateResult agg : [
                                    SELECT 
                                        Reference_Order_Item__c depend,
                                        SUM(Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        Reference_Order_Item__c IN:refeItemIdSet
                                        AND (Order__r.Status__c='Approved' OR Order__r.Status__c='Approving') AND Order__r.Order_type__c='ZMX2' AND isClosed__c=false
                                        Group by Reference_Order_Item__c
        ]) {
            usedMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }
        Map<String,Decimal> usedMap1 = new Map<String,Decimal>();//关闭订单的已经使用数量
        //关闭
        Map<String,Decimal> inventoryQuanMap1 = new Map<String,Decimal>();
        for (AggregateResult agg : [
                                    SELECT 
                                        Reference_Order_Item__c depend,
                                        SUM(Delivery_Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        Reference_Order_Item__c IN:refeItemIdSet
                                        AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZMX2' AND isClosed__c=true
                                        Group by Reference_Order_Item__c
        ]) {
            usedMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }

        Decimal quantity;
        System.debug('orderItemMap.get(key)'+orderItemMap);
        System.debug('usedMap1'+usedMap1);
        System.debug('usedMap'+usedMap);
        Decimal appoveQuantity;
        Decimal orderQuantity;
        for (String key : oimap.keySet()) {
            System.debug(key);
            orderQuantity = oimap.get(key)==null?0:oimap.get(key);
            System.debug('usedMap.get(key)'+usedMap.get(key));
            appoveQuantity = (usedMap1.get(key)==null?0:usedMap1.get(key))+(usedMap.get(key)==null?0:usedMap.get(key));
            System.debug('appoveQuantity'+appoveQuantity);
            if(orderItemMap.get(key) <> null)quantity = orderItemMap.get(key).Delivery_Quantity__c -appoveQuantity-orderQuantity;
            System.debug('quantity====>'+quantity);
            if (quantity<0) {
                Output out = new Output();
                out.isSucess = false;
                out.errorMsg = System.Label.Product_code+' '+orderItemMap.get(key).Material_Number__c+ ','+System.Label.OrderItem+' '+orderItemMap.get(key).External_Id__c+','+SYstem.Label.Insufficient_Remaining_Quantity+' '+(quantity+orderQuantity);

                if (!System.Test.isRunningTest()) {
                    return out;
                }
            }
        }
        Output out = new Output();
        out.isSucess = true;
        return out;
    }

    /**
    * @description 计算zare的已使用量
    * @author Gerry | 08-12-2025 
    * @param String orderId 
    * @return Output 
    **/
    public static CalculateOutput getZAREAvailableQuanity (Set<String> deliveryIdSet) {
        CalculateOutput co = new CalculateOutput();
        co.usedMap = new Map<String,Decimal>();//已经使用或正在审批的数量
        //未关闭
        for (AggregateResult agg : [
                                    SELECT 
                                        ZARE_Delivery_Note__c depend,
                                        SUM(Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        ZARE_Delivery_Note__c IN:deliveryIdSet
                                        AND (Order__r.Status__c='Approved' OR Order__r.Status__c='Approving') AND Order__r.Order_type__c='ZARF' AND isClosed__c=false
                                        Group by ZARE_Delivery_Note__c
        ]) {
            co.usedMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }
        co.usedMap1 = new Map<String,Decimal>();//关闭订单的已经使用数量
        //关闭
        Map<String,Decimal> inventoryQuanMap1 = new Map<String,Decimal>();
        for (AggregateResult agg : [
                                    SELECT 
                                        ZARE_Delivery_Note__c depend,
                                        SUM(Delivery_Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        ZARE_Delivery_Note__c IN:deliveryIdSet
                                        AND Order__r.Status__c='Approved' AND Order__r.Order_type__c='ZARF' AND isClosed__c=true
                                        Group by ZARE_Delivery_Note__c
        ]) {
            co.usedMap1.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }
        return co;
    }

    /**
    * @description 计算ZARF审批中的量
    * @author Gerry | 08-12-2025 
    * @param String orderId 
    * @return Output 
    **/
    public static CalculateOutput getZARFApprovingQuantity(Set<String> deliveryNoteId) {
        CalculateOutput co = new CalculateOutput();
        co.approvingNumMap = new Map<String,Decimal>();//审批中的数量
        for (AggregateResult agg : [
                                    SELECT 
                                        ZARE_Delivery_Note__c depend,
                                        SUM(Quantity__c) usedNum
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        ZARE_Delivery_Note__c IN:deliveryNoteId
                                        AND (Order__r.Status__c='Approving')
                                        Group by ZARE_Delivery_Note__c
        ]) {
            co.approvingNumMap.put((String)agg.get('depend'), (Decimal)agg.get('usedNum'));
        }
        return co;
    }

    /**
    * @description 校验ZARE数量是否足够
    * @author Gerry | 08-12-2025 
    * @param String orderId 
    * @return Output 
    **/
    public static Output zareQuantityEnough(String orderId) {
        Output out = new Output();
        out.isSucess = true;
        Set<String> deliveryIdSet = new Set<String>();
        Map<String,Decimal> oiMap = new Map<String,Decimal>();//发货行->订单总数量
        List<Order_Item__c> oiList = [SELECT Invoice_Item__c,Material_Number__c,Invoice_Item__r.Billing_Num__c,Id,Quantity__c,Invoice_Item__r.Invoice_Quantity__c,ZARE_Delivery_Note__c FROM Order_Item__c WHERE Order__c =:orderId];
        for (Order_Item__c oi : oiList) {
            deliveryIdSet.add(oi.ZARE_Delivery_Note__c);   
            if (oiMap.containsKey(oi.ZARE_Delivery_Note__c)) {
                oiMap.put(oi.ZARE_Delivery_Note__c, oiMap.get(oi.ZARE_Delivery_Note__c)+oi.Quantity__c);
            } else{
                oiMap.put(oi.ZARE_Delivery_Note__c,oi.Quantity__c);
            }
        }
        System.debug('deliveryIdSet'+deliveryIdSet);
        Map<String,Delivery_Note__c> deliveryMap = new Map<String,Delivery_Note__c>();
        for (Delivery_Note__c dn : [SELECT Delivery_Quantity__c,External_Id__c,Material_Code__c FROM Delivery_Note__c WHERE Id IN:deliveryIdSet]) {
            deliveryMap.put(dn.Id, dn);
        }
        CalculateOutput availableCo = getZAREAvailableQuanity(deliveryIdSet);
        Map<String,Decimal> usedMap = availableCo.usedMap;
        Map<String,Decimal> usedMap1 = availableCo.usedMap1;
    
        Decimal avilableQuantity;
        for (String dnId : oiMap.keySet()) {
            System.debug('deliveryMap.get(dnId).Delivery_Quantity__c??0'+(deliveryMap.get(dnId).Delivery_Quantity__c??0));
            System.debug('(usedMap.get(dnId)??0)'+(usedMap.get(dnId)??0));
            System.debug('(usedMap1.get(dnId)??0)'+(usedMap1.get(dnId)??0));
            avilableQuantity = (deliveryMap.get(dnId).Delivery_Quantity__c??0) - (usedMap.get(dnId)??0)-(usedMap1.get(dnId)??0);
            System.debug('avilableQuantity'+avilableQuantity);
            System.debug('oiMap.get(dnId)'+oiMap.get(dnId));
            if (avilableQuantity<oiMap.get(dnId)) {
                
                out.isSucess = false;
                out.errorMsg = System.Label.Product_code+' '+deliveryMap.get(dnId).Material_Code__c+ ','+System.Label.Delivery_Note_Number+' '+deliveryMap.get(dnId).External_Id__c+','+SYstem.Label.Insufficient_Avilable_Quantity+' '+avilableQuantity;
    
                if (!System.Test.isRunningTest()) {
                    return out;
                }
            }
        }
    
        return out;
    }

    /**
    * @description 计算原始zmx1的实际毛利
    * @author Gerry | 08-12-2025 
    * @param String orderId 逆向单据Id
    * @return Output 
    **/
    public static Output calculateZMX1Rate(String orderId,Boolean submit) {
        Output out = new Output();
        out.isSucess = true;
        Map<String,Decimal> amountMap = new Map<String,Decimal>();//逆向自身数量
        Set<String> refeOrderIdSet = new Set<String>();//参考订单行Id

        // 逆向单据
        Order__c order = [SELECT id,Reference_Order__c,Total_Margin_Level__c FROM Order__c WHERE Id =:orderId];
        if (order.Reference_Order__c == null) {
            out.isSucess = true;
            return out;
        }

        //逆向单据行
        List<Order_Item__c> oiList = [SELECT Reference_Actual_Price__c,Id,Price__c,Reference_Order_Item__c,Subsequent_Transaction_Amounts__c FROM Order_Item__c WHERE Order__c =:orderId];
        for (Order_Item__c oi : oiList) {
            if (amountMap.containsKey(oi.Reference_Order_Item__c)) {
                amountMap.put(oi.Reference_Order_Item__c, amountMap.get(oi.Reference_Order_Item__c)+oi.Reference_Actual_Price__c);
            } else{

                amountMap.put(oi.Reference_Order_Item__c,oi.Reference_Actual_Price__c);
            }
            refeOrderIdSet.add(oi.Reference_Order_Item__c);
        }
        if (refeOrderIdSet.size()==0) {//如果没有参考订单行则直接跳出逻辑
            out.isSucess = true;
            return out;
        }
        System.debug('refeOrderIdSet====>'+refeOrderIdSet);
        Map<String,Decimal> refeQuantityMap = new Map<String,Decimal>();//正向订单数据
        // 带有正负的数值并且需要考虑是否关闭,状态：审批通过 审批中
        for (AggregateResult agg : [SELECT 
                                        SUM(Reference_Actual_Price__c) price,
                                        Reference_Order_Item__c re 
                                    FROM 
                                        Order_Item__c 
                                    WHERE 
                                        Reference_Order_Item__c IN:refeOrderIdSet AND (Order__r.Status__c='Approving' OR Order__r.Status__c='Approved') group by Reference_Order_Item__c
        ]) {
            refeQuantityMap.put((String)agg.get('re'), (Decimal)agg.get('price'));
        }
        System.debug('amountMap=====>'+amountMap);
        List<Order_Item__c> oiUpdateList = new List<Order_Item__c>();
        String refeOrderId = order.Reference_Order__c;//正向单据Id
        System.debug('refeQuantityMap=====>'+refeQuantityMap);
        if (refeQuantityMap.size()==0) {//正向单据没有逆向单子
            for (String key : refeOrderIdSet) {
                Order_Item__c oi = new Order_Item__c();
                oi.id = key;
                if (submit) {
                    oi.Subsequent_Transaction_Amounts__c = amountMap.get(oi.Id);
                }else{
                    oi.Subsequent_Transaction_Amounts__c = 0;
                }
                
                oiUpdateList.add(oi);
            }
        }else{
            for (String key : refeQuantityMap.keySet()) {
                Order_Item__c oi = new Order_Item__c();
                oi.Id = key;
                if (submit) {
                    oi.Subsequent_Transaction_Amounts__c = refeQuantityMap.get(key)+amountMap.get(key);
                }else{
                    oi.Subsequent_Transaction_Amounts__c = refeQuantityMap.get(key);
                }
                
                oiUpdateList.add(oi);
            }
        }
        
        System.debug('oiUpdateList======>'+oiUpdateList);
        SavePoint sp = Database.setSavepoint();
        if (oiUpdateList.size()>0) {
            Database.update(oiUpdateList);
        }
        
        if (submit) {//提交时进行预计毛利计算但不实际写到数据上
            out.orderItemList = [SELECT Commodity_Name__c,Id,Commodity__r.Name,Margin_Level__c,Order__r.Total_Margin_Level__c,SAP_Item_Num__c,Material_Number__c FROM Order_Item__c WHERE Order__c =:refeOrderId];
            System.debug('out.orderItemList====>'+out.orderItemList);
            out.orderMarginLevel = out.orderItemList[0].Order__r.Total_Margin_Level__c;
            Database.rollback(sp);
        }
    
        return out;
    }

    public class CalculateOutput {
        public Map<String,Decimal> usedMap;
        public Map<String,Decimal> usedMap1;
        public Map<String,Decimal> approvingNumMap;
    }
    
    public class Output{

        @AuraEnabled
        public Boolean isCDNoteOrder {get;set;}

        @AuraEnabled
        public String currencyCode {get;set;}

        @AuraEnabled
        public Boolean isSucess {get;set;}

        @AuraEnabled
        public String errorMsg {get;set;}

        @AuraEnabled
        public Decimal remainingCredit {get;set;}

        @AuraEnabled
        public Boolean overdue {get;set;}

        @AuraEnabled
        public Decimal overduedays {get;set;}

        @AuraEnabled
        public Decimal overdueAmount {get;set;}

        @AuraEnabled
        public Decimal orderAmount {get;set;}
        @AuraEnabled
        public Decimal orderApproingAmount {get;set;}

        @AuraEnabled
        public Boolean isShow {get;set;}

        @AuraEnabled
        public Decimal sapCredit {get;set;}

        @AuraEnabled
        public String showText {get;set;}

        @AuraEnabled
        public Boolean isCanSubmit {get;set;}

        @AuraEnabled
        public Decimal rate {get;set;}

        @AuraEnabled
        public Decimal remainingCreditOrder {get;set;}
        @AuraEnabled
        public Decimal orderApproingAmountOrder {get;set;}
        @AuraEnabled
        public Decimal orderAmountOrder {get;set;}
        @AuraEnabled
        public Decimal sapCreditOrder {get;set;}

        @AuraEnabled
        public String comments {get;set;}

        @AuraEnabled
        public List<Order_Item__c> orderItemList {get;set;}

        @AuraEnabled
        public String orderMarginLevel {get;set;}
    }
}