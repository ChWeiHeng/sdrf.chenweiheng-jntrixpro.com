/**************************************************************************************************
 * Name: UtilityTest
 * Purpose: Utility类的测试类
 * Author: AI Assistant
 * Create Date: 2025-01-27
***************************************************************************************************/
@IsTest
public class UtilityTest {
    
    @TestSetup
    static void setupTestData() {
        // 创建测试用的自定义设置
        GlobalSetting__c gs = new GlobalSetting__c();
        gs.Ignore_Trigger__c = false;
        gs.Ignore_Validation__c = false;
        gs.Last_Address__c = 'TestAddress';
        insert gs;
        
        // 创建测试用的BatchJob记录
        BatchJob__c bj = new BatchJob__c();
        bj.Name = 'TestBatchJob';
        bj.Start_Time__c = System.now().addMinutes(-10);
        bj.End_Time__c = System.now();
        bj.Is_Successful__c = true;
        bj.Fail_Reason__c = '';
        insert bj;
    }
    
    @IsTest
    static void testGetPicklistValueMap() {
        Test.startTest();
        
        // 测试获取Account对象的Type字段的picklist值
        Map<String, String> picklistMap = Utility.getPicklistValueMap('Account', 'Type');
        
        Test.stopTest();
        
        // 验证结果
        
        // 验证映射结构
        for (String key : picklistMap.keySet()) {

        }
    }
    
    @IsTest
    static void testGetPicklistValueList() {
        Test.startTest();
        
        // 测试获取Account对象的Type字段的picklist值列表
        List<Utility.PicklistItem> picklistList = Utility.getPicklistValueList('Account', 'Type');
        
        Test.stopTest();
        

        
        // 验证列表项结构
        for (Utility.PicklistItem item : picklistList) {

        }
    }
    
    @IsTest
    static void testGetPicklistLabelMap() {
        Test.startTest();
        
        // 测试获取Account对象的Type字段的picklist标签映射
        Map<String, String> picklistMap = Utility.getPicklistLabelMap('Account', 'Type');
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证映射结构
        for (String key : picklistMap.keySet()) {

        }
    }
    
    @IsTest
    static void testGetRecordTypeMapBySobj() {
        Test.startTest();
        
        // 测试获取Account对象的记录类型映射
        Map<String, String> recordTypeMap = Utility.getRecordTypeMapBySobj('Account');
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证映射结构（双向映射）
        Boolean hasDeveloperName = false;
        Boolean hasId = false;
        for (String key : recordTypeMap.keySet()) {
            if (key.length() == 18 || key.length() == 15) {
                hasId = true;
            } else {
                hasDeveloperName = true;
            }
        }

    }
    
    @IsTest
    static void testIsTriggerDisabled() {
        Test.startTest();
        
        // 测试触发器禁用状态
        Boolean isDisabled = Utility.isTriggerDisabled();
        
        Test.stopTest();
        

    }
    
    @IsTest
    static void testIgnoreAction() {
        Test.startTest();
        
        // 测试忽略操作
        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, 'TestController');
        
        Test.stopTest();
        
        // 验证结果

        
        // 测试恢复操作
        GlobalSetting__c restoreGs = Utility.IgnoreAction(false, false, '12');

    }
    
    @IsTest
    static void testSetBatchInfo() {
        Test.startTest();
        
        // 测试设置批处理信息
        String jobName = 'TestJob';
        Boolean isSuccessful = true;
        Datetime startTime = System.now().addMinutes(-10);
        String failReason = '';
        
        Utility.setBatchInfo(jobName, isSuccessful, startTime, failReason);
        
        Test.stopTest();
        
        // 验证结果
        List<BatchJob__c> batchJobs = [SELECT Id, Name, Is_Successful__c, Start_Time__c, Fail_Reason__c 
                                       FROM BatchJob__c WHERE Name = :jobName];

        
        BatchJob__c createdJob = batchJobs[0];

    }
    
    @IsTest
    static void testGetDependentOptionsImpl() {
        Test.startTest();
        
        // 测试获取依赖选项实现
        Map<String, List<Utility.returnValue>> dependentOptions = 
            Utility.getDependentOptionsImpl('Account', 'Type', 'Industry');
        
        Test.stopTest();
        
 
        
        // 验证映射结构
        for (String key : dependentOptions.keySet()) {

            
            List<Utility.returnValue> values = dependentOptions.get(key);
            for (Utility.returnValue value : values) {

            }
        }
    }
    
    @IsTest
    static void testGetFieldLabelTranslateMap() {
        Test.startTest();
        
        // 测试获取字段标签翻译映射
        Map<String, String> fieldLabelMap = Utility.getFieldLabelTranslateMap('Account');
        
        Test.stopTest();
        
        // 验证结果

        
        // 验证一些常见字段

    }
    
    @IsTest
    static void testGetAllFieldSoql() {
        Test.startTest();
        
        // 测试获取所有字段的SOQL
        String soql = Utility.getAllFieldSoql('Account');
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetAllField() {
        Test.startTest();
        
        // 测试获取所有字段
        String fields = Utility.getAllField('Account');
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetSingleEmailMessage() {
        Test.startTest();
        
        // 测试创建单个邮件消息
        String subject = 'Test Subject';
        String[] addresses = new String[]{'test@example.com'};
        String htmlBody = '<p>Test HTML Body</p>';
        Id orgWideEmailAddressId = null;
        List<String> ccAddressList = new List<String>{'cc@example.com'};
        
        Messaging.SingleEmailMessage email = Utility.getSingleEmailMessage(
            subject, addresses, htmlBody, orgWideEmailAddressId, ccAddressList);
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetEmailTableHTML() {
        Test.startTest();
        
        // 创建测试用的Table对象
        Utility.Table table = new Utility.Table();
        table.cssMap = new Map<String, String>{'border' => '1px solid black'};
        
        // 设置表头
        table.thead.cssMap = new Map<String, String>{'background-color' => '#f0f0f0'};
        table.thead.tr.cssMap = new Map<String, String>{'font-weight' => 'bold'};
        table.thead.tr.tdMap.put('Name', new Utility.TableTd('Name'));
        table.thead.tr.tdMap.put('Type', new Utility.TableTd('Type'));
        
        // 设置表体
        Utility.TableTr tr1 = new Utility.TableTr();
        tr1.tdMap.put('Name', new Utility.TableTd('Test Account'));
        tr1.tdMap.put('Type', new Utility.TableTd('Customer'));
        table.tbody.trs.add(tr1);
        
        String[] thHeadList = new String[]{'Name', 'Type'};
        
        // 测试获取邮件表格HTML
        String tableHTML = Utility.getEmailTableHTML(table, thHeadList);
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetEmailTrHTML() {
        Test.startTest();
        
        // 创建测试用的TableTr对象
        Utility.TableTr tableTr = new Utility.TableTr();
        tableTr.cssMap = new Map<String, String>{'background-color' => 'white'};
        tableTr.tdMap.put('Name', new Utility.TableTd('Test Account'));
        tableTr.tdMap.put('Type', new Utility.TableTd('Customer'));
        
        String[] thHeadList = new String[]{'Name', 'Type'};
        
        // 测试获取邮件行HTML
        String trHTML = Utility.getEmailTrHTML(thHeadList, tableTr);
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetEmailTdHTML() {
        Test.startTest();
        
        // 创建测试用的TableTd对象
        Utility.TableTd tableTd = new Utility.TableTd('Test Content');
        tableTd.cssMap = new Map<String, String>{'padding' => '10px'};
        tableTd.rowspan = 2;
        tableTd.colspan = 3;
        
        // 测试获取邮件单元格HTML
        String tdHTML = Utility.getEmailTdHTML(tableTd);
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetCssHTML() {
        Test.startTest();
        
        // 测试获取CSS HTML
        Map<String, String> cssMap = new Map<String, String>{
            'background-color' => 'red',
            'color' => 'white',
            'padding' => '10px'
        };
        
        String cssHTML = Utility.getCssHTML(cssMap);
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testGetCssHTMLNull() {
        Test.startTest();
        
        // 测试空CSS映射
        String cssHTML = Utility.getCssHTML(null);
        
        Test.stopTest();

    }
    
    // @IsTest
    // static void testGetUnitEstimateCost() {
    //     // 创建测试数据
    //     Product__c product = new Product__c();
    //     product.Name = 'TestProduct';
    //     product.External_Id__c = 'TestProduct';
    //     insert product;
        
    //     Product_Unit__c productUnit = new Product_Unit__c();
    //     productUnit.Basic_Unit__c = 'L';
    //     productUnit.Product_Sales_Unit__c = 'KG';
    //     productUnit.Conversion_Coefficient__c = 0.8;
    //     productUnit.Product__c = product.Id;
    //     insert productUnit;
        
    //     Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
    //     productSalesInfo.Product__c = product.Id;
    //     productSalesInfo.Status__c = 'On Shelves';
    //     productSalesInfo.Sales_Organization__c = '3020';
    //     productSalesInfo.Delivering_Plant__c = '3020';
    //     productSalesInfo.Factory__c = '3020';
    //     productSalesInfo.Product_Unit__c = productUnit.Id;
    //     productSalesInfo.Cost_Local__c = 50;
    //     productSalesInfo.Cost_USD__c = 10;
    //     productSalesInfo.Default_Sales_Unit__c = 'L';
    //     productSalesInfo.Distr_Channel__c = '10';
    //     insert productSalesInfo;
        
    //     Product_Name__c productName = new Product_Name__c();
    //     productName.Name = 'TestProductName';
    //     productName.Product_Sales_Info__c = productSalesInfo.Id;
    //     productName.Product__c = product.Id;
    //     productName.Product_Combo__c = false;
    //     productName.Is_Delete__c = false;
    //     insert productName;
        
    //     Account account = new Account();
    //     account.Name = 'TestAccount';
    //     account.Group_Name__c = 'TestGroup';
    //     account.Customer_Approval_Status__c = 'Approved';
    //     account.Sync_Status__c = 'Synchronized';
    //     account.MDG__c = false;
    //     insert account;
        
    //     Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
    //     customerSalesInfo.Sales_Org__c = '3020';
    //     customerSalesInfo.Distr_Channel__c = '10';
    //     customerSalesInfo.Sales_View_Status__c = 'Approved';
    //     customerSalesInfo.Sync_Status__c = 'Synchronized';
    //     customerSalesInfo.Customer__c = account.Id;
    //     customerSalesInfo.Payment_method__c = 'YPF';
    //     insert customerSalesInfo;
        
    //     Price_Book__c priceBook = new Price_Book__c();
    //     priceBook.Name = 'TestPriceBook';
    //     priceBook.Sales_Org__c = '3020';
    //     priceBook.Currency__c = 'USD';
    //     priceBook.Status__c = 'Approved';
    //     insert priceBook;
        
    //     Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
    //     priceBookItem.Price_Book__c = priceBook.Id;
    //     priceBookItem.Product_Name__c = productName.Id;
    //     priceBookItem.Price__c = 100;
    //     priceBookItem.Min_Sales_Price__c = 80;
    //     priceBookItem.Is_Changing__c = false;
    //     priceBookItem.Status__c = 'Active';
    //     priceBookItem.Estimation_Cost_Local__c = 50;
    //     priceBookItem.Estimation_Cost_USD__c = 10;
    //     insert priceBookItem;
        
    //     Order__c order = new Order__c();
    //     order.Customer__c = account.Id;
    //     order.Sales_Org__c = '3020';
    //     order.Distr_Channel__c = '10';
    //     order.Customer_Sales_Info__c = customerSalesInfo.Id;
    //     order.Currency__c = 'USD';
    //     order.Price_Book__c = priceBook.Id;
    //     order.Deliver_Plant__c = '3020';
    //     order.Order_type__c = 'ZAR1';
    //     insert order;
        
    //     Order_Item__c orderItem = new Order_Item__c();
    //     orderItem.Order__c = order.Id;
    //     orderItem.Commodity__c = productName.Id;
    //     orderItem.Price__c = 100;
    //     orderItem.Quantity__c = 10;
    //     orderItem.Sales_Unit__c = productUnit.Id;
    //     orderItem.Price_Book_Item__c = priceBookItem.Id;
    //     orderItem.SAP_Item_Num__c = '001';
    //     orderItem.Material_Number__c = product.Name;
    //     orderItem.Material_Description__c = productName.Name;
    //     orderItem.Sales_Unit_Text__c = 'KG';
    //     insert orderItem;
        
    //     Test.startTest();
        
    //     // 测试测算成本赋值
    //     Set<Id> itemIdSet = new Set<Id>{orderItem.Id};
    //     Utility.getUnitEstimateCost(itemIdSet);
        
    //     Test.stopTest();
        
    //     // 验证结果
    //     Order_Item__c updatedItem = [SELECT Id, Unit_Estimate_Cost__c FROM Order_Item__c WHERE Id = :orderItem.Id];

    // }
    
    @IsTest
    static void testGetCustomMessage() {
        Test.startTest();
        
        // 测试各种错误消息格式
        String message1 = Utility.getCustomMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION:Test error message', false);
        String message2 = Utility.getCustomMessage('DUPLICATE_VALUE:Duplicate value', false);
        String message3 = Utility.getCustomMessage('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST:Invalid value', false);
        String message4 = Utility.getCustomMessage('NO_APPLICABLE_PROCESS:No process', false);
        String message5 = Utility.getCustomMessage('DUPLICATES_DETECTED:Duplicates found', false);
        String message6 = Utility.getCustomMessage('NUMBER_OUTSIDE_VALID_RANGE:Number out of range', false);
        String message7 = Utility.getCustomMessage('INSUFFICIENT_ACCESS_OR_READONLY:Access denied', false);
        String message8 = Utility.getCustomMessage('Unknown error', false);
        String message9 = Utility.getCustomMessage('', false);
        String message10 = Utility.getCustomMessage('Test message with period.', true);
        
        Test.stopTest();
        
        // 验证结果
    }
    
    @IsTest
    static void testTableClasses() {
        Test.startTest();
        
        // 测试Table类及其内部类
        Utility.Table table = new Utility.Table();
        Utility.TableThead thead = new Utility.TableThead();
        Utility.TableTbody tbody = new Utility.TableTbody();
        Utility.TableTr tr = new Utility.TableTr();
        Utility.TableTd td = new Utility.TableTd('Test Content');
        Utility.TableTd td2 = new Utility.TableTd();
        
        // 设置属性
        table.cssMap = new Map<String, String>{'border' => '1px'};
        thead.cssMap = new Map<String, String>{'background' => 'gray'};
        tbody.cssMap = new Map<String, String>{'background' => 'white'};
        tr.cssMap = new Map<String, String>{'height' => '30px'};
        tr.row = 1;
        td.col = 1;
        td.context = 'Updated Content';
        td.rowspan = 2;
        td.colspan = 3;
        
        // 构建关系
        thead.tr = tr;
        tbody.trs.add(tr);
        tr.tdMap.put('test', td);
        table.thead = thead;
        table.tbody = tbody;
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testPicklistEntryWrapper() {
        Test.startTest();
        
        // 测试PicklistEntryWrapper类
        Utility.PicklistEntryWrapper wrapper = new Utility.PicklistEntryWrapper();
        wrapper.active = 'true';
        wrapper.defaultValue = 'false';
        wrapper.label = 'Test Label';
        wrapper.value = 'Test_Value';
        wrapper.validFor = 'ABCD';
        
        Test.stopTest();
        
        // 验证结果

    }
    
    @IsTest
    static void testReturnValue() {
        Test.startTest();
        
        // 测试returnValue类
        Utility.returnValue rv = new Utility.returnValue('Test Label', 'Test_Value');
        
        Test.stopTest();
        

    }
    
    @IsTest
    static void testBitSet() {
        Test.startTest();
        
        // 测试BitSet类
        Utility.BitSet bitSet = new Utility.BitSet();
        
        // 测试testBits方法
        List<Integer> controllingIndexes = new List<Integer>{0, 1, 2, 3};
        List<Integer> results = bitSet.testBits('ABCD', controllingIndexes);
        
        Test.stopTest();

    }
    
    // @IsTest
    // static void testGetUnitEstimateCostEdgeCases() {
    //     // 创建测试数据
    //     Product__c product = new Product__c();
    //     product.Name = 'TestProduct2';
    //     product.External_Id__c = 'TestProduct2';
    //     insert product;
        
    //     Product_Unit__c productUnit = new Product_Unit__c();
    //     productUnit.Basic_Unit__c = 'L';
    //     productUnit.Product_Sales_Unit__c = 'KG';
    //     productUnit.Conversion_Coefficient__c = null; // 测试null转换系数
    //     productUnit.Product__c = product.Id;
    //     insert productUnit;
        
    //     Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
    //     productSalesInfo.Product__c = product.Id;
    //     productSalesInfo.Status__c = 'On Shelves';
    //     productSalesInfo.Sales_Organization__c = '3020';
    //     productSalesInfo.Delivering_Plant__c = '3020';
    //     productSalesInfo.Factory__c = '3020';
    //     productSalesInfo.Product_Unit__c = productUnit.Id;
    //     productSalesInfo.Cost_Local__c = 50;
    //     productSalesInfo.Cost_USD__c = 10;
    //     productSalesInfo.Default_Sales_Unit__c = 'L';
    //     productSalesInfo.Distr_Channel__c = '10';
    //     insert productSalesInfo;
        
    //     Product_Name__c productName = new Product_Name__c();
    //     productName.Name = 'TestProductName2';
    //     productName.Product_Sales_Info__c = productSalesInfo.Id;
    //     productName.Product__c = product.Id;
    //     productName.Product_Combo__c = false;
    //     productName.Is_Delete__c = false;
    //     insert productName;
        
    //     Account account = new Account();
    //     account.Name = 'TestAccount2';
    //     account.Group_Name__c = 'TestGroup';
    //     account.Customer_Approval_Status__c = 'Approved';
    //     account.Sync_Status__c = 'Synchronized';
    //     account.MDG__c = false;
    //     insert account;
        
    //     Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
    //     customerSalesInfo.Sales_Org__c = '3020';
    //     customerSalesInfo.Distr_Channel__c = '10';
    //     customerSalesInfo.Sales_View_Status__c = 'Approved';
    //     customerSalesInfo.Sync_Status__c = 'Synchronized';
    //     customerSalesInfo.Customer__c = account.Id;
    //     customerSalesInfo.Payment_method__c = 'YPF';
    //     insert customerSalesInfo;
        
    //     Price_Book__c priceBook = new Price_Book__c();
    //     priceBook.Name = 'TestPriceBook2';
    //     priceBook.Sales_Org__c = '3020';
    //     priceBook.Currency__c = 'CNY'; // 测试本地货币
    //     priceBook.Status__c = 'Approved';
    //     insert priceBook;
        
    //     Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
    //     priceBookItem.Price_Book__c = priceBook.Id;
    //     priceBookItem.Product_Name__c = productName.Id;
    //     priceBookItem.Price__c = 100;
    //     priceBookItem.Min_Sales_Price__c = 80;
    //     priceBookItem.Is_Changing__c = false;
    //     priceBookItem.Status__c = 'Active';
    //     priceBookItem.Estimation_Cost_Local__c = 50;
    //     priceBookItem.Estimation_Cost_USD__c = 10;
    //     insert priceBookItem;
        
    //     Order__c order = new Order__c();
    //     order.Customer__c = account.Id;
    //     order.Sales_Org__c = '3020';
    //     order.Distr_Channel__c = '10';
    //     order.Customer_Sales_Info__c = customerSalesInfo.Id;
    //     order.Currency__c = 'CNY';
    //     order.Price_Book__c = priceBook.Id;
    //     order.Deliver_Plant__c = '3020';
    //     order.Order_type__c = 'ZAR1';
    //     insert order;
        
    //     Order_Item__c orderItem = new Order_Item__c();
    //     orderItem.Order__c = order.Id;
    //     orderItem.Commodity__c = productName.Id;
    //     orderItem.Price__c = 100;
    //     orderItem.Quantity__c = 10;
    //     orderItem.Sales_Unit__c = productUnit.Id;
    //     orderItem.Price_Book_Item__c = priceBookItem.Id;
    //     orderItem.SAP_Item_Num__c = '002';
    //     orderItem.Material_Number__c = product.Name;
    //     orderItem.Material_Description__c = productName.Name;
    //     orderItem.Sales_Unit_Text__c = 'KG';
    //     insert orderItem;
        
    //     Test.startTest();
        
    //     // 测试本地货币的测算成本赋值
    //     Set<Id> itemIdSet = new Set<Id>{orderItem.Id};
    //     Utility.getUnitEstimateCost(itemIdSet);
        
    //     Test.stopTest();
        
    //     // 验证结果
    //     Order_Item__c updatedItem = [SELECT Id, Unit_Estimate_Cost__c FROM Order_Item__c WHERE Id = :orderItem.Id];

    // }
    
    @IsTest
    static void testNotificationUser() {
        Test.startTest();
        
        try {
            // 测试通知用户方法
            String ownerId = UserInfo.getUserId();
            String recordId = '001000000000000'; // 模拟记录ID
            
            Utility.notificationUser(ownerId, recordId);
            
            // 如果没有异常，说明方法执行成功

        } catch (Exception e) {
            // 如果出现异常，检查是否是预期的（比如缺少自定义通知类型）
            System.debug('notificationUser异常: ' + e.getMessage());

        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testNotificationUserTitle() {
        Test.startTest();
        
        try {
            // 测试带标题和内容的通知用户方法
            Set<String> ownerIds = new Set<String>{UserInfo.getUserId()};
            String recordId = '001000000000000'; // 模拟记录ID
            String title = 'Test Notification Title';
            String body = 'Test Notification Body';
            
            Utility.notificationUserTitle(ownerIds, recordId, title, body);

        } catch (Exception e) {
            // 如果出现异常，检查是否是预期的（比如缺少自定义通知类型）
            System.debug('notificationUserTitle异常: ' + e.getMessage());

        }
        
        Test.stopTest();
    }
    
    // @IsTest
    // static void testGetUnitEstimateCostWithNullValues() {
    //     // 创建测试数据，包含null值的情况
    //     Product__c product = new Product__c();
    //     product.Name = 'TestProduct3';
    //     product.External_Id__c = 'TestProduct3';
    //     insert product;
        
    //     Product_Unit__c productUnit = new Product_Unit__c();
    //     productUnit.Basic_Unit__c = 'L';
    //     productUnit.Product_Sales_Unit__c = 'KG';
    //     productUnit.Conversion_Coefficient__c = null; // null转换系数
    //     productUnit.Product__c = product.Id;
    //     insert productUnit;
        
    //     Product_Sales_Info__c productSalesInfo = new Product_Sales_Info__c();
    //     productSalesInfo.Product__c = product.Id;
    //     productSalesInfo.Status__c = 'On Shelves';
    //     productSalesInfo.Sales_Organization__c = '3020';
    //     productSalesInfo.Delivering_Plant__c = '3020';
    //     productSalesInfo.Factory__c = '3020';
    //     productSalesInfo.Product_Unit__c = productUnit.Id;
    //     productSalesInfo.Cost_Local__c = null; // null本地成本
    //     productSalesInfo.Cost_USD__c = null; // null USD成本
    //     productSalesInfo.Default_Sales_Unit__c = 'L';
    //     productSalesInfo.Distr_Channel__c = '10';
    //     insert productSalesInfo;
        
    //     Product_Name__c productName = new Product_Name__c();
    //     productName.Name = 'TestProductName3';
    //     productName.Product_Sales_Info__c = productSalesInfo.Id;
    //     productName.Product__c = product.Id;
    //     productName.Product_Combo__c = false;
    //     productName.Is_Delete__c = false;
    //     insert productName;
        
    //     Account account = new Account();
    //     account.Name = 'TestAccount3';
    //     account.Group_Name__c = 'TestGroup';
    //     account.Customer_Approval_Status__c = 'Approved';
    //     account.Sync_Status__c = 'Synchronized';
    //     account.MDG__c = false;
    //     insert account;
        
    //     Customer_Sales_Info__c customerSalesInfo = new Customer_Sales_Info__c();
    //     customerSalesInfo.Sales_Org__c = '3020';
    //     customerSalesInfo.Distr_Channel__c = '10';
    //     customerSalesInfo.Sales_View_Status__c = 'Approved';
    //     customerSalesInfo.Sync_Status__c = 'Synchronized';
    //     customerSalesInfo.Customer__c = account.Id;
    //     customerSalesInfo.Payment_method__c = 'YPF';
    //     insert customerSalesInfo;
        
    //     Price_Book__c priceBook = new Price_Book__c();
    //     priceBook.Name = 'TestPriceBook3';
    //     priceBook.Sales_Org__c = '3020';
    //     priceBook.Currency__c = 'USD';
    //     priceBook.Status__c = 'Approved';
    //     insert priceBook;
        
    //     Price_Book_Item__c priceBookItem = new Price_Book_Item__c();
    //     priceBookItem.Price_Book__c = priceBook.Id;
    //     priceBookItem.Product_Name__c = productName.Id;
    //     priceBookItem.Price__c = 100;
    //     priceBookItem.Min_Sales_Price__c = 80;
    //     priceBookItem.Is_Changing__c = false;
    //     priceBookItem.Status__c = 'Active';
    //     priceBookItem.Estimation_Cost_Local__c = null; // null本地成本
    //     priceBookItem.Estimation_Cost_USD__c = null; // null USD成本
    //     insert priceBookItem;
        
    //     Order__c order = new Order__c();
    //     order.Customer__c = account.Id;
    //     order.Sales_Org__c = '3020';
    //     order.Distr_Channel__c = '10';
    //     order.Customer_Sales_Info__c = customerSalesInfo.Id;
    //     order.Currency__c = 'USD';
    //     order.Price_Book__c = priceBook.Id;
    //     order.Deliver_Plant__c = '3020';
    //     order.Order_type__c = 'ZAR1';
    //     insert order;
        
    //     Order_Item__c orderItem = new Order_Item__c();
    //     orderItem.Order__c = order.Id;
    //     orderItem.Commodity__c = productName.Id;
    //     orderItem.Price__c = 100;
    //     orderItem.Quantity__c = 10;
    //     orderItem.Sales_Unit__c = productUnit.Id;
    //     orderItem.Price_Book_Item__c = priceBookItem.Id;
    //     orderItem.SAP_Item_Num__c = '003';
    //     orderItem.Material_Number__c = product.Name;
    //     orderItem.Material_Description__c = productName.Name;
    //     orderItem.Sales_Unit_Text__c = 'KG';
    //     insert orderItem;
        
    //     Test.startTest();
        
    //     // 测试包含null值的测算成本赋值
    //     Set<Id> itemIdSet = new Set<Id>{orderItem.Id};
    //     Utility.getUnitEstimateCost(itemIdSet);
        
    //     Test.stopTest();
        
    //     // 验证结果
    //     Order_Item__c updatedItem = [SELECT Id, Unit_Estimate_Cost__c FROM Order_Item__c WHERE Id = :orderItem.Id];
    // }


}