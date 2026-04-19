- # 客户(Account)模块详细业务逻辑文档

  ## 目录

  1. [模块概述](#一模块概述)
  2. [核心对象详解](#二核心对象详解)
  3. [关联子对象](#三关联子对象)
  4. [触发器链路](#四触发器链路)
  5. [审批流程体系](#五审批流程体系)
  6. [SAP接口同步](#六sap接口同步)
  7. [业务流程图](#七业务流程图)
  8. [字段映射表](#八字段映射表)
  9. [代码片段解析](#九代码片段解析)
  10. [异常处理机制](#十异常处理机制)
  11. [相关文件清单](#十一相关文件清单)

  ---

  ## 一、模块概述

  ### 1.1 功能说明

  客户模块是CRM系统的核心模块之一，负责管理客户主数据、客户销售视图、信用额度等信息，并与SAP系统进行双向同步。

  ### 1.2 核心业务流程

  ```
  客户创建 → 客户审批 → 销售视图创建 → 销售视图审批 → 信用额度申请 → SAP同步
       ↓           ↓            ↓              ↓             ↓          ↓
    自动分配    状态联动      税收类别        状态联动      额度变更    实时同步
    客户小组    销售视图      自动创建        SAP同步      审批通过    状态回写
  ```

  ### 1.3 销售组织编码说明

  |         销售组织代码          | 说明           | 地区 |
  | :---------------------------: | -------------- | :--: |
  | 1040/1050/1060/1080/2010/2210 | 总部销售组织   |  HQ  |
  |           3010/3020           | MX工厂销售组织 |  MX  |
  |           5070/5130           | AR工厂销售组织 |  AR  |

  ---

  ## 二、核心对象详解

  ### 2.1 Account（客户主数据）

  #### 2.1.1 关键字段

  | 字段API名                     | 字段标签       | 数据类型 | 说明                                                |
  | ----------------------------- | -------------- | -------- | --------------------------------------------------- |
  | `Customer_Approval_Status__c` | 客户审批状态   | Picklist | Draft/Approving/Approved/Rejected                   |
  | `MDG_Customer_Code__c`        | MDG客户编码    | Text     | SAP返回的客户编码                                   |
  | `MDG__c`                      | MDG标识        | Checkbox | 是否为MDG客户                                       |
  | `Sync_Status__c`              | 同步状态       | Picklist | Synchronized/Synchronization Failure/Unsynchronized |
  | `Sync_Failure_Reasons__c`     | 同步失败原因   | Text     | 记录SAP同步失败原因                                 |
  | `Customer_Group__c`           | 客户组         | Text     | SAP客户组                                           |
  | `Tax_Number__c`               | 税号           | Text     | 客户税号                                            |
  | `Country__c`                  | 国家           | Lookup   | 国家主数据                                          |
  | `Province_State__c`           | 省份/州        | Lookup   | 省份主数据                                          |
  | `City__c`                     | 城市           | Text     | 城市名称                                            |
  | `Street__c`                   | 街道地址       | Text     | 详细地址                                            |
  | `Postal_Code__c`              | 邮编           | Text     | 邮政编码                                            |
  | `Sinosure_Customer_Code__c`   | 中信保客户编码 | Text     | 中信保系统编码                                      |
  | `Is_YPF__c`                   | 是否YPF客户    | Checkbox | 自动判断是否有YPF付款方式                           |

  #### 2.1.2 审批状态流转

  ```
                      ┌─────────────────┐
                      │     Draft       │ (草稿)
                      └────────┬────────┘
                               │ 提交审批
                               ▼
                      ┌─────────────────┐
                      │   Approving     │ (审批中)
                      └────────┬────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
           审批通过                         审批拒绝
                │                             │
                ▼                             ▼
      ┌─────────────────┐           ┌─────────────────┐
      │    Approved     │           │    Rejected      │
      └─────────────────┘           └─────────────────┘
  ```

  #### 2.1.3 FieldSet说明

  - **Customer_Info**：已审批客户可编辑字段集合
  - **Can_not_change**：已审批客户不可修改字段集合
  - **ChangeFieldByFinance**：MX财务不可修改字段集合

  ---

  ### 2.2 Customer_Sales_Info__c（客户销售视图）

  #### 2.2.1 关键字段

  | 字段API名                   | 字段标签       | 数据类型 | 说明                               |
  | --------------------------- | -------------- | -------- | ---------------------------------- |
  | `Sales_View_Status__c`      | 销售视图状态   | Picklist | Draft/Approving/Approved/Reject    |
  | `Sales_Org__c`              | 销售组织       | Text     | SAP销售组织代码                    |
  | `Distr_Channel__c`          | 分销渠道       | Text     | 分销渠道代码                       |
  | `Division__c`               | 产品组         | Text     | 产品组代码                         |
  | `Delivering_Plant__c`       | 交货工厂       | Text     | 工厂代码(3010/3011/3020/5070/5130) |
  | `Terms_Of_Payment__c`       | 付款条件       | Text     | 付款条件代码                       |
  | `Currency__c`               | 币种           | Text     | 货币代码                           |
  | `Reconciliation_Account__c` | 统驭科目       | Text     | 会计科目编码                       |
  | `Acct_Assmt_Grp_Cust__c`    | 客户科目分配组 | Text     | 01/02                              |
  | `Payment_method__c`         | 付款方式       | Text     | 付款方式代码                       |
  | `Is_Freeze__c`              | 冻结标识       | Text     | 客户冻结状态                       |
  | `External_ID__c`            | 外部ID         | Text     | 客户ID_销售组织_分销渠道           |
  | `Sync_Status__c`            | 同步状态       | Picklist | 同步状态                           |
  | `isSync__c`                 | 是否已同步     | Checkbox | 是否已同步过SAP                    |

  #### 2.2.2 统驭科目自动计算规则

  ```apex
  // 工厂为 3010/3011/3020 时
  if (Delivering_Plant__c == '3010' || '3011' || '3020') {
      if (Acct_Assmt_Grp_Cust__c == '01') {
          Reconciliation_Account__c = '1122010100'; // 应收内部账款-集团内
      }
      if (Acct_Assmt_Grp_Cust__c == '02') {
          Reconciliation_Account__c = '1122020100'; // 应收内部账款-关联方
      }
  }
  
  // 工厂为 5070/5130 时
  if (Delivering_Plant__c == '5070' || '5130') {
      if (Acct_Assmt_Grp_Cust__c == '01') {
          Reconciliation_Account__c = '1122010000'; // 应收账款-一般
      }
      if (Acct_Assmt_Grp_Cust__c == '02') {
          Reconciliation_Account__c = '1122020000'; // 应收账款-关联方
      }
  }
  ```

  ---

  ### 2.3 Customer_Credit_Info__c（客户信用额度）

  #### 2.3.1 关键字段

  | 字段API名                      | 字段标签          | 数据类型 | 说明                 |
  | ------------------------------ | ----------------- | -------- | -------------------- |
  | `Actual_Credit_limit__c`       | 实际信用额度      | Currency | 当前生效的信用额度   |
  | `Local_Credit_Limit__c`        | 本地信用额度      | Currency | 本币信用额度         |
  | `Local_Credit_Line_USD__c`     | 本地信用额度(USD) | Currency | USD计价的额度        |
  | `Sinosure_Credit_Limit__c`     | 中信保信用额度    | Currency | 中信保额度           |
  | `Guarantee_Credit_Line_USD__c` | 保函信用额度(USD) | Currency | 保函额度             |
  | `Clean_Line_USD__c`            | 免保额度(USD)     | Currency | 免保授信额度         |
  | `Remaining_Credit__c`          | 剩余额度          | Currency | 可用信用额度         |
  | `Valid_Until__c`               | 有效期至          | Date     | 额度有效截止日期     |
  | `Rules__c`                     | 规则              | Text     | 信用规则代码         |
  | `Risk_Class__c`                | 风险类别          | Text     | 风险分类             |
  | `Check_Rule__c`                | 检查规则          | Text     | 信用检查规则         |
  | `Credit_Segment__c`            | 信用段            | Text     | 信用分段             |
  | `Type_of_Guarantee__c`         | 担保类型          | Text     | 担保方式             |
  | `Sync_Status__c`               | 同步状态          | Picklist | SAP同步状态          |
  | `ExternalId__c`                | 外部ID            | Text     | 客户ID（用于Upsert） |

  ---

  ### 2.4 Customer_Quota_Change__c（额度变更申请）

  #### 2.4.1 关键字段

  | 字段API名                    | 字段标签       | 数据类型 | 说明             |
  | ---------------------------- | -------------- | -------- | ---------------- |
  | `Approval_Status__c`         | 审批状态       | Picklist | 审批状态         |
  | `Customer__c`                | 客户           | Lookup   | 关联客户         |
  | `Sales_Org__c`               | 销售组织       | Text     | 销售组织代码     |
  | `Post_Application_Credit__c` | 申请后信用额度 | Currency | 申请的新额度     |
  | `Customer_Credit_Line__c`    | 客户信用额度   | Currency | 客户信用额度     |
  | `Valid_After_Change_To__c`   | 变更后有效期   | Date     | 新有效期         |
  | `Rules__c`                   | 规则           | Text     | 信用规则         |
  | `Risk_Class__c`              | 风险类别       | Text     | 风险分类         |
  | `Check_Rule__c`              | 检查规则       | Text     | 检查规则         |
  | `Credit_Segment__c`          | 信用段         | Text     | 信用分段         |
  | `C_C_Approve__c`             | CC审批         | Checkbox | CC级别审批标识   |
  | `Payment_Term_Days__c`       | 账期天数       | Number   | 自动填充付款天数 |
  | `Payment_Term__c`            | 账期           | Text     | 付款条件代码     |

  ---

  ### 2.5 Customer_Tax_Category__c（客户税收类别）

  #### 2.5.1 关键字段

  | 字段API名                     | 字段标签       | 说明                         |
  | ----------------------------- | -------------- | ---------------------------- |
  | `Sales_View__c`               | 销售视图       | 关联Customer_Sales_Info__c   |
  | `Tax_Category_Master_Data__c` | 税收类别主数据 | Lookup到主数据               |
  | `Tax_Category_Type__c`        | 税收类别类型   | 税收类别名称                 |
  | `Tax_Category__c`             | 税收类别       | 完整税收类别编码(格式:XX-YY) |

  ---

  ### 2.6 Customer_Tax_Number_Category__c（客户税号类别）

  #### 2.6.1 关键字段

  | 字段API名                   | 字段标签   | 说明            |
  | --------------------------- | ---------- | --------------- |
  | `Customer__c`               | 客户       | Lookup到Account |
  | `Tax_Number_Master_Data__c` | 税号主数据 | Lookup到主数据  |
  | `Long_Tax_Number__c`        | 长税号     | 完整税号        |

  ---

  ## 三、关联子对象

  > Account 模块下除了核心对象外，还有以下6个关联子对象，用于存储客户的各类业务信息。

  ### 3.1 关联对象总览

  ```
  ┌─────────────────────────────────────────────────────────────────────────────────┐
  │                              Account 关联对象总图                               │
  └─────────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   Account    │
                              │   客户主数据  │
                              └──────┬───────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
        ▼                            ▼                            ▼
  ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
  │   Bank_Info__c  │       │Customer_Tax_    │       │Customer_Shipping│
  │   银行信息       │       │Number_Category__c│      │_Address__c     │
  │                 │       │ 客户税号        │       │ 客户收货地址    │
  └─────────────────┘       └─────────────────┘       └─────────────────┘

  ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
  │ Company_        │       │ Account_        │       │ Sales_Forecast  │
  │ Dynamics__c     │       │ Receivable__c   │       │ _Summary__c     │
  │ 公司动态         │       │ 客户应收账款     │       │ 销售预测汇总    │
  │                 │       │ (SAP同步)       │       │                 │
  └─────────────────┘       └─────────────────┘       └─────────────────┘
                                                         │
                                                         ▼
                                                 ┌─────────────────┐
                                                 │ Sales_Forcast__c │
                                                 │ 销售预测明细     │
                                                 └─────────────────┘
  ```

  ### 3.2 Bank_Info__c（银行信息）

  #### 3.2.1 对象基本信息

  | 属性 | 值 |
  |-----|-----|
  | API Name | `Bank_Info__c` |
  | Label | Bank Info |
  | 名称格式 | `BI-{000000}` |
  | 共享模式 | `ControlledByParent` (受父Account控制) |

  #### 3.2.2 字段列表

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Customer__c` | Customer | Lookup(Account) | 父客户 |
  | `Bank_Key__c` | Bank Key | Text(255) | 银行代码 |
  | `Bank_Name__c` | Bank Name | Text | 银行名称 |
  | `Bank_Acct__c` | Bank Acct | Text | 银行账号 |
  | `Account_Holder__c` | Account Holder | Text | 账户持有人 |
  | `Branch__c` | Branch | Text | 分行 |
  | `C_R__c` | C/R | Text | 银行国家 |
  | `Control_Key__c` | Control Key | Picklist | 控制码 |
  | `Account_Title__c` | Account Title | Text | 账户标题 |
  | `External_Id__c` | External Id | Text | 外部ID |
  | `Valid_Start_Date__c` | Valid Start Date | Date | 生效开始日期 |
  | `Valid_End_Date__c` | Valid End Date | Date | 生效结束日期 |

  #### 3.2.3 触发器逻辑

  **BankInfoTriggerHandler** - 触发时机: After Insert / After Update

  ```
  触发条件:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 1. Account.Customer_Approval_Status__c = 'Approved'                         │
  │ 2. Account.Sync_Status__c = 'Synchronized'                                  │
  │ 3. Account.MDG__c = false                                                   │
  │ 4. 非Batch/非Future执行                                                      │
  └─────────────────────────────────────────────────────────────────────────────┘

  触发行为:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 触发 CustomerInfoSyncToSAP.submitToSAPFu(Customer__c, 'U')                  │
  │ 说明: 银行信息变更时，重新同步客户基本信息到SAP                               │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```

  #### 3.2.4 SAP同步

  银行信息通过 `CustomerInfoSyncToSAP` 接口同步，字段对应:

  | CRM字段 | SAP字段 |
  |--------|--------|
  | `C_R__c` | banks |
  | `Bank_Key__c` | bankl |
  | `Bank_Name__c` | banka |
  | `Bank_Acct__c` | bankn |
  | `Account_Holder__c` | koinh |
  | `Control_Key__c` | accname |

  ---

  ### 3.3 Customer_Shipping_Address__c（客户收货地址）

  #### 3.3.1 对象基本信息

  | 属性 | 值 |
  |-----|-----|
  | API Name | `Customer_Shipping_Address__c` |
  | Label | Customer Shipping Address |
  | 名称格式 | `CSA-{000000}` |
  | 共享模式 | `ControlledByParent` |

  #### 3.3.2 字段列表

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Customer__c` | Customer | Lookup(Account) | 父客户 |
  | `Customer_Name__c` | Customer Name | Text | 客户名称 |
  | `Direction__c` | Direction | Text | 地址方向/备注 |
  | `Status__c` | Status | Picklist | 状态 |
  | `Remarks__c` | Remarks | Text | 备注 |

  #### 3.3.3 业务说明

  - **无自定义触发器**: 此对象没有自定义的Trigger Handler
  - **数据共享**: 继承父Account的共享权限
  - **用途**: 存储客户的多个收货地址信息

  ---

  ### 3.4 Company_Dynamics__c（公司动态）

  #### 3.4.1 对象基本信息

  | 属性 | 值 |
  |-----|-----|
  | API Name | `Company_Dynamics__c` |
  | Label | Company Dynamics |
  | 名称格式 | `CD-{000000}` |
  | 共享模式 | `Private` (私有) |

  #### 3.4.2 字段列表

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Customer__c` | Customer | Lookup(Account) | 父客户 |
  | `Company_Dynamics__c` | Company Dynamics | Html(32768) | 公司动态内容 |
  | `Market_Dynamics__c` | Market Dynamics | Text Area | 市场动态 |
  | `Product_Dynamics__c` | Product Dynamics | Text Area | 产品动态 |
  | `Staff_Dynamics__c` | Staff Dynamics | Text Area | 员工动态 |
  | `Remark__c` | Remark | Text Area | 备注 |

  #### 3.4.3 触发器逻辑

  **CompanyDynamicsTriggerHandler** - 触发时机: After Insert / After Update

  ```
  触发行为:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 共享数据到客户小组                                                            │
  │ 调用: ShareDataToAccountTeam.shareData()                                     │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```

  #### 3.4.4 业务说明

  - **Html字段**: `Company_Dynamics__c` 是富文本字段，用于存储公司动态的详细内容
  - **私有共享**: 记录默认私有，通过触发器共享给客户小组

  ---

  ### 3.5 Account_Receivable__c（客户应收账款）

  > 注: 此对象对应SAP中的应收账款数据，**从SAP同步到CRM**

  #### 3.5.1 对象基本信息

  | 属性 | 值 |
  |-----|-----|
  | API Name | `Account_Receivable__c` |
  | Label | Account Receivable |
  | 名称格式 | `AR-{000000}` |
  | 共享模式 | `Private` |

  #### 3.5.2 字段列表

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Customer__c` | Customer | Lookup(Account) | 客户 |
  | `Customer_Code__c` | Customer Code | Text | 客户编码 |
  | `Company_Code__c` | Company Code | Text | 公司代码 |
  | `Document_Number__c` | Document Number | Text | 会计凭证号 |
  | `Posting_Item__c` | Posting Item | Text | 凭证行号 |
  | `Document_Type__c` | Document Type | Picklist | 凭证类型 |
  | `Document_Currency__c` | Document Currency | Text | 凭证货币 |
  | `Local_Currency__c` | Local Currency | Text | 本位币 |
  | `Exchange_Rate__c` | Exchange Rate | Number | 汇率 |
  | `Posting_Date__c` | Posting Date | Date | 过账日期 |
  | `Baseline_Date__c` | Baseline Date | Date | 付款基准日期 |
  | `Due_On__c` | Due On | Date | 到期日期 |
  | `Debit_Credit__c` | Debit Credit | Text | 借贷方 |
  | `Amount_in_Trans_Crcy__c` | Amount in Trans Crcy | Currency | 凭证货币金额 |
  | `Amount_in_Local_Crcy__c` | Amount in Local Crcy | Currency | 本位币金额 |
  | `Amount_USD__c` | Amount USD | Currency | 美元金额 |
  | `Payment_Terms__c` | Payment Terms | Text | 付款条件 |
  | `Overdue_Days__c` | Overdue Days | Number | 逾期天数 |
  | `Overdue_Flag__c` | Overdue Flag | Checkbox | 逾期标识 |
  | `Invoice_Number__c` | Invoice Number | Text | 发票号 |
  | `Invoice__c` | Invoice | Lookup(Invoice) | 发票 |
  | `Sales_Org__c` | Sales Org | Text | 销售组织 |
  | `ExternalId__c` | ExternalId | Text | 外部ID |

  #### 3.5.3 逾期账龄字段

  | 字段API名称 | 标签 | 类型 |
  |------------|------|------|
  | `X1_30_days_Overdue_Local_Currency__c` | 1-30 Days Overdue | Currency |
  | `X31_60_days_Overdue_Local_Currency__c` | 31-60 Days Overdue | Currency |
  | `X61_90_days_Overdue_Local_Currency__c` | 61-90 Days Overdue | Currency |
  | `X91_180_days_Overdue_Local_Currency__c` | 91-180 Days Overdue | Currency |
  | `X180_days_Overdue_Local_Currency__c` | 180+ Days Overdue | Currency |

  #### 3.5.4 SAP同步接口

  **SAPReceivableWebService** - 接口类型: `@RestResource` (SAP → CRM 被动接收)

  ```
  同步方向: SAP → CRM (被动接收)

  Upsert逻辑:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ ExternalId__c = Customer_Code + Company_Code + Fiscal_Year +               │
  │                  Document_Number + Posting_Item                            │
  └─────────────────────────────────────────────────────────────────────────────┘

  Owner分配逻辑:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 1. 如果有发票(Invoice)，则Owner = Invoice.OwnerId                            │
  │ 2. 否则根据 Customer + Sales_Org 查找 Customer_Sales_Info                   │
  │    Owner = Customer_Sales_Info.OwnerId                                     │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```

  ---

  ### 3.6 Sales_Forecast__c / Sales_Forecast_Summary__c（销售预测）

  #### 3.6.1 对象基本信息

  | 对象 | API Name | Label | 名称格式 | 共享模式 |
  |-----|----------|-------|---------|---------|
  | 汇总 | `Sales_Forecast_Summary__c` | Sales Forecast | `SF-{000000}` | Private |
  | 明细 | `Sales_Forcast__c` | Sales Forecast Detail | `SFD-{000000}` | Private |

  #### 3.6.2 对象关系

  ```
  Sales_Forecast_Summary__c (销售预测汇总)
      │
      └── Sales_Forcast__c (销售预测明细，多)
              │
              └── Account (客户)
              └── Customer_Sales_View__c (销售视图)
              └── Product_Name__c (产品)
  ```

  #### 3.6.3 汇总对象字段

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Year__c` | Year | Text | 年份 |
  | `Sales_Org__c` | Sales Org | Text | 销售组织 |
  | `Delivery_Plant__c` | Delivery Plant | Text | 交货工厂 |
  | `Status__c` | Status | Picklist | 状态 |
  | `Total_Forecast_Amount_USD__c` | Total Forecast Amount USD | Currency | 预测总额(USD) |

  #### 3.6.4 明细对象字段

  | 字段API名称 | 标签 | 类型 | 说明 |
  |------------|------|------|------|
  | `Sales_Forecast_Summary__c` | Sales Forecast Summary | Lookup | 所属汇总 |
  | `Customer__c` | Customer | Lookup(Account) | 客户 |
  | `Customer_Sales_View__c` | Customer Sales View | Lookup | 客户销售视图 |
  | `Product_Name__c` | Product Name | Text | 产品名称 |
  | `Year__c` | Year | Text | 年份 |
  | `Month__c` | Month | Text | 月份 |
  | `Quarter__c` | Quarter | Text | 季度 |
  | `Monthly_Forecast_USD__c` | Monthly Forecast USD | Currency | 月度预测(USD) |
  | `Monthly_Actual_USD__c` | Monthly Actual USD | Currency | 月度实际(USD) |
  | `Achievement_Rate_USD__c` | Achievement Rate USD | Percent | 达成率 |
  | `External_Id__c` | External Id | Text | 外部ID |

  #### 3.6.5 触发器逻辑

  **SalesForecastSummaryTriggerHandler** - 触发时机: Before Update

  ```
  触发条件: Status__c 变为 'Approved'

  触发行为:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 计算并更新 Total_Forecast_Amount_USD__c                                      │
  │ 逻辑: 汇总所有 Sales_Forcast__c 的 Monthly_Forecast_USD__c                   │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```

  #### 3.6.6 销售预测达成计算 Batch

  **SalesForecastDataBatch** - 类型: Batch + Schedulable + Stateful

  ```
  执行时机: 每月1号自动执行 (0 0 0 1 * ?)

  数据来源: Billing__c (发票)
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ 查询条件:                                                                    │
  │ - Invoice_Date_Month__c = 当前月份                                           │
  │ - Invoice_Date_Year__c = 当前年份                                            │
  │ - Order_Item__r.Commodity__c IN 产品列表                                     │
  │ - Billing_Status__c = 'C' (已清)                                            │
  └─────────────────────────────────────────────────────────────────────────────┘

  达成计算逻辑:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │ External_Id__c 格式: Year + Month + Product_Name + Customer + Owner         │
  │ 匹配发票: Billing.Invoice_Year + Month + Commodity + Customer + Owner        │
  │ 更新: Monthly_Actual_USD__c = 匹配的发票金额(USD)                             │
  └─────────────────────────────────────────────────────────────────────────────┘
  ```

  #### 3.6.7 销售预测流程

  ```
  1. 【创建汇总】Sales_Forecast_Summary__c → 指定 Year, Sales_Org, Delivery_Plant
  2. 【创建明细】Sales_Forcast__c → 指定 Customer, Product, Month, 填写预测金额
  3. 【提交审批】Summary.Status = 'Approved' → 触发器汇总 Total_Forecast_Amount_USD__c
  4. 【达成计算】每月1号 Batch → 根据实际发票计算 Monthly_Actual → 更新达成率
  ```

  ---

  ### 3.7 关联子对象SAP同步汇总

  | 对象 | 同步方向 | 接口 |
  |-----|---------|------|
  | Bank_Info__c | CRM → SAP | CustomerInfoSyncToSAP |
  | Customer_Tax_Number_Category__c | CRM → SAP | CustomerSalesInfoSyncToSAP |
  | Account_Receivable__c | **SAP → CRM** | SAPReceivableWebService |
  | Customer_Shipping_Address__c | - | 无同步 |
  | Company_Dynamics__c | - | 无同步 |
  | Sales_Forecast__c | - | 无同步 |

  ---

  ## 四、触发器链路

  ### 4.1 AccountTriggerHandler（客户触发器）

  #### 4.1.1 完整代码结构

  ```apex
  public without sharing class AccountTriggerHandler implements Triggers.Handler {
      public void handle() {
          // 1. isAfter + isUpdate: 主逻辑处理块
          // 2. isAfter + isInsert: 客户创建后自动逻辑
          // 3. isBefore + (isUpdate || isInsert): 数据格式化
      }
  }
  ```

  #### 4.1.2 isAfter + isUpdate 逻辑详解

  **触发条件**: Account记录被更新后执行

  **代码段1: 字段变更检测与通知** (第25-58行)

  ```apex
  // 获取所有填充字段
  Map<String, Object> newFields = acc.getPopulatedFieldsAsMap();
  Map<String, Object> oldFields = accMap.get(acc.Id).getPopulatedFieldsAsMap();
  
  // 跳过系统字段列表
  Set<String> skipFields = new Set<String>{
      'LastModifiedDate', 'SystemModstamp', 'CreditNumber__c',
      'LastModifiedById', 'ACN_No__c', 'Accounts_Email__c',
      'Date_Business_Started__c', 'Operating_Address__c', 'OwnerId'
  };
  
  // 检测是否有业务字段变更
  Boolean hasChanges = false;
  for (String fieldName : newFields.keySet()) {
      if (!skipFields.contains(fieldName)) {
          if (newFields.get(fieldName) != oldFields.get(fieldName)) {
              hasChanges = true;
              break;
          }
      }
  }
  ```

  **作用**: 检测客户关键字段变更，用于触发后续SAP同步逻辑

  ---

  **代码段2: 销售视图状态联动** (第62-141行)

  ```apex
  // 客户状态变更时，同步更新所有销售视图的状态
  if (acc.Customer_Approval_Status__c != oldMap.get(acc.Id).Customer_Approval_Status__c) {
      if (acc.Customer_Approval_Status__c == 'Approved') {
          accSet.add(acc.Id);  // → 销售视图变为 Approved
      }
      if (acc.Customer_Approval_Status__c == 'Approving') {
          accSet1.add(acc.Id); // → 销售视图变为 Approving
      }
      if (acc.Customer_Approval_Status__c == 'Draft') {
          accSet2.add(acc.Id); // → 销售视图变为 Draft
      }
      if (acc.Customer_Approval_Status__c == 'Rejected') {
          accSet3.add(acc.Id); // → 销售视图变为 Reject
      }
  }
  
  // 批量更新销售视图状态
  for (Customer_Sales_Info__c csi : [SELECT Id FROM Customer_Sales_Info__c WHERE Customer__c IN:accSet]) {
      csi.Sales_View_Status__c = 'Approved';
      csiList.add(csi);
  }
  Database.update(csiList);
  ```

  **业务规则**: 

  - 客户审批通过 → 所有销售视图同步变为Approved
  - 客户审批拒绝 → 所有销售视图同步变为Reject
  - 使用`Utility.IgnoreAction()`避免触发器递归

  ---

  **代码段3: 已审批客户字段修改校验** (第67-75行)

  ```apex
  // 已审批客户不允许修改关键字段
  if (acc.Customer_Approval_Status__c == 'Approved') {
      for (Schema.FieldSetMember f : fieldSetMembersCanChange) {
          if (oldAcc.get(f.getFieldPath()) != acc.get(f.getFieldPath())) {
              acc.addError(System.Label.Customer_Field_Edit);
          }
      }
  }
  ```

  **FieldSet**: `Can_not_change` - 定义已审批客户不可修改的字段

  ---

  **代码段4: 已审批客户变更通知** (第76-104行)

  ```apex
  // 已审批客户关键字段变更，通知上级
  if (acc.Customer_Approval_Status__c == 'Approved' 
      && acc.Customer_Approval_Status__c == oldMap.get(acc.Id).Customer_Approval_Status__c 
      && UserInfo.getProfileId() != adminPro.Id) {
      
      for (Schema.FieldSetMember f : fieldSetMembers) {
          if (oldAcc.get(f.getFieldPath()) != acc.get(f.getFieldPath())) {
              // 发送通知给上级
              CustomNotificationFromApex.notifyUsers(
                  notificationType, 
                  adminSet, 
                  acc.Id,
                  System.Label.AccountUpdateNotfication,
                  System.Label.AccountUpdateNotficationBody
              );
              break;
          }
      }
  }
  ```

  **FieldSet**: `Customer_Info` - 定义需要通知上级的变更字段

  ---

  **代码段5: MX财务字段修改校验** (第271-292行)

  ```apex
  // MX特定用户不允许修改关键财务字段
  if (u.Deliver_Plant_Text__c != null && u.Deliver_Plant_Text__c.startsWith('30') && !Utility.isPassTriggerLogic) {
      for (Schema.FieldSetMember f : fieldSetMembers) {
          if (acc.get(f.getFieldPath()) != oldMap.get(acc.Id).get(f.getFieldPath())) {
              acc.addError(System.Label.CanNotChangeCustomerKeyInfo.replace('[XXXX]',labelValue));
          }
      }
  }
  ```

  **FieldSet**: `ChangeFieldByFinance` - MX财务不可修改字段

  ---

  **代码段6: 资信调查完成通知** (第303-346行)

  ```apex
  // 资信调查日期/备注/附件变更时，通知销售
  if (accMap.get(acc.Id).Credit_Investigation_Date__c != acc.Credit_Investigation_Date__c ||
      accMap.get(acc.Id).Credit_Investigation_Note__c != acc.Credit_Investigation_Note__c ||
      accMap.get(acc.Id).Is_Credit_Investigation_Attached__c != acc.Is_Credit_Investigation_Attached__c) {
      
      // 发送应用内通知
      CustomNotificationFromApex.notifyUsers(...);
      
      // 发送邮件通知
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new List<String>{u.Email});
      email.setSubject(System.Label.NotficationServiceSaleTitle);
      email.setPlainTextBody(body);
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress];
      if (owea.size() > 0) {
          email.setOrgWideEmailAddressId(owea.get(0).Id);
      }
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
  }
  ```

  ---

  **代码段7: SAP同步触发** (第105-125行)

  ```apex
  // 客户审批状态变为Approved时，同步SAP
  if (acc.Customer_Approval_Status__c == 'Approved' 
      && acc.Customer_Approval_Status__c != oldMap.get(acc.Id).Customer_Approval_Status__c) {
      if (acc.MDG_Customer_Code__c != null) {
          CustomerInfoSyncToSAP.submitToSAPFu(acc.Id, 'U');  // 更新
      } else {
          CustomerInfoSyncToSAP.submitToSAPFu(acc.Id, 'I');  // 新增
      }
  }
  
  // 已审批客户字段变更时，同步SAP
  if (hasChanges && acc.Customer_Approval_Status__c == 'Approved' 
      && !acc.MDG__c && !System.isBatch() && !System.isFuture()
      && acc.Sync_Status__c == 'Synchronized' 
      && acc.Name == oldMap.get(acc.Id).Name) {
      CustomerInfoSyncToSAP.submitToSAPFu(acc.Id, 'U');
  }
  ```

  ---

  #### 4.1.3 isAfter + isInsert 逻辑

  ```apex
  // 创建客户后自动执行
  if (Trigger.isAfter && Trigger.isInsert) {
      // 1. 创建客户小组记录
      Account_Team__c at = new Account_Team__c();
      at.Customer__c = acc.Id;
      at.Sales_Rep__c = acc.OwnerId;  // 自动分配创建人为销售代表
      atList.add(at);
      
      // 2. 创建默认税收类别
      Customer_Tax_Number_Category__c ctnc = new Customer_Tax_Number_Category__c();
      ctnc.Customer__c = acc.Id;
      ctnc.Long_Tax_Number__c = acc.Tax_Number__c;
      
      // 根据国家自动分配税号主数据
      if (countryMap.get(acc.Country__c) == 'AR') {
          ctnc.Tax_Number_Master_Data__c = ctncMap.get('AR1A');
      }
      if (countryMap.get(acc.Country__c) == 'MX') {
          ctnc.Tax_Number_Master_Data__c = ctncMap.get('MX1');
      }
      ctncList.add(ctnc);
  }
  ```

  ---

  #### 4.1.4 isAfter + isUpdate (客户小组变更)

  ```apex
  if (Trigger.isAfter && Trigger.isUpdate) {
      for (Account acc : Trigger.new) {
          // 客户负责人变更时
          if (acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
              // 1. 创建AccountShare记录（给原负责人分配编辑权限）
              AccountShare sharingObject = new AccountShare();
              sharingObject.put('AccountId', acc.Id);
              sharingObject.put('AccountAccessLevel', 'Edit');
              sharingObject.put('OpportunityAccessLevel', 'None');
              sharingObject.put('RowCause', 'Manual');
              sharingObject.put('UserOrGroupId', oldMap.get(acc.Id).OwnerId);
              accountShareList.add(sharingObject);
              
              // 2. 创建新的客户小组记录
              Account_Team__c at = new Account_Team__c();
              at.Customer__c = acc.Id;
              at.Sales_Rep__c = acc.OwnerId;
              at.External_Id__c = at.Customer__c + '_' + at.Sales_Rep__c;
              atList.add(at);
          }
          
          // 3. 审批结果通知
          if (acc.Customer_Approval_Status__c == 'Approved' 
              && acc.Customer_Approval_Status__c != oldMap.get(acc.Id).Customer_Approval_Status__c) {
              Utility.notificationUserTitle(uSet, acc.Id, 
                  System.Label.Acc_Approved_Title, 
                  System.Label.Acc_Approved_Title + acc.Name);
          }
      }
  }
  ```

  ---

  #### 4.1.5 isBefore + (isUpdate || isInsert) 逻辑

  ```apex
  // 税号格式化
  if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
      for (Account acc : Trigger.new) {
          if (acc.Tax_Number__c != null) {
              // 去掉税号中的横杠
              acc.Tax_Numbe_No_Bar__c = acc.Tax_Number__c.replace('-', '');
          }
      }
  }
  ```

  ---

  ### 4.2 CustomerSalesInfoTriggerHandler（销售视图触发器）

  #### 4.2.1 isAfter + (isInsert || isUpdate) 逻辑

  **税收类别自动创建**:

  ```apex
  // 国家变更时，删除旧税收类别，创建新税收类别
  if (Trigger.isUpdate && csi.Country__c != oldMap.get(csi.Id).Country__c) {
      // 1. 删除旧的Customer_Tax_Category__c记录
      List<Customer_Tax_Category__c> ccDeleteList = [
          SELECT Id FROM Customer_Tax_Category__c 
          WHERE Sales_View__c IN :csiSet
      ];
      Database.delete(ccDeleteList);
      
      // 2. 根据新国家查询税分类主数据
      Map<String, List<Tax_Category_Master_Data__c>> tcmdMap = new Map<String, List<Tax_Category_Master_Data__c>>();
      for (Tax_Category_Master_Data__c tcmd : [SELECT Id, Country_Code__c, Name 
                                                FROM Tax_Category_Master_Data__c 
                                                WHERE Country_Code__c IN :countrySet]) {
          if (tcmdMap.containsKey(tcmd.Country_Code__c)) {
              tcmdMap.get(tcmd.Country_Code__c).add(tcmd);
          } else {
              tcmdMap.put(tcmd.Country_Code__c, new List<Tax_Category_Master_Data__c>{tcmd});
          }
      }
      
      // 3. 自动创建新的Customer_Tax_Category__c记录
      for (Customer_Sales_Info__c csi : Trigger.new) {
          if (tcmdMap.get(csi.Country_Code_Text__c) != null) {
              for (Tax_Category_Master_Data__c tcm : tcmdMap.get(csi.Country_Code_Text__c)) {
                  Customer_Tax_Category__c ctc = new Customer_Tax_Category__c();
                  ctc.Sales_View__c = csi.Id;
                  ctc.Tax_Category_Master_Data__c = tcm.Id;
                  ctc.Tax_Category_Type__c = tcm.Name;
                  insertList.add(ctc);
              }
          }
      }
      Database.Insert(insertList);
  }
  ```

  **YPF客户判断**:

  ```apex
  // 判断客户是否有YPF付款方式的销售视图
  List<Account> accList = new List<Account>();
  for (Account acc : [SELECT Id, Is_YPF__c,
                      (SELECT Id FROM Account_Sales_Info__r 
                       WHERE Payment_method__c = 'YPF' LIMIT 1) 
                      FROM Account WHERE Id IN :customerSet]) {
      if (acc.Account_Sales_Info__r.size() > 0) {
          acc.Is_YPF__c = true;
      } else {
          acc.Is_YPF__c = false;
      }
      accList.add(acc);
  }
  Utility.IgnoreAction(true, false, 'CustomerSalesInfoTriggerHandler');
  Database.Update(accList);
  Utility.IgnoreAction(false, false, 'CustomerSalesInfoTriggerHandler');
  ```

  ---

  #### 4.2.2 isBefore + (isInsert || isUpdate) 逻辑

  **统驭科目自动计算**:

  ```apex
  // 根据交货工厂和客户科目分配组自动计算统驭科目
  if (csi.Delivering_Plant__c == '3010' || csi.Delivering_Plant__c == '3011' || csi.Delivering_Plant__c == '3020') {
      if (csi.Acct_Assmt_Grp_Cust__c == '01') {
          csi.Reconciliation_Account__c = '1122010100';
      }
      if (csi.Acct_Assmt_Grp_Cust__c == '02') {
          csi.Reconciliation_Account__c = '1122020100';
      }
  }
  
  if (csi.Delivering_Plant__c == '5070' || csi.Delivering_Plant__c == '5130') {
      if (csi.Acct_Assmt_Grp_Cust__c == '01') {
          csi.Reconciliation_Account__c = '1122010000';
      }
      if (csi.Acct_Assmt_Grp_Cust__c == '02') {
          csi.Reconciliation_Account__c = '1122020000';
      }
  }
  
  // External_ID自动生成
  csi.External_ID__c = csi.Customer__c + '_' + csi.Sales_Org__c + '_' + csi.Distr_Channel__c;
  ```

  **客户审批状态校验**:

  ```apex
  // 销售视图只能为Draft或Approved状态的客户创建
  Map<String, Account> accMap = new Map<String, Account>();
  for (Account acc : [SELECT Id, Customer_Approval_Status__c, MDG_Customer_Code__c 
                      FROM Account WHERE Id IN :customerSet]) {
      accMap.put(acc.Id, acc);
  }
  
  for (Customer_Sales_Info__c csi : Trigger.new) {
      if (accMap.get(csi.Customer__c).Customer_Approval_Status__c != 'Draft' 
          && accMap.get(csi.Customer__c).Customer_Approval_Status__c != 'Approved') {
          csi.addError(System.Label.SalesInfoCannotSave);
      }
  }
  ```

  ---

  #### 4.2.3 isAfter + isUpdate 逻辑

  **SAP同步触发**:

  ```apex
  for (Customer_Sales_Info__c csi : Trigger.new) {
      // 状态变为Approved时
      if (oldMap.get(csi.Id).Sales_View_Status__c != csi.Sales_View_Status__c 
          && csi.Sales_View_Status__c == 'Approved') {
          
          if (accMap.get(csi.Customer__c).MDG_Customer_Code__c != null) {
              // 已有SAP编码 → 更新
              if (!csi.isSync__c) {
                  CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id, 'I');
              } else {
                  CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id, 'U');
              }
          } else {
              // 无SAP编码 → 延迟1分钟后同步（等待客户SAP编码生成）
              Datetime d = Datetime.now();
              String minute = d.minute() + 1 + '';
              String sch = d.second() + ' ' + minute + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ? ' + d.year();
              SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(csi.Id);
              System.schedule('定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(), sch, schup);
          }
      }
      
      // 已Approved状态下字段变更时同步
      if (oldMap.get(csi.Id).Sales_View_Status__c == csi.Sales_View_Status__c 
          && csi.Sales_View_Status__c == 'Approved' 
          && !System.isBatch() && !System.isFuture() 
          && csi.Sync_Status__c == oldMap.get(csi.Id).Sync_Status__c) {
          CustomerSalesInfoSyncToSAP.submitToSAPFutrue(csi.Id, csi.isSync__c ? 'U' : 'I');
      }
  }
  ```

  ---

  ### 4.3 CustomerCreditTriggerHandler（信用额度触发器）

  ```apex
  public without sharing class CustomerCreditTriggerHandler implements Triggers.Handler {
      public void handle() {
          if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
              for (Customer_Credit_Info__c csi : Trigger.new) {
                  // 跳过Remaining_Credit__c变更的触发动作
                  if (Trigger.isUpdate && csi.Remaining_Credit__c != oldMap.get(csi.Id).Remaining_Credit__c) {
                      continue;
                  }
                  
                  // 跳过批处理和Future方法内触发的
                  if (System.isBatch() || System.isFuture()) {
                      continue;
                  }
                  
                  if (Trigger.isUpdate) {
                      // 以下字段变更时同步SAP
                      if (oldMap.get(csi.Id).Actual_Credit_limit__c != csi.Actual_Credit_limit__c ||
                          oldMap.get(csi.Id).Check_Rule__c != csi.Check_Rule__c ||
                          oldMap.get(csi.Id).Credit_Segment__c != csi.Credit_Segment__c ||
                          oldMap.get(csi.Id).Risk_Class__c != csi.Risk_Class__c ||
                          oldMap.get(csi.Id).Rules__c != csi.Rules__c ||
                          oldMap.get(csi.Id).Valid_Until__c != csi.Valid_Until__c) {
                          CustomerlimitSyncToSAP.submitToSAPFutrue(csi.Id);
                      }
                  } else {
                      // 新增时直接同步
                      CustomerlimitSyncToSAP.submitToSAPFutrue(csi.Id);
                  }
              }
          }
      }
  }
  ```

  ---

  ### 4.4 CustomerQuotaChangeTriggerHandler（额度变更申请触发器）

  #### 4.4.1 isBefore + isInsert 逻辑

  **前置校验与数据填充**:

  ```apex
  if (Trigger.isBefore && Trigger.isInsert) {
      // 1. 校验客户审批状态必须为Approved
      if (accMap.get(cqc.Customer__c).Customer_Approval_Status__c != 'Approved') {
          cqc.addError(System.Label.NoCredit);
      }
      
      // 2. 校验是否为总部客户（总部客户不能申请额度变更）
      Map<String, Boolean> hqSalesInfo = new Map<String, Boolean>();
      for (Customer_Sales_Info__c csi : [SELECT Customer__c FROM Customer_Sales_Info__c 
                                         WHERE Customer__c IN :customerIdSet 
                                         AND Sales_View_Status__c = 'Approved' 
                                         AND (Sales_Org__c = '1040' OR Sales_Org__c = '1050' 
                                              OR Sales_Org__c = '1060' OR Sales_Org__c = '1080' 
                                              OR Sales_Org__c = '2010' OR Sales_Org__c = '2210')]) {
          hqSalesInfo.put(csi.Customer__c, true);
      }
      
      // MX工厂销售组织客户，且有总部销售视图 → 不允许申请
      if ((cqc.Sales_Org__c == '3010' || cqc.Sales_Org__c == '3020') 
          && hqSalesInfo.get(cqc.Customer__c) != null) {
          cqc.addError('This customer is a headquarters client and cannot apply for credit.');
      }
      
      // 3. 自动填充现有额度信息
      List<Customer_Credit_Info__c> cciList = [SELECT Local_Credit_Line_USD__c, Sinosure_Credit_Limit__c,
                                                Local_Credit_Limit__c, Type_of_Guarantee__c,
                                                Guarantee_Credit_Line_USD__c, Clean_Line_USD__c,
                                                Sinosure_Expiration_Date__c, Sinosure_Payment_Term__c,
                                                Guarantee_Expiration_Date__c, Credit_Analysis_Date__c
                                                FROM Customer_Credit_Info__c 
                                                WHERE Customer__c IN :customerIdSet];
      
      for (Customer_Quota_Change__c cqc : Trigger.new) {
          if (cciList.size() > 0) {
              cqc.Sinosure_Credit_Limit__c = cciList[0].Sinosure_Credit_Limit__c;
              cqc.Type_of_Guarantee__c = cciList[0].Type_of_Guarantee__c;
              cqc.Guarantee_Credit_Line_USD__c = cciList[0].Guarantee_Credit_Line_USD__c;
              cqc.Clean_Line_USD__c = cciList[0].Clean_Line_USD__c;
              // ... 其他字段
          }
      }
      
      // 4. 自动计算账期天数
      for (Customer_Quota_Change__c cqc : Trigger.new) {
          if (accSalesInfoMap != null && accSalesInfoMap.get(cqc.Customer__c) == null) {
              cqc.addError(System.Label.NoCustomerSalesInfo);
          } else {
              Customer_Sales_Info__c csi = accSalesInfoMap.get(cqc.Customer__c);
              if (csi != null && paymentRateMap.get(csi.Terms_Of_Payment__c) != null) {
                  cqc.Payment_Term_Days__c = paymentRateMap.get(csi.Terms_Of_Payment__c).Days__c;
                  cqc.Payment_Term__c = csi.Terms_Of_Payment__c;
              }
          }
      }
  }
  ```

  ---

  #### 4.4.2 isAfter + isUpdate 逻辑

  **审批通过后更新额度**:

  ```apex
  if (Trigger.isAfter && Trigger.isUpdate) {
      for (Customer_Quota_Change__c cqc : Trigger.new) {
          // 审批状态变为Approved
          if (cqc.Approval_Status__c != cqcOldMap.get(cqc.Id).Approval_Status__c 
              && cqc.Approval_Status__c == 'Approved') {
              
              // 1. 创建/更新Customer_Credit_Info__c
              Customer_Credit_Info__c cci = new Customer_Credit_Info__c();
              cci.Customer__c = cqc.Customer__c;
              
              // 额度优先级：Post_Application_Credit__c > Customer_Credit_Line__c
              if (cqc.Post_Application_Credit__c != null) {
                  cci.Actual_Credit_limit__c = cqc.Post_Application_Credit__c;
              }
              if (cqc.Customer_Credit_Line__c != null) {
                  cci.Actual_Credit_limit__c = cqc.Customer_Credit_Line__c;
              }
              
              // 其他字段赋值
              if (String.isNotBlank(String.valueOf(cqc.Valid_After_Change_To__c))) {
                  cci.Valid_Until__c = cqc.Valid_After_Change_To__c;
              }
              cci.Rules__c = cqc.Rules__c;
              cci.Risk_Class__c = cqc.Risk_Class__c;
              cci.Check_Rule__c = cqc.Check_Rule__c;
              cci.Credit_Segment__c = cqc.Credit_Segment__c;
              cci.Sinosure_Credit_Limit__c = cqc.Sinosure_Credit_Limit__c;
              cci.Local_Credit_Limit__c = cqc.Local_Credit_Limit__c;
              cci.Local_Credit_Limit2__c = cqc.Local_Credit_Limit2_USD__c;
              cci.Sinosure_Payment_Term__c = cqc.Sinosure_Payment_Term__c;
              cci.Guarantee_Credit_Line_USD__c = cqc.Guarantee_Credit_Line_USD__c;
              cci.Clean_Line_USD__c = cqc.Clean_Line_USD__c;
              cci.Applied_Credit_Date__c = System.today();
              cci.Credit_Analysis_Date__c = cqc.Credit_Analysis_Date__c;
              cci.Guarantee_Expiration_Date__c = cqc.Guarantee_Expiration_Date__c;
              cci.Type_of_Guarantee__c = cqc.Type_of_Guarantee__c;
              cci.Sinosure_Expiration_Date__c = cqc.Sinosure_Expiration_Date__c;
              cci.Sync_Status__c = 'Unsynchronized';
              cci.ExternalId__c = cci.Customer__c;
              cqcList.add(cci);
              
              // 2. 更新Account上的额度字段
              Account acc = new Account();
              acc.Id = cci.Customer__c;
              acc.Customer_Credit_Limit__c = cci.Actual_Credit_limit__c;
              acc.Customer_Credit_Is_Valid_Until__c = cqc.Valid_After_Change_To__c;
              acc.Check_Rule__c = cqc.Check_Rule__c;
              acc.Risk_Class__c = cqc.Risk_Class__c;
              accList.add(acc);
              
              // 3. 发送审批结果通知
              if (cqc.Approval_Status__c == 'Approved') {
                  Utility.notificationUserTitle(uSet, cqc.Id, 
                      System.Label.Credit_Approved_Title, 
                      System.Label.Credit_Approved_Title + cqc.Name);
              }
              if (cqc.Approval_Status__c == 'Rejected') {
                  Utility.notificationUserTitle(uSet, cqc.Id, 
                      System.Label.Credit_Rejected_Title, 
                      System.Label.Credit_Rejected_Title + cqc.Name);
              }
          }
      }
      
      // 批量Upsert额度记录
      upsert cqcList ExternalId__c;
      Utility.IgnoreAction(true, false, 'CustomerQuotaChangeTriggerHandler');
      update accList;
      Utility.IgnoreAction(false, false, 'CustomerQuotaChangeTriggerHandler');
  }
  ```

  ---

  ### 4.5 CustomerUpdateTriggerHandler（客户信息变更触发器）

  ```apex
  // isAfter + isUpdate: 审批通过后更新客户
  if (Trigger.isAfter && Trigger.isUpdate) {
      for (Customer_Update__c cu : Trigger.new) {
          if (cu.Approve_Status__c == 'Approved' 
              && cu.Approve_Status__c <> oldMap.get(cu.Id).Approve_Status__c) {
              Account acc = new Account();
              acc.Id = cu.Customer__c;
              
              // 可以更新的字段
              if (String.isNotBlank(cu.New_Customer_Name__c)) {
                  acc.Name = cu.New_Customer_Name__c;
              }
              accUpdateList.add(acc);
          }
      }
      
      if (accUpdateList.size() > 0) {
          Utility.isPassTriggerLogic = TRUE;  // 跳过Account触发器校验
          Database.update(accUpdateList);
      }
  }
  
  // isBefore + isInsert: 自动分配财务用户
  if (Trigger.isBefore && Trigger.isInsert) {
      Map<String, String> financeMap = new Map<String, String>();
      for (Finance__mdt fin : [SELECT Delivery_Pant__c, Finance__c FROM Finance__mdt]) {
          financeMap.put(fin.Delivery_Pant__c, fin.Finance__c);
      }
      
      for (Customer_Update__c cu : Trigger.new) {
          cu.Finance_User__c = financeMap.get(cu.Owner_Plant__c);
      }
  }
  ```

  ---

  ### 4.6 CustomeSalesInfoApplicationHandler（销售视图变更申请触发器）

  ```apex
  // isAfter + isUpdate: 审批通过后更新销售视图
  if (Trigger.isAfter && Trigger.isUpdate) {
      for (Customer_Sales_Info_Change_Application__c csca : Trigger.new) {
          if (csca.Approve_Status__c == 'Approved' 
              && csca.Approve_Status__c != oldMap.get(csca.Id).Approve_Status__c) {
              
              Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
              Boolean flag = false;
              
              // 新付款条件
              if (csca.New_Payment_term__c != null) {
                  csi.Terms_Of_Payment__c = csca.New_Payment_term__c;
                  flag = true;
              }
              // 新客户组
              if (csca.New_Customer_Group__c != null) {
                  csi.Payment_method__c = csca.New_Customer_Group__c;
                  flag = true;
              }
              // 新装运条件
              if (csca.New_Shipping_Conditions__c != null) {
                  csi.Shipping_Conditions__c = csca.New_Shipping_Conditions__c;
                  flag = true;
              }
              // 新币种
              if (csca.New_Currency__c != null) {
                  csi.Currency__c = csca.New_Currency__c;
                  flag = true;
              }
              // 新科目评估组
              if (csca.New_Account_Assessment__c != null) {
                  csi.Acct_Assmt_Grp_Cust__c = csca.New_Account_Assessment__c;
                  flag = true;
              }
              
              csi.Id = csca.Customer_Sales_Info__c;
              if (flag) {
                  csiList.add(csi);
              }
          }
      }
      Update csiList;
  }
  
  // isBefore + isUpdate: 校验必须有变更内容
  if (Trigger.isBefore && Trigger.isUpdate) {
      for (Customer_Sales_Info_Change_Application__c csca : Trigger.new) {
          if (csca.Approve_Status__c == 'Approving' 
              && csca.Approve_Status__c != oldMap.get(csca.Id).Approve_Status__c) {
              
              // 5130/5070销售组织：只校验Is_Change__c
              if (csca.Sales_Org__c == '5130' || csca.Sales_Org__c == '5070') {
                  if (!csca.Is_Change__c) {
                      csca.addError(System.Label.NoChanged);
                  }
              } else {
                  // 其他销售组织：校验Is_Change__c和Change_Item__c
                  if (!csca.Is_Change__c && csca.Change_Item__c == 0) {
                      csca.addError(System.Label.NoChanged);
                  }
              }
          }
      }
  }
  ```

  ---

  ## 五、审批流程体系

  ### 5.1 客户主数据审批流程

  **触发条件**: 用户手动提交审批

  **审批流程**:

  1. 客户经理提交 → 上级审批
  2. 审批通过 → 自动同步SAP
  3. 审批拒绝 → 状态回写Reject

  **审批状态字段**: `Customer_Approval_Status__c`

  - Draft（草稿）
  - Approving（审批中）
  - Approved（已批准）
  - Rejected（已拒绝）

  ---

  ### 5.2 客户销售视图审批流程

  **触发条件**: 用户手动提交审批

  **审批状态字段**: `Sales_View_Status__c`

  - Draft（草稿）
  - Approving（审批中）
  - Approved（已批准）
  - Reject（已拒绝）

  **联动规则**: 

  - Account.Customer_Approval_Status__c 变更 → 自动同步所有 Customer_Sales_Info__c.Sales_View_Status__c

  ---

  ### 5.3 客户额度变更审批流程

  **触发条件**: 用户创建 `Customer_Quota_Change__c` 记录并提交

  **前置条件**:

  1. Account.Customer_Approval_Status__c = 'Approved'
  2. Customer_Sales_Info__c.Sales_View_Status__c = 'Approved'（同销售组织）
  3. 非总部客户（MX工厂客户有总部销售视图则不允许）

  **审批通过后**:

  1. 创建/更新 `Customer_Credit_Info__c` 记录
  2. 更新 Account 上的额度字段
  3. 自动同步SAP

  ---

  ### 5.4 客户信息变更审批流程

  **触发条件**: 用户创建 `Customer_Update__c` 记录

  **可变更字段**:

  - New_Customer_Name__c（客户名称）

  **审批通过后**:

  - 更新 Account.Name 字段

  ---

  ### 5.5 销售视图信息变更审批流程

  **触发条件**: 用户创建 `Customer_Sales_Info_Change_Application__c` 记录

  **可变更字段**:

  - New_Payment_term__c（付款条件）
  - New_Customer_Group__c（客户组/付款方式）
  - New_Shipping_Conditions__c（装运条件）
  - New_Currency__c（币种）
  - New_Account_Assessment__c（科目评估组）

  **校验规则**:

  - 提交审批时必须有变更内容（Is_Change__c 或 Change_Item__c > 0）
  - 5130/5070销售组织只需校验 Is_Change__c

  ---

  ## 六、SAP接口同步

  ### 6.1 客户基本信息同步 (CustomerInfo)

  **接口端点**: `CustomerInfo`

  **触发时机**:

  1. Account.Customer_Approval_Status__c 变为 'Approved'（新增/更新）
  2. 已审批客户的字段发生变更（已同步且非MDG客户）

  **请求体结构**:

  ```json
  {
    "esbinfo": {
      "instid": "GMDG011",
      "attr2": "SFCRM",
      "requesttime": "2025-03-10 12:00:00"
    },
    "resultinfo": [{
      "partner": "C00001",           // 客户编码（更新时必填）
      "maintype": "BP1P1",           // 维护标识：BP1P1=新增 BP2P1=更新
      "usmdcreqtext": "RecordId OwnerName",
      "langu": "ZH",                // 语言
      "butype": "2",                // 业务伙伴类别
      "bugroup": "Z01",             // 客户组
      "nameorg1": "测试客户",        // 客户名称
      "busort1": "测试",             // 客户简称
      "nameorg3": "集团名称",        // 集团名称
      "type": "TAXID",              // 唯一性属性类别
      "idnumber": "91110000123456789X",
      "zzcontt": "Asia",             // 大洲
      "zzregin": "North China",     // 大区
      "country": "CN",              // 国家
      "region": "110000",           // 省份
      "city1": "Beijing",           // 城市
      "street": "街道地址",
      "postcode1": "100000",
      "rltyp": "CU",                // 业务伙伴角色
      "zzcudis": "Z001",            // 客户类型
      "nameco": "联系人",            // 联系人
      "telnumber1": "010-12345678", // 电话
      "smtpaddr": "test@example.com",
      "faxnumber": "010-12345679",
      "ZZXBCODE": "ZB2021001",      // 中信保客户编码
      "banks": [{                   // 银行信息
        "banks": "CN",
        "bankl": "BK001",
        "banka": "中国银行",
        "bankn": "1234567890123456",
        "koinh": "开户名称",
        "accname": "付款方式",
        "bkext": "外部标识"
      }]
    }]
  }
  ```

  **响应处理**:

  ```apex
  if (syncReturnData.esbinfo.returnstatus == 'S') {
      // 成功：回写客户编码和同步状态
      upAcc.MDG_Customer_Code__c = syncReturnData.resultinfo[0].partner;
      upAcc.Sync_Status__c = 'Synchronized';
      upAcc.SAP_Customer_Name__c = accList[0].Name;
  }
  
  if (syncReturnData.esbinfo.returnstatus == 'E') {
      if (changeType == 'I' && String.isNotBlank(syncReturnData.resultinfo[0].partner)) {
          // 新增时SAP返回了编码：也算成功
          upAcc.MDG_Customer_Code__c = syncReturnData.resultinfo[0].partner;
          upAcc.Sync_Status__c = 'Synchronized';
          upAcc.MDG__c = true;
          upAcc.SAP_Customer_Name__c = syncReturnData.resultinfo[0].nameorg1;
      } else {
          // 真正的失败
          upAcc.Sync_Status__c = 'Synchronization Failure';
          upAcc.Sync_Failure_Reasons__c = syncReturnData.esbinfo.returnmsg;
          Utility.notificationUser(accList[0].OwnerId, Id);  // 通知负责人
      }
  }
  ```

  ---

  ### 6.2 客户销售视图同步 (CustomerSalesInfoNEW / CustomerSalesInfoUpdate)

  **接口端点**: 

  - 新增: `CustomerSalesInfoNEW`
  - 更新: `CustomerSalesInfoUpdate`

  **触发时机**:

  1. Customer_Sales_Info__c.Sales_View_Status__c 变为 'Approved'
  2. 已Approved状态下字段发生变更

  **延迟同步机制**:

  ```apex
  if (accMap.get(csi.Customer__c).MDG_Customer_Code__c == null) {
      // 如果客户还没有SAP编码，延迟1分钟后同步
      Datetime d = Datetime.now();
      String minute = d.minute() + 1 + '';
      String sch = d.second() + ' ' + minute + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ? ' + d.year();
      SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(csi.Id);
      System.schedule('定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(), sch, schup);
  }
  ```

  **请求体结构**:

  ```json
  {
    "esbinfo": {
      "attr1": "SFCRM",
      "attr2": "SAP"
    },
    "resultinfo": [{
      "ktokk": "Z01",               // 客户组
      "partner": "C00001",          // 客户编码
      "flucu00": [{                 // 财务视图
        "kunnr": "C00001",
        "bukrs": "3010",            // 公司代码
        "akont": "1122010100"       // 统驭科目
      }],
      "taxnums": [{                 // 税号类别
        "partner": "C00001",
        "taxtype": "MX1",
        "taxnumxl": "123456789"
      }],
      "flucu01": [{                 // 销售视图
        "kunnr": "C00001",
        "vkorg": "3010",            // 销售组织
        "vtweg": "01",              // 分销渠道
        "spart": "01",              // 产品组
        "bzirk": "B001",            // 销售地区
        "kdgrp": "",                // 客户组
        "kvgr1": "YPF",             // 付款方式
        "kvgr3": "B2B",             // 商业模式
        "vkbur": "3010",             // 销售部门
        "vkgrp": "001",             // 销售组
        "waers": "CNY",             // 币种
        "konda": "P01",             // 价格组
        "kalks": "1",               // 客户定价过程
        "vwerk": "3010",            // 交货工厂
        "vsbed": "01",              // 装运条件
        "zterm": "PT30",            // 付款条件
        "ktgrd": "01",              // 客户科目分配组
        "inco1": "EXW",             // 国际贸易条款
        "inco2_L": "工厂",
        "AUFSD": "",                // 冻结标识
        "TAXKDS": [{               // 税收类别
          "aland": "MX",
          "tatyp": "MX1A",
          "taxkd": "0"
        }]
      }]
    }]
  }
  ```

  **税收类别同步规则**:

  ```apex
  // 以下情况需要同步税收类别
  if (!accList[0].isSync__c ||                        // 从未同步过
      accList[0].Sales_Org__c == '3010' ||            // 3010组织
      accList[0].Sales_Org__c == '3020' ||            // 3020组织
      accList[0].Sales_Org__c == '2100') {            // 2100组织
      // 同步税收类别
      si.TAXKDS = taxList;
  }
  ```

  ---

  ### 6.3 客户信用额度同步 (creditLimit)

  **接口端点**: `creditLimit`

  **接口编号**: `GSD003`

  **触发时机**:

  1. Customer_Credit_Info__c 新增时
  2. Customer_Credit_Info__c 更新时，以下字段变更:
     - Actual_Credit_limit__c（实际信用额度）
     - Check_Rule__c（检查规则）
     - Credit_Segment__c（信用段）
     - Risk_Class__c（风险类别）
     - Rules__c（规则）
     - Valid_Until__c（有效期）

  **跳过条件**:

  - Remaining_Credit__c（剩余额度）变更时不触发（避免循环）
  - 在Batch或Future方法内不触发

  **请求体结构**:

  ```json
  {
    "esbinfo": {
      "instid": "GSD003",
      "requesttime": "2025-03-10 12:00:00"
    },
    "resultinfo": [{
      "partner": "C00001",           // 客户编码
      "limitrule": "Z01",            // 额度规则
      "riskclass": "01",             // 风险类别
      "checkrule": "Z001",           // 检查规则
      "creditsgmnt": "01",           // 信用段
      "creditlimit": "100000",       // 信用额度
      "valid_date": "20251231"       // 有效期(yyyyMMdd格式)
    }]
  }
  ```

  ---

  ## 七、业务流程图

  ### 7.1 客户创建完整流程

  ```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                           客户创建流程                                   │
  └─────────────────────────────────────────────────────────────────────────┘
  
  [1. 创建客户]
         │
         ▼
  ┌─────────────────┐
  │  Account (Draft) │
  └────────┬────────┘
           │
           │ 提交审批
           ▼
  ┌─────────────────────────┐
  │ Account.Approval_Status│ ───→ Approving
  └────────┬────────────────┘
           │
      ┌────┴────┐
      │审批通过 │
      │审批拒绝 │
      └────┬────┘
           │
           ▼
      ┌────────┐     ┌──────────────────────┐
      │ Approved│ ←── │ 同步SAP (CustomerInfo)│
      └────┬────┘     └──────────────────────┘
           │                │
           │                │ SAP返回MDG_Customer_Code
           │                ▼
           │         ┌──────────────────────┐
           │         │ 创建销售视图          │
           │         │ Customer_Sales_Info   │
           │         └──────────┬───────────┘
           │                    │
           │         ┌──────────┴───────────┐
           │         │提交审批              │
           │         └──────────┬───────────┘
           │                    │
           │         ┌─────────┴────────┐
           │         │ Sales_View_Status │
           │         │    = Approving    │
           │         └─────────┬─────────┘
           │                   │
           │         ┌─────────┴─────────┐
           │         │审批通过            │
           │         │审批拒绝            │
           │         └─────────┬─────────┘
           │                   │
           │                   ▼
           │         ┌────────────────────────┐
           │         │同步SAP (CustomerSalesInfo)│
           │         └────────────────────────┘
           │                   │
           │                   ▼
           │         ┌────────────────────────┐
           │         │ 创建信用额度            │
           │         │ Customer_Credit_Info   │
           │         └────────────────────────┘
           │                   │
           │                   ▼
           │         ┌────────────────────────┐
           │         │ 同步SAP (creditLimit)  │
           │         └────────────────────────┘
           │
           ▼
  [2. 客户创建完成]
  ```

  ---

  ### 7.2 额度变更申请流程

  ```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                         额度变更申请流程                                 │
  └─────────────────────────────────────────────────────────────────────────┘
  
  [1. 创建额度变更申请]
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │ Customer_Quota_Change__c                                         │
  │  - 自动填充现有额度信息 (Sinosure_Credit_Limit, Guarantee_...)   │
  │  - 自动计算账期天数 (Payment_Term_Days)                          │
  │  - 校验: 客户必须为Approved状态                                    │
  │  - 校验: 非总部客户                                                │
  └────────────────────────┬────────────────────────────────────────┘
                           │
                    提交审批
                           │
                           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │ Approval_Status = 'Approving'                                    │
  │ 前置校验: 必须有变更内容 (Is_Change__c || Change_Item__c > 0)     │
  └────────────────────────┬────────────────────────────────────────┘
                           │
                ┌──────────┴──────────┐
                │                   │
           审批通过              审批拒绝
                │                   │
                ▼                   ▼
  ┌─────────────────────────┐ ┌─────────────────────────┐
  │ 创建/更新信用额度记录    │ │ 流程结束                 │
  │ upsert Customer_Credit_Info__c
  │ (ExternalId = Customer__c) │
  └────────────┬────────────┘
               │
               │ Actual_Credit_limit
               │ Valid_Until
               │ Rules/Risk_Class/Check_Rule
               ▼
  ┌─────────────────────────┐
  │ 更新Account额度字段      │
  │ - Customer_Credit_Limit__c
  │ - Customer_Credit_Is_Valid_Until__c
  │ - Check_Rule__c
  │ - Risk_Class__c          │
  └────────────┬────────────┘
               │
               │ Sync_Status = 'Unsynchronized'
               ▼
  ┌─────────────────────────┐
  │ 同步SAP (creditLimit)   │
  └─────────────────────────┘
  ```

  ---

  ## 八、字段映射表

  ### 8.1 Account → SAP (CustomerInfo)

  | SF字段                      | SF标签         | SAP字段      | SAP标签        | 说明       |
  | --------------------------- | -------------- | ------------ | -------------- | ---------- |
  | `MDG_Customer_Code__c`      | MDG客户编码    | `partner`    | 客户编码       | 更新时必填 |
  | `Customer_Group__c`         | 客户组         | `bugroup`    | 客户组         |            |
  | `Name`                      | 客户名称       | `nameorg1`   | 业务伙伴名称   |            |
  | `Customer_Short_Name__c`    | 客户简称       | `busort1`    | 业务伙伴简称   |            |
  | `Group_Name__c`             | 集团名称       | `nameorg3`   | 集团名称       |            |
  | `Tax_Identification__c`     | 税号标识类型   | `type`       | 唯一性属性类别 |            |
  | `Tax_Number__c`             | 税号           | `idnumber`   | 唯一性识别属性 |            |
  | `Continent__c`              | 大洲           | `zzcontt`    | 大洲           |            |
  | `Region__c`                 | 大区           | `zzregin`    | 大区           |            |
  | `Country__r.Code__c`        | 国家代码       | `country`    | 国家           |            |
  | `Province_State__r.Code__c` | 省份代码       | `region`     | 地区           |            |
  | `City__c`                   | 城市           | `city1`      | 城市           |            |
  | `Street__c`                 | 街道           | `street`     | 街道           |            |
  | `Postal_Code__c`            | 邮编           | `postcode1`  | 邮编           |            |
  | `SAP_Customer_Type__c`      | SAP客户类型    | `zzcudis`    | 客户类型       |            |
  | `Contact_Name__c`           | 联系人         | `nameco`     | 联系人         |            |
  | `Telephone__c`              | 电话           | `telnumber1` | 电话           |            |
  | `Email__c`                  | 邮箱           | `smtpaddr`   | 邮箱           |            |
  | `Fax`                       | 传真           | `faxnumber`  | 传真           |            |
  | `Sinosure_Customer_Code__c` | 中信保客户编码 | `ZZXBCODE`   | 中信保编码     |            |
  | `Language__c`               | 语言           | `langu`      | 语言           |            |

  ---

  ### 8.2 Customer_Sales_Info__c → SAP (CustomerSalesInfo)

  | SF字段                             | SF标签         | SAP字段   | SAP标签        |
  | ---------------------------------- | -------------- | --------- | -------------- |
  | `Customer__r.MDG_Customer_Code__c` | 客户编码       | `partner` | 客户编码       |
  | `Customer__r.Customer_Group__c`    | 客户组         | `ktokk`   | 客户组         |
  | `Reconciliation_Account__c`        | 统驭科目       | `akont`   | 统驭科目       |
  | `Sales_Org__c`                     | 销售组织       | `vkorg`   | 销售组织       |
  | `Distr_Channel__c`                 | 分销渠道       | `vtweg`   | 分销渠道       |
  | `Division__c`                      | 产品组         | `spart`   | 产品组         |
  | `Sales_District__c`                | 销售地区       | `bzirk`   | 销售地区       |
  | `Payment_method__c`                | 付款方式       | `kvgr1`   | 客户组1        |
  | `Business_model__c`                | 商业模式       | `kvgr3`   | 客户组3        |
  | `Sales_Office__c`                  | 销售部门       | `vkbur`   | 销售部门       |
  | `Sales_Group__c`                   | 销售组         | `vkgrp`   | 销售组         |
  | `Currency__c`                      | 币种           | `waers`   | 币种           |
  | `Price_Group__c`                   | 价格组         | `konda`   | 价格组         |
  | `Cust_Pric_Procedure__c`           | 客户定价过程   | `kalks`   | 客户定价过程   |
  | `Delivering_Plant__c`              | 交货工厂       | `vwerk`   | 交货工厂       |
  | `Shipping_Conditions__c`           | 装运条件       | `vsbed`   | 装运条件       |
  | `Terms_Of_Payment__c`              | 付款条件       | `zterm`   | 付款条件       |
  | `Acct_Assmt_Grp_Cust__c`           | 客户科目分配组 | `ktgrd`   | 客户科目分配组 |
  | `Incoterms__c`                     | 国际贸易条款   | `inco1`   | 国贸条款       |
  | `Inco_Location1__c`                | 国贸条款位置   | `inco2_L` | 国贸条款位置   |
  | `Is_Freeze__c`                     | 冻结标识       | `AUFSD`   | 销售冻结       |

  ---

  ### 8.3 Customer_Credit_Info__c → SAP (creditLimit)

  | SF字段                             | SF标签       | SAP字段       | SAP标签  |
  | ---------------------------------- | ------------ | ------------- | -------- |
  | `Customer__r.MDG_Customer_Code__c` | 客户编码     | `partner`     | 客户编码 |
  | `Rules__c`                         | 规则         | `limitrule`   | 额度规则 |
  | `Risk_Class__c`                    | 风险类别     | `riskclass`   | 风险类   |
  | `Check_Rule__c`                    | 检查规则     | `checkrule`   | 检查规则 |
  | `Credit_Segment__c`                | 信用段       | `creditsgmnt` | 信用段   |
  | `Actual_Credit_limit__c`           | 实际信用额度 | `creditlimit` | 额度     |
  | `Valid_Until__c`                   | 有效期至     | `valid_date`  | 有效至   |

  ---

  ## 九、代码片段解析

  ### 9.1 统驭科目自动计算逻辑

  ```apex
  /**
   * 根据交货工厂和客户科目分配组自动计算统驭科目
   * 
   * 工厂3010/3011/3020（中国工厂）:
   *   - 科目分配组01 → 1122010100 (应收内部账款-集团内)
   *   - 科目分配组02 → 1122020100 (应收内部账款-关联方)
   * 
   * 工厂5070/5130（阿根廷工厂）:
   *   - 科目分配组01 → 1122010000 (应收账款-一般)
   *   - 科目分配组02 → 1122020000 (应收账款-关联方)
   */
  
  // 触发器位置: CustomerSalesInfoTriggerHandler.isBefore
  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
      for (Customer_Sales_Info__c csi : Trigger.new) {
          // 中国工厂逻辑
          if (csi.Delivering_Plant__c == '3010' || 
              csi.Delivering_Plant__c == '3011' || 
              csi.Delivering_Plant__c == '3020') {
              
              if (csi.Acct_Assmt_Grp_Cust__c == '01') {
                  csi.Reconciliation_Account__c = '1122010100';
              }
              if (csi.Acct_Assmt_Grp_Cust__c == '02') {
                  csi.Reconciliation_Account__c = '1122020100';
              }
          }
          
          // 阿根廷工厂逻辑
          if (csi.Delivering_Plant__c == '5070' || 
              csi.Delivering_Plant__c == '5130') {
              
              if (csi.Acct_Assmt_Grp_Cust__c == '01') {
                  csi.Reconciliation_Account__c = '1122010000';
              }
              if (csi.Acct_Assmt_Grp_Cust__c == '02') {
                  csi.Reconciliation_Account__c = '1122020000';
              }
          }
      }
  }
  ```

  ---

  ### 9.2 税收类别自动创建逻辑

  ```apex
  /**
   * 当销售视图的国家变更时，自动删除旧税收类别并创建新税收类别
   * 
   * 逻辑说明:
   * 1. 查询新国家对应的所有税分类主数据
   * 2. 为每个税分类主数据创建Customer_Tax_Category__c记录
   * 3. Tax_Category__c字段格式: "XX-YY" (如 "MX-01")
   */
  
  // 触发器位置: CustomerSalesInfoTriggerHandler.isAfter
  if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
      // 收集国家代码
      Set<String> countrySet = new Set<String>();
      for (Customer_Sales_Info__c csi : Trigger.new) {
          countrySet.add(csi.Country_Code_Text__c);
      }
      
      // 查询税分类主数据
      Map<String, List<Tax_Category_Master_Data__c>> tcmdMap = new Map<String, List<Tax_Category_Master_Data__c>>();
      for (Tax_Category_Master_Data__c tcmd : [SELECT Id, Country_Code__c, Name 
                                                FROM Tax_Category_Master_Data__c 
                                                WHERE Country_Code__c IN :countrySet]) {
          if (tcmdMap.containsKey(tcmd.Country_Code__c)) {
              tcmdMap.get(tcmd.Country_Code__c).add(tcmd);
          } else {
              tcmdMap.put(tcmd.Country_Code__c, new List<Tax_Category_Master_Data__c>{tcmd});
          }
      }
      
      // 创建税收类别记录
      List<Customer_Tax_Category__c> insertList = new List<Customer_Tax_Category__c>();
      for (Customer_Sales_Info__c csi : Trigger.new) {
          // 插入时或国家变更时创建
          if (Trigger.isInsert || (Trigger.isUpdate && csi.Country__c != oldMap.get(csi.Id).Country__c)) {
              if (tcmdMap.get(csi.Country_Code_Text__c) != null) {
                  for (Tax_Category_Master_Data__c tcm : tcmdMap.get(csi.Country_Code_Text__c)) {
                      Customer_Tax_Category__c ctc = new Customer_Tax_Category__c();
                      ctc.Sales_View__c = csi.Id;
                      ctc.Tax_Category_Master_Data__c = tcm.Id;
                      ctc.Tax_Category_Type__c = tcm.Name;
                      insertList.add(ctc);
                  }
              }
          }
      }
      Database.Insert(insertList);
  }
  ```

  ---

  ### 9.3 External_ID自动生成

  ```apex
  /**
   * 为每个销售视图生成唯一外部ID
   * 格式: {Customer__c}_{Sales_Org__c}_{Distr_Channel__c}
   * 
   * 示例: 0015g000006ABCD_3010_01
   */
  
  // 触发器位置: CustomerSalesInfoTriggerHandler.isBefore
  csi.External_ID__c = csi.Customer__c + '_' + csi.Sales_Org__c + '_' + csi.Distr_Channel__c;
  ```

  ---

  ### 9.4 延迟同步机制

  ```apex
  /**
   * 当客户还未获得SAP编码时，延迟1分钟后同步销售视图
   * 
   * 原因: 客户审批通过后，客户基本信息同步SAP需要时间
   *       如果立即同步销售视图，可能客户还没有SAP编码
   * 
   * 实现: 使用System.schedule创建定时任务
   */
  
  // 触发器位置: CustomerSalesInfoTriggerHandler.isAfter
  if (accMap.get(csi.Customer__c).MDG_Customer_Code__c == null) {
      // 计算1分钟后的时间
      Datetime d = Datetime.now();
      String minute = d.minute() + 1 + '';
      String sch = d.second() + ' ' + minute + ' ' + d.hour() + ' ' + 
                   d.day() + ' ' + d.month() + ' ? ' + d.year();
      
      // 创建定时任务
      SyncAccountSalesInfoSchedule schup = new SyncAccountSalesInfoSchedule(csi.Id);
      System.schedule(
          '定时一分钟后SyncAccountSalesInfo' + Datetime.now().getTime(),
          sch,
          schup
      );
  }
  ```

  ---

  ### 9.5 触发器递归控制

  ```apex
  /**
   * 使用Utility.IgnoreAction方法避免触发器递归
   * 
   * 原理: 在执行Database.update前设置flag为true
   *       在Trigger中检查flag，如果为true则跳过逻辑
   *       执行完成后重置flag为false
   */
  
  // 更新Account时跳过AccountTriggerHandler的逻辑
  Utility.IgnoreAction(true, false, 'AccountTriggerHandler');
  Database.update(csiList1);  // 批量更新销售视图状态
  Utility.IgnoreAction(false, false, 'AccountTriggerHandler');
  
  // 更新Account时跳过CustomerSalesInfoTriggerHandler的逻辑
  Utility.IgnoreAction(true, false, 'CustomerSalesInfoTriggerHandler');
  Database.Update(accList);  // 更新Account的YPF标识
  Utility.IgnoreAction(false, false, 'CustomerSalesInfoTriggerHandler');
  
  // 更新Account时跳过CustomerQuotaChangeTriggerHandler的逻辑
  Utility.IgnoreAction(true, false, 'CustomerQuotaChangeTriggerHandler');
  update accList;  // 更新Account的额度字段
  Utility.IgnoreAction(false, false, 'CustomerQuotaChangeTriggerHandler');
  
  // 客户信息变更审批通过时，跳过AccountTriggerHandler的校验
  Utility.isPassTriggerLogic = TRUE;
  Database.update(accUpdateList);
  ```

  ---

  ### 9.6 SAP同步状态回写

  ```apex
  /**
   * SAP同步成功/失败后，更新同步状态和相关信息
   */
  
  // 成功时
  if (syncReturnData.esbinfo.returnstatus == 'S') {
      upAcc.Sync_Status__c = 'Synchronized';
      upAcc.Sync_Failure_Reasons__c = '';
  }
  
  // 失败时
  if (syncReturnData.esbinfo.returnstatus == 'E') {
      upAcc.Sync_Status__c = 'Synchronization Failure';
      upAcc.Sync_Failure_Reasons__c = syncReturnData.esbinfo.returnmsg;
      // 通知客户负责人
      Utility.notificationUser(accList[0].OwnerId, Id);
  }
  ```

  ---

  ## 十、异常处理机制

  ### 10.1 接口调用异常处理

  ```apex
  try {
      // 调用SAP接口
      HttpResponse responseBody = InterfaceUtility.send_SAP_POST_Service(requestBody, END_POINT);
      
      // 检查HTTP状态码
      isSuccess = responseBody.getStatusCode() == 200 ? true : false;
      
      if (isSuccess) {
          // 解析响应
          ResponseBody syncReturnData = (ResponseBody) JSON.deserialize(responseBodyStr, ResponseBody.class);
          
          if (syncReturnData.esbinfo != null) {
              // 检查SAP返回状态
              if (syncReturnData.esbinfo.returnstatus == 'S') {
                  // 成功处理
              } else if (syncReturnData.esbinfo.returnstatus == 'E') {
                  // 业务错误处理
                  returnResult.isSuccess = false;
                  returnResult.message = syncReturnData.esbinfo.returnmsg;
              }
          } else {
              // 响应格式错误
              returnResult.isSuccess = false;
              returnResult.message = responseBodyStr;
          }
      } else {
          // HTTP错误
          returnResult.isSuccess = false;
          returnResult.message = responseBodyStr;
      }
  } catch (Exception e) {
      // 捕获异常
      returnResult.isSuccess = false;
      returnResult.message = e.getMessage() + e.getLineNumber();
      errorMessage = e.getMessage() + e.getLineNumber();
  }
  
  // 记录接口日志
  InterfaceUtility.insertInterfaceLog(
      'CustomerInfoSyncToSAP',      // 类名
      'CRM',                         // 发送方
      'SAP',                         // 接收方
      END_POINT,                     // 接口端点
      requestBody,                   // 请求体
      isSuccess,                     // 是否成功
      false,                         // 是否异步
      responseBodyStr,               // 响应体
      errorMessage,                  // 错误信息
      'POST',                        // 请求方式
      new List<String>{Id},          // 关联记录ID
      '客户基本信息同步SAP',          // 接口描述
      'CRM同步客户基本信息至SAP'      // 详细描述
  );
  ```

  ---

  ### 10.2 通知机制

  ```apex
  /**
   * SAP同步失败时通知客户负责人
   */
  Utility.notificationUser(accList[0].OwnerId, Id);
  
  /**
   * 审批结果通知
   */
  if (cqc.Approval_Status__c == 'Approved' 
      && cqc.Approval_Status__c != cqcOldMap.get(cqc.Id).Approval_Status__c) {
      Utility.notificationUserTitle(
          uSet,                          // 通知用户ID集合
          cqc.Id,                        // 记录ID
          System.Label.Credit_Approved_Title,   // 标题
          System.Label.Credit_Approved_Title + cqc.Name  // 内容
      );
  }
  
  /**
   * 资信调查完成通知（应用内通知 + 邮件）
   */
  CustomNotificationFromApex.notifyUsers(
      notificationType,
      adminSet,
      acc.Id,
      acc.Name + System.Label.NotficationServiceSaleTitle,
      System.Label.NotficationService
  );
  
  // 发送邮件
  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
  email.setToAddresses(new List<String>{u.Email});
  email.setSubject(System.Label.NotficationServiceSaleTitle);
  email.setPlainTextBody(body);
  // 设置OrgWideEmailAddress（如果有配置）
  OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rb@crm.com'];
  if (owea.size() > 0) {
      email.setOrgWideEmailAddressId(owea.get(0).Id);
  }
  Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
  ```

  ---

  ## 十一、相关文件清单

  ### 11.1 Trigger文件

  | 文件路径                                                     | 说明                   |
  | ------------------------------------------------------------ | ---------------------- |
  | `force-app/main/default/triggers/AccountTrigger.trigger`     | 客户主数据触发器       |
  | `force-app/main/default/triggers/CustomerSalesInfoTrigger.trigger` | 销售视图触发器         |
  | `force-app/main/default/triggers/CustomerCreditTrigger.trigger` | 信用额度触发器         |
  | `force-app/main/default/triggers/CustomerQuotaChangeTrigger.trigger` | 额度变更申请触发器     |
  | `force-app/main/default/triggers/CustomerUpdateTrigger.trigger` | 客户信息变更触发器     |
  | `force-app/main/default/triggers/CustomerSalesInfoChangeApplicationTrigger.trigger` | 销售视图变更申请触发器 |
  | `force-app/main/default/triggers/BankInfoTrigger.trigger` | 银行信息触发器 |
  | `force-app/main/default/triggers/CompanyDynamicsTrigger.trigger` | 公司动态触发器 |
  | `force-app/main/default/triggers/CustomerTaxNumberCategoryTrigger.trigger` | 客户税号触发器 |
  | `force-app/main/default/triggers/SalesForecastSummaryTrigger.trigger` | 销售预测汇总触发器 |

  ### 11.2 Handler文件

  | 文件路径                                                     | 说明               |
  | ------------------------------------------------------------ | ------------------ |
  | `force-app/main/default/classes/AccountTriggerHandler.cls`   | 客户触发器处理类   |
  | `force-app/main/default/classes/CustomerSalesInfoTriggerHandler.cls` | 销售视图处理类     |
  | `force-app/main/default/classes/CustomerCreditTriggerHandler.cls` | 信用额度处理类     |
  | `force-app/main/default/classes/CustomerQuotaChangeTriggerHandler.cls` | 额度变更处理类     |
  | `force-app/main/default/classes/CustomerUpdateTriggerHandler.cls` | 客户信息变更处理类 |
  | `force-app/main/default/classes/CustomeSalesInfoApplicationHandler.cls` | 销售视图变更处理类 |
  | `force-app/main/default/classes/BankInfoTriggerHandler.cls` | 银行信息处理类 |
  | `force-app/main/default/classes/CompanyDynamicsTriggerHandler.cls` | 公司动态处理类 |
  | `force-app/main/default/classes/CustomerTaxNumberCategoryTriggerHandler.cls` | 客户税号处理类 |
  | `force-app/main/default/classes/SalesForecastSummaryTriggerHandler.cls` | 销售预测汇总处理类 |

  ### 11.3 SAP接口类

  | 文件路径                                                     | 说明             |
  | ------------------------------------------------------------ | ---------------- |
  | `force-app/main/default/classes/CustomerInfoSyncToSAP.cls`   | 客户基本信息同步 |
  | `force-app/main/default/classes/CustomerSalesInfoSyncToSAP.cls` | 销售视图同步     |
  | `force-app/main/default/classes/CustomerlimitSyncToSAP.cls`  | 信用额度同步     |
  | `force-app/main/default/classes/SAPReceivableWebService.cls` | 应收账款同步(SAP→CRM) |
  | `force-app/main/default/classes/SalesForecastDataBatch.cls` | 销售预测达成计算 |

  ### 11.4 对象定义

  | 文件路径                                                     | 说明             |
  | ------------------------------------------------------------ | ---------------- |
  | `force-app/main/default/objects/Account/Account.object-meta.xml` | 客户主数据       |
  | `force-app/main/default/objects/Customer_Sales_Info__c/Customer_Sales_Info__c.object-meta.xml` | 销售视图         |
  | `force-app/main/default/objects/Customer_Credit_Info__c/Customer_Credit_Info__c.object-meta.xml` | 信用额度         |
  | `force-app/main/default/objects/Customer_Quota_Change__c/Customer_Quota_Change__c.object-meta.xml` | 额度变更申请     |
  | `force-app/main/default/objects/Customer_Tax_Category__c/Customer_Tax_Category__c.object-meta.xml` | 税收类别         |
  | `force-app/main/default/objects/Customer_Tax_Number_Category__c/Customer_Tax_Number_Category__c.object-meta.xml` | 税号类别         |
  | `force-app/main/default/objects/Customer_Update__c/Customer_Update__c.object-meta.xml` | 客户信息变更     |
  | `force-app/main/default/objects/Customer_Sales_Info_Change_Application__c/Customer_Sales_Info_Change_Application__c.object-meta.xml` | 销售视图变更申请 |
  | `force-app/main/default/objects/Bank_Info__c/Bank_Info__c.object-meta.xml` | 银行信息 |
  | `force-app/main/default/objects/Customer_Shipping_Address__c/Customer_Shipping_Address__c.object-meta.xml` | 客户收货地址 |
  | `force-app/main/default/objects/Company_Dynamics__c/Company_Dynamics__c.object-meta.xml` | 公司动态 |
  | `force-app/main/default/objects/Account_Receivable__c/Account_Receivable__c.object-meta.xml` | 客户应收账款 |
  | `force-app/main/default/objects/Sales_Forecast_Summary__c/Sales_Forecast_Summary__c.object-meta.xml` | 销售预测汇总 |
  | `force-app/main/default/objects/Sales_Forcast__c/Sales_Forcast__c.object-meta.xml` | 销售预测明细 |

  ### 11.5 Flow文件

  | 文件路径                                                     | 说明                 |
  | ------------------------------------------------------------ | -------------------- |
  | `force-app/main/default/flows/AccountKeyFieldUpdate.flow-meta.xml` | 客户关键信息更新流程 |
  | `force-app/main/default/flows/Set_address_Customer_Name.flow-meta.xml` | 设置客户名称流程     |

  ### 11.6 FieldSet定义

  | 文件路径                                                     | 说明               |
  | ------------------------------------------------------------ | ------------------ |
  | `force-app/main/default/objects/Account/fieldSets/Customer_Info.fieldSet-meta.xml` | 客户信息字段集     |
  | `force-app/main/default/objects/Account/fieldSets/Can_not_change.fieldSet-meta.xml` | 不可修改字段集     |
  | `force-app/main/default/objects/Account/fieldSets/ChangeFieldByFinance.fieldSet-meta.xml` | 财务不可修改字段集 |

  ---

  ## 附录

  ### A1. 销售组织代码对照表

  | 代码 | 描述             | 工厂 | 国家 |
  | :--: | ---------------- | :--: | :--: |
  | 1040 | HQ Sales Org     |  -   |  CN  |
  | 1050 | HQ Sales Org     |  -   |  CN  |
  | 1060 | HQ Sales Org     |  -   |  CN  |
  | 1080 | HQ Sales Org     |  -   |  CN  |
  | 2010 | HQ Sales Org     |  -   |  CN  |
  | 2210 | HQ Sales Org     |  -   |  CN  |
  | 2100 | Sales Org        |  -   |  CN  |
  | 3010 | MX Factory Sales | 3010 |  MX  |
  | 3011 | MX Factory Sales | 3011 |  MX  |
  | 3020 | MX Factory Sales | 3020 |  MX  |
  | 5070 | AR Factory Sales | 5070 |  AR  |
  | 5130 | AR Factory Sales | 5130 |  AR  |

  ### A2. 统驭科目编码规则

  |      工厂      | 科目分配组 | 统驭科目   | 描述                |
  | :------------: | :--------: | ---------- | ------------------- |
  | 3010/3011/3020 |     01     | 1122010100 | 应收内部账款-集团内 |
  | 3010/3011/3020 |     02     | 1122020100 | 应收内部账款-关联方 |
  |   5070/5130    |     01     | 1122010000 | 应收账款-一般       |
  |   5070/5130    |     02     | 1122020000 | 应收账款-关联方     |

  ### A3. 状态值说明

  | 对象                     | 字段                        | 可选值                                                |
  | ------------------------ | --------------------------- | ----------------------------------------------------- |
  | Account                  | Customer_Approval_Status__c | Draft, Approving, Approved, Rejected                  |
  | Customer_Sales_Info__c   | Sales_View_Status__c        | Draft, Approving, Approved, Reject                    |
  | Customer_Quota_Change__c | Approval_Status__c          | Draft, Approving, Approved, Rejected                  |
  | Account                  | Sync_Status__c              | Synchronized, Synchronization Failure, Unsynchronized |
  | Customer_Sales_Info__c   | Sync_Status__c              | Synchronized, Synchronization Failure, Unsynchronized |
  | Customer_Credit_Info__c  | Sync_Status__c              | Synchronized, Synchronization Failure, Unsynchronized |

