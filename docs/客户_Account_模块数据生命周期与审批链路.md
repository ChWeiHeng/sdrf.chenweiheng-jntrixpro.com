# 客户模块数据生命周期与审批链路

> 本文档详细说明客户相关数据的创建、审批、修改、同步的完整链路

---

## 一、数据流转总览图

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              客户数据流转总图                                     │
└─────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   1.客户主数据  │
    │   Account    │
    └──────┬───────┘
           │
           │ 创建
           ▼
    ┌──────────────┐      审批通过       ┌──────────────┐       同步        ┌──────────┐
    │   Draft      │ ─────────────────▶ │   Approved   │ ────────────────▶ │   SAP    │
    │   (草稿)     │                    │   (已批准)   │                  │  MDG系统  │
    └──────────────┘                    └──────────────┘                  └──────────┘
                                              │                                │
                                              │ 获得MDG客户编码                  │ 返回客户编码
                                              ▼                                │
                                    ┌──────────────────┐                       │
                                    │ MDG_Customer_Code__c                    │
                                    └──────────────────┘                       │
                                              │                                │
                                              │◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀
                                              │
           ┌─────────────────────────────────┼─────────────────────────────────┐
           │                                 │                                 │
           ▼                                 ▼                                 ▼
    ┌──────────────┐               ┌──────────────┐                  ┌──────────────┐
    │  2.销售视图   │               │  3.信用额度  │                  │  4.客户信息   │
    │ Sales_Info   │               │ Credit_Info  │                  │   Update    │
    └──────┬───────┘               └──────┬───────┘                  └──────┬───────┘
           │                               │                                 │
           │ 创建                          │ 创建/修改                        │ 创建
           ▼                               ▼                                 ▼
    ┌──────────────┐               ┌──────────────┐                  ┌──────────────┐
    │   Draft      │               │  额度变更申请 │                  │   变更申请   │
    │   (草稿)     │               │ Quota_Change │                  │Customer_Update
    └──────┬───────┘               └──────┬───────┘                  └──────┬───────┘
           │                              │                                 │
           │ 审批通过                      │ 审批通过                         │ 审批通过
           ▼                              ▼                                 ▼
    ┌──────────────┐               ┌──────────────┐                  ┌──────────────┐
    │   Approved   │               │   Approved   │                  │   Approved   │
    │   (已批准)   │               │   (已批准)   │                  │   (已批准)   │
    └──────┬───────┘               └──────┬───────┘                  └──────┬───────┘
           │                              │                                 │
           │ 同步                         │ 同步                             │ 同步
           ▼                              ▼                                 ▼
    ┌──────────────┐               ┌──────────────┐                  ┌──────────────┐
    │   → SAP      │               │   → SAP      │                  │   → SAP      │
    │ 同步销售信息  │               │ 同步信用额度  │                  │ 同步客户信息   │
    └──────────────┘               └──────────────┘                  └──────────────┘
           │
           │ 自动生成
           ▼
    ┌──────────────┐
    │ 5.税务类别     │
    │Tax_Category  │
    │ (自动生成)    │
    └──────────────┘


    ═══════════════════════════════════════════════════════════════════════════════
                                    审批变更流程
    ═══════════════════════════════════════════════════════════════════════════════

    ┌──────────────────┐
    │  6.销售视图变更申请  │
    │Sales_Info_Change  │
    │    _Application   │
    └────────┬─────────┘
             │
             │ 创建
             ▼
    ┌──────────────────┐
    │   Pending         │◀──────── 用户填写需要变更的字段
    │   (待审批)        │
    └────────┬─────────┘
             │
             │ 审批通过
             ▼
    ┌──────────────────┐      写入到       ┌──────────────┐
    │   Approved       │ ──────────────▶ │  销售视图     │
    │   (已批准)        │                 │ Sales_Info   │
    └──────────────────┘                 └──────────────┘
                                                 │
                                                 │ 如果有变更
                                                 ▼
                                          ┌──────────────┐
                                          │  再次同步SAP  │
                                          └──────────────┘
```

---

## 二、各数据生命周期详解

### 1. 客户主数据 (Account)

#### 创建流程
```
用户操作                    系统行为
─────────────────────────────────────────────────────────
1. 创建客户                  → 生成客户记录 (状态=Draft)
2. 填写客户信息              → 关联创建:
   - Account_Team__c (客户小组)
   - Customer_Tax_Number_Category__c (税号类别)
3. 提交审批                  → 状态变为: Approving
4. 审批通过                  → 状态变为: Approved
                               同时触发SAP同步
5. SAP返回                   → 获得 MDG_Customer_Code__c
```

#### 修改流程
```
前置条件: Account状态 = Approved

修改类型          需要的操作                    产生的新数据
─────────────────────────────────────────────────────────────────
普通字段修改       直接修改                      Customer_Update__c (变更申请)
关键字段修改       通过Customer_Update申请审批    审批通过后更新Account
```

#### 关键触发逻辑 (AccountTriggerHandler)

| 行号 | 触发条件 | 行为 |
|-----|---------|------|
| 62-64 | Account状态变为Approving | 检查是否所有销售视图都已提交 |
| 67-74 | Account已Approved | 锁定FieldSet中的关键字段不可直接修改 |
| 105-111 | Account状态变为Approved | 同步客户信息到SAP |
| 113-125 | Account已Approved且字段变更 | 同步变更到SAP |
| 128-141 | Account状态变更 | 同步变更所有关联的销售视图状态 |

---

### 2. 销售视图 (Customer_Sales_Info)

#### 创建流程
```
用户操作                    系统行为
─────────────────────────────────────────────────────────
1. 创建销售视图              → 生成记录 (状态=Draft)
2. 填写销售信息              → 自动填充:
   - External_ID__c = Customer + Sales_Org + Distr_Channel
   - Reconciliation_Account__c (根据工厂+账户评估组自动算)
3. 提交审批                  → 状态变为: Approving
4. 审批通过                  → 状态变为: Approved
                               自动生成Customer_Tax_Category__c
                               同步到SAP
```

#### 创建后自动生成的数据
```
Customer_Sales_Info创建/国家变更
                │
                ▼
    ┌───────────────────────────┐
    │  Customer_Tax_Category__c │
    │  (税务类别)                 │
    └───────────────────────────┘
    
    生成规则:
    - 根据 Country_Code__c 查找 Tax_Category_Master_Data__c
    - 为该销售视图创建对应的所有税务类别记录
```

#### 关键触发逻辑 (CustomerSalesInfoTriggerHandler)

| 行号 | 触发条件 | 行为 |
|-----|---------|------|
| 13-50 | After Insert/Update且国家变更 | 删除旧税务类别，生成新税务类别 |
| 52-65 | After Insert | 判断客户是否为YPF客户 |
| 69-118 | Before Insert/Update | 自动计算统驭科目 + 校验Account状态 |
| 120-170 | After Update | 审批通过后同步SAP + 发送通知 |
| 174-178 | After Insert | 共享数据到客户小组 |
| 180-187 | Before Update且工厂变更 | 重新分配数据共享权限 |

#### 保存校验 (Before Insert/Update)
```apex
// Account状态必须为 Draft 或 Approved 才能保存销售视图
if(accMap.get(csi.Customer__c).Customer_Approval_Status__c != 'Draft' 
   && accMap.get(csi.Customer__c).Customer_Approval_Status__c != 'Approved') {
    csi.addError('不允许保存');
}
```

---

### 3. 信用额度 (Customer_Credit_Info)

#### 核心理解
**信用额度不是直接创建的！** 是通过**额度变更申请**审批通过后自动创建的。

#### 完整流程
```
┌─────────────────────────────────────────────────────────────────────────┐
│                         信用额度申请流程                                  │
└─────────────────────────────────────────────────────────────────────────┘

    前提条件:
    1. Account状态 = Approved ✓
    2. 存在已审批的销售视图 ✓

    ┌──────────────────────┐
    │ Customer_Quota_Change │   ← 用户创建"额度变更申请"
    │    (额度变更申请)     │
    └──────────┬───────────┘
               │
               │ 创建时自动填充 (从现有的Customer_Credit_Info复制):
               ▼
    ┌──────────────────────┐
    │ 字段自动填充:         │
    │ - Sinosure_Credit_Limit__c  (中信保额度)     │
    │ - Type_of_Guarantee__c      (担保类型)       │
    │ - Guarantee_Credit_Line__c  (担保额度)       │
    │ - Clean_Line_USD__c         (信用额度)       │
    │ - Sinosure_Expiration_Date__c (中信保到期日) │
    │ - Payment_Term_Days__c      (账期天数)       │
    │ ... 等                     │
    └──────────┬───────────┘
               │
               │ 用户填写需要修改的额度:
               ▼
    ┌──────────────────────┐
    │ 待填写字段:           │
    │ - Post_Application_Credit__c  (申请后额度)   │
    │ - Customer_Credit_Line__c     (客户信用额度) │
    │ - Valid_After_Change_To__c    (有效期至)     │
    │ - Rules__c / Risk_Class__c / Check_Rule__c  │
    └──────────┬───────────┘
               │
               │ 提交审批
               ▼
    ┌──────────────────────┐
    │    审批通过           │
    └──────────┬───────────┘
               │
               │ 触发器自动执行:
               ▼
    ┌──────────────────────────────────────────────────────┐
    │  1. upsert Customer_Credit_Info__c                    │
    │     ExternalId__c = Customer__c                      │
    │     (根据Customer查重，存在则更新，不存在则创建)          │
    │                                                        │
    │  2. 更新 Account 字段:                                 │
    │     - Customer_Credit_Limit__c (额度)                 │
    │     - Customer_Credit_Is_Valid_Until__c (有效期)       │
    │     - Check_Rule__c / Risk_Class__c                   │
    │                                                        │
    │  3. 同步到 SAP                                         │
    └──────────────────────────────────────────────────────┘
```

#### 关键触发逻辑 (CustomerQuotaChangeTriggerHandler)

| 行号 | 触发条件 | 行为 |
|-----|---------|------|
| 22-96 | Before Insert | 校验前提条件 + 自动填充字段 |
| 46-51 | 总部客户不能申请额度 | 校验并阻止 |
| 52-54 | Account未审批 | 阻止创建 |
| 55-66 | 自动填充现有额度信息 | 从已有Customer_Credit_Info复制 |
| 69-96 | 填充账期信息 | 查询Payment_Rate获取账期天数 |
| 99-215 | After Update且审批通过 | 创建/更新Customer_Credit_Info + 更新Account |

#### 额度同步到SAP (CustomerlimitSyncToSAP)

```
触发时机:
─────────────────────────────────────────────────────
1. Customer_Credit_Info INSERT 时
2. Customer_Credit_Info UPDATE 且以下字段变更:
   - Actual_Credit_limit__c (实际信用额度)
   - Check_Rule__c (检查规则)
   - Credit_Segment__c (信用段)
   - Risk_Class__c (风险类别)
   - Rules__c (规则)
   - Valid_Until__c (有效期至)

同步内容:
─────────────────────────────────────────────────────
- partner: 客户编码 (MDG_Customer_Code__c)
- creditlimit: 信用额度
- limitrule: 规则
- riskclass: 风险类
- checkrule: 检查规则
- creditsgmnt: 信用段
- valid_date: 有效期
```

---

### 4. 客户信息变更 (Customer_Update)

#### 用途
用于修改已审批(Approved)的客户基本信息

#### 流程
```
创建申请                填写内容                    审批通过
    │                      │                         │
    ▼                      ▼                         ▼
┌─────────┐          ┌─────────────┐          ┌─────────────┐
│ 变更申请 │    →     │ New_Customer │    →     │ 更新Account │
│         │          │   _Name__c    │          │    .Name    │
└─────────┘          └─────────────┘          └─────────────┘
```

#### 关键逻辑 (CustomerUpdateTriggerHandler)
```apex
// 审批通过后更新Account
if (cu.Approve_Status__c == 'Approved') {
    Account acc = new Account();
    acc.Id = cu.Customer__c;
    if (String.isNotBlank(cu.New_Customer_Name__c)) {
        acc.Name = cu.New_Customer_Name__c;
    }
    Database.update(accUpdateList);
}
```

---

### 5. 销售视图变更申请 (Customer_Sales_Info_Change_Application)

#### 用途
修改已审批的销售视图字段

#### 可变更的字段
```
┌─────────────────────────────────────────────────┐
│ Customer_Sales_Info_Change_Application__c       │
├─────────────────────────────────────────────────┤
│ New_Payment_term__c       → Terms_Of_Payment__c │
│ New_Customer_Group__c     → Payment_method__c   │
│ New_Shipping_Conditions__c → Shipping_Conditions__c│
│ New_Currency__c           → Currency__c         │
│ New_Account_Assessment__c → Acct_Assmt_Grp_Cust__c│
│ [关联子表] Customer_Tax_Category_Application__c │
│         → New_Tax_Category__c → Tax_Category__c│
└─────────────────────────────────────────────────┘
```

#### 流程
```
创建申请                         填写内容
    │                               │
    ▼                               ▼
┌──────────────────┐      ┌─────────────────────────┐
│ 变更申请记录      │      │ 1. 选择要变更的字段       │
│                  │      │ 2. 填写新值                │
└────────┬─────────┘      │ 3. [可选] 关联税务类别变更  │
         │                └────────┬────────────────┘
         │ 提交审批                         │
         ▼                                │
┌──────────────────┐                      │
│ Approving        │◀─────────────────────┘
└────────┬─────────┘
         │ 审批通过
         ▼
┌──────────────────────────────────────────────────┐
│ 1. 更新 Customer_Sales_Info__c                   │
│ 2. [Sales_Org != 5130/5070时] 更新税务类别        │
│ 3. 变更后的销售视图如果状态=Approved，会同步SAP   │
└──────────────────────────────────────────────────┘
```

#### 关键逻辑 (CustomeSalesInfoApplicationHandler)
```apex
// 审批通过后执行
if (csca.Approve_Status__c == 'Approved') {
    // 1. 更新销售视图
    Customer_Sales_Info__c csi = new Customer_Sales_Info__c();
    if (csca.New_Payment_term__c != null) {
        csi.Terms_Of_Payment__c = csca.New_Payment_term__c;
    }
    // ... 其他字段类似
    
    // 2. [特定销售组织] 更新税务类别
    if (csca.Sales_Org__c != '5130' && csca.Sales_Org__c != '5070') {
        // 更新 Customer_Tax_Category__c.Tax_Category__c
    }
}
```

#### 保存校验
```apex
// 提交审批时必须有变更
if (csca.Approve_Status__c == 'Approving') {
    if (csca.Sales_Org__c != '5130' && csca.Sales_Org__c != '5070') {
        if (!csca.Is_Change__c && csca.Change_Item__c == 0) {
            csca.addError('没有变更内容'); // NoChanged Label
        }
    } else {
        if (!csca.Is_Change__c) {
            csca.addError('没有变更内容');
        }
    }
}
```

---

## 三、审批链路图

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              审批流程层级图                                       │
└─────────────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────┐
                    │   1. Account     │
                    │   客户主数据     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
    ┌─────────────────┐ ┌──────────────┐ ┌─────────────────────┐
    │Customer_Update  │ │Customer_      │ │ Customer_Sales_Info │
    │客户信息变更申请  │ │Quota_Change   │ │ 销售视图             │
    │                 │ │额度变更申请    │ │                     │
    └────────┬────────┘ └───────┬──────┘ └─────────┬───────────┘
             │                   │                   │
             │                   │                   │
             └─────────┬─────────┘                   │
                       │                             │
                       ▼                             │
             ┌─────────────────────┐                  │
             │Customer_Sales_Info  │                  │
             │_Change_Application  │                  │
             │ 销售视图变更申请     │                  │
             └─────────┬───────────┘                  │
                       │                              │
                       │ 关联子表:                     │
                       ▼                              │
             ┌─────────────────────┐                   │
             │Customer_Tax_Category│◀──────────────────┘
             │_Application         │
             │ 税务类别变更申请     │
             └─────────────────────┘


    ═══════════════════════════════════════════════════════════════════════════
                              审批状态与同步关系
    ═══════════════════════════════════════════════════════════════════════════

    Account审批通过 ─────────────────────────────────────────▶ 同步SAP
         │                                                            │
         │ 同步状态                                                    ▼
         │                                                        获得MDG编码
         ▼                                                        (MDG_Customer_Code__c)
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  此时才允许:                                                  │
    │  ✓ 创建 Customer_Sales_Info (状态=Draft/Approved)            │
    │  ✓ 创建 Customer_Quota_Change                               │
    │  ✓ 创建 Customer_Update                                     │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘


    Sales_Info审批通过 ──────────────────────────────────────────▶ 同步SAP
         │                                                            │
         │ 自动生成                                                    ▼
         ▼                                                        同步销售数据
    ┌─────────────────────────────────────────────────────────────┐
    │  Customer_Tax_Category__c (税务类别)                         │
    │  根据国家自动生成该销售视图下的所有税务类别                     │
    └─────────────────────────────────────────────────────────────┘


    Quota_Change审批通过 ─────────────────────────────────────────▶ 同步SAP
         │                                                            │
         │ 自动创建/更新                                               ▼
         ▼                                                        同步额度数据
    ┌─────────────────────────────────────────────────────────────┐
    │  Customer_Credit_Info__c                                     │
    │  - 存在则更新                                                  │
    │  - 不存在则创建                                                │
    └─────────────────────────────────────────────────────────────┘
```

---

## 四、SAP同步触发条件汇总

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SAP同步触发条件                                  │
├──────────────────┬──────────────────────────────────────────────────────────┤
│ 数据对象          │ 同步触发条件                                             │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ Account          │ 1. INSERT + 状态变为Approved                             │
│ (客户基本信息)     │ 2. UPDATE + 状态变为Approved                             │
│                  │ 3. UPDATE + 状态=Approved + 关键字段变更 + 未MDG同步       │
│                  │ 4. UPDATE + 字段变更 + 状态=Approved + 已同步             │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ Customer_Sales   │ 1. UPDATE + 状态变为Approved                              │
│ _Info            │ 2. UPDATE + 状态=Approved + 字段变更 + 未变更             │
│ (销售视图)        │ 注意: 需要 Account.MDG_Customer_Code__c 不为空           │
│                  │     如果为空则延迟1分钟同步                                 │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ Customer_Credit  │ 1. INSERT (新建额度)                                       │
│ _Info            │ 2. UPDATE + 以下任一字段变更:                              │
│ (信用额度)        │    - Actual_Credit_limit__c                               │
│                  │    - Check_Rule__c                                        │
│                  │    - Credit_Segment__c                                     │
│                  │    - Risk_Class__c                                        │
│                  │    - Rules__c                                             │
│                  │    - Valid_Until__c                                       │
│                  │ 注意: Remaining_Credit__c变更不触发同步                      │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ Customer_Update  │ 审批通过后更新Account，不单独同步                          │
│ (客户信息变更)    │ (通过Account的变更触发同步)                                │
├──────────────────┼──────────────────────────────────────────────────────────┤
│ Sales_Info_      │ 审批通过后更新Sales_Info，不单独同步                        │
│ Change_App       │ (通过Sales_Info的变更触发同步)                             │
│ (销售视图变更)    │                                                          │
└──────────────────┴──────────────────────────────────────────────────────────┘
```

---

## 五、数据依赖关系

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              数据依赖图                                         │
└─────────────────────────────────────────────────────────────────────────────────┘

    必须存在                    必须存在                    必须存在
         │                         │                         │
         ▼                         ▼                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Account       │     │  Customer_Sales │     │ Customer_Quota  │
│   (客户)         │     │     _Info        │     │    _Change      │
│                 │     │   (销售视图)      │     │  (额度变更申请)  │
│ 必须状态=Approved│     │                 │     │                 │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                        │                        │
         │ 依赖                    │ 依赖                   │ 依赖
         ▼                        ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│Customer_Update  │     │Customer_Tax_    │     │Customer_Credit │
│ (客户信息变更)  │     │Category         │     │   _Info         │
│                 │     │ (税务类别)       │     │  (信用额度)     │
│                 │     │ [自动生成]       │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘


    ═══════════════════════════════════════════════════════════════════════
                              字段级依赖
    ═══════════════════════════════════════════════════════════════════════

    Customer_Sales_Info 创建时需要:
    ┌─────────────────────────────────────────────────────────────────┐
    │ 字段                  │ 依赖来源                                     │
    ├───────────────────────┼─────────────────────────────────────────┤
    │ Customer__c           │ Account.Id                                 │
    │ External_ID__c        │ 自动生成: Customer_Sales_Org_DistrChannel   │
    │ Reconciliation_Account │ 自动计算: 根据 Delivering_Plant +          │
    │                       │             Acct_Assmt_Grp_Cust            │
    │ Country__c            │ 关联 Account.Country__c                   │
    │ Sales_View_Status__c  │ 继承 Account.Customer_Approval_Status__c   │
    └───────────────────────┴─────────────────────────────────────────┘

    Customer_Tax_Category 创建时需要:
    ┌─────────────────────────────────────────────────────────────────┐
    │ 字段                       │ 依赖来源                              │
    ├────────────────────────────┼─────────────────────────────────────┤
    │ Sales_View__c              │ Customer_Sales_Info.Id              │
    │ Tax_Category_Master_Data__c│ 根据 Country_Code 查找               │
    │ Tax_Category_Type__c       │ Tax_Category_Master_Data.Name        │
    └────────────────────────────┴─────────────────────────────────────┘

    Customer_Quota_Change 创建时需要:
    ┌─────────────────────────────────────────────────────────────────┐
    │ 字段                    │ 依赖来源                                 │
    ├─────────────────────────┼───────────────────────────────────────┤
    │ Customer__c             │ Account.Id                            │
    │ Account状态              │ 必须 = Approved                        │
    │ 现有额度信息             │ 从 Customer_Credit_Info 复制           │
    │ 账期天数                 │ 从 Payment_Rate 查找                   │
    │ Payment_Term_Days__c    │ 根据 Terms_Of_Payment 查找              │
    └─────────────────────────┴───────────────────────────────────────┘

    Customer_Credit_Info 创建/更新时需要:
    ┌─────────────────────────────────────────────────────────────────┐
    │ 字段                       │ 依赖来源                              │
    ├────────────────────────────┼─────────────────────────────────────┤
    │ Customer__c                 │ Account.Id                          │
    │ ExternalId__c               │ Customer__c (用于upsert查重)         │
    │ Actual_Credit_limit__c      │ 来自 Customer_Quota_Change           │
    │ Sync_Status__c              │ 初始值 = 'Unsynchronized'            │
    └────────────────────────────┴─────────────────────────────────────┘
```

---

## 六、常见场景分析

### 场景1: 新客户完整创建流程

```
步骤    操作                    系统行为                              结果
──────────────────────────────────────────────────────────────────────────────
1       创建Account             生成记录(状态=Draft)                   Account.Draft
2       填写客户信息             -                                    -
3       提交审批                 Account.Approving                     -
4       审批通过                 Account.Approved                      -
                                  → 同步SAP                            -
                                  → 获得MDG_Customer_Code              Account.MDG已获得
5       创建销售视图             生成记录(状态=Draft)                   Sales_Info.Draft
6       填写销售信息             自动填充统驭科目                       -
7       提交审批                 Sales_Info.Approving                  -
8       审批通过                 Sales_Info.Approved                   -
                                  → 同步SAP                            -
                                  → 自动生成税务类别                     Tax_Category已生成
9       创建额度变更申请         生成记录                              Quota_Change
10      填写申请额度             填写Post_Application_Credit           -
11      提交审批                 审批通过                              -
                                  → 创建/更新Customer_Credit_Info      Credit_Info
                                  → 同步SAP                            -
```

### 场景2: 修改已审批客户的付款条款

```
步骤    操作                    系统行为                              结果
──────────────────────────────────────────────────────────────────────────────
1       创建销售视图变更申请     生成记录                              Change_App
2       选择字段                New_Payment_term__c = 'NET60'         -
3       提交审批                 审批通过                              -
4       系统执行                 更新Sales_Info.Payment_method__c       Sales_Info已更新
                                  → 同步SAP                            -
```

### 场景3: 修改客户名称

```
步骤    操作                    系统行为                              结果
──────────────────────────────────────────────────────────────────────────────
1       创建客户信息变更申请     生成记录                              Update
2       填写新名称              New_Customer_Name__c = '新名称'        -
3       提交审批                 审批通过                              -
4       系统执行                 更新Account.Name                      Account已更新
                                  → 同步SAP                            -
```

### 场景4: 额度变更流程

```
步骤    操作                    系统行为                              结果
──────────────────────────────────────────────────────────────────────────────
1       创建额度变更申请         从现有额度自动填充字段                 Quota_Change(带默认值)
2       修改额度                 Post_Application_Credit__c = 100000  -
3       提交审批                 审批通过                              -
4       系统执行                 upsert Customer_Credit_Info           Credit_Info已更新
                                  (ExternalId__c = Customer__c)
                                  → 更新Account额度字段                Account已更新
                                  → 同步SAP                            -
```

---

## 七、关键业务规则总结

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              关键业务规则                                     │
└─────────────────────────────────────────────────────────────────────────────┘

1. 【前置条件】Account必须Approved
   ─────────────────────────────────────────────
   以下操作要求Account状态为Approved:
   - 创建/修改Customer_Sales_Info
   - 创建Customer_Quota_Change
   - 创建Customer_Update

2. 【同步前提】必须有MDG客户编码
   ─────────────────────────────────────────────
   Customer_Sales_Info同步SAP时:
   - 如果Account.MDG_Customer_Code__c存在 → 立即同步
   - 如果Account.MDG_Customer_Code__c为空 → 延迟1分钟后同步

3. 【自动生成】税务类别
   ─────────────────────────────────────────────
   Customer_Sales_Info创建/国家变更时:
   - 自动根据国家查找税务主数据
   - 为该销售视图创建所有对应的税务类别记录

4. 【额度合并】一个客户一个额度
   ─────────────────────────────────────────────
   Customer_Credit_Info使用ExternalId__c = Customer__c:
   - upsert操作确保一个客户只有一条额度记录
   - 每次审批通过都是更新该记录

5. 【状态锁定】Approved后关键字段不可改
   ─────────────────────────────────────────────
   AccountApproved后:
   - FieldSet中的关键字段不能直接修改
   - 必须通过Customer_Update走审批流程

6. 【YPF标识】自动判断
   ─────────────────────────────────────────────
   当任一销售视图的Payment_method__c='YPF'时:
   - Account.Is_YPF__c = true
   - 否则 = false
```

---

## 八、相关文件索引

| 文件类型 | 文件路径 | 说明 |
|---------|---------|-----|
| Trigger | `triggers/Account.trigger` | 客户触发器 |
| Handler | `classes/AccountTriggerHandler.cls` | 客户业务逻辑 |
| Trigger | `triggers/Customer_Sales_Info.trigger` | 销售视图触发器 |
| Handler | `classes/CustomerSalesInfoTriggerHandler.cls` | 销售视图业务逻辑 |
| Trigger | `triggers/Customer_Credit_Info.trigger` | 信用额度触发器 |
| Handler | `classes/CustomerCreditTriggerHandler.cls` | 信用额度业务逻辑 |
| Trigger | `triggers/Customer_Quota_Change.trigger` | 额度变更申请触发器 |
| Handler | `classes/CustomerQuotaChangeTriggerHandler.cls` | 额度变更申请业务逻辑 |
| Trigger | `triggers/Customer_Update.trigger` | 客户信息变更触发器 |
| Handler | `classes/CustomerUpdateTriggerHandler.cls` | 客户信息变更业务逻辑 |
| Trigger | `triggers/Customer_Sales_Info_Change_Application.trigger` | 销售视图变更申请触发器 |
| Handler | `classes/CustomeSalesInfoApplicationHandler.cls` | 销售视图变更申请业务逻辑 |
| Sync类 | `classes/CustomerInfoSyncToSAP.cls` | 客户信息→SAP同步 |
| Sync类 | `classes/CustomerSalesInfoSyncToSAP.cls` | 销售视图→SAP同步 |
| Sync类 | `classes/CustomerlimitSyncToSAP.cls` | 信用额度→SAP同步 |

---

> 文档版本: 1.0  
> 最后更新: 2026-04-18
