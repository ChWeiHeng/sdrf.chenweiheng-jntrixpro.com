# 市场活动（Campaign）模块业务逻辑文档

> 整理时间：2026-04-18
> 模块负责人：Gerry

---

## 目录

- [一、模块概述](#一模块概述)
- [二、核心对象详解](#二核心对象详解)
- [三、触发器链路](#三触发器链路)
- [四、审批流程体系](#四审批流程体系)
- [五、预算管理体系](#五预算管理体系)
- [六、市场活动产品](#六市场活动产品)
- [七、参会人名单](#七参会人名单)
- [八、自动免费订单创建](#八自动免费订单创建)
- [九、附件校验逻辑](#九附件校验逻辑)
- [十、销售组织与币种映射](#十销售组织与币种映射)
- [十一、接口清单](#十一接口清单)
- [十二、文件清单](#十二文件清单)
- [十三、业务流程图](#十三业务流程图)
- [十四、运维注意事项](#十四运维注意事项)
- [十五、相关文档](#十五相关文档)

---

## 一、模块概述

市场活动（Campaign）模块是山东润丰 Salesforce CRM 项目中用于管理营销活动的核心模块，支持四种活动类型。该模块与预算管理、产品管理、免费订单生成等功能紧密集成。

### 1.1 核心对象列表

| 对象名称 | 类型 | 说明 |
|---------|------|------|
| Campaign | 标准对象 | 市场活动主记录 |
| Campaign_Budget__c | 自定义对象 | 年度预算 |
| Monthly_Budget__c | 自定义对象 | 月度预算 |
| Campaign_Product__c | 自定义对象 | 市场活动产品 |
| Participants_List__c | 自定义对象 | 参会人名单 |

### 1.2 模块架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           市场活动模块架构                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│  │Campaign_Budget│    │Monthly_Budget│    │Campaign_Product│            │
│  │  (年度预算)   │───▶│  (月度预算)   │◀───│ (市场活动产品) │            │
│  └──────────────┘    └──────┬───────┘    └──────────────┘              │
│                            │                                            │
│                            ▼                                            │
│                     ┌──────────────┐                                    │
│                     │  Campaign    │                                    │
│                     │ (市场活动)    │                                    │
│                     └──────┬───────┘                                    │
│                            │                                            │
│          ┌─────────────────┼─────────────────┐                          │
│          ▼                 ▼                 ▼                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│  │Participants  │  │   Order__c   │  │ContentDocument│                   │
│  │_List(参会名单)│  │   (ZFD订单)   │  │   (附件)      │                   │
│  └──────────────┘  └──────────────┘  └──────────────┘                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 二、核心对象详解

### 2.1 Campaign（市场活动）

**RecordType 类型**（共4种）：

| RecordType | 说明 | 适用场景 | 是否需要月度预算 | 是否自动创建免费订单 |
|-----------|------|---------|----------------|-----------------|
| **Field_Demo** | 田间示范 | 田间示范活动 | ✅ 需要 | ✅ 是 |
| **Offline_Campaign** | 线下活动 | 农民会、展会等 | ✅ 需要 | ❌ 否 |
| **Online_Campaign** | 线上活动 | 社交媒体推广、网络营销 | ✅ 需要 | ❌ 否 |
| **Sample** | 样品活动 | 免费样品申请 | ❌ 不需要 | ✅ 是 |

**RecordType 差异化说明**：

1. **Field_Demo（田间示范）**：
   - 需要关联月度预算
   - 审批通过后自动创建 ZFD 免费订单
   - 有独特的字段配置（Audience, Crop_Problematic, Crop_Solution 等）
   - 田间活动特有字段：Observation__c

2. **Offline_Campaign（线下活动）**：
   - 需要关联月度预算
   - 有字段锁定校验（Approved 状态锁定核心字段）
   - 需要附件校验（≥5图+1视频）
   - 不自动创建订单

3. **Online_Campaign（线上活动）**：
   - 需要关联月度预算
   - 有线上特有字段（Social_Media_Channel, Campaig_Duration, Season 等）
   - 不自动创建订单

4. **Sample（样品活动）**：
   - **不需要**关联月度预算
   - 审批通过后自动创建 ZFD 免费订单
   - 有样品特有字段（Sample_Type）

### 2.2 Field_Demo（田间示范）特有字段

从 `Field_Demo.recordType-meta.xml` 配置中，Field Demo 类型有以下特有字段配置：

**受众类型 (Audience__c)**：
| 值 | 说明 |
|---|------|
| Advisor | 顾问 |
| Cooperatives | 合作社 |
| Distributor/Dealer | 经销商/零售商 |
| Large Farmer | 大农户 |
| Medium Farmer | 中等农户 |
| Small Farmer | 小农户 |

**作物问题 (Crop_Problematic__c)**：
包括 Agave, Alfalfa, Avocado, Banana, Barley, Beans, Berries, Brassicas, Canola, Citrus, Corn, Cotton, Cucurbits, Others, Palm, Pastures, Potatoes, Rice, Sorghum, Soybean, Sugarcane, Sunflower, Tomato %26 Pepper, Turf %26 Ornamentals, Wheat 等

**作物方案 (Crop_Solution__c)**：
包括 Agave, Avocado, Berries, Brasicas, Citrus, Corn, Pineapple, Potato, Sugarcane, Tomatoe %26 pepper 等

**样品类型 (Sample_Type__c)**：
| 值 | 说明 |
|---|------|
| Demo Sample (for large producers/distributors) | 演示样品（针对大农户/经销商） |
| Technical Sample (small scale, one-off validation) | 技术样品（小规模、一次性验证） |
| Trade Sample (strong sign of purchase interest) | 贸易样品（强烈购买意向） |

**关键字段**：

| 字段 | API名称 | 类型 | 说明 |
|------|---------|------|------|
| 审批状态 | Approval_Status__c | Picklist | Draft/Approving/Approved/Rejected |
| 营销审批状态 | MKT_Approval__c | Picklist | Draft/Approving/Approved/Rejected |
| 是否超预算 | Is_MKT_Approvel__c | Checkbox | 是否超出月度预算 |
| 是否营销经理 | Is_MKT_Manager__c | Checkbox | 创建人是否为营销经理 |
| 预算金额 | Budget__c | Currency | 活动预算 |
| 实际成本 | Actual_Costs__c | Currency | 实际花费 |
| 活动日期 | Date__c | Date | 活动计划日期 |
| 事件日期 | Date_of_the_event__c | Date | 实际事件日期 |
| 销售组织 | Sales_Org__c | Picklist | 3010/3011/3020/5070/5130等 |
| 交货工厂 | Delivery_Plant__c | Picklist | 交货工厂 |
| 币种 | Currency__c | Picklist | CNY/MXN/ARS/USD |
| 客户 | Customer_Lookup__c | Lookup(Account) | 关联客户 |
| 收货方 | Ship_To__c | Lookup | 收货地址 |
| 预计参会人数 | Estimated_Participants__c | Number | 预计参与人数 |
| 实际参会人数 | Actual_number_of_Participants__c | Number | 实际参与人数 |
| 产品线 | Product_Line__c | Picklist | 产品线分类 |
| 月度预算 | Monthly_Budget__c | Lookup | 关联月度预算 |
| 申请人 | Applicant__c | Lookup(User) | 申请人 |
| 用户经理 | User_Manager__c | Lookup(User) | 用户经理 |

---

## 三、触发器链路

### 3.1 触发器清单

| 触发器文件 | 处理程序类 | 触发事件 | 功能说明 |
|-----------|-----------|---------|---------|
| CampaignTrigger.trigger | CampaignTriggerHandler | before/after insert/update/delete | 市场活动主逻辑 |
| CampaignBudgetTrigger.trigger | CampaignBudgetTriggerHandler | before insert/update | 年度预算逻辑 |
| MonthlyBudgetTrigger.trigger | MonthlyBudgetTriggerHandler | before/after insert/update | 月度预算逻辑 |
| CampaignProductTrigger.trigger | CampaignProductTriggerHandler | before/after insert/update | 市场活动产品逻辑 |

### 3.2 CampaignTriggerHandler 执行链路（330行）

#### 触发时机 1：Before Insert（创建时自动填充）

**方法**：`autoRelationBudget()`, `autoChangeManager()`

**执行逻辑**：

```
1. autoRelationBudget() - 自动关联月度预算
   ├── 获取市场活动的 OwnerId、活动日期
   ├── 根据日期计算年度和月度
   ├── 查询匹配条件的 Monthly_Budget__c
   │   └── 匹配条件: Sales_Org + Delivery_Plant + Year + OwnerId + Month
   ├── 自动关联到 Campaign.Monthly_Budget__c
   └── 若无匹配月度预算 → 阻止创建
   │
   └── ⚠️ 特殊逻辑：Sample 类型跳过月度预算关联！

2. autoChangeManager() - 自动填充经理信息
   ├── 查询 Owner 的 ManagerId
   ├── 填充 Campaign.User_Manager__c
   ├── 填充 Campaign.Sales_Org__c
   ├── 填充 Campaign.Delivery_Plant__c
   └── 判断是否为营销经理 → Campaign.Is_MKT_Manager__c

3. 币种自动设置
   ├── Sales_Org = 5070/5130 (阿根廷) → Currency = USD
   ├── Sales_Org = 3010/3020 (墨西哥) → Currency = MXN
   └── 其他 → 默认 CNY

4. 申请人默认赋值
   └── Applicant__c = OwnerId (若为空)
```

#### 触发时机 2：Before Update（更新时校验）

**校验规则 1：Approved 状态下核心字段锁定**
- 锁定字段（Offline_Campaign）：Name, Date__c, Type, Budget__c, Objective__c, Segment_1__c, Segment_2__c, Crop_Problematic__c, Applicant__c, Related_Product_Level__c, Product_Line__c, Crop_Solution__c, Customer__c, Customer_Type__c, Customer_Lookup__c, Audience__c, Co_branding_Sponsorship__c, Detail_Plan__c, Estimated_Participants__c
- 锁定字段（Online_Campaign）：Name, Date__c, Type, Budget__c, Social_Meida_Channel__c, Applicant__c, Campaig_Duration__c, Season__c, Target_Audience_Interestes__c, Target_Audiences_Age_Range__c, Target_Audiences_Gender__c, Target_Potential_Audiences__c, Geographics_Area__c
- **例外**：营销经理可修改 Budget__c

**校验规则 2：Approved 状态下结果字段锁定**
- 锁定字段：Location__c, Date_of_the_event__c, Actual_Costs__c, Actual_number_of_Participants__c, Quality_of_Participants__c, Whether_Generated_Orders__c, Order_Amount__c, New_Customers_Generated__c, Competitor_Info__c, Client_Feedback__c, Summary__c, Frecuency__c, Reach__c, Mark_the_event__c
- **例外**：MKT_Approval 状态为 Draft 或 Rejected 时可修改

**校验规则 3：MKT_Approval 审批通过时附件校验**

```apex
checkAttachments(cam.Id)
├── 查询 ContentDocumentLink 获取附件列表
├── 统计图片数量 (FileType 在 ImageType Label 中)
├── 统计视频数量 (FileType 在 VideoType Label 中)
└── 校验规则：
    ├── 图片数量 < 5 → 阻止，提示：请上传至少5张现场照片
    └── 视频数量 < 1 → 阻止，提示：请上传至少1个视频
```

**校验规则 4：自动更新活动状态**
- 若 MKT_Approval 变为 'Approved' → 活动 Status 变为 'Completed'

#### 触发时机 3：After Update（审批后处理）

**处理 1：超预算审批通过通知**

```apex
if (MKT_Approval__c == 'Approved' && Is_MKT_Approvel__c == true) {
    // 发送系统通知给活动 Owner
    CustomNotificationFromApex.notifyUsers(
        notificationType, 
        adminSet,  // 发送给谁
        cam.Id,    // 点击跳转
        System.Label.BudgetTitle,  // 标题
        System.Label.BudgetBody.replace('[Campaign Owner Name]', cam.Owner_Name__c)  // 内容
    );
}
```

**处理 2：审批通过自动创建免费订单**

```apex
if (Approval_Status__c == 'Approved' && 变更了) {
    CreateFreeOrderController.createFreeOrder(cam.Id);
    // 订单创建失败 → addError
}
```

> ⚠️ **注意**：所有市场活动审批通过都会尝试创建免费订单，但只有 `Field_Demo` 和 `Sample` 类型有产品时会成功创建。

**处理 3：更新月度预算已使用金额**

```apex
calBudgetAmount(Set<String> updateMonthBudget)
├── 查询已审批的 Campaign Actual_Costs__c 总和
│   └── 条件: Monthly_Budget__c IN updateMonthBudget AND MKT_Approval__c = 'Approved'
├── 查询占用中的 Campaign Budget__c 总和
│   └── 条件: Monthly_Budget__c IN updateMonthBudget AND Approval_Status__c IN ('Approving','Approved') AND MKT_Approval__c NOT IN ('Approved','Rejected')
├── 更新 Monthly_Budget__c：
│   ├── Amount_Spent__c = 实际已花费
│   └── Amount_Occupied__c = 占用中金额
└── DML 更新
```

---

## 四、审批流程体系

> ⚠️ **重要发现**：Campaign 模块共有 **21 个审批流程**，针对不同销售组织、RecordType 和场景进行了精细化配置。

### 4.1 审批流程清单（共21个）

| 序号 | 审批流程名称 | 激活状态 | 适用场景 | 审批步骤 |
|:---:|-------------|:-------:|---------|---------|
| 1 | Campaign Budget Approval New1 | ❌ 未激活 | MX/AR (3010/3020/5070/5130) | MKT→Fin→GM (多级) |
| 2 | Campaign Budget Approval New2 | ❌ 未激活 | MX/AR (3020/5130) | MKT→Fin→GM |
| 3 | Campaign Budget MX ModelC | ✅ 激活 | MX 3020 + Is_Approval=true | MKT→GM |
| 4 | Campaign Budget MX ModelC+ | ✅ 激活 | MX 3011 | GM (Country Manager) |
| 5 | Campaign Budget MX ModelC+ AC | ✅ 激活 | MX 3011 + MKT审批 | GM |
| 6 | Campaign Budget MX ModelC NO Condition | ✅ 激活 | MX 3020 + Is_Approval=false | MKT |
| 7 | Campaign Budget AR ModelC | ❌ 未激活 | AR 5130 | MKT→Credit→GM |
| 8 | Campaign Budget AR ModelC1 | ❌ 未激活 | AR 5130 | MKT→GM→Area Head |
| 9 | Campaign Budget AR ModelC2 | ❌ 未激活 | AR 5130 | MKT→GM→Area Head→GM |
| 10 | Campaign Budget AR ModelC3 | ❌ 未激活 | AR 5130 | MKT→GM→Area Head(双人) |
| 11 | Campaign Budget Demo AR ModelC | ❌ 未激活 | AR 5130 + Field Demo | MKT→GM |
| 12 | Campaign Budget Demo AR ModelC1 | ✅ 激活 | AR 5130 + Field Demo | MKT→GM→Area Head |
| 13 | Campaign Budget Sample AR ModelC | ❌ 未激活 | AR 5130 + Sample | MKT→GM |
| 14 | Campaign Budget Sample AR ModelC1 | ✅ 激活 | AR 5130 + Sample | MKT→GM→Area Head |
| 15 | Campaign Budget On/Offline AR ModelC | ❌ 未激活 | AR 5130 + Offline/Online | MKT→GM |
| 16 | Campaign Budget On/Offline AR ModelC1 | ✅ 激活 | AR 5130 + Offline/Online | MKT→GM→Area Head |
| 17 | Campaign Actual Cost Over Budget New | ❌ 未激活 | 预算超支审批(MKT) | MKT Manager |
| 18 | Campaign Actual Cost Over Budget New1 MC | ✅ 激活 | MX 3020 超支审批 | MKT→GM |
| 19 | Campaign Actual Cost Over Budget AR | ✅ 激活 | AR 5130 超支审批 | MKT→GM |
| 20 | Cam Actual Cost Over Bud No Approval MXC | ✅ 激活 | MX 3020 超支免审批 | MKT Manager |
| 21 | Cam Actual Cost Over Bud No Approval ARC | ✅ 激活 | AR 5130 超支免审批 | MKT Manager |

### 4.2 审批流程分类

#### 4.2.1 预算审批流程（主流程）

**进入条件**：`Approval_Status__c = 'Draft' 或 'Rejected'`

| 销售组织 | Delivery_Plant | 审批流程 | 激活 | 审批链路 |
|---------|---------------|---------|:---:|---------|
| **阿根廷** | 5130 | Campaign Budget On/Offline AR ModelC1 | ✅ | Marketing Manager (juan.fernandez) → General Manager (pablo.torasso) → Area Head (eric_wang) |
| **阿根廷** | 5130 | Campaign Budget AR ModelC3 | ❌ | Marketing Manager → GM → Area Head(双人) |
| **阿根廷** | 5130 | Campaign Budget Demo AR ModelC1 | ✅ | Marketing Manager → GM → Area Head *(Field Demo 专用)* |
| **阿根廷** | 5130 | Campaign Budget Sample AR ModelC1 | ✅ | Marketing Manager → GM → Area Head *(Sample 专用)* |
| **墨西哥** | 3020 | Campaign Budget MX ModelC | ✅ | Marketing Manager → Country Manager *(Is_Approval=true)* |
| **墨西哥** | 3020 | Campaign Budget MX ModelC NO Condition | ✅ | Marketing Manager *(Is_Approval=false)* |
| **墨西哥** | 3011 | Campaign Budget MX ModelC+ | ✅ | Mexico Country Manager (benjamin.robles) |

**审批页面显示字段**：Name, Owner, Budget__c

#### 4.2.2 超预算审批流程（MKT审批）

**进入条件**：
- `Approval_Status__c = 'Approved'`
- `MKT_Approval__c = 'Draft' 或 'Rejected'`
- `Is_MKT_Approvel__c = True`（超预算标记）
- `Is_MKT_Manager__c = False`（创建人非营销经理）

| 流程 | 激活 | 适用Plant | 审批链路 |
|-----|:---:|----------|---------|
| Campaign Actual Cost Over Budget New1 MC | ✅ | 3020 | Marketing Manager (marketing1@agroterrum.com.mx) → Marketing Manager (pablo.torasso) |
| Campaign Actual Cost Over Budget AR | ✅ | 5130 | Marketing Manager (juan.fernandez@agroterrum.com.ar) → General Manager (pablo.torasso) |
| Cam Actual Cost Over Bud No Approval MXC | ✅ | 3020 | Manager层级 *(Is_MKT_Approvel=true时跳过)* |
| Cam Actual Cost Over Bud No Approval ARC | ✅ | 5130 | Manager层级 *(Is_MKT_Approvel=true时跳过)* |

**审批页面显示字段**：Name, Owner, Budget__c, Actual_Costs__c

### 4.3 审批流程详细说明

#### 4.3.1 AR（阿根廷）审批链路 - Campaign Budget On/Offline AR ModelC1（激活）

**适用**：AR 5130 + Offline_Campaign / Online_Campaign

**审批步骤**：

```
Step 1: Marketing Manager (juan.fernandez@agroterrum.com.ar)
├── 进入条件：Delivery_Plant = '5130' 且 用户角色不包含 'Marketing Manage'
└── 跳过条件：用户已是营销经理 → 自动通过

Step 2: General Manager (pablo.torasso@agroterrum.com.ar)
├── 进入条件：Delivery_Plant = '5130' 且 Is_Approval = true 且 用户角色不包含 'General Manager'
└── 跳过条件：Is_Approval = false → 跳过此步

Step 3: Area Head (eric_wang@rainbowagro.com)
├── 进入条件：Is_Approval = true
└── 跳过条件：Is_Approval = false → 跳过此步
```

**特殊逻辑**：
- 如果提交人角色包含 "Marketing Manage"，Step 1 自动通过
- 如果 Is_Approval = false，Step 2 和 Step 3 跳过
- 如果 Is_Approval = true，需要 Area Head 审批

#### 4.3.2 AR（阿根廷）Field Demo 审批链路 - Campaign Budget Demo AR ModelC1（激活）

**适用**：AR 5130 + Field_Demo RecordType

**审批步骤**：

```
Step 1: Marketing Manager (juan.fernandez@agroterrum.com.ar)
├── 进入条件：Delivery_Plant = '5130' 且 用户角色不包含 'Marketing Manage'
└── 跳过条件：用户已是营销经理 → 自动通过

Step 2: General Manager (pablo.torasso@agroterrum.com.ar)
├── 进入条件：Delivery_Plant = '5130' 且 Is_Approval = true
└── 跳过条件：Is_Approval = false → 跳过此步

Step 3: Area Head (eric_wang@rainbowagro.com)
├── 进入条件：Delivery_Plant = '5130'
└── 跳过条件：无
```

#### 4.3.3 MX（墨西哥）审批链路 - Campaign Budget MX ModelC（激活）

**适用**：MX 3020 + Is_Approval = true

**审批步骤**：

```
Step 1: Marketing Manager (marketing1@agroterrum.com.mx)
├── 进入条件：Delivery_Plant = '3020' 且 用户角色不包含 'Marketing Manage'
└── 跳过条件：用户已是营销经理 → 自动通过

Step 2: Country Manager (benjamin.robles@rainbowagro.com)
├── 进入条件：Delivery_Plant = '3020' 且 Is_Approval = true 且 用户角色不包含 'Country Manager'
└── 跳过条件：Is_Approval = false 或 用户是Country Manager → 跳过此步
```

#### 4.3.4 MX（墨西哥）免条件审批 - Campaign Budget MX ModelC NO Condition（激活）

**适用**：MX 3020 + Is_Approval = false

**审批步骤**：

```
Step 1: Marketing Manager (marketing1@agroterrum.com.mx)
├── 进入条件：Delivery_Plant = '3020' 且 用户角色不包含 'Marketing Manage'
└── 跳过条件：用户已是营销经理 → 自动通过

└── 最终结果：直接更新 Approval_Status = 'Approved'
```

> 💡 **关键区别**：当 Is_Approval = false 时，审批流程更简单，只需要 MKT 审批，不需要 Country Manager 审批。

#### 4.3.5 MX（墨西哥）3011 审批链路 - Campaign Budget MX ModelC+（激活）

**适用**：MX 3011

**审批步骤**：

```
Step 1: Mexico Country Manager (benjamin.robles@rainbowagro.com)
├── 进入条件：Delivery_Plant = '3011' 且 用户角色不包含 'Mexico Country Manager'
└── 跳过条件：用户已是Mexico Country Manager → 自动通过
```

> 💡 **简化流程**：MX 3011 只有一级审批，由 Country Manager 直接审批。

### 4.4 审批状态与字段更新

#### 4.4.1 审批动作与状态变更

| 审批动作 | 触发的字段更新 | 说明 |
|---------|--------------|------|
| **提交审批** | `Approval_Status__c = 'Approving'` | 初始提交时 |
| **审批通过** | `Approval_Status__c = 'Approved'` | 预算审批通过 |
| **审批拒绝** | `Approval_Status__c = 'Rejected'` | 预算审批拒绝 |
| **撤回审批** | `Approval_Status__c = 'Draft'` | 申请人撤回 |

#### 4.4.2 字段更新定义

| 字段更新名称 | 更新字段 | 更新值 |
|------------|---------|-------|
| Status_Approving | Approval_Status__c | Approving |
| Status_approved | Approval_Status__c | Approved |
| Status_Rejected | Approval_Status__c | Rejected |
| Status_Draft | Approval_Status__c | Draft |
| MKT_Approvaing | MKT_Approval__c | Approving |
| MKT_Approved | MKT_Approval__c | Approved |
| MKT_Reject | MKT_Approval__c | Rejected |
| MKT_Draft | MKT_Approval__c | Draft |

### 4.5 审批流程元数据文件清单

```
force-app/main/default/approvalProcesses/
├── Campaign.Campaign_Budget_Approval_New1.approvalProcess-meta.xml     (未激活)
├── Campaign.Campaign_Budget_Approval_New2.approvalProcess-meta.xml     (未激活)
├── Campaign.Campaign_Budget_AR_ModelC.approvalProcess-meta.xml         (未激活)
├── Campaign.Campaign_Budget_AR_ModelC1.approvalProcess-meta.xml         (未激活)
├── Campaign.Campaign_Budget_AR_ModelC2.approvalProcess-meta.xml         (未激活)
├── Campaign.Campaign_Budget_AR_ModelC3.approvalProcess-meta.xml         (未激活)
├── Campaign.Campaign_Budget_Demo_AR_ModelC.approvalProcess-meta.xml     (未激活)
├── Campaign.Campaign_Budget_Demo_AR_ModelC1.approvalProcess-meta.xml    (✅激活)
├── Campaign.Campaign_Budget_MX_ModelC.approvalProcess-meta.xml          (✅激活)
├── Campaign.Campaign_Budget_MX_ModelCplus.approvalProcess-meta.xml      (✅激活)
├── Campaign.Campaign_Budget_MX_ModelCplus_AC.approvalProcess-meta.xml   (✅激活)
├── Campaign.Campaign_Budget_MX_ModelC_NO_Condition.approvalProcess-meta.xml (✅激活)
├── Campaign.Campaign_Budget_On_AR_ModelC.approvalProcess-meta.xml       (未激活)
├── Campaign.Campaign_Budget_On_AR_ModelC1.approvalProcess-meta.xml      (✅激活)
├── Campaign.Campaign_Budget_Sample_AR_ModelC.approvalProcess-meta.xml   (未激活)
├── Campaign.Campaign_Budget_Sample_AR_ModelC1.approvalProcess-meta.xml  (✅激活)
├── Campaign.Campaign_Actual_Cost_Over_Budget_AR.approvalProcess-meta.xml (✅激活)
├── Campaign.Campaign_Actual_Cost_Over_Budget_New.approvalProcess-meta.xml (未激活)
├── Campaign.Campaign_Actual_Cost_Over_Budget_New1.approvalProcess-meta.xml (✅激活)
├── Campaign.Cam_Actual_Cost_Over_Bud_No_Approval.approvalProcess-meta.xml (✅激活)
└── Campaign.Cam_Actual_Cost_Over_Bud_No_ApprovalAR.approvalProcess-meta.xml (✅激活)
```

### 4.6 审批流程设计要点

#### 4.6.1 双签名字段 Is_Approval__c

- **Is_Approval__c = true**：表示需要更高层级审批（Country Manager 或 Area Head）
- **Is_Approval__c = false**：表示只需 Marketing Manager 审批

#### 4.6.2 营销经理自动跳过

```apex
// 审批条件示例
formula: AND(TEXT(Delivery_Plant__c)=='5130', !CONTAINS($UserRole.Name,'Marketing Manage'))
```

- 如果提交人角色包含 "Marketing Manage"，Marketing Manager 审批步骤自动通过
- 这是 Salesforce 审批流程的 `GotoNextStep` 特性

#### 4.6.3 审批记录锁定

| 审批流程 | 审批时锁定 | 审批后锁定 |
|---------|:--------:|:---------:|
| Cam Actual Cost Over Bud No Approval MXC | ❌ | ✅ |
| 其他流程 | ❌ | ❌ |

#### 4.6.4 审批撤回

| 审批流程 | 允许撤回 |
|---------|:-------:|
| 大部分流程 | ✅ 允许 |
| Cam Actual Cost Over Bud No Approval MXC/AR | ❌ 不允许 |

---

## 五、预算管理体系

### 5.1 预算层级结构

```
年度预算 (Campaign_Budget__c)
    │
    ├── 销售组织 (Sales_Org__c)
    ├── 工厂 (Plant__c)
    ├── 年度 (Year__c)
    ├── 预算金额 (Budgeted_Amount__c)
    │
    └── 月度预算 (Monthly_Budget__c)
            │
            ├── 关联年度预算 (Campaign_Budget__c)
            ├── 销售代表 (Sales_Rep__c)
            ├── 月份 (Month__c)
            ├── 预算金额 (Budgeted_Amount__c)
            ├── 已使用金额 (Amount_Spent__c)
            ├── 占用金额 (Amount_Occupied__c)
            └── 剩余金额 (Month_Remaining_Budget__c)
                    │
                    └── 市场活动 (Campaign)
                            │
                            ├── 预算金额 (Budget__c)
                            └── 实际成本 (Actual_Costs__c)
```

### 5.2 年度预算 (Campaign_Budget__c)

**触发器**：CampaignBudgetTrigger → CampaignBudgetTriggerHandler

**触发时机**：Before Insert, Before Update

**核心逻辑**：

```apex
// 自动生成外部ID
campaignBudget.ExteralId__c = Sales_Org__c + '_' + Plant__c + '_' + Year__c;
// 格式示例: 3010_CD_2026
```

**唯一性约束**：
- 同一销售组织 + 同一工厂 + 同一年度 不能重复

---

### 5.3 月度预算 (Monthly_Budget__c)

**触发器**：MonthlyBudgetTrigger → MonthlyBudgetTriggerHandler

#### 触发时机 1：Before Insert/Update

**逻辑 1：自动生成外部ID**

```apex
monthBudget.ExteralId__c = Campaign_Budget__c + '_' + Sales_Rep__c + '_' + Month__c;
```

**逻辑 2：月度预算不能超过年度剩余**

```apex
// 计算逻辑
年度预算金额 = Campaign_Budget__r.Budgeted_Amount__c
已分配月度总额 = SUM(Monthly_Budget__c WHERE Campaign_Budget__c = 当前年度)
月度剩余 = 年度预算金额 - 已分配月度总额

// 校验规则
if (月度预算 > 月度剩余) {
    monthBudget.addError(UserName + Month + '月度总预算超出年度预算');
}
```

**逻辑 3：预算金额不能小于已使用金额**

```apex
if (Budgeted_Amount__c < Amount_Spent__c) {
    monthBudget.addError(UserName + Month + '预算金额不能小于已使用金额');
}
```

---

## 六、市场活动产品 (Campaign_Product__c)

### 6.1 触发器：CampaignProductTrigger

**处理程序**：CampaignProductTriggerHandler

#### 触发时机：Before Insert

**校验规则**：
```apex
if (Status__c == 'Approved') {
    campaignProduct.addError(System.Label.CampaignProductInsertError);
    // 提示：活动已审批，不能添加产品
}
```

#### 触发时机：Before Update

**校验规则**：
```apex
if (Status__c == 'Approved') {
    campaignProduct.addError(System.Label.CampaignProductUpdateError);
    // 提示：活动已审批，不能修改产品
}
```

### 6.2 关键字段

| 字段 | API名称 | 类型 | 说明 |
|------|---------|------|------|
| 市场活动 | Campaign__c | Lookup | 关联市场活动 |
| 产品名称 | Product_Name__c | Lookup | 关联商品名 |
| 数量 | Quantity__c | Number | 赠送数量 |
| 交货日期 | Delivery_Date__c | Date | 计划交货日期 |
| 产品单位 | Product_Unit_Lookup__c | Lookup | 产品单位 |
| 单位 | Unit__c | Text | 单位文本 |

---

## 七、参会人名单 (Participants_List__c)

### 7.1 对象概述

参会人名单用于记录市场活动的参与人员信息，支持批量导入。

### 7.2 批量导入控制器：BatchImportParticipantsListController

**核心方法**：

#### 1. getInitData(id) - 初始化导入数据

```apex
@AuraEnabled
public static InitData getInitData(String id) {
    // 1. 校验导入用户与活动同一销售组织
    // 2. 根据销售组织获取导入模板
    //    ├── MX (3010/3020) → Participants_List_MX
    //    └── AR (5070/5130) → Participants_List_AR
    // 3. 获取字段配置
    //    └── 查询 ImportDataFieldConf__c WHERE Obj_Name__c = 'Participants_List__c'
    // 4. 返回字段映射和必填字段
}
```

#### 2. saveData() - 保存导入数据

```apex
@AuraEnabled
public static InsertSalesTargetResult saveData(
    String TargetJson,           // Excel JSON 数据
    Map<String,String> excelHeaderKeyToLabelMap,  // 字段映射
    List<String> mustFillValueFields,  // 必填字段列表
    String camId                  // 市场活动ID
)
```

**导入流程**：

```
1. 数据校验
   ├── 检查必填字段
   ├── 检查最大行数限制 (MaxRow 配置)
   └── 检查数据重复

2. 数据映射
   ├── Excel列名 → API字段名
   └── 创建 Participants_List__c 记录

3. 批量插入
   ├── 全部验证通过 → 直接 insert
   ├── 存在验证失败 → 返回失败列表
   └── 系统异常 → 回滚并返回错误

4. 返回结果
   ├── lResult: Success/Failed/Error
   ├── successValiAmount: 验证成功数
   ├── failedValiAmount: 验证失败数
   └── valiriFailedSalesTarget: 失败详情列表
```

**导入字段配置**：

| 字段 | API名称 | 必填 | 说明 |
|------|---------|------|------|
| 姓名 | Name | ✓ | 参会人姓名 |
| 邮箱 | Email__c | | 邮箱地址 |
| 电话 | Phone__c | | 联系电话 |
| 公司名称 | Company_Name__c | | 公司/农场名称 |
| 公司类型 | Company_Type__c | | 公司类型 |
| 职位 | Position__c | | 职位 |
| 作物 | Crop__c | | 种植作物 |
| 产品线 | Product_Line__c | | 产品线 |
| 偏好产品 | Preferred_Product_Name__c | | 偏好产品 |
| 销售代表 | Sales_rep__c | | 负责销售 |
| 田地面积 | Hectares_of_Field__c | | 田地公顷数 |
| 地区 | Region__c | | 所在地区 |
| 社交媒体 | Social_Media__c | | 社交媒体账号 |

---

## 八、自动免费订单创建

### 8.1 控制器：CreateFreeOrderController

**触发时机**：市场活动 Approval_Status 变为 'Approved'

### 8.2 createFreeOrder(recordId) 方法逻辑

```apex
@AuraEnabled
public static Output createFreeOrder(String recordId) {
    // 1. 查询市场活动
    Campaign ca = [SELECT OwnerId,Ship_To__c,Approval_Status__c,Id,
                   Sales_Org__c,Delivery_Plant__c,Customer_Lookup__c,
                   Distribution_Channel__c 
                   FROM Campaign WHERE Id =:recordId];

    // 2. 校验审批状态
    if (ca.Approval_Status__c != 'Approved') {
        out.errorMsg = 'The campaign is not approved.';
        return out;
    }

    // 3. 创建免费订单 (ZFD)
    Order__c order = new Order__c();
    order.Sales_Org__c = ca.Sales_Org__c;           // 销售组织
    order.Deliver_Plant__c = ca.Delivery_Plant__c;  // 交货工厂
    order.Business_Model__c = 'C0';                 // 业务模式
    order.RecordTypeId = Model_C;                  // RecordType
    order.Campaign__c = recordId;                   // 关联活动
    order.Status__c = 'Draft';                      // 草稿状态
    order.Order_type__c = 'ZFD';                    // 免费样品订单
    order.Customer__c = ca.Customer_Lookup__c;     // 客户
    order.Currency__c = 'USD';                     // 币种
    order.Distr_Channel__c = ca.Distribution_Channel__c;
    order.Ship_To__c = ca.Ship_To__c;              // 收货方
    order.OwnerId = ca.OwnerId;                    // 活动 Owner
    order.Terms_Of_Payment__c = 'AR01';            // 付款条款
    Database.insert(order);

    // 4. 创建订单行项目
    List<Campaign_Product__c> cpList = [
        SELECT Id,Product_Name__c,Quantity__c,
               Product_Name__r.Product__r.Name,
               Product_Name__r.Name,
               Product_Unit_Lookup__c,
               Delivery_Date__c,Unit__c
        FROM Campaign_Product__c 
        WHERE Campaign__c = :recordId
        AND Product_Name__r.Product__r.Name != null
        AND Product_Name__r.Name != null
    ];

    for (Campaign_Product__c cp : cpList) {
        Order_Item__c oi = new Order_Item__c();
        oi.Order__c = order.Id;
        oi.Commodity__c = cp.Product_Name__c;
        oi.Campaign_Product__c = cp.Id;
        oi.IsCreate__c = TRUE;
        oi.Quantity__c = cp.Quantity__c;
        oi.Material_Number__c = cp.Product_Name__r.Product__r.Name;
        oi.Product_Type__c = 'Free Product';        // 产品类型：免费产品
        oi.Price__c = 0;                           // 价格：0
        oi.Sales_Unit__c = cp.Product_Unit_Lookup__c;
        oi.Delivery_Date__c = cp.Delivery_Date__c;
        // ...
        oiList.add(oi);
    }
    Database.insert(oiList);

    // 5. 自动审批订单
    order.Status__c = 'Approved';
    update order;  // 触发 SAP 同步

    return out;
}
```

### 8.3 免费订单默认配置

| 字段 | 默认值 | 说明 |
|------|--------|------|
| Order_type__c | ZFD | 免费样品订单 |
| Business_Model__c | C0 | 业务模式 |
| RecordType | Model_C | 订单类型 |
| Currency__c | USD | 美元 |
| Terms_Of_Payment__c | AR01 | 付款条款 |
| Price__c | 0 | 免费价格 |
| Product_Type__c | Free Product | 产品类型 |

---

## 九、附件校验逻辑

### 9.1 checkAttachments(recordId) 方法

**触发时机**：MKT_Approval 审批时

```apex
public static Map<String,Integer> checkAttachments(Id recordId) {
    // 1. 查询附件列表
    List<ContentDocumentLink> cdlList = [
        SELECT Id,ContentDocumentId 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :recordId
    ];

    // 2. 获取文件类型
    List<ContentDocument> attachments = [
        SELECT Id,FileType 
        FROM ContentDocument 
        WHERE Id IN :documentrecordId
    ];

    // 3. 统计图片和视频
    Set<String> imageExtensions = System.label.ImageType.split(';');
    Set<String> videoExtensions = System.Label.VideoType.split(';');

    Integer imageNumber = 0;
    Integer videoNumber = 0;

    for (ContentDocument att : attachments) {
        if (imageExtensions.contains(att.FileType.toLowerCase())) {
            imageNumber++;
        } else if (videoExtensions.contains(att.FileType.toLowerCase())) {
            videoNumber++;
        }
    }

    return new Map<String,Integer>{'image' => imageNumber, 'video' => videoNumber};
}
```

### 9.2 校验规则

| 类型 | 最少数量 | 触发条件 |
|------|---------|---------|
| 图片 | 5张 | MKT_Approval 变为 'Approving' |
| 视频 | 1个 | MKT_Approval 变为 'Approving' |

---

## 十、销售组织与币种映射

### 10.1 币种配置

| 销售组织 | 国家/地区 | 币种 |
|---------|----------|------|
| 3010/3011 | 墨西哥 | MXN |
| 3020 | 墨西哥 | MXN |
| 5070 | 阿根廷 | USD |
| 5130 | 阿根廷/YPF | USD |
| 1040/1050/1060/1080 | 中国总部 | CNY |
| 2010/2210 | 中国 | CNY |

### 10.2 参会人名单模板配置

| 销售组织 | 模板配置键 | 说明 |
|---------|-----------|------|
| 3010/3020 | Participants_List_MX | 墨西哥参会名单模板 |
| 5070/5130 | Participants_List_AR | 阿根廷参会名单模板 |

---

## 十一、接口清单

### 11.1 Campaign 模块无直接 SAP/BPM 接口

**说明**：
- 市场活动模块主要在 Salesforce 内部流转
- 审批通过后自动创建 ZFD 免费订单，由订单模块同步到 SAP
- 无独立的 Campaign 同步接口

### 11.2 关联的 SAP 接口

| 接口 | 说明 | 关联方式 |
|------|------|---------|
| OrderSyncToSAP | ZFD 订单同步到 SAP | 订单 Approval 后自动触发 |
| ZSD005_001 | 新增订单操作 | ZFD 订单使用此操作类型 |

---

## 十二、文件清单

### 12.1 Trigger 文件

| 文件路径 | 行数 | 说明 |
|---------|------|------|
| `force-app/main/default/triggers/CampaignTrigger.trigger` | 8行 | 市场活动触发器 |
| `force-app/main/default/triggers/CampaignBudgetTrigger.trigger` | 8行 | 年度预算触发器 |
| `force-app/main/default/triggers/MonthlyBudgetTrigger.trigger` | 8行 | 月度预算触发器 |
| `force-app/main/default/triggers/CampaignProductTrigger.trigger` | 8行 | 活动产品触发器 |

### 12.2 TriggerHandler 文件

| 文件路径 | 行数 | 说明 |
|---------|------|------|
| `force-app/main/default/classes/CampaignTriggerHandler.cls` | 330行 | 市场活动处理程序 |
| `force-app/main/default/classes/CampaignBudgetTriggerHandler.cls` | 27行 | 年度预算处理程序 |
| `force-app/main/default/classes/MonthlyBudgetTriggerHandler.cls` | 142行 | 月度预算处理程序 |
| `force-app/main/default/classes/CampaignProductTriggerHandler.cls` | 22行 | 活动产品处理程序 |

### 12.3 Controller 文件

| 文件路径 | 行数 | 说明 |
|---------|------|------|
| `force-app/main/default/classes/AddCampaignProductController.cls` | 345行 | 活动产品添加控制器 |
| `force-app/main/default/classes/CreateFreeOrderController.cls` | 99行 | 免费订单创建控制器 |
| `force-app/main/default/classes/BatchImportParticipantsListController.cls` | 279行 | 参会人名单批量导入 |

### 12.4 AddCampaignProductController 功能说明

**文件**：`force-app/main/default/classes/AddCampaignProductController.cls`

**用途**：LWC 组件调用，用于添加/编辑市场活动产品

**核心方法**：

| 方法 | 说明 |
|------|------|
| `initData()` | 初始化活动产品数据，判断是否免费订单 |
| `searchDataMe()` | 按销售组织搜索可添加的产品 |
| `saveData()` | 保存/更新活动产品 |

**关键逻辑**：

```apex
// initData() 中判断是否免费订单类型
if (campaign.RecordType_Name__c == 'Field_Demo' || campaign.RecordType_Name__c == 'Sample') {
    out.isFreeOrder = true;  // 田间示范/样品活动
}
```

**RecordType 与产品添加**：

| RecordType | isFreeOrder | 说明 |
|-----------|------------|------|
| **Field_Demo** | ✅ true | 田间示范产品，免费赠送 |
| **Sample** | ✅ true | 样品产品，免费赠送 |
| Offline_Campaign | ❌ false | 线下活动产品 |
| Online_Campaign | ❌ false | 线上活动产品 |

**产品查询条件**：
- 状态：`On Shelves`（上架）
- 销售组织：匹配当前活动
- 未删除：`Is_Delete__c = false`

### 12.5 Test 文件

| 文件路径 | 说明 |
|---------|------|
| `force-app/main/default/classes/CampaignTriggerHandlerTest.cls` | 市场活动测试类 |
| `force-app/main/default/classes/CampaignBudgetTriggerHandlerTest.cls` | 年度预算测试类 |
| `force-app/main/default/classes/MonthlyBudgetTriggerHandlerTest.cls` | 月度预算测试类 |
| `force-app/main/default/classes/CampaignProductTriggerHandlerTest.cls` | 活动产品测试类 |
| `force-app/main/default/classes/BatchImportParticipantsListTest.cls` | 参会人名单导入测试类 |

---

## 十三、业务流程图

### 13.1 市场活动创建流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                        市场活动创建流程                               │
└─────────────────────────────────────────────────────────────────────┘

[开始] ──▶ [填写活动信息]
              │
              ▼
        [Before Insert Trigger]
              │
              ├─▶ autoRelationBudget() - 关联月度预算
              │       │
              │       ▼
              │   有匹配月度预算? ──否──▶ [阻止创建，提示无月度预算]
              │       │
              │      是
              │       │
              ├─▶ autoChangeManager() - 填充经理信息
              │
              ├─▶ 自动设置币种 (根据销售组织)
              │
              └─▶ 默认申请人 = Owner
              
              │
              ▼
        [保存市场活动]
              │
              ▼
        [市场活动创建成功]
```

### 13.2 市场活动审批流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                        市场活动审批流程                               │
└─────────────────────────────────────────────────────────────────────┘

[开始] ──▶ [提交审批 (Approval_Status = Approving)]
              │
              ▼
        [Approval 审批通过]
              │
              ▼
        [Before Update Trigger]
              │
              ▼
        [MKT_Approval 变为 Approving?]
              │
              ├─否─────────────────────────┐
              │                              │
              │                              ▼
              │                        [End]
              │
              │是
              ▼
        [检查附件]
              │
              ▼
        [图片≥5 且 视频≥1?] ──否──▶ [阻止，提示上传附件]
              │
             是
              │
              ▼
        [After Update Trigger]
              │
              ▼
        [CreateFreeOrderController]
              │
              ├─▶ 创建 ZFD 订单
              ├─▶ 复制活动产品到订单行
              └─▶ 订单自动审批同步 SAP
              
              │
              ▼
        [更新 Monthly_Budget.Amount_Occupied__c]
              │
              ▼
        [End]
```

### 13.3 预算占用流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                        预算占用流程                                   │
└─────────────────────────────────────────────────────────────────────┘

年度预算 (Campaign_Budget__c)
      │
      │  创建年度预算
      │  设置: Sales_Org, Plant, Year, Budgeted_Amount
      │
      ▼
月度预算 (Monthly_Budget__c)
      │
      │  创建月度预算
      │  设置: Campaign_Budget, Sales_Rep, Month, Budgeted_Amount
      │
      ▼
[Trigger: 月度预算金额校验]
      │
      ▼
[月度预算 ≤ 年度剩余?] ──否──▶ [阻止，月度超出年度]
      │
     是
      │
      ▼
市场活动 (Campaign)
      │
      │  创建活动时自动关联月度预算
      │  设置: Budget__c (占用金额)
      │
      ▼
[Trigger: 活动 MKT_Approval 变为 Approved]
      │
      ▼
[更新 Monthly_Budget.Amount_Spent__c += Actual_Costs__c]
[更新 Monthly_Budget.Amount_Occupied__c -= Budget__c]
```

---

## 十四、运维注意事项

### 14.1 常见问题排查

| 问题现象 | 可能原因 | 解决方案 |
|---------|---------|---------|
| 创建活动失败，提示"无月度预算" | 月度预算不存在或条件不匹配 | 检查 Monthly_Budget__c 是否存在，匹配条件：Sales_Org + Delivery_Plant + Year + Owner + Month |
| 审批通过后未创建免费订单 | Approval_Status 变更检测失败 | 检查 Trigger 代码逻辑，确认状态变更检测 |
| 活动产品无法添加/修改 | 活动已审批 | 活动审批后锁定产品，需先取消审批 |
| 月度预算无法修改 | 新预算 < 已使用金额 | 需先处理已占用的活动 |
| MKT_Approval 审批失败 | 附件不足5张图+1个视频 | 上传足够附件后重新审批 |

### 14.2 关键配置检查点

| 配置项 | 路径 | 说明 |
|-------|------|------|
| System.Label.ImageType | 设置 → 自定义标签 | 图片文件类型列表 |
| System.Label.VideoType | 设置 → 自定义标签 | 视频文件类型列表 |
| DataImportTemplate__c.Participants_List_MX | 自定义设置 | 墨西哥参会名单模板 |
| DataImportTemplate__c.Participants_List_AR | 自定义设置 | 阿根廷参会名单模板 |
| ImportDataFieldConf__c | 自定义对象 | 参会人名单导入字段配置 |

### 14.3 性能优化建议

| 场景 | 建议 |
|------|------|
| 批量导入参会人名单 | 单次导入建议不超过1000条 |
| 月度预算校验 | 使用聚合查询计算年度已分配金额 |
| 附件统计 | 使用 ContentDocumentLink 而非直接查 ContentDocument |

---

## 十五、相关文档

- [山东润丰_Salesforce_CRM_业务逻辑文档.md](./山东润丰_Salesforce_CRM_业务逻辑文档.md) - 完整业务逻辑文档
- [Salesforce 标准对象文档](https://developer.salesforce.com/docs/atlas.en-us/sfdc/pdf/salesforce_standard_objects.pdf) - Campaign 标准对象参考
