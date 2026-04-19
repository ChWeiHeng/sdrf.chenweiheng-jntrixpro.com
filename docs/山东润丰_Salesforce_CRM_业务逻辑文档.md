# 山东润丰 Salesforce CRM 系统业务逻辑文档

> 本文档整理了山东润丰（Shandong Rainbow Agro）Salesforce CRM 项目的完整业务逻辑，供后续 Claude 分析使用。

---

## 一、系统架构总览

### 1.1 系统定位

```
┌─────────────────────────────────────────────────────────────────┐
│                        Salesforce CRM                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ 客户管理  │  │ 订单管理  │  │ 报价管理  │  │ 合同管理  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ 营销管理  │  │ 收款管理  │  │ 发票管理  │  │ 库存管理  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
├─────────────────────────────────────────────────────────────────┤
│                    集成层 (Interface Layer)                      │
│  ┌─────────────────┐     ┌─────────────────┐                   │
│  │  SAP ERP 集成   │◄───►│  BPM 系统集成    │                   │
│  │  (SAPDelivery)  │     │  (合同管理)      │                   │
│  └─────────────────┘     └─────────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
           │                              │
           ▼                              ▼
┌───────────────────┐          ┌───────────────────┐
│      SAP ERP      │          │      BPM 系统     │
│   (后端ERP系统)    │          │    (合同审批)     │
└───────────────────┘          └───────────────────┘
```

### 1.2 技术栈

| 组件 | 技术 |
|------|------|
| CRM 平台 | Salesforce |
| 开发语言 | Apex, JavaScript (LWC) |
| 前端框架 | Lightning Web Components (LWC) |
| 集成方式 | REST API, @RestResource |
| 审批流 | Salesforce Flow / Approval Process |
| 批量处理 | Batch Apex |
| 日志系统 | Interface_Log__c 自定义对象 |

### 1.3 销售组织与多币种支持

| 销售组织代码 | 国家/地区 | 币种 |
|-------------|----------|------|
| 3010, 3011 | 墨西哥 MX | MXN |
| 3020 | 墨西哥 MX | MXN |
| 5070, 5130 | 阿根廷 AR / YPF | ARS |
| 1040, 1050, 1060, 1080 | 总部 CN | CNY |
| 2010, 2210 | 总部 CN | CNY |

---

## 二、核心对象关系图

```
┌─────────────────┐
│     Account     │  客户主数据
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│ Quote  │ │ Order  │  报价单 / 销售订单
└───┬────┘ └───┬────┘
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│Quote   │ │Order   │  报价明细 / 订单明细
│Detail  │ │Item    │
└────────┘ └───┬────┘
              │
              ▼
       ┌─────────────┐
       │Delivery_Note │  交货单
       └─────────────┘
```

---

## 三、订单类型体系

### 3.1 订单类型列表

| 订单类型代码 | 名称 | 说明 |
|-------------|------|------|
| ZAR1 | 标准销售订单 | 常规销售流程 |
| ZARE | 寄售发货 | 从寄售库存发货，关联 ZARB |
| ZARA | 寄售退回 | 退货到寄售库存 |
| ZARF | 冻结库存占用 | 占用寄售库存 |
| ZAR2 | 退货订单 | 客户退货 |
| ZARB | 返还订单/寄售库存 | 寄售库存返还 |
| ZMX1 | 墨西哥订单类型1 | 墨西哥特定业务 |
| ZMX2 | 墨西哥订单类型2 | 墨西哥特定业务 |
| ZMX3 | 墨西哥订单类型3 | 墨西哥特定业务 |
| ZMX4 | 墨西哥订单类型4 | 墨西哥特定业务 |
| ZFD | 免费样品 | 样品赠送 |

### 3.2 订单状态流转

```
┌────────┐    提交审批     ┌────────────┐    审批通过     ┌──────────┐
│ Draft  │ ─────────────► │ Approving  │ ─────────────► │ Approved │
└────────┘                └────────────┘                └────┬─────┘
     ▲                           │                          │
     │                           │ 审批拒绝                  │
     │                           ▼                          │
     │                    ┌──────────┐                      │
     └────────────────────│ Rejected │                     │
                          └──────────┘                      │
                                                             │
                                                             ▼
                                                   ┌──────────────────┐
                                                   │ Synchronized      │ (SAP同步成功)
                                                   └──────────────────┘
```

### 3.3 寄售库存完整生命周期 (核心业务流程)

```
ZARB 创建 ──► ZARE 发货 ──► ZARF 冻结 ──► ZARA 退回
(返还订单)    (寄售发货)    (占用库存)    (退回库存)

详细说明：
1. ZARB (返还订单/寄售库存)
   - 客户将未使用的产品返还
   - 创建后生成 Delivery_Note (交货单)
   - Delivery_Quantity = 返还数量
   - Remain_Quantity = Delivery_Quantity - Issue_Quantity

2. ZARE (寄售发货)
   - 客户需要再次使用寄售库存
   - 系统自动关联到 ZARB 的 Remain_Quantity
   - 先进先出 (FIFO) 原则消耗 ZARB 库存
   - Issue_Quantity 增加，Remain_Quantity 减少

3. ZARF (冻结库存占用)
   - 占用寄售库存，确保库存保留
   - 审批通过后，ZARB Remain_Quantity 返回
   - 提交时校验：系统中其他 ZARE 订单必须全部审批通过

4. ZARA (寄售退回)
   - 客户退货
   - 可通过 ZSD005_004 自动创建
   - 关联到 ZARF 冻结的库存
```

---

## 四、业务模块详细说明

### 4.1 客户管理模块

#### 4.1.1 AccountTriggerHandler (客户触发器处理)

**功能说明**：
- 管理客户的审批状态 (Customer_Approval_Status__c)
- 客户信息变更后自动同步 SAP
- 墨西哥特定字段保护逻辑

**审批状态流转**：
```
Draft ──► Approving ──► Approved
                       └──► Rejected
```

**关键逻辑**：
1. 新客户创建后状态为 Draft
2. 提交审批后变为 Approving
3. 审批通过后变为 Approved，同时同步 SAP 获取客户编码
4. 审批拒绝后变为 Rejected

#### 4.1.2 CustomerInfoSyncToSAP (客户主数据同步)

**接口端点**：`CustomerInfo`

**同步字段**：
| Salesforce 字段 | SAP 字段 | 说明 |
|----------------|----------|------|
| Name | 客户名称 | |
| Customer_Code__c | 客户编码 | SAP 返回 |
| Bank_Info__c | 银行信息 | |
| Bank_Account__c | 银行账号 | |

#### 4.1.3 CustomerSalesInfoSyncToSAP (客户销售视图同步)

**接口端点**：
- 新增：`CustomerSalesInfoNEW`
- 更新：`CustomerSalesInfoUpdate`

**同步内容**：
- 销售视图信息
- 税收类别 (Tax_Category__c)
- 付款条款 (Payment_Terms__c)
- 财务相关信息

#### 4.1.4 CustomerQuotaChangeTriggerHandler (信用额度变更审批)

**功能**：处理客户信用额度变更请求的审批流程

**审批后操作**：
- 更新 Customer_Credit_Info 中的信用额度信息

---

### 4.2 订单管理模块

#### 4.2.1 OrderTriggerHandler (订单触发器处理) - 1186行

**核心功能**：

1. **订单审批管理**
   - 校验订单类型
   - 计算佣金
   - 发送通知邮件

2. **ZARF 数量占用逻辑**
   - `calculateZARERemainQuantity()` 计算 ZARB 剩余数量
   - ZARF 订单占用寄售库存

3. **墨西哥订单毛利计算**
   - ZMX1/ZMX2/ZMX3/ZMX4 类型订单
   - 计算逆向单据的毛利

4. **邮件通知**
   - `EmailToUser()` - 通用订单通知
   - `ZARAEmailToUser()` - 寄售退回通知

**订单类型处理**：

| 订单类型 | 特殊处理 |
|---------|---------|
| ZAR1 | 标准销售流程 |
| ZARE | 关联 ZARB 库存，先进先出 |
| ZARA | 寄售退回，关联 ZARF |
| ZARF | 冻结库存占用 |
| ZAR2 | 退货订单 |
| ZARB | 创建寄售库存 |
| ZMX1-4 | 墨西哥特殊处理 |

#### 4.2.2 OrderItemTriggerHandler (订单明细处理) - 1765行

**核心功能**：

1. **库存校验**
   - ZARF/ZARE/ZARA 类型订单校验库存
   - `validateRemainQty()` 校验库存余量
   - `validateRemainMinusQty()` 校验消耗数量

2. **ZARB FIFO 先进先出关联**
   - `splitZAREToZARBFIFO()` 按时间顺序关联
   - 自动拆分订单明细
   - 更新交货单 Issue_Quantity

3. **ZARF 提交校验**
   - `validateApprovingOrder()` 校验审批中 ZARE 订单
   - ZARF 提交时，系统中相同客户_产品的 ZARE 必须全部审批通过

4. **库存数量追踪**
   - Remain_Quantity: 剩余数量
   - Issue_Quantity: 消耗数量
   - Auto_ZARA_Issue_Quantity: 自动退回消耗量

**关键算法**：

```apex
// ZARB FIFO 先进先出关联
// 唯一键：客户_产品_销售组织
// 按 Delivery_Post_Date 升序排列
// 优先消耗最早的 ZARB 库存
```

#### 4.2.3 SubmitOrderController (订单提交审批) - 974行

**提交审批前的校验**：

1. **信用额度校验** `GetCustomerlimitFROMSAP.submitToSAP()`
   - 查询 SAP 获取客户信用额度
   - 校验订单金额是否超过可用额度

2. **ZARF 数量校验** `zareQuantityEnough()`
   - 校验 ZARB 库存是否足够占用

3. **ZMX1 数量校验** `orderItem()`
   - 墨西哥订单特殊数量校验

4. **发票数量校验** `invoice()`
   - 校验发票与订单数量匹配

#### 4.2.4 AddOrderItemController (订单明细添加) - 1645行

**功能**：
- 按订单类型不同处理逻辑
- 库存校验和数量计算
- 产品包处理
- 自动拆分逻辑

---

### 4.3 报价管理模块

#### 4.3.1 QuoteTriggerHandler (报价单触发器)

**功能**：
- 付款条款成本自动赋值
- 冻结客户校验
- 报价转订单时的数据传递

#### 4.3.2 AddQuoteDetailController (报价明细添加)

**功能**：
- 添加报价明细行
- 产品价格计算
- 数量和金额汇总

---

### 4.4 合同管理模块

#### 4.4.1 ContractsTriggerHandler (合同触发器)

**功能**：
- 合同审批后同步 BPM 系统
- 付款条款成本费率自动赋值

#### 4.4.2 DraftContractSyncToBPM (合同同步 BPM)

**接口端点**：`CreateContract`

**同步内容**：

| 内容类型 | 处理方式 |
|---------|---------|
| 产品信息 | 解析产品描述，关联产品 |
| 附件 | 上传附件到 BPM |
| 付款条款 | 获取付款条款列表 |

**数据结构**：
```apex
roi.CONTRACT_NUMBER = '';        // 合同编号
roi.CONTRACT_TYPE = '';         // 合同类型
roi.SALES_ORG = '';             // 销售组织
roi.DIST_CHANNEL = '';          // 分销渠道
roi.DIVISION = '';              // 产品组
roi.VALID_FROM = '';            // 有效期开始
roi.VALID_TO = '';              // 有效期结束
roi.PAYMENT_TERMS = '';         // 付款条款
roi.CURRENCY = '';              // 币种
roi.CUSTOMER_CODE = '';         // 客户编码
roi.CUSTOMER_NAME = '';         // 客户名称
```

---

### 4.5 营销管理模块

#### 4.5.1 CampaignTriggerHandler (营销活动触发器)

**功能**：

1. **预算校验**
   - 活动预算不能为负数

2. **审批后自动创建免费订单**
   - 审批通过后自动生成 ZFD 免费样品订单

3. **附件校验**
   - 至少 5 张照片
   - 至少 1 个视频

---

### 4.6 发票管理模块

#### 4.6.1 InvoiceTriggerHandler (发票触发器)

**功能**：
- 发票共享到 AccountTeam
- 维护 AccountTeam 成员对发票的访问权限

---

### 4.7 寄售库存管理

#### 4.7.1 ConsignmentOrderQuantityReturn (寄售订单数量管理) - 107行

**核心方法**：

1. **addRemainQuantity()**
   - ZARF 审批通过时调用
   - 返回 ZARB 数量
   - 增加 ZARB Remain_Quantity

2. **subRemianQuantity()**
   - ZARE/ZARA 创建时调用
   - 消耗 ZARB 数量
   - 减少 ZARB Remain_Quantity
   - 关闭已完成的 ZARF

---

## 五、SAP/BPM 集成接口（完整版）

系统包含 **21 个接口**，分为三大类：

### 5.1 接口总览

| 方向 | 接口名称 | 说明 | 端点/方法 |
|------|---------|------|----------|
| **SAP→CRM** | SAPOrderWebService | SAP 非常规订单同步 | `@RestResource('/SAPOrderWebService')` |
| **SAP→CRM** | SAPBillingWebService | SAP 开票信息同步 | `@RestResource('/SAPBillingWebService')` |
| **SAP→CRM** | SAPCollectionWebService | SAP 回款信息同步 | `@RestResource('/SAPCollectionWebService')` |
| **SAP→CRM** | SAPReceivableWebService | SAP 应收账款同步 | `@RestResource('/SAPReceivableWebService')` |
| **SAP→CRM** | SAPProductWebService | SAP 产品主数据同步 | `@RestResource('/SAPProductWebService')` |
| **SAP→CRM** | SAPPackageDataWebService | SAP 包装规格数据同步 | `@RestResource('/SAPPackageDataWebService')` |
| **SAP→CRM** | DeleteDeliveryNoteWebService | SAP 交货单删除同步 | `@RestResource('/DeleteDeliveryNoteWebService')` |
| **SAP→CRM** | ProductNameWebservice | SAP 商品名称同步 | `@RestResource('/ProductNameWebservice')` |
| **BPM→CRM** | PriceListWebService | BPM 价格列表同步 | `@RestResource('/PriceListWebService')` |
| **BPM→CRM** | BPMContractWebService | BPM 合同信息同步 | `@RestResource('/BPMContractWebService')` |
| **SAP→CRM** | MainBusinessIncomeWebService | SAP 主营业务收入同步 | `@RestResource('/MainBusinessIncomeWebService')` |
| **CRM→SAP** | OrderSyncToSAP | 订单同步到 SAP | `ZSD005_001/002/004` |
| **CRM→SAP** | CustomerInfoSyncToSAP | 客户主数据同步 | `CustomerInfo` |
| **CRM→SAP** | CustomerSalesInfoSyncToSAP | 客户销售视图同步 | `CustomerSalesInfoNEW/Update` |
| **CRM→SAP** | CustomerlimitSyncToSAP | 客户信用额度同步 | `creditLimit` |
| **CRM→SAP** | GetCustomerlimitFROMSAP | 客户额度查询 | `getLimit` |
| **CRM→SAP** | ProductSyncToSAP | 产品主数据同步到 SAP | `productNumber` |
| **CRM→SAP** | ProductSalesInfoSyncToSAP | 产品销售视图同步 | - |
| **CRM→BPM** | DraftContractSyncToBPM | 合同同步到 BPM | `CreateContract` |
| **CRM→BPM** | RecallContractFROMBPM | BPM 合同取回 | `RecallContract` |

---

### 5.2 SAP → CRM 入站接口（接收 SAP/BPM 数据）

#### 5.2.1 SAPOrderWebService - SAP 非常规订单同步

**端点**：`@RestResource(urlMapping='/SAPOrderWebService')`

**功能**：接收 SAP 创建的非常规订单

**目标对象**：`Order__c` + `Order_Item__c`

**关键字段**：VBELN(SAP订单号), KUNNR(客户编号), VKORG(销售组织), AUART(销售凭证类型)

---

#### 5.2.2 SAPBillingWebService - SAP 开票信息同步

**端点**：`@RestResource(urlMapping='/SAPBillingWebService')`

**功能**：接收 SAP 开票信息

**目标对象**：`Invoice__c` + `Billing__c`

---

#### 5.2.3 SAPCollectionWebService - SAP 回款信息同步

**端点**：`@RestResource(urlMapping='/SAPCollectionWebService')`

**功能**：接收 SAP 回款/收款明细数据

**目标对象**：`Collection_Details__c`

---

#### 5.2.4 SAPReceivableWebService - SAP 应收账款同步

**端点**：`@RestResource(urlMapping='/SAPReceivableWebService')`

**功能**：接收 SAP 应收账款数据

**目标对象**：`Account_Receivable__c`

---

#### 5.2.5 SAPProductWebService - SAP 产品主数据同步

**端点**：`@RestResource(urlMapping='/SAPProductWebService')`

**功能**：接收 SAP 产品主数据

**目标对象**：`Product__c`, `Product_Sales_Info__c`, `Product_Unit__c`, `Product_Name__c`

---

#### 5.2.6 SAPPackageDataWebService - SAP 包装规格数据同步

**端点**：`@RestResource(urlMapping='/SAPPackageDataWebService')`

**功能**：接收 SAP 包装规格数据

**目标对象**：`Package_Data__c`

---

#### 5.2.7 DeleteDeliveryNoteWebService - SAP 交货单删除同步

**端点**：`@RestResource(urlMapping='/DeleteDeliveryNoteWebService')`

**功能**：接收 SAP 交货单删除请求

---

#### 5.2.8 ProductNameWebservice - SAP 商品名称同步

**端点**：`@RestResource(urlMapping='/ProductNameWebservice')`

**功能**：接收 SAP 商品名称数据

**目标对象**：`Product_Name__c`

---

#### 5.2.9 PriceListWebService - BPM 价格列表同步

**端点**：`@RestResource(urlMapping='/PriceListWebService')`

**功能**：接收 BPM 价格列表数据

**目标对象**：`Price_List__c`

---

#### 5.2.10 BPMContractWebService - BPM 合同信息同步

**端点**：`@RestResource(urlMapping='/BPMContractWebService')`

**功能**：接收 BPM 合同信息（审批通过后回写）

**目标对象**：`Contracts__c` + `Contracts_Detail__c`

---

#### 5.2.11 MainBusinessIncomeWebService - SAP 主营业务收入同步

**端点**：`@RestResource(urlMapping='/MainBusinessIncomeWebService')`

**功能**：接收 SAP 主营业务收入数据

**目标对象**：`Main_Business_Income__c` + `Main_Business_Income_Detail__c`

---

### 5.3 CRM → SAP 出站接口（推送数据到 SAP）

#### 5.3.1 OrderSyncToSAP - 订单同步 SAP

**端点**：`ZSD005_001`（新增）/ `ZSD005_002`（变更）/ `ZSD005_004`（自动ZARA）

| 操作类型 | 说明 | 使用场景 |
|---------|------|---------|
| ZSD005_001 | 新增订单 | 订单审批通过后首次同步 |
| ZSD005_002 | 变更订单 | 订单信息变更后同步 |
| ZSD005_004 | 自动 ZARA | ZARA 自动创建 |

---

#### 5.3.2 CustomerInfoSyncToSAP - 客户主数据同步

**端点**：`CustomerInfo`

**同步字段**：客户基本信息、银行信息

---

#### 5.3.3 CustomerSalesInfoSyncToSAP - 客户销售视图同步

**端点**：`CustomerSalesInfoNEW`（新增）/ `CustomerSalesInfoUpdate`（更新）

**同步内容**：销售视图、税收类别、财务信息

---

#### 5.3.4 GetCustomerlimitFROMSAP - 客户额度查询

**端点**：`getLimit`

**功能**：查询 SAP 获取客户剩余信用额度

**响应数据**：partner(客户编码), amount(剩余额度), zsfyq(是否逾期), ZOVDAYS(最大逾期天数)

---

### 5.4 CRM → BPM 出站接口

#### 5.4.1 DraftContractSyncToBPM - 合同同步到 BPM

**端点**：`CreateContract`

**功能**：合同审批通过后同步到 BPM 系统

---

#### 5.4.2 RecallContractFROMBPM - BPM 合同取回

**端点**：`RecallContract`

**功能**：从 BPM 取回合同到草稿状态

**处理逻辑**：更新合同状态为 Draft，解锁合同记录

---

### 5.5 接口日志机制

**Interface_Log__c 对象记录字段**：

| 字段 | 说明 |
|-----|------|
| Name | 日志名称 |
| Request_Message__c | 请求消息 |
| Response_Message__c | 响应消息 |
| Status__c | 状态 (Success/Failed) |
| Interface_Type__c | 接口类型 |

---

### 5.6 接口配置

**Interface_Info__mdt 元数据配置**：

| 元数据名称 | 说明 |
|-----------|------|
| Interface_Info.CreateOrderPRODUCTION | 订单同步 SAP（生产） |
| Interface_Info.CreateContractPRODUCTION | 合同同步 BPM（生产） |
| Interface_Info.CustomerInfoPRODUCTION | 客户信息同步（生产） |
| Interface_Info.CustomerSalesInfoNEWPRODUCTION | 客户销售视图新增（生产） |
| Interface_Info.CustomerSalesInfoUpdatePRODUCTION | 客户销售视图更新（生产） |
| Interface_Info.creditLimitPRODUCTION | 信用额度同步（生产） |
| Interface_Info.getLimitPRODUCTION | 客户额度查询（生产） |
| Interface_Info.productNumberPRODUCTION | 产品编号同步（生产） |
| Interface_Info.RecallContractPRODUCTION | 合同取回（生产） |

---

### 5.7 接口数据流向总图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              SAP ERP 系统                                │
└──────┬──────────────┬──────────────┬──────────────┬──────────────┬──────┘
       │              │              │              │              │
       ▼              ▼              ▼              ▼              ▼
  ┌─────────┐    ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
  │  订单   │    │  开票   │   │  收款   │   │ 应收账  │   │  产品   │
  │SAPOrder│    │SAPBilling│   │SAPCollec│   │SAPReceiv│   │SAPProduct│
  │WebSvc  │    │WebSvc   │   │tionSvc  │   │ableSvc  │   │WebSvc   │
  └────┬────┘    └────┬────┘   └────┬────┘   └────┬────┘   └────┬────┘
       │              │              │              │              │
       ▼              ▼              ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        Salesforce CRM 系统                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Order__c   │  │Invoice/Bill│  │Collection_ │  │  Product__c │     │
│  │ Order_Item │  │  __c       │  │  Details__c │  │Product_Name│     │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
       │              │              │
       ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│OrderSyncToSAP│  │CustomerInfo │  │DraftContract│
│             │  │SyncToSAP    │  │SyncToBPM    │
└─────────────┘  └─────────────┘  └─────────────┘
       │              │              │
       ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   SAP ERP   │  │   SAP ERP   │  │   BPM 系统  │
└─────────────┘  └─────────────┘  └─────────────┘
```

---

## 六、触发器执行链路

### 6.1 触发器列表

| 对象 | 触发器 | Handler 类 | 主要功能 |
|-----|--------|------------|---------|
| Account | AccountTrigger | AccountTriggerHandler | 客户审批状态管理 |
| Account | AccountTeamTrigger | AccountTeamTriggerHandler | 客户小组管理 |
| Order__c | OrderTrigger | OrderTriggerHandler | 订单生命周期管理 |
| Order_Item__c | OrderItemTrigger | OrderItemTriggerHandler | 订单明细处理 |
| Quote | QuoteTrigger | QuoteTriggerHandler | 报价单处理 |
| Contract | ContractsTrigger | ContractsTriggerHandler | 合同审批后同步 |
| Campaign | CampaignTrigger | CampaignTriggerHandler | 营销活动管理 |
| Invoice | InvoiceTrigger | InvoiceTriggerHandler | 发票共享 |
| Customer_Quota_Change__c | - | CustomerQuotaChangeTriggerHandler | 信用额度变更审批 |

### 6.2 触发器执行模式

```apex
// Trigger Handler 实现模式
public class XxxTriggerHandler implements Triggers.Handler {
    public void beforeInsert() { ... }
    public void beforeUpdate() { ... }
    public void beforeDelete() { ... }
    public void afterInsert() { ... }
    public void afterUpdate() { ... }
    public void afterDelete() { ... }
    public void afterUndelete() { ... }
}

// 触发器控制
Utility.IgnoreAction('ObjectName');  // 忽略触发器执行
Utility.isTriggerDisabled('ObjectName');  // 检查是否禁用
```

### 6.3 关键触发器链路

**订单提交审批链路**：
```
OrderTrigger (beforeUpdate)
  ├── 校验订单状态变化
  ├── 计算佣金
  └── OrderItemTriggerHandler.validateRemainQty()
        └── validateApprovingOrder()  // 校验 ZARE 审批状态
            └── SubmitOrderController
                  ├── GetCustomerlimitFROMSAP.submitToSAP()  // 信用额度校验
                  ├── zareQuantityEnough()  // ZARF 数量校验
                  ├── orderItem()  // ZMX1 数量校验
                  └── invoice()  // 发票数量校验
```

**寄售库存生命周期链路**：
```
ZARB 创建
  └── OrderTrigger (afterInsert)
        └── ConsignmentOrderQuantityReturn.addRemainQuantity()
              └── 增加 ZARB Remain_Quantity

ZARE 创建
  └── OrderItemTriggerHandler.splitZAREToZARB()
        └── 关联 ZARB，消耗 Remain_Quantity
            └── ConsignmentOrderQuantityReturn.subRemianQuantity()

ZARF 审批通过
  └── ConsignmentOrderQuantityReturn.addRemainQuantity()
        └── 返回 ZARB Remain_Quantity

ZARA 创建
  └── OrderSyncToSAP.sendToSAP('ZSD005_004')
        └── 关联 ZARF，更新 Issue_Quantity
```

---

## 七、批量任务清单

### 7.1 BatchOrderSyncToSap (批量订单同步)

**功能**：批量同步订单到 SAP

**执行方式**：
```apex
Database.executeBatch(new BatchOrderSyncToSap(...), 1)
```

**用途**：
- 避免 Future 方法的并发限制
- 处理大量订单同步场景

---

## 八、Utility 工具类 (644行)

**核心功能**：

1. **触发器控制**
   - `IgnoreAction()` - 设置忽略触发器执行
   - `isTriggerDisabled()` - 检查触发器是否禁用

2. **Picklist 值映射**
   - 销售组织映射
   - 付款条款映射
   - 其他业务字段映射

3. **邮件和通知服务**
   - 发送订单通知邮件
   - 发送审批通知

4. **HTML 表格生成**
   - 生成订单明细 HTML 表格
   - 生成邮件内容

5. **通用工具方法**
   - `getAllField()` - 获取对象所有字段
   - 日期时间处理
   - 字符串处理

---

## 九、关键业务规则汇总

### 9.1 订单校验规则

| 规则 | 校验时机 | 说明 |
|-----|---------|------|
| 信用额度校验 | 订单提交审批前 | 订单金额不能超过客户信用额度 |
| ZARF 数量校验 | 订单提交审批前 | ZARB 库存必须足够占用 |
| ZMX1 数量校验 | 订单提交审批前 | 墨西哥订单特殊数量校验 |
| ZARF 审批中校验 | ZARF 提交审批时 | 同客户_产品的 ZARE 必须全部审批通过 |
| 库存余量校验 | 订单明细保存时 | 库存 Remain_Quantity 必须足够 |

### 9.2 寄售库存规则

1. **先进先出 (FIFO)**
   - ZARE 关联 ZARB 时，按时间顺序优先消耗最早的库存

2. **数量追踪**
   - Remain_Quantity = Delivery_Quantity - Issue_Quantity
   - Issue_Quantity 包含 ZARE + ZARA 消耗

3. **状态联动**
   - ZARF 审批通过 → ZARB Remain_Quantity 增加
   - ZARE/ZARA 创建 → ZARB Remain_Quantity 减少
   - ZARF 关闭 → 关联的 ZARE/ZARA 关联到新的 ZARB

### 9.3 客户同步规则

1. **审批状态驱动**
   - 客户必须审批通过才能同步 SAP
   - 同步后获取 SAP 客户编码

2. **墨西哥特殊处理**
   - 特定字段需要保护，不同步 SAP

### 9.4 合同同步规则

1. **审批后同步**
   - 合同审批通过后同步 BPM 系统

2. **数据完整性**
   - 必须包含产品信息
   - 必须包含付款条款

---

## 十、接口日志机制

### 10.1 Interface_Log__c 对象

**记录字段**：
| 字段 | 说明 |
|-----|------|
| Name | 日志名称/接口名称 |
| Request_Message__c | 请求消息 |
| Response_Message__c | 响应消息 |
| Status__c | 状态 (Success/Failed) |
| Request_Time__c | 请求时间 |
| Response_Time__c | 响应时间 |
| Interface_Type__c | 接口类型 |
| Record_Id__c | 关联记录 ID |

### 10.2 日志记录时机

1. **SAP 接口调用**
   - 每次调用 `send_SAP_POST_Service` 都记录

2. **BPM 接口调用**
   - 合同同步 BPM 时记录

3. **错误捕获**
   - 所有接口异常都记录到日志

---

## 十一、数据流向图

### 11.1 订单数据流向

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐
│ 报价单   │────►│  销售订单   │────►│  订单明细   │
│ (Quote) │     │  (Order)    │     │(Order_Item)│
└─────────┘     └──────┬──────┘     └──────┬──────┘
                       │                   │
                       ▼                   ▼
              ┌─────────────────┐   ┌─────────────────┐
              │  OrderSyncToSAP │   │Delivery_Note__c │
              │   (SAP同步)      │   │    (交货单)      │
              └────────┬────────┘   └─────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │    SAP ERP     │
              │   (后端系统)     │
              └─────────────────┘
```

### 11.2 寄售库存数据流向

```
ZARB ──► Delivery_Note (Remain_Quantity 初始化)
              │
              ├──► ZARE ──► Issue_Quantity 增加
              │             Remain_Quantity 减少
              │
              ├──► ZARF ──► 冻结数量
              │
              └──► ZARA ──► Issue_Quantity 增加
                            Remain_Quantity 减少
```

---

## 十二、系统配置要点

### 12.1 自定义设置/元数据

| 配置项 | 说明 |
|-------|------|
| RecordType | 订单类型、客户类型等 |
| Picklist Values | 订单状态、销售组织、付款条款 |
| Custom Labels | 错误消息、多语言支持 |

### 12.2 审批流程配置

| 审批对象 | 审批步骤 | 审批后操作 |
|---------|---------|-----------|
| Account | 客户信息审批 | 同步 SAP |
| Order__c | 订单审批 | 同步 SAP |
| Contract | 合同审批 | 同步 BPM |
| Customer_Quota_Change__c | 信用额度变更 | 更新信用信息 |

---

## 十三、文件清单

### 13.1 核心业务类 (按行数排序)

| 文件名 | 行数 | 主要功能 |
|-------|------|---------|
| OrderItemTriggerHandler.cls | 1765 | 订单明细处理，库存校验 |
| AddOrderItemController.cls | 1645 | 订单明细添加 |
| OrderTriggerHandler.cls | 1186 | 订单生命周期管理 |
| SubmitOrderController.cls | 974 | 订单提交审批 |
| OrderSyncToSAP.cls | 693 | 订单同步 SAP |
| Utility.cls | 644 | 全局工具类 |
| AddQuoteDetailController.cls | ~400 | 报价明细添加 |
| DraftContractSyncToBPM.cls | 438 | 合同同步 BPM |
| AccountTriggerHandler.cls | 357 | 客户审批状态管理 |
| CustomerSalesInfoSyncToSAP.cls | 322 | 客户销售视图同步 |
| CustomerInfoSyncToSAP.cls | 290 | 客户主数据同步 |
| AccountTeamTriggerHandler.cls | - | 客户小组管理 |
| QuoteTriggerHandler.cls | 143 | 报价单处理 |
| ConsignmentOrderQuantityReturn.cls | 107 | 寄售数量管理 |
| InterfaceUtility.cls | 193 | SAP HTTP 调用 |
| BatchOrderSyncToSap.cls | 74 | 批量订单同步 |
| InvoiceTriggerHandler.cls | 26 | 发票触发器 |

### 13.2 触发器文件

| 触发器文件 | Handler 类 |
|-----------|------------|
| AccountTrigger.trigger | AccountTriggerHandler |
| AccountTeamTrigger.trigger | AccountTeamTriggerHandler |
| OrderTrigger.trigger | OrderTriggerHandler |
| OrderItemTrigger.trigger | OrderItemTriggerHandler |
| QuoteTrigger.trigger | QuoteTriggerHandler |
| ContractsTrigger.trigger | ContractsTriggerHandler |
| CampaignTrigger.trigger | CampaignTriggerHandler |
| InvoiceTrigger.trigger | InvoiceTriggerHandler |

---

## 十四、运维注意事项

### 14.1 常见问题排查

| 问题 | 可能原因 | 排查方法 |
|-----|---------|---------|
| 订单同步失败 | SAP 接口超时 | 检查 Interface_Log__c |
| 库存校验失败 | ZARB 库存不足 | 检查 Delivery_Note Remain_Quantity |
| 审批卡住 | 审批流程配置问题 | 检查 Approval Process |
| 邮件未发送 | 邮件配置问题 | 检查 Email 状态 |

### 14.2 性能优化建议

1. **批量处理**
   - 使用 Batch Apex 处理大批量数据
   - 避免在触发器中处理过多数据

2. **查询优化**
   - 使用 selective query
   - 避免全表扫描

3. **触发器控制**
   - 使用 Utility.IgnoreAction() 控制递归
   - 合理使用 after/before 触发器

### 14.3 监控指标

| 指标 | 说明 |
|-----|------|
| Interface_Log__c 失败率 | 接口调用成功率 |
| Order 审批时长 | 审批流程效率 |
| 库存校验失败次数 | 库存管理健康度 |
| SAP 同步延迟 | 数据一致性 |

---

## 十五、总结

本系统是一个典型的 **Salesforce + SAP ERP 双向集成** 的 CRM 项目，主要特点包括：

1. **订单类型丰富**：支持 10+ 种订单类型，覆盖标准销售、寄售、退货等多种业务场景
2. **寄售库存管理完整**：实现了 ZARB → ZARE → ZARF → ZARA 的完整寄售生命周期管理
3. **多国家/多币种支持**：支持中国、墨西哥、阿根廷等国家的业务需求
4. **双向集成**：Salesforce 与 SAP、BPM 系统实时数据同步
5. **完善的审批流**：客户、订单、合同、信用额度等多种审批流程

---

*文档生成时间：2026-04-16*
*项目名称：山东润丰 Salesforce CRM*
