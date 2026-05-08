/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 05-08-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-29-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import init from '@salesforce/apex/AddOrderItemController.initData';
import save from '@salesforce/apex/AddOrderItemController.saveData';
import search from '@salesforce/apex/AddOrderItemController.searchDataMe';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Action from '@salesforce/label/c.Action';
import Amount_per_item from '@salesforce/label/c.Amount_per_item';
import Approving_Inventory from '@salesforce/label/c.Approving_Inventory';
import Available_Inventory from '@salesforce/label/c.Available_Inventory';
import Basic_Unit from '@salesforce/label/c.Basic_Unit';
import Delivery_Date from '@salesforce/label/c.Delivery_Date';
import Gross_Weight from '@salesforce/label/c.Gross_Weight';
import Material_Code from '@salesforce/label/c.Material_Code';
import Net_Weight from '@salesforce/label/c.Net_Weight';
import OrderItem from '@salesforce/label/c.OrderItem';
import OrderItemHeader from '@salesforce/label/c.OrderItemHeader';
import Place_order from '@salesforce/label/c.Place_order';
import Price from '@salesforce/label/c.Price';
import ProductNameOrderItem from '@salesforce/label/c.ProductNameOrderItem';
import Search from '@salesforce/label/c.Search';
import Search_Result from '@salesforce/label/c.Search_Result';
import searchText from '@salesforce/label/c.searchText';
import Show_Less from '@salesforce/label/c.Show_Less';
import Show_More from '@salesforce/label/c.Show_More';
import CancelLable from '@salesforce/label/c.CancelLable';
import ConfirmLabel from '@salesforce/label/c.ConfirmLabel';
import Quantity from '@salesforce/label/c.Quantity';
import Sales_Unit  from '@salesforce/label/c.Sales_Unit';
import FillUpOrder  from '@salesforce/label/c.FillUpOrder';
import FillUpOrderCreateDate  from '@salesforce/label/c.FillUpOrderCreateDate';
import Local_Currency  from '@salesforce/label/c.Local_Currency';
import Material_Descriptio from '@salesforce/label/c.Material_Descriptio';
import productDescription from '@salesforce/label/c.productDescription';
import Corn from '@salesforce/label/c.Corn';
import Product_Usage from '@salesforce/label/c.Product_Usage';
import productCost from '@salesforce/label/c.productCost';
import MarginRate from '@salesforce/label/c.MarginRate';
import Inventory from '@salesforce/label/c.Inventory';
import OrderFieldRequired from '@salesforce/label/c.OrderFieldRequired';
import OrderDeliveryDateRequired from '@salesforce/label/c.OrderDeliveryDateRequired';
import OrderSalesUnitRequired from '@salesforce/label/c.OrderSalesUnitRequired';
import OrderPriceQuantityVertify from '@salesforce/label/c.OrderPriceQuantityVertify';
import Product_Type from '@salesforce/label/c.Product_Type';
import Commission_Calculation_Method from '@salesforce/label/c.Commission_Calculation_Method';
import Commission_Rate from '@salesforce/label/c.Commission_Rate';
import Commission_Amount from '@salesforce/label/c.Commission_Amount';
import CashPrice from '@salesforce/label/c.CashPrice';
import invoiceItemNumber from '@salesforce/label/c.InvoiceItemNumber';
import ZAREOrderNumber from '@salesforce/label/c.ZAREOrderNumber';
import Delivery_Note_Number from '@salesforce/label/c.Delivery_Note_Number';
import Product_Code from '@salesforce/label/c.Product_Code';
import Toxicity_Classification from '@salesforce/label/c.Toxicity_Classification';
import FECHA_DE_PAGO from '@salesforce/label/c.FECHA_DE_PAGO';
import FECHA_DE_VENCIMIENTO from '@salesforce/label/c.FECHA_DE_VENCIMIENTO';
export default class AddOrderItemLWC extends LightningElement {
    customLabel = {
        FECHA_DE_VENCIMIENTO,
        FECHA_DE_PAGO,
        Toxicity_Classification,
        Product_Code,
        Delivery_Note_Number,
        ZAREOrderNumber,
        invoiceItemNumber,
        CashPrice,
        Commission_Amount,
        Commission_Rate,
        Commission_Calculation_Method,
        Inventory,
        productCost,
        MarginRate,
        Sales_Unit,
        Quantity,
        Action,
        Amount_per_item,
        Approving_Inventory,
        Available_Inventory,
        Basic_Unit,
        Delivery_Date,
        Gross_Weight,
        Material_Code,
        Net_Weight,
        OrderItem,
        OrderItemHeader,
        Place_order,
        Price,
        ProductNameOrderItem,
        Search,
        Search_Result,
        searchText,
        Show_Less,
        Show_More,
        CancelLable,
        ConfirmLabel,
        FillUpOrder,
        FillUpOrderCreateDate,
        Local_Currency,
        Material_Descriptio,
        productDescription,
        Corn,
        Product_Usage,
        OrderFieldRequired,
        OrderDeliveryDateRequired,
        OrderSalesUnitRequired,
        OrderPriceQuantityVertify,
        Product_Type

    }
    @api recordId;
    @track lengthData = {};
    @track isPC;
    @track isShowSpinner;
    @track deleteIdList = [];
    @track searchText = '';
    @track productItemList = [];
    @track Error = ErrorMSG;
    @track cu = '';
    @track showSearchPage = false;
    @track isShowFiled = false;
    @track isShowUsage = false;
    @track iscornReq = false;
    @track disableAction = false;
    @track isYPF = false;
    @track isAutoZAR1 = false;
    @track inList = [];
    @track showCommission;
    @track interestRate;
    @track showCashPrice;
    @track isZAR2;
    @track isZARF;
    @track needPaymentTerm;//单价是否需要含账期
    @track isCreditNote = false;
    @track isMX = false;
    @track toxicityList = [];
    @track isZFD = false;
    @track isNotShowSearch = false;
    @track isFROMInvoice = false;
    @track isReturnOrder = false;
    @track orderItemList = [{
        Commodity__c: "a0QD600000DmGI9MAN",
        Quantity__c: "1",
        Price__c: "1",
        Sales_Unit__c: "a0OD60000071QTuMAM",
        Amount_per_item__c: "111",
        Delivery_Date__c: null
    },{
        Commodity__c: "a0QD600000DmGI9MAN",
        Quantity__c: "1",
        Price__c: "1",
        Sales_Unit__c: "a0OD60000071QTuMAM",
        Amount_per_item__c: "111",
        Delivery_Date__c: null
    }];
    @track commissionTypeOptions = [
        { label: 'None', value: '' },
        { label: 'Percent', value: 'Percent' },
        { label: 'Amount', value: 'Amount' }
    ];
    shooMoreMe(event) {
        let index = event.target.name;
        console.log('index',index);
        this.orderItemList[index].orderItemData.Show_More__c=true;
    }

    shooLessMe(event) {
        let index = event.target.name;
        this.orderItemList[index].orderItemData.Show_More__c=false;
    }

    showSearch() {
        this.showSearchPage = true;
    }

    cancelAddPage() {
        this.showSearchPage = false;
    }

    textChange(event) {
        this.searchText = event.target.value;
    }
    
    commissionTypeChange(event) {
        const index = event.target.dataset.record;
        const value = event.detail.value;
        let item = this.orderItemList[index].orderItemData;
        item.Commission_Calculation_Method__c = value;
        if (value === 'Percent') {
            item.Commission_Amount__c = '';
            item.Commission_Rate__c = '';
            this.orderItemList[index].showPercentage = true;
            this.orderItemList[index].showCommissionAmount = false;
        } else if (value === 'Amount') {
            item.Commission_Rate__c = '';
            item.Commission_Amount__c = '';
            this.orderItemList[index].showPercentage = false;
            this.orderItemList[index].showCommissionAmount = true;
        }else{
            this.orderItemList[index].showPercentage = false;
            this.orderItemList[index].showCommissionAmount = false;
        }
        this.orderItemList = [...this.orderItemList];
    }
    
    commissionRateChange(event) {
        const index = event.target.dataset.record;
        const value = parseFloat(event.target.value) || 0;
        console.log('value=====>'+value);
        let item = this.orderItemList[index].orderItemData;
        item.Commission_Rate__c = parseFloat(value);
        console.log('value1=====>'+value);
        // 行总金额字段为 Amount_per_item__c
        const total = parseFloat(item.Amount_per_item__c) || 0;
        console.log('value2=====>'+((total * value)/100).toFixed(2));
        item.Commission_Amount__c = parseFloat(((total * value)/100).toFixed(2));
        
        // 实时计算Cash Price
        this.calculateCashPrice(index);
        
        // console.log('Commission_Amount__c====>'+Commission_Amount__c);
        this.orderItemList = [...this.orderItemList];
    }
    
    commissionAmountChange(event) {
        const index = event.target.dataset.record;
        const value = parseFloat(event.target.value) || 0;
        let item = this.orderItemList[index].orderItemData;
        item.Commission_Amount__c = parseFloat(value);
        const total = parseFloat(item.Amount_per_item__c) || 0;
        item.Commission_Rate__c = parseFloat(((total ? ((value / total)) : 0)*100).toFixed(2));
        
        // 实时计算Cash Price
        this.calculateCashPrice(index);
        
        this.orderItemList = [...this.orderItemList];
    }
    queryData() {
        console.log('queryData:',this.searchText);
        // if(!this.searchText) {
        //     console.log('queryData1:');
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: 'Fill the search text',
        //         variant: 'error',
        //     })); 
        //     console.log('queryData2:');
        // }else{
            console.log('queryData3:');
            this.isShowSpinner = true;
            search({
                orderRecordId : this.recordId,
                searchData : this.searchText
            }).then(result => {
                if (result.isSucess) {
                    this.productItemList = [];
                    this.productItemList = result.productNameList;
                    console.log('this.productItemList',JSON.stringify(this.productItemList));
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));    
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.Error+';'+JSON.stringify(error) ,
                    variant: 'error',
                }));
            });
        // }
    }
    connectedCallback() {
        this.lengthData.big = 'width: 300px;';
        this.lengthData.small = 'width: 50px;';
        this.lengthData.medium = 'width: 200px;';
        this.lengthData.mediumSmall = 'width: 100px;';
        this.lengthData.mediumBig = 'width: 150px;';
        this.lengthData.num = '4%';
        this.lengthData.Commodity = '9%';
        this.lengthData.Quantity = '8%';
        this.lengthData.Price = '8%';
        // this.lengthData.cost = '8%';
        this.lengthData.SalesUnit = '6%';
        this.lengthData.Amountperitem = '8%';
        // this.lengthData.MarginRate = '6%';
        this.lengthData.DeliveryDate = '9%';
        this.lengthData.Corn = '8%';
        this.lengthData.Inventory = '8%';
        this.lengthData.grossWeight = '8%';
        this.lengthData.netWeight = '8%';
        this.lengthData.Action = '5%';
        this.lengthData.Usage = '8%';
        console.log('this.formFactorPropertyName',formFactorPropertyName);
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        this.isShowSpinner = true;
		init({
            orderRecordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.isReturnOrder = result.isReturnOrder;
                this.isFROMInvoice = result.isFROMInvoice;
                this.isNotShowSearch = result.isNotShowSearch;
                this.isZFD = result.isZFD;
                console.log('result=====>',JSON.stringify(result));
                this.needPaymentTerm = result.needPaymentTerm;
                this.isZAR2 = result.isZAR2;
                this.isZARF = result.isZARF;
                this.showCommission = result.showCommission;
                this.showCashPrice = result.showCashPrice;
                this.interestRate = result.interestRate;
            	this.orderItemList = result.orderItemList;
                this.cu = result.cuCode;
                this.isShowFiled = result.isConsignmentShipment;
                this.isShowUsage = result.showProductusage;
                this.iscornReq = result.cornReq;
                this.disableAction = result.action;
                this.isYPF = result.isYPF;
                this.isAutoZAR1 = result.isAutoZAR1;
                this.inList = result.inventoryList;
                this.isMX = result.isMX;
                this.toxicityList = result.toxicityList;
                this.isCreditNote = result.isCreditNote;
                // if(this.isShowUsage) {
                //     this.lengthData.Usage = '9%';
                // }
                console.log('isMX===========>',this.isMX);
                this.productItemList = result.productNameList;
                console.log('this.orderItemList',JSON.stringify(this.orderItemList));
                // console.log('========>',this.orderItemList[0].orderItemData.Commodity__c);
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.Error+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
    }

    close(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    selectChange(event) {
        let product = this.productItemList[event.currentTarget.dataset.record];
        console.log(product.salesUnitValue);
        console.log('product:'+JSON.stringify(product));
        let item = {
            Commodity__c: product.productNameId,
            Quantity__c: null,
            Price__c: product.Price,
            Sales_Unit__c: product.salesUnitValue,
            Amount_per_item__c: null,
            Delivery_Date__c: null,
            Order__c : this.recordId,
            Material_Description__c : product.productName,
            Price_Book_Item__c:product.priceBookItem,
            Product_Usage__c : 'Crop using',
            Product_Cost__c : product.cost,
            Invoice_Item__c:product.invoiceItemId,
            Invoice_Item_Number__c:product.invoiceItemNumber,
            ZARE_Order_Number__c:product.oldCode,
            Delivery_Note_Number__c:product.deliveryNoteNumber,
            Material_Number__c:product.materialCode
        };
        if(this.isFROMInvoice) {
            item.FECHA_DE_PAGO__c = product.FECHA_DE_PAGO;
            item.Invoice_Amount_Number__c = product.amount;
        }
        if(this.isCreditNote) {
            item.Quantity__c = 1;
            item.Amount_per_item__c = item.Quantity__c*item.Price__c;
        }
        if(product.deliveryNoteId) {
            item.Delivery_Note__c = product.deliveryNoteId;
        }

        if(product.zareDeliveryNoteId) {
            item.ZARE_Delivery_Note__c = product.zareDeliveryNoteId;
        }

        if(this.isZFD) {
            item.Product_Type__c = 'Free Product';
        }

        //unitPrice 需要含账期 ----start
        if(this.needPaymentTerm) {
            item.Price__c = item.Price__c*this.interestRate;
        }

        //unitPrice 需要含账期 ----end
                    
        if(this.isShowFiled) {
            // item.Fill_UP_Quantity__c = product.quantity;
            // item.Fill_UP_Send_Back__c = product.addNum;
            // item.Fill_UP_Return_Goods__c = product.retrunNum;
            // item.Fill_UP_Used_Num__c = product.usedNum;
        }
        if(product.refeOrderItemId) {
            item.Reference_Order_Item__c = product.refeOrderItemId;
        }
        if(product.orderItemId) {
            item.Depend_On_Item__c = product.orderItemId;
        }
        if(product.salesUnit) {
            item.Sales_Unit__c = product.salesUnit;
        }
        let orderItem = {};
        orderItem.indexNum = (this.orderItemList.length+1)*10+'';
        orderItem.orderItemData = item;
        orderItem.orderItemData.SAP_Item_Num__c = orderItem.indexNum;
        orderItem.opList = this.productItemList[event.currentTarget.dataset.record].opList;
        // console.log(orderItem.opList);
        this.orderItemList.push(orderItem);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Add Success',
            variant: 'Success',
        }));
    }

    deleteDetailData(event) {
        let index = event.currentTarget.dataset.record;
        console.log('this.orderItemList[index].Id',this.orderItemList[index].orderItemData.Id);
        if (this.orderItemList[index].orderItemData.Id) {
			this.deleteIdList.push(this.orderItemList[index].orderItemData.Id);
		}
        this.orderItemList.splice(index, 1);

        for (let index = 0; index < this.orderItemList.length; index++) {
            this.orderItemList[index].indexNum = (index+1)*10+'';
            this.orderItemList[index].orderItemData.SAP_Item_Num__c = this.orderItemList[index].indexNum;
        }
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Delete Success',
            variant: 'Success',
        }));
    }

    confirmData() {
        let allValid2 = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(!element.reportValidity()){
                allValid2 = false;
            }
        });
        let allValid1 = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                allValid1 = false;
            }
        });
        if(!allValid1 || !allValid2) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Input Required',//订单交付日期必填
                message: this.customLabel.OrderFieldRequired,
                variant: 'error',
            }));
            return;
        }
        for (let index = 0; index < this.orderItemList.length; index++) {
            if (!this.orderItemList[index].orderItemData.Delivery_Date__c && !this.isCreditNote) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    //message: 'Delivery Date Required',//订单交付日期必填
                    message: this.customLabel.OrderDeliveryDateRequired,
                    variant: 'error',
                }));
                return;
            }

            if (!this.orderItemList[index].orderItemData.Sales_Unit__c) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    //message: 'Sales Unit Required',//订单交付日期必填
                    message: this.customLabel.OrderSalesUnitRequired,
                    variant: 'error',
                }));
                return;
            }

            if (this.orderItemList[index].orderItemData.Quantity__c<=0 || this.orderItemList[index].orderItemData.Price__c<0) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    //message: 'Quantity and price can not be negative',//订单交付日期必填
                    message: this.customLabel.OrderPriceQuantityVertify,
                    variant: 'error',
                }));
                return;
            }
        }
        this.isShowSpinner = true;
        console.log('this.orderItemList'+JSON.stringify(this.orderItemList));
        save({
            orderItemListData : this.orderItemList,
            deleteList : this.deleteIdList
        }).then(result => {
            if (result.isSucess) {
            	this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'Success',
                }));
                this.dispatchEvent(new CustomEvent('refreshview'));
                this.dispatchEvent(new CustomEvent('closemodal'));
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.Error+';'+JSON.stringify(error),
                variant: 'error',
            }));
        });
    }

    productChange(event) {
        let index = event.currentTarget.dataset.record;
        let filedName = event.target.name;
        console.log("index:",index);
        console.log("filedName:",filedName);
        if(filedName==='Price__c' || filedName==='Quantity__c') {
            this.orderItemList[index].orderItemData[filedName] = event.target.value*1;
        }else{
            this.orderItemList[index].orderItemData[filedName] = event.target.value;
        }

        if (filedName === 'FECHA_DE_VENCIMIENTO__c') {
            const fechaPago = this.orderItemList[index].orderItemData.FECHA_DE_PAGO__c;
            const fechaVenc = this.orderItemList[index].orderItemData.FECHA_DE_VENCIMIENTO__c;

            // 仅当两个日期都有值时才计算
            if (fechaPago && fechaVenc) {
                // 兼容 YYYY-MM-DD 与 Date/Datetime 字符串
                const start = new Date(fechaVenc);
                const end = new Date(fechaPago);

                if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
                    // 计算自然日差：向下取整
                    const msPerDay = 24 * 60 * 60 * 1000;
                    const diffMs = end.getTime() - start.getTime();
                    const days = Math.floor(diffMs / msPerDay);

                    console.log('days=====>'+days);

                    const invoiceAmt = parseFloat(this.orderItemList[index].orderItemData.Invoice_Amount_Number__c) || 0;

                    // 若允许负天数，直接使用 days；若不允许负数，可用 Math.max(days, 0)
                    const price = (invoiceAmt * (days / 30 / 100));
                    this.orderItemList[index].orderItemData.Price__c = parseFloat(price.toFixed(2));
                } else {
                    // 日期无法解析时，避免 NaN 污染
                    this.orderItemList[index].orderItemData.Price__c = null;
                }
            } else {
                // 缺少任一日期，不计算
                this.orderItemList[index].orderItemData.Price__c = null;
            }
        }
        
        if(this.orderItemList[index].orderItemData.Price__c && this.orderItemList[index].orderItemData.Quantity__c) {
            this.orderItemList[index].orderItemData.Amount_per_item__c = parseFloat(this.orderItemList[index].orderItemData.Price__c) * parseFloat(this.orderItemList[index].orderItemData.Quantity__c);
        }else{
            this.orderItemList[index].orderItemData.Amount_per_item__c = null;
        }

        

        if(this.orderItemList[index].orderItemData.Price__c && this.orderItemList[index].orderItemData.Product_Cost__c) {
            this.orderItemList[index].orderItemData.Margin__c = parseFloat(this.orderItemList[index].orderItemData.Price__c) - parseFloat(this.orderItemList[index].orderItemData.Product_Cost__c);
            this.orderItemList[index].orderItemData.Margin_Rate__c = (parseFloat(this.orderItemList[index].orderItemData.Price__c) - parseFloat(this.orderItemList[index].orderItemData.Product_Cost__c))*100/parseFloat(this.orderItemList[index].orderItemData.Price__c);
        }else{
            this.orderItemList[index].orderItemData.Margin__c = null;
            this.orderItemList[index].orderItemData.Margin_Rate__c = null;
        }

        if(this.orderItemList[index].orderItemData.Commission_Calculation_Method__c == 'Percent') {
            const total = parseFloat(this.orderItemList[index].orderItemData.Amount_per_item__c) || 0;
            console.log('value2=====>'+((total * this.orderItemList[index].orderItemData.Commission_Rate__c)/100).toFixed(2));
            this.orderItemList[index].orderItemData.Commission_Amount__c = parseFloat(((total * this.orderItemList[index].orderItemData.Commission_Rate__c)/100).toFixed(2));
           
        }

        if(this.orderItemList[index].orderItemData.Commission_Calculation_Method__c == 'Amount') {
            console.log('进入逻辑1');
            const total = parseFloat(this.orderItemList[index].orderItemData.Amount_per_item__c) || 0;
            this.orderItemList[index].orderItemData.Commission_Rate__c = parseFloat(((total ? ((this.orderItemList[index].orderItemData.Commission_Amount__c/ total)) : 0)*100).toFixed(2));
            console.log('进入逻辑2');
        }
        // 实时计算Cash Price
        this.calculateCashPrice(index);
        console.log('this.orderItemList[index]'+JSON.stringify(this.orderItemList[index]));
    }

    // 计算Cash Price的方法
    calculateCashPrice(index) {
        const item = this.orderItemList[index].orderItemData;
        const price = parseFloat(item.Price__c) || 0;
        const commissionRate = parseFloat(item.Commission_Rate__c) || 0;
        
        // 计算公式: (price - price * Commission_Rate__c)/Intereste Rate
        const cashPrice = ((price - (price * commissionRate/100))/this.interestRate).toFixed(2);
        item.Cash_Price__c = parseFloat(cashPrice);
    }

    
}