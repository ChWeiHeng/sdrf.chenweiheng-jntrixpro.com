# 订单(Order)模块详细业务逻辑文档

## 目录

1. [模块概述](#第一章模块概述)
2. [记录类型(RecordType)](#第二章记录类型recordtype)
3. [订单类型(OrderType)](#第三章订单类型ordertype)
4. [关联对象关系图](#第四章关联对象关系图)
5. [销售组织与业务模型](#第五章销售组织与业务模型)
6. [核心业务流程](#第六章核心业务流程)
7. [关联子对象详细说明](#第七章关联子对象详细说明)
8. [特殊业务场景](#第八章特殊业务场景)
9. [审批与状态管理](#第九章审批与状态管理)
10. [SAP同步机制](#第十章sap同步机制)

---

## 第一章：模块概述

### 1.1 订单模块定位

订单(Order)是RBCRM系统的核心业务对象，贯穿从销售报价、订单创建、审批、库存分配、交货执行到开票结算的完整业务流程。

### 1.2 订单核心属性

| 属性 | 说明 |
|------|------|
| 对象名 | `Order__c` |
| 主要标识 | `Name`（订单编号） |
| SAP集成 | `SAP_Order_Code__c`（SAP订单号） |
| 状态管理 | `Status__c`（Draft/Approving/Approved/Rejected） |
| 变更状态 | `Change_Status__c`（Model B专用） |

### 1.3 订单生命周期

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          订单生命周期流程                                  │
└─────────────────────────────────────────────────────────────────────────┘

  创建订单 ──→ 填写订单信息 ──→ 提交审批 ──→ 审批通过 ──→ SAP同步 ──→ 执行交货 ──→ 开票结算
     │              │              │              │              │              │
   Draft          Draft        Approving      Approved      Synchronized     Closed
                                                                              │
                                                                              ↓
                                                                        订单完成/关闭
```

---

## 第二章：记录类型(RecordType)

系统定义了两个订单记录类型，分别适用于不同的业务场景：

### 2.1 Model B（标准销售订单）

| 属性 | 说明 |
|------|------|
| DeveloperName | `Model_B` |
| Label | `Model B` |
| 适用业务模型 | A0, A1, B0, B1, C0, C1 |
| 适用销售组织 | 1040-1104系列, 1050-2290系列 |
| 特点 | 支持订单变更(Change)、毛利计算、佣金计算 |

**Model B订单特点：**
- 支持订单变更（Change Order）流程
- 有独立的`Change_Status__c`状态
- 计算Guide Price和毛利
- 支持佣金百分比和佣金金额

### 2.2 Model C（简化订单/特殊订单）

| 属性 | 说明 |
|------|------|
| DeveloperName | `Model_C` |
| Label | `Model C` |
| 适用业务模型 | B0, C0, C1 |
| 适用销售组织 | 5070, 5130（寄售业务）及其他 |
| 特点 | 简化流程、支持寄售订单（ZAR系列） |

**Model C订单特点：**
- 寄售订单专用（ZARB/ZARA/ZARE/ZARF等）
- 不支持订单变更
- 支持库存老化（Stock Aging）管理
- 支持FIFO库存分配

---

## 第三章：订单类型(OrderType)

### 3.1 OrderType总览

系统支持**40+种**订单类型，按销售组织分组：

| 销售组织 | OrderType |
|---------|-----------|
| **5070/5130**（寄售/YPF） | ZAR1, ZARB, ZARA, ZARE, ZARF, ZAR2, ZAR3, ZAR4, ZAR5, ZAR7, ZARM, ZAR6, ZAR8, ZAR9, ZARD, ZARX, ZARY, ZARG, ZARH |
| **3010/3020**（墨西哥） | ZMX1, ZMX2, ZMX3, ZMX4, ZMX6, ZMX8 |
| **其他（1040-2380系列）** | ZCR, ZDR, ZFD, ZIRE, ZIRT, ZOR1-ZOR8, ZRE, ZRE1, ZREQ, ZSER |

---

### 3.2 5070/5130 寄售订单系列（重点）

这是YPF（阿根廷石油公司）寄售业务专用的订单类型体系。

#### 3.2.1 寄售业务概念

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          寄售业务模式                                     │
└─────────────────────────────────────────────────────────────────────────┘

  RBCRM（卖方）                    YPF（买方/寄售商）
       │                                  │
       │  1. ZARB：补货到YPF仓库              │
       ├─────────────────────────────────→│
       │                                   │
       │  2. YPF使用库存                    │
       │  （产生ZARE出库记录）               │
       │                                   │
       │  3. ZARF：冻结未用完的库存           │
       │                                   │
       │  4. ZARA：退货                    │
       │  ←────────────────────────────────┤
       │                                   │
       │  5. ZAR1：开票结算                │
       ├─────────────────────────────────→│
```

#### 3.2.2 各OrderType详细说明

| OrderType | 名称 | 说明 | 是否需要Order Reason |
|-----------|------|------|---------------------|
| **ZARB** | Consignment Replenishment（寄售补货） | YPF向RBCRM补货请求，库存从RBCRM转到YPF仓库 | 否 |
| **ZARE** | Consignment Issue（寄售出库） | YPF使用寄售库存的记录，消耗ZARB的库存 | 否 |
| **ZARF** | Consignment Freeze（寄售冻结） | 冻结ZARB中未使用完的库存（通常是ZARE审批前） | 是 |
| **ZARA** | Consignment Return（寄售退回） | 将未使用的寄售库存退回RBCRM | 是 |
| **ZAR1** | Consignment Billing（寄售开票） | 对已消耗的寄售库存开票结算 | 否 |
| **ZAR2** | Credit Memo（贷项通知单） | 5070/5130信用调整 | 是 |
| **ZAR3** | Debit Memo（借项通知单） | 5070/5130借项调整 | 是 |
| **ZAR4** | Consignment Transfer（寄售调拨） | 5070寄售调拨 | 否 |
| **ZAR5** | Consignment Destruction（寄售销毁） | 5070寄售库存销毁 | 是 |
| **ZAR7** | Special Return（特殊退货） | 5070特殊退货 | 是 |
| **ZARM** | Manual Consignment Return（手动寄售退回） | 5070手动寄售退回 | 是 |
| **ZAR6/ZAR8/ZAR9** | 5070专用类型 | 其他特殊用途 | 是 |
| **ZARD/ZARX/ZARY/ZARG/ZARH** | 5070专用类型 | 其他特殊用途 | 是 |

#### 3.2.3 ZAR系列核心业务流程

**ZARB → ZARA 退货流程：**

```
Step 1: ZARB订单创建和审批
┌─────────────────────────────────────────────────────────┐
│ 创建ZARB订单                                            │
│ - 客户：YPF Argentina                                   │
│ - 订单类型：ZARB                                        │
│ - 销售组织：5070                                       │
│ - 订单行：润滑油 Silver 5W-30 x 1000桶                  │
└─────────────────────────────────────────────────────────┘
                         ↓ 审批通过
Step 2: 生成交货单
┌─────────────────────────────────────────────────────────┐
│ Delivery_Note自动生成                                   │
│ - Delivery_Quantity: 1000桶                            │
│ - Remain_Quantity: 1000桶（初始等于全部数量）            │
│ - Stock_Aging_Countdown: 65天                          │
└─────────────────────────────────────────────────────────┘
                         ↓ YPF使用了700桶
Step 3: 库存消耗（ZARE出库）
┌─────────────────────────────────────────────────────────┐
│ 交货单状态更新                                          │
│ - Issue_Quantity: 700桶（已消耗）                       │
│ - Remain_Quantity: 300桶（剩余）                        │
└─────────────────────────────────────────────────────────┘
                         ↓ 库存老化倒计时
Step 4: 触发ZARA生成
┌─────────────────────────────────────────────────────────┐
│ 两种触发方式：                                           │
│ 1. 手动：点击"Create ZARA"按钮                          │
│ 2. 自动：定时任务BatchSendEmailToOrder                  │
│          当Stock_Aging_Countdown ≤ 0时                  │
└─────────────────────────────────────────────────────────┘
                         ↓
Step 5: ZARA订单生成（克隆ZARB）
┌─────────────────────────────────────────────────────────┐
│ 新建ZARA订单（不是改OrderType！）                       │
│ - Source_Order: 关联ZARB订单                           │
│ - Order_Reason: Z05（库存老化）                        │
│ - 订单行数量: 300桶（=Remain_Quantity）                 │
│ - 订单行关联交货单: DN-001（ZARB的交货单）              │
│ - Status: Draft                                        │
└─────────────────────────────────────────────────────────┘
                         ↓ 审批通过
Step 6: ZARA后续处理
┌─────────────────────────────────────────────────────────┐
│ 1. FIFO关联ZARB库存                                     │
│ 2. 通知物流取货或创建发票                               │
│ 3. 实际货物退回                                        │
└─────────────────────────────────────────────────────────┘
```

**ZARF冻结流程：**

```
ZARF订单用途：
┌─────────────────────────────────────────────────────────┐
│ ZARB补货1000桶                                          │
│ YPF用了600桶 → Remain_Quantity=400桶                    │
│                                                          │
│ 此时要创建ZARE（出库600桶）                              │
│ 但ZARE审批前，需要先冻结剩余的400桶                      │
│                                                          │
│ 创建ZARF订单（冻结400桶）                                │
│ 审批通过 → 更新ZARB交货单的Issue_Quantity               │
└─────────────────────────────────────────────────────────┘
```

---

### 3.3 墨西哥订单系列（ZMX）

适用于墨西哥销售组织3010/3020。

| OrderType | 名称 | 说明 |
|-----------|------|------|
| **ZMX1** | Normal Order（正常订单） | 标准销售订单 |
| **ZMX2** | Credit Note（贷项通知单） | 退货退款 |
| **ZMX3** | Debit Note（借项通知单） | 价格调整 |
| **ZMX4** | Exchange（换货） | 以旧换新 |
| **ZMX6** | Free Replacement（免费更换） | 质保更换 |
| **ZMX8** | Sample Order（样品订单） | 3010专用样品订单 |

**墨西哥订单特殊逻辑：**
- 逆向单据（ZMX2/ZMX3/ZMX4）会触发正常订单的毛利重计算
- 计算公式：`calculateZMX1Rate(orderId, false)`
- 特殊margin level验证

---

### 3.4 其他销售组织订单类型

适用于1040-2380系列销售组织：

| OrderType | 名称 | 说明 |
|-----------|------|------|
| **ZCR** | Credit Request（信用请求） | 信用申请 |
| **ZDR** | Debit Request（借项请求） | 借项申请 |
| **ZFD** | Free Delivery（免费发货） | 赠送/免费发货 |
| **ZIRE** | Invoice Rejection（发票拒绝） | 发票拒收 |
| **ZIRT** | Invoice Return（发票退货） | 发票退货 |
| **ZOR1-ZOR8** | Order Type 1-8（标准订单1-8） | 标准销售订单 |
| **ZRE** | Return（退货） | 普通退货 |
| **ZRE1** | Return Type 1（退货类型1） | 特殊退货 |
| **ZREQ** | Return Request（退货请求） | 退货申请 |
| **ZSER** | Service Order（服务订单） | 服务类订单 |

---

## 第四章：关联对象关系图

### 4.1 订单关联对象全景

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          订单核心关联对象                                 │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│    Account      │ ← 客户信息
│   （客户）       │
└────────┬────────┘
         │ 1:N
         ↓
┌─────────────────┐       ┌─────────────────┐
│   Order__c      │──────→│  Order_Item__c  │
│   （订单）       │  1:N  │   （订单行）     │
└────────┬────────┘       └────────┬────────┘
         │                        │
         │ 1:N                    │ 1:1
         ↓                        ↓
┌─────────────────┐       ┌─────────────────┐
│ Delivery_Note__c│       │   Invoice__c    │
│  （交货单）      │       │   （发票）      │
└────────┬────────┘       └─────────────────┘
         │
         │ 1:N
         ↓
┌─────────────────┐
│ Billing__c      │
│  （发货单/账单） │
└─────────────────┘

┌─────────────────┐
│    Quote__c     │ ← 报价单（可选来源）
│   （报价）       │
└─────────────────┘

┌─────────────────┐
│  Contracts__c   │ ← 合同（可选来源）
│   （合同）       │
└─────────────────┘
```

### 4.2 订单行(Order_Item)关联

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          订单行关联关系                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐       ┌─────────────────┐
│  Order_Item__c  │──────→│   Product__c    │
│   （订单行）     │  N:1  │    （产品）      │
└────────┬────────┘       └─────────────────┘
         │
         │ 1:1（可选）
         ↓
┌─────────────────┐
│ Delivery_Note__c│ ← 交货单（ZAR系列订单关联）
│  （交货单）      │
└────────┬────────┘
         │
         │ N:1（可选）
         ↓
┌─────────────────┐
│  Order_Item__c  │ ← Depend_On_Item（FIFO关联）
│  （ZARB订单行） │
└─────────────────┘
```

### 4.3 ZAR系列特殊关联

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ZAR系列订单特殊关联（FIFO）                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  ZARB订单       │
│ Order_type=ZARB │
└────────┬────────┘
         │
         │ 产生
         ↓
┌─────────────────┐
│ Delivery_Note   │  ← Remain_Quantity（剩余可退数量）
│ 交货单          │
└────────┬────────┘
         │ FIFO消耗
         │
         ↓
┌─────────────────┐
│ ZARE/ZARA订单   │
│ Order_type=ZARE │  ← Depend_On_Item__c 关联 ZARB的Order_Item
│ /ZARA           │  ← Delivery_Note__c 关联 ZARB的交货单
└─────────────────┘
         │
         │ 可能产生
         ↓
┌─────────────────┐
│ ZAR1发票        │
│ Order_type=ZAR1 │
└─────────────────┘
```

---

## 第五章：销售组织与业务模型

### 5.1 销售组织列表

| 销售组织代码 | 名称 | 主要业务类型 |
|------------|------|-------------|
| 3010 | 墨西哥销售组织 | ZMX系列订单 |
| 3020 | 墨西哥销售组织 | ZMX系列订单 |
| 5070 | YPF Argentina | ZAR系列寄售订单 |
| 5130 | YPF/Agroterrum | ZAR系列寄售订单 |
| 1040-1104 | 标准销售组织 | ZOR系列标准订单 |
| 1050-2290 | 亚太/其他 | ZCR/ZDR等特殊订单 |

### 5.2 Business Model（业务模型）

| Code | 名称 | 适用RecordType | 说明 |
|------|------|---------------|------|
| A0 | Agency Model A | Model_B | 代理模式A |
| A1 | Agency Model A | Model_B | 代理模式A |
| B0 | Buy & Sell | Model_B/Model_C | 买卖模式 |
| B1 | Buy & Sell | Model_B | 买卖模式 |
| C0 | Consignment | Model_B/Model_C | 寄售模式 |
| C1 | Consignment | Model_B/Model_C | 寄售模式 |

### 5.3 5070/5130寄售专属逻辑

5070和5130销售组织使用寄售模式（Model_C），有以下特殊处理：

**1. Stock Aging（库存老化）管理**
```apex
// ZARB订单自动设置65天库存老化期限
if(String.isBlank(order.Stock_Aging_Limit__c) && order.Order_type__c == 'ZARB'){
    order.Stock_Aging_Limit__c = '65';
}
```

**2. FIFO库存分配**
```apex
// 查询同客户、同产品的ZARB交货单，按最早发货日期排序
ORDER BY Delivery_Post_Date__c, CreatedDate
```

**3. 寄售订单特有校验**
- ZARB/ZARF/ZARE/ZARA订单审批通过时自动关联ZARB库存
- ZARA必须填写Order_Reason
- 自动生成的ZARA订单不可手动编辑

---

## 第六章：核心业务流程

### 6.1 标准订单流程（Model B）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Model B 标准订单流程                                   │
└─────────────────────────────────────────────────────────────────────────┘

  1. 创建订单
     └→ 选择RecordType: Model_B
     └→ 选择OrderType: ZOR1-ZOR8
     └→ 填写客户、产品、数量、价格
     
  2. 提交审批
     └→ 检查必填字段
     └→ 检查客户信用额度
     └→ 检查价格/毛利限制
     
  3. 审批流程
     └→ Approving → Approved/Rejected
     └→ 通知订单Owner及Manager
     
  4. SAP同步
     └→ 审批通过后自动同步
     └→ SAP返回订单号(SAP_Order_Code__c)
     
  5. 执行交货
     └→ 创建Delivery_Note
     └→ 过账(Delivery_Post_Status='C')
     
  6. 开票结算
     └→ 创建Invoice/Billing
     └→ 佣金计算与分配
```

### 6.2 ZAR系列寄售订单流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    5070/5130 寄售订单流程                                 │
└─────────────────────────────────────────────────────────────────────────┘

【ZARB补货流程】
  ZARB创建 → 审批通过 → 生成交货单 → YPF使用库存
  
【ZARE出库流程】  
  ZARE创建 → 关联ZARB交货单 → 审批通过 → FIFO消耗库存
  
【ZARF冻结流程】
  ZARF创建 → 关联ZARB交货单 → 审批通过 → 冻结剩余库存
  
【ZARA退货流程】
  手动/自动触发 → 克隆ZARB → 生成ZARA → 关联交货单
       ↓
  审批通过 → FIFO退回库存 → 通知物流/开票

【ZAR1开票流程】
  ZAR1创建 → 关联ZARA/ZARB → 审批通过 → SAP开票
```

### 6.3 订单变更流程（Model B）

Model B支持订单变更（Change Order）：

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Model B 订单变更流程                                   │
└─────────────────────────────────────────────────────────────────────────┘

  原订单(Approved) → 创建变更单 → 填写变更内容 → 变更审批 → 变更同步SAP
                        ↓
                   原订单状态不变
                        ↓
                   变更审批通过后
                        ↓
                   原订单同步更新
```

---

## 第七章：关联子对象详细说明

### 7.1 Order_Item__c（订单行）

**主要字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| Order__c | Lookup | 所属订单 |
| Commodity__c | Lookup | 产品 |
| Quantity__c | Number | 数量 |
| Price__c | Currency | 单价（含税） |
| Unit_Price__c | Currency | 单价（不含税） |
| Amount_per_item__c | Currency | 行金额 |
| Delivery_Date__c | Date | 交货日期 |
| Delivery_Quantity__c | Number | 已交货数量 |
| Undelivered_Quantity__c | Number | 未交货数量 |
| isClosed__c | Checkbox | 是否关闭 |
| Depend_On_Item__c | Lookup | 关联ZARB订单行（FIFO） |
| Delivery_Note__c | Lookup | 关联交货单 |

**ZAR系列特殊字段：**

| 字段 | 说明 |
|------|------|
| Depend_On_Item__c | FIFO关联：ZARE/ZARA订单行关联到ZARB的订单行 |
| Delivery_Note__c | FIFO关联：ZARE/ZARA订单行关联到ZARB的交货单 |
| Undelivered_Quantity_Apex__c | 未交货数量（计算字段） |
| ZARE_Order_Number__c | 关联的ZARE订单号 |

---

### 7.2 Delivery_Note__c（交货单）

**主要字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| Order__c | Lookup | 关联订单（ZARB） |
| Order_Item__c | Lookup | 关联订单行 |
| Delivery_Quantity__c | Number | 交货数量 |
| Issue_Quantity__c | Number | 已消耗数量（ZAR系列） |
| Remain_Quantity__c | Number | 剩余数量 |
| Delivery_Post_Date__c | Date | 过账日期 |
| Delivery_Post_Status__c | Picklist | 过账状态（C=已过账） |
| Stock_Aging_Countdown__c | Number | 库存老化倒计时 |
| Stock_Aging_Limit__c | Number | 库存老化期限 |

**ZAR系列核心逻辑：**

```
Remain_Quantity = Delivery_Quantity - Issue_Quantity

ZARE/ZARA审批通过时：
  Issue_Quantity += ZARE/ZARA数量
  
ZARF审批通过时：
  Issue_Quantity += ZARF数量
```

---

### 7.3 Invoice__c（发票）

**主要字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| Order__c | Lookup | 关联订单 |
| Invoice_Amount__c | Currency | 发票金额 |
| Invoice_Date__c | Date | 发票日期 |
| Invoice_Number__c | String | 发票编号 |
| Currency__c | Picklist | 币种 |
| Status__c | Picklist | 发票状态 |

---

### 7.4 Billing__c（发货单/账单）

**主要字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| Order__c | Lookup | 关联订单 |
| Order_Item__c | Lookup | 关联订单行 |
| Billing_Amount__c | Currency | 账单金额 |
| Billing_Date__c | Date | 账单日期 |

---

## 第八章：特殊业务场景

### 8.1 FIFO库存分配（先进先出）

**场景：** ZARE/ZARA订单需要消耗ZARB订单的库存时，采用FIFO原则。

**FIFO逻辑：**

```
假设：
  - 客户：YPF Argentina
  - 产品：润滑油 Silver 5W-30
  
ZARB交货单库存（按日期排序）：
  1. DN-A（1月1日）：200桶
  2. DN-B（2月1日）：300桶
  3. DN-C（3月1日）：100桶
  
ZARA订单需要退回250桶：

处理过程：
  1. 消耗DN-A全部200桶（最早入库）
  2. 再消耗DN-B的50桶
  3. DN-C暂不消耗
  
结果：
  ZARA Item1：关联DN-A，200桶
  ZARA Item2：关联DN-B，50桶
  克隆2个ZARA订单行
```

**代码位置：** `OrderItemTriggerHandler.splitZAREToZARB()`

---

### 8.2 库存老化（Stock Aging）

**场景：** 5070/5130的ZARB订单产生的寄售库存有保质期限制。

**处理流程：**

```
Stock_Aging倒计时：
  - 初始值：65天（Stock_Aging_Limit）
  - 每天定时任务 -1
  
预警通知：
  - countdown = 10天：发送第一封预警邮件
  - countdown = 5天：发送第二封预警邮件
  
自动处理：
  - countdown ≤ 0：自动生成ZARA订单
```

**定时任务：** `BatchSendEmailToOrder`

---

### 8.3 自动生成ZARA

**触发条件：**
1. 手动触发：点击"Create ZARA"按钮
2. 自动触发：`Stock_Aging_Countdown <= 0`

**处理逻辑（BatchSendEmailToOrder.generateZaraData）：**

```apex
// 1. 克隆ZARB订单为ZARA
Order__c zaraOrder = zarbOrder.clone(FALSE,TRUE,FALSE,FALSE);
zaraOrder.Order_type__c = 'ZARA';
zaraOrder.Source_Order__c = zarbOrder.Id;  // 关联源订单
zaraOrder.Order_Reason__c = 'Z05';  // 自动赋值退货原因
zaraOrder.Auto_issue_Consignment__c = TRUE;  // 标记为自动生成

// 2. 克隆订单行，关联ZARB的交货单
Order_Item__c zar1Item = zarbItem.clone(FALSE,TRUE,FALSE,FALSE);
zar1Item.Delivery_Note__c = noteId;  // 关联交货单
zar1Item.Quantity__c = note.Remain_Quantity__c;  // 数量=剩余数量

// 3. 更新交货单
note.Issue_Quantity__c = note.Delivery_Quantity__c;  // 全部标记已消耗
note.Auto_issue_Consignment__c = TRUE;
```

---

### 8.4 订单关闭（Close Order）

**关闭触发：**
1. YPF确认收到退货
2. 手动点击"Close Order"按钮
3. 定时任务自动关闭

**关闭处理（CloseOrderController）：**
- 更新订单`isClosed__c = TRUE`
- 检查所有订单行`Undelivered_Quantity__c`
- 如果全部为0，自动关闭订单

---

## 第九章：审批与状态管理

### 9.1 订单状态（Status）

| Status | 说明 | 可转换状态 |
|--------|------|-----------|
| Draft | 草稿 | Approving, Rejected |
| Approving | 审批中 | Approved, Rejected |
| Approved | 已审批 | （后续可同步SAP） |
| Rejected | 已拒绝 | Draft, Approving |

### 9.2 订单变更状态（Change_Status）

Model B订单支持变更，有独立的变更状态：

| Change_Status | 说明 | 可转换状态 |
|--------------|------|-----------|
| Draft | 草稿 | Approving |
| Approving | 变更审批中 | Approved, Reject |
| Approved | 变更已审批 | - |
| Reject | 变更已拒绝 | Draft |

### 9.3 审批触发逻辑

**审批前校验（OrderTriggerHandler）：**
```apex
// 1. 客户必须已同步SAP
if(acc.Sync_Status__c != 'Synchronized') {
    order.addError('Order Customer is not synchronized.');
}

// 2. 客户信用信息必须存在
if(cciMap.get(order.Customer__c) == null) {
    order.addError('No Customer Credit Info.');
}

// 3. 客户销售信息必须存在
if(csiMap.get(key) == null) {
    order.addError('No Sales Info.');
}

// 4. 账期验证
if(daysMap.get(order.Terms_Of_Payment__c) > 
   daysMap.get(csi.Terms_Of_Payment__c)) {
    order.addError('Payment term exceeds allowed days.');
}

// 5. 特定OrderType必须填写Order_Reason
if(order.Order_Reason__c == null && 
   (order.Order_type__c == 'ZAR2' || order.Order_type__c == 'ZARF' || 
    order.Order_type__c == 'ZMX2' || order.Order_type__c == 'ZARA')) {
    order.addError('Order Reason is required.');
}
```

---

## 第十章：SAP同步机制

### 10.0 双向数据同步概述

订单模块在SAP和CRM之间存在**双向数据同步**，这是理解订单业务逻辑的核心：

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     SAP ↔ CRM 双向数据同步                               │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐                              ┌─────────────────┐
    │      SAP        │                              │      CRM        │
    │   (ERP系统)     │                              │   (RBCRM)       │
    └────────┬────────┘                              └────────┬────────┘
             │                                                │
             │  ←──────────── 【SAP推送到CRM】 ────────────────  │
             │                                                │
             │    SAPOrderWebService     SAPDeliveryNoteWebService    │
             │    SAPBillingWebService    SAPCollectionWebService     │
             │                                                │
             │  ──────────── 【CRM同步到SAP】 ──────────────→  │
             │                                                │
             │    OrderSyncToSAP        (ZSD005_001/002/004)         │
             └────────────────────────────────────────────────┘
```

**核心原则：**
- SAP是数据的"源头"（主数据、价格、客户信息等）
- CRM是"执行层"（审批流程、库存分配、寄售管理等）
- 双方通过WebService接口双向同步

---

### 10.1 SAP → CRM 同步（被动接收）

SAP主动推送数据到CRM，CRM的WebService接口**被动接收并处理**。

#### 10.1.1 SAPOrderWebService - SAP订单同步到CRM

**接口信息：**
- URL: `/services/apexrest/receiveDataFromExternal/requestCode:SAP001`
- 触发时机: SAP创建订单后，推送到CRM
- 处理逻辑: Upsert订单和订单行

**同步场景：**

```
┌─────────────────────────────────────────────────────────────────────────┐
│              SAP → CRM：SAP订单同步（SAPOrderWebService）                │
└─────────────────────────────────────────────────────────────────────────┘

场景：SAP中创建了订单（如ZOR1标准订单），同步到CRM

【SAP端数据】
┌─────────────────────────────────────────────────────────┐
│ SAP订单数据                                              │
│ - VBELN: 0000046659 (SAP订单号)                         │
│ - BSTNK: O-2411-003294 (客户参考号)                      │
│ - KUNNR: 0001003223 (客户编码)                           │
│ - VKORG: 3010 (销售组织)                                 │
│ - AUART: ZOR1 (订单类型)                                 │
│ - ITEMS: [                                              │
│     {                                                    │
│       POSNR: 10,                                        │
│       MATNR: 100001,                                     │
│       KWMENG: 100,                                       │
│       ...                                                │
│     }                                                    │
│   ]                                                      │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ SAP调用CRM接口
                      ↓ POST /SAPOrderWebService
                      ↓
【CRM端处理结果】
┌─────────────────────────────────────────────────────────┐
│ Order__c (Upsert by SAP_Order_Code__c)                  │
│ - SAP_Order__c: true ← 标记为SAP来源                     │
│ - SAP_Order_Code__c: 0000046659                          │
│ - Status__c: 'Approved' ← SAP直接审批通过                 │
│ - Sync_Status__c: 'Synchronized'                         │
│                                                          │
│ Order_Item__c (Upsert by External_Id__c = VBELN+POSNR)  │
│ - External_Id__c: 0000046659_10                          │
│ - Quantity__c: 100                                       │
│ - ...                                                    │
└─────────────────────────────────────────────────────────┘
```

**代码逻辑（SAPOrderWebService.cls 第172-215行）：**

```apex
// 核心Upsert逻辑
// 订单用SAP_Order_Code__c作为External Key
Database.upsert(orderMap.values(), Order__c.fields.SAP_Order_Code__c, false);

// 订单行用 External_Id__c = SAP订单号+行号 作为External Key
oi.External_Id__c = reqOrder.VBELN + '_' + oir.POSNR;
Database.upsert(orderItemFinal.values(), Order_Item__c.fields.External_Id__c, false);
```

**特点：**
1. SAP推送过来的订单，**Status直接为Approved**，不需要CRM审批
2. SAP_Order__c = true 标记为SAP来源
3. 如果SAP订单号已存在，则更新；不存在则创建

---

#### 10.1.2 SAPDeliveryNoteWebService - SAP交货单同步到CRM

**接口信息：**
- URL: `/services/apexrest/receiveDataFromExternal/requestCode:SAP003`
- 触发时机: SAP创建交货单（发货过账）后，同步到CRM

**同步场景：**

```
┌─────────────────────────────────────────────────────────────────────────┐
│        SAP → CRM：SAP交货单同步（SAPDeliveryNoteWebService）            │
└─────────────────────────────────────────────────────────────────────────┘

场景：ZOR1订单审批后，SAP创建交货单，同步到CRM

【SAP端数据】
┌─────────────────────────────────────────────────────────┐
│ SAP交货单数据                                            │
│ - VBELN: 0080001234 (交货单号)                          │
│ - LFART: NL (交货类型)                                  │
│ - WBSTK: C (发货过账状态)                               │
│ - wadat_ist: 2026-01-15 (发货过账日期)                  │
│ - ITEMS: [                                              │
│     {                                                    │
│       POSNR: 10,                                        │
│       VGBEL: 0000046659, ← 参考订单号                    │
│       VGPOS: 10,       ← 参考订单行号                    │
│       ZQCOV: 100,      ← 交货数量                        │
│       ...                                                │
│     }                                                    │
│   ]                                                      │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ SAP调用CRM接口
                      ↓ POST /SAPDeliveryNoteWebService
                      ↓
【CRM端处理结果】
┌─────────────────────────────────────────────────────────┐
│ Delivery_Note__c (Upsert by External_Id__c)             │
│ - Delivery_Note_Num__c: 0080001234                      │
│ - Order__c: [关联到CRM订单]                              │
│ - Order_Item__c: [关联到CRM订单行]                       │
│ - Delivery_Quantity__c: 100                             │
│ - Delivery_Post_Status__c: 'C' (已过账)                  │
│ - Delivery_Post_Date__c: 2026-01-15                     │
│                                                          │
│ DeliveryNumber__c (交货单号主表)                         │
│ - External_Id__c: 0080001234                            │
└─────────────────────────────────────────────────────────┘
```

**关键字段映射：**
- `VGBEL+VGPOS` → `External_Id__c` (用于关联订单行)
- `VGBEL` → Order__c (通过SAP_Order_Code__c查找)
- `WBSTK` → `Delivery_Post_Status__c` (发货过账状态)

---

#### 10.1.3 SAPBillingWebService - SAP开票信息同步到CRM

**接口信息：**
- URL: `/services/apexrest/receiveDataFromExternal/requestCode:SAP003`
- 触发时机: SAP开票后，同步到CRM

**同步场景：**

```
┌─────────────────────────────────────────────────────────────────────────┐
│          SAP → CRM：SAP开票信息同步（SAPBillingWebService）             │
└─────────────────────────────────────────────────────────────────────────┘

场景：交货完成后，SAP创建发票，同步到CRM

【SAP端数据】
┌─────────────────────────────────────────────────────────┐
│ SAP发票数据                                              │
│ - VBELN: 9000001234 (发票号)                            │
│ - FKART: F2 (发票类型)                                  │
│ - ERDAT: 2026-01-20 (开票日期)                          │
│ - ITEMS: [                                              │
│     {                                                    │
│       POSNR: 10,                                        │
│       AUBEL: 0000046659, ← 参考订单号                    │
│       AUPOS: 10,       ← 参考订单行号                    │
│       VGBEL: 0080001234, ← 参考交货单                    │
│       VGPOS: 10,       ← 参考交货单行号                  │
│       FKIMG: 100,      ← 发票数量                        │
│       NETWR: 10000.00 ← 净额                            │
│     }                                                    │
│   ]                                                      │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ SAP调用CRM接口
                      ↓ POST /SAPBillingWebService
                      ↓
【CRM端处理结果】
┌─────────────────────────────────────────────────────────┐
│ Invoice__c (发票主表)                                    │
│ - External_Id__c: 9000001234                             │
│ - Order__c: [关联到CRM订单]                              │
│ - Invoice_Status__c: 'C' (已过账)                       │
│ - Invoice_Date__c: 2026-01-20                           │
│                                                          │
│ Billing__c (发票行)                                      │
│ - External_Id__c: 900000123410 (发票号+行号)            │
│ - Order__c: [关联到CRM订单]                              │
│ - Order_Item__c: [关联到CRM订单行]                       │
│ - Delivery_Note__c: [关联到交货单]                       │
│ - Invoice_Quantity__c: 100                               │
└─────────────────────────────────────────────────────────┘
```

**特殊处理：**
- 冲销发票(SFAKN不为空) → Billing_Status__c = 'E' (取消)
- 关联原发票 → Reverse_Billing__c = 原发票Id

---

#### 10.1.4 SAP → CRM 同步总结

| 接口 | 同步方向 | 触发时机 | 创建对象 | External Key |
|------|---------|---------|---------|-------------|
| SAPOrderWebService | SAP→CRM | SAP创建订单 | Order__c, Order_Item__c | SAP_Order_Code__c |
| SAPDeliveryNoteWebService | SAP→CRM | SAP创建交货单 | Delivery_Note__c, DeliveryNumber__c | External_Id__c |
| SAPBillingWebService | SAP→CRM | SAP开票 | Invoice__c, Billing__c | External_Id__c |
| SAPCollectionWebService | SAP→CRM | SAP回款 | Collection__c | - |
| SAPReceivableWebService | SAP→CRM | SAP应收账款更新 | Account_Receivable__c | - |

**SAP→CRM同步的特点：**
1. CRM是被动接收，不需要额外操作
2. 同步后对象标记 `SAP_Order__c = true` 或类似标识
3. 订单状态直接为最终状态（Approved），无需CRM审批
4. 如果数据已存在则更新，不存在则创建（Upsert）

---

### 10.2 CRM → SAP 同步（主动推送）

CRM中创建的订单需要同步到SAP进行实际业务处理。

#### 10.2.1 同步触发时机

| 触发条件 | 同步类型 | OPERATION_TYPE | 说明 |
|---------|---------|---------------|------|
| 订单审批通过后 | Create (I) | ZSD005_001 | CRM创建订单后首次同步 |
| 订单信息变更 | Update (U) | ZSD005_002 | 修改订单后同步更新 |
| 订单关闭 | Update (U) | ZSD005_002 | 带关闭标识 |
| 订单重新打开 | Update (U) | ZSD005_002 | 带释放暂停标识 |
| ZARA自动生成 | Create (I) | ZSD005_004 | YPF寄售自动创建ZARA |

#### 10.2.2 OrderSyncToSAP - CRM订单同步到SAP

**接口端点：** `CreateOrder`

**同步流程：**

```
┌─────────────────────────────────────────────────────────────────────────┐
│              CRM → SAP：CRM订单同步（OrderSyncToSAP）                   │
└─────────────────────────────────────────────────────────────────────────┘

【场景1：CRM创建ZOR1订单后同步】

Step 1: 用户在CRM创建订单
┌─────────────────────────────────────────────────────────┐
│ Order__c (CRM创建)                                      │
│ - Name: O-2601-001234                                   │
│ - Order_type__c: ZOR1                                    │
│ - Status__c: Draft                                      │
│ - Customer__c: [客户]                                    │
│ - Sales_Org__c: 3010                                    │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ 用户提交审批
                      ↓
Step 2: 审批通过
┌─────────────────────────────────────────────────────────┐
│ Order__c (审批通过)                                      │
│ - Status__c: Approved                                   │
│ - 触发OrderTrigger.afterUpdate                          │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ 调用 OrderSyncToSAP.submitToSAPFu
                      ↓
Step 3: 同步到SAP
┌─────────────────────────────────────────────────────────┐
│ SAP请求 (ZSD005_001 - 新增订单)                          │
│ - OPERATION_TYPE: 'ZSD005_001'                           │
│ - AUART: 'ZOR1'                                         │
│ - KUNNR: '0001003223'                                   │
│ - VKORG: '3010'                                         │
│ - ITEMS: [...]                                          │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ SAP处理
                      ↓
Step 4: SAP返回结果
┌─────────────────────────────────────────────────────────┐
│ SAP返回数据                                              │
│ - VBELN: 0000047000 (SAP订单号)                         │
│ - returnstatus: 'S'                                     │
│ - items: [{posnr: 10, netwr: 1000.00}]                  │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ CRM更新订单
                      ↓
Step 5: 更新CRM订单
┌─────────────────────────────────────────────────────────┐
│ Order__c (同步完成)                                      │
│ - SAP_Order_Code__c: 0000047000                         │
│ - Sync_Status__c: 'Synchronized'                        │
│                                                          │
│ Order_Item__c (同步完成)                                 │
│ - External_Id__c: 0000047000_10                        │
│ - SAP_Total_Net__c: 1000.00                             │
└─────────────────────────────────────────────────────────┘
```

**代码核心逻辑（OrderSyncToSAP.cls）：**

```apex
// 第98-108行：判断操作类型
if (changeType == 'I') {  // 新增
    roi.OPERATION_TYPE = 'ZSD005_001';
}
if (changeType == 'U') {  // 变更
    roi.OPERATION_TYPE = 'ZSD005_002';
}
// ZARA自动生成特殊处理
if(order.Order_type__c == 'ZARA' && order.Auto_Issue_Consignment__c){
    roi.OPERATION_TYPE = 'ZSD005_004';
}

// 第118-119行：SAP订单号处理
if (changeType=='I' && orderList[0].SAP_Order_Code__c!=null) {
    roi.VBELN = orderList[0].SAP_Order_Code__c;  // 如果已有SAP订单号则更新
}

// 第366-368行：更新CRM订单的SAP订单号
upOrder.SAP_Order_Code__c = syncReturnData.resultinfo[0].VBELN;
if (syncReturnData.resultinfo[0].VBELN2 != null) {
    upOrder.SAP_Order_Code2__c = syncReturnData.resultinfo[0].VBELN2;  // 寄售订单号
}
```

---

#### 10.2.3 ZAR系列特殊同步逻辑

**ZARB/ZARE/ZARF订单同步：**

```
┌─────────────────────────────────────────────────────────────────────────┐
│           CRM → SAP：ZAR系列订单同步（特殊处理）                         │
└─────────────────────────────────────────────────────────────────────────┘

【ZARB订单同步】
┌─────────────────────────────────────────────────────────┐
│ 1. CRM审批通过 → 触发同步                              │
│ 2. OPERATION_TYPE = 'ZSD005_001'                        │
│ 3. SAP创建ZARB订单                                      │
│ 4. 返回 SAP_Order_Code__c (ZARB主订单号)               │
│ 5. 返回 SAP_Order_Code2__c (ZAR相关订单号)             │
└─────────────────────────────────────────────────────────┘
                      ↓
                      ↓ SAP创建交货单后
                      ↓
【SAPDeliveryNoteWebService回调】
┌─────────────────────────────────────────────────────────┐
│ 1. SAP推送交货单到CRM                                   │
│ 2. Delivery_Note__c关联ZARB订单                         │
│ 3. Stock_Aging_Countdown开始倒计时                      │
└─────────────────────────────────────────────────────────┘

【ZARA订单同步（自动生成）】
┌─────────────────────────────────────────────────────────┐
│ 1. Stock_Aging_Countdown ≤ 0                           │
│ 2. CRM克隆ZARB为ZARA                                    │
│ 3. ZARA.Order_type__c = 'ZARA'                        │
│ 4. ZARA.Source_Order__c = ZARB.Id                      │
│ 5. 审批通过 → 同步SAP                                   │
│ 6. OPERATION_TYPE = 'ZSD005_004'                       │
│ 7. 额外参数：                                          │
│    - WADAT_IST: 发货过账日期                            │
│    - VBELN_RE: ZARA的SAP订单号（填空）                  │
│    - VBELN_ZARB: ZARB的SAP订单号                       │
└─────────────────────────────────────────────────────────┘
```

**代码核心逻辑（OrderSyncToSAP.cls 第190-212行）：**

```apex
// ZARA自动生成的特殊处理
if(order.Order_type__c == 'ZARA' && order.Auto_Issue_Consignment__c 
   && order.Sync_Status__c != 'Synchronization error'){
    // 设置发货过账日期
    Date d = order.DN_Post_Date__c;
    roi.WADAT_IST = year + month + day;
    // ZARA的SAP订单号置空，让SAP新建
    roi.VBELN = '';
    // ZARB的SAP订单号（关键！）
    roi.VBELN_ZARB = order.Source_Order__r.SAP_Order_Code__c;
    isYPF = true;
}

// 订单行也需要特殊处理
if (order.Order_type__c == 'ZARA' || order.Order_type__c == 'ZARF' 
    || order.Order_type__c == 'ZARE') {
    // 传递批次信息
    oir.CHARG = oi.Delivery_Note__r.Batch__c;
    // ZARA需要关联ZARB的行号
    oir.POSNR_ZARB = oi.Depend_On_Item__r.SAP_Item_Num__c;
}
```

---

### 10.3 完整业务场景对比

#### 10.3.1 场景对比总览

| 场景 | 订单来源 | 创建地点 | 审批 | SAP同步方向 | SAP返回 |
|------|---------|---------|------|------------|-------|
| **场景A** | SAP业务员在SAP创建 | SAP | SAP审批 | SAP→CRM | Status=Approved |
| **场景B** | CRM用户在CRM创建 | CRM | CRM审批 | CRM→SAP | SAP返回订单号 |
| **场景C** | YPF在SAP下ZARB | SAP | SAP审批 | SAP→CRM | 创建交货单，Start Aging |
| **场景D** | ZARB Aging到期 | CRM | CRM审批 | CRM→SAP | ZARA同步 |
| **场景E** | 墨西哥ZMX1订单 | CRM | CRM审批 | CRM→SAP | 标准同步 |

---

#### 10.3.2 场景A：SAP业务员创建订单（最常见）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    场景A：SAP创建 → 同步到CRM                           │
└─────────────────────────────────────────────────────────────────────────┘

1. SAP业务员在SAP系统创建订单（如ZOR1标准订单）
          ↓
2. SAP审批通过
          ↓
3. SAP调用 SAPOrderWebService 接口
          ↓
4. CRM Upsert订单，Status='Approved'，SAP_Order__c=true
          ↓
5. SAP创建交货单
          ↓
6. SAP调用 SAPDeliveryNoteWebService 接口
          ↓
7. CRM Upsert交货单
          ↓
8. SAP开票
          ↓
9. SAP调用 SAPBillingWebService 接口
          ↓
10. CRM Upsert发票和账单

【特点】
- 订单完全由SAP控制
- CRM只做数据同步和展示
- 不需要CRM审批
```

---

#### 10.3.3 场景B：CRM用户创建订单（标准流程）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    场景B：CRM创建 → 同步到SAP                           │
└─────────────────────────────────────────────────────────────────────────┘

1. CRM用户在RBCRM创建订单（如ZOR1标准订单）
   - Status = 'Draft'
   - SAP_Order__c = false
          ↓
2. 用户点击"Submit for Approval"
          ↓
3. CRM审批流程通过
   - Status = 'Approved'
          ↓
4. 触发器调用 OrderSyncToSAP.submitToSAPFu
   - OPERATION_TYPE = 'ZSD005_001'
          ↓
5. SAP创建订单，返回SAP_Order_Code__c
          ↓
6. CRM更新订单
   - SAP_Order_Code__c = '0000047000'
   - Sync_Status__c = 'Synchronized'
          ↓
7. 后续SAP交货、开票流程同场景A

【特点】
- CRM是主控方
- SAP是执行方
- 需要CRM审批后才能同步
```

---

#### 10.3.4 场景C：YPF寄售补货（ZARB）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    场景C：YPF ZARB寄售补货流程                          │
└─────────────────────────────────────────────────────────────────────────┘

【阶段1：ZARB订单】
1. YPF业务员在SAP创建ZARB订单
          ↓
2. SAP审批 → SAPOrderWebService同步到CRM
   - CRM订单: Order_type='ZARB', SAP_Order__c=true
          ↓
3. SAP创建ZARB交货单
          ↓
4. SAPDeliveryNoteWebService同步到CRM
   - CRM交货单: Stock_Aging_Countdown=65天
          ↓
5. YPF使用寄售库存（产生ZARE出库记录）
   - 更新交货单的Issue_Quantity
   - Remain_Quantity减少
          ↓

【阶段2：库存老化到期 → 自动生成ZARA】
6. Stock_Aging_Countdown ≤ 0
          ↓
7. BatchSendEmailToOrder.generateZaraData()
   - 克隆ZARB为ZARA
   - Source_Order = ZARB.Id
   - Order_Reason = 'Z05'
   - Auto_issue_Consignment = true
          ↓
8. CRM审批ZARA（自动或手动）
          ↓
9. OrderSyncToSAP.submitToSAPFu
   - OPERATION_TYPE = 'ZSD005_004' (自动ZARA)
   - VBELN_ZARB = ZARB的SAP订单号
          ↓
10. SAP创建ZARA订单
    - 自动关联ZARB
    - 消耗ZARB的寄售库存
          ↓

【阶段3：ZAR1开票】
11. ZARA审批通过后
    - 可手动/自动创建ZAR1
          ↓
12. ZAR1审批 → 同步SAP
    - SAP开票
    - SAPBillingWebService同步到CRM
```

---

#### 10.3.5 场景D：手动触发ZARA（Create ZARA按钮）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 场景D：手动触发ZARA（Create ZARA按钮）                   │
└─────────────────────────────────────────────────────────────────────────┘

1. 用户在ZARB订单详情页
   - 点击 "Create ZARA" QuickAction
          ↓
2. 弹出确认Flow（manualGenerateZARA.flow）
   - 显示ZARB订单信息
   - 显示可退数量（Remain_Quantity）
          ↓
3. 用户确认
          ↓
4. ManualGenerateZARAController.execute()
   - 调用 BatchSendEmailToOrder.generateZaraData()
   - 只处理当前这一个ZARB订单
          ↓
5. 生成ZARA订单
   - Source_Order = 当前ZARB.Id
   - Order_Reason = 用户选择/Z05
   - Status = 'Draft'
          ↓
6. ZARA订单出现在系统
   - 用户提交审批
   - 后续流程同场景C的步骤7-12
```

---

### 10.4 SAP同步相关字段

#### 10.4.1 订单同步关键字段

| CRM字段 | SAP字段 | 说明 |
|--------|--------|------|
| SAP_Order__c | - | 标记订单来源（true=SAP创建） |
| SAP_Order_Code__c | VBELN | SAP订单号 |
| SAP_Order_Code2__c | VBELN2 | SAP寄售订单号 |
| Sync_Status__c | - | 同步状态 |
| Sync_Failure_Reasons__c | - | 同步失败原因 |
| Source_Order__c | - | 关联源订单（ZARA→ZARB） |
| Auto_issue_Consignment__c | - | 自动寄售标识 |

#### 10.4.2 订单行同步关键字段

| CRM字段 | SAP字段 | 说明 |
|--------|--------|------|
| External_Id__c | - | VBELN+POSNR（用于Upsert） |
| External_Id2__c | - | VBELN2+POSNR（寄售订单） |
| Depend_On_Item__c | - | FIFO关联（ZARA关联ZARB行） |
| Delivery_Note__c | - | 关联交货单 |

#### 10.4.3 交货单同步关键字段

| CRM字段 | SAP字段 | 说明 |
|--------|--------|------|
| External_Id__c | - | VBELN+POSNR |
| Reference_Order__c | VGBEL | 参考订单号 |
| Reference_Order_Item__c | VGPOS | 参考订单行号 |
| Stock_Aging_Countdown__c | - | 库存老化倒计时 |
| Issue_Quantity__c | - | 已消耗数量 |
| Remain_Quantity__c | - | 剩余数量 |

---

## 附录A：关键代码文件

| 文件 | 说明 |
|------|------|
| `OrderTriggerHandler.cls` | 订单触发器 |
| `OrderItemTriggerHandler.cls` | 订单行触发器 |
| `OrderSyncToSAP.cls` | SAP同步 |
| `BatchSendEmailToOrder.cls` | ZARA自动生成 |
| `ManualGenerateZARAController.cls` | ZARA手动生成 |
| `ConsignmentOrderQuantityReturn.cls` | 寄售数量回写 |
| `SubmitOrderController.cls` | 订单提交 |
| `CloneOrderController.cls` | 订单克隆 |
| `CloseOrderController.cls` | 订单关闭 |

## 附录B：关键字段映射

| CRM字段 | SAP字段 | 说明 |
|--------|--------|------|
| Order_type__c | AUART | 订单类型 |
| SAP_Order_Code__c | VBELN | SAP订单号 |
| Customer__r.MDG_Customer_Code__c | KUNNR | 客户编码 |
| Sales_Org__c | VKORG | 销售组织 |
| Distr_Channel__c | VTWEG | 分销渠道 |
| Terms_Of_Payment__c | ZTERM | 付款条件 |

---

*文档生成时间：2026-04-18*
*最后更新：添加ZAR系列完整业务流程说明*
