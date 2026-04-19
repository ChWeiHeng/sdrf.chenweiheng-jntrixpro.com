/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-22-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-07-2026   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import init from '@salesforce/apex/EditContractDetailController.initOrderData';
import save from '@salesforce/apex/EditContractDetailController.saveOrderData';
//import mapProduct from '@salesforce/apex/EditContractDetailController.mapOrderProduct';
import vertifyProduct from '@salesforce/apex/EditContractDetailController.vertifyOrderProduct';
import { NavigationMixin } from 'lightning/navigation';
import ErrorMSG from '@salesforce/label/c.Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Action from '@salesforce/label/c.Action';
import FOB_Price from '@salesforce/label/c.FOB_Price';
import Net_Weight from '@salesforce/label/c.Net_Weight';
import QuoteDetail from '@salesforce/label/c.QuoteDetail';
import QuoteDetailHeader from '@salesforce/label/c.QuoteDetailHeader';
import Price_List_Name from '@salesforce/label/c.Price_List_Name';
import Search_Product from '@salesforce/label/c.Search_Product';
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
import Order_Qnty from '@salesforce/label/c.Order_Qnty';
import Product_Code from '@salesforce/label/c.Product_Code';
import FOB_Bulking_Price from '@salesforce/label/c.FOB_Bulking_Price';
import Pallet from '@salesforce/label/c.Pallet';
import Freight_Cost from '@salesforce/label/c.Freight_Cost';
import Payment_Terms from '@salesforce/label/c.Payment_Terms';
import Commission from '@salesforce/label/c.Commission';
import CIF_Price from '@salesforce/label/c.CIF_Price';
import BU_Margin_Rate from '@salesforce/label/c.BU_Margin_Rate';
import CIF_Price_Without_Margin from '@salesforce/label/c.CIF_Price_Without_Margin';
import Packing_Cost from '@salesforce/label/c.Packing_Cost';
import Packing_Size from '@salesforce/label/c.Packing_Size';
import Commission_Percent from '@salesforce/label/c.Commission_Percent';
import Currency from '@salesforce/label/c.Currency';
import Delivery_Date from '@salesforce/label/c.Delivery_Date';
import Total_Amount from '@salesforce/label/c.Total_Amount';
import Product_Name from '@salesforce/label/c.Product_Name';
import Price from '@salesforce/label/c.Price';
import Amount_per_item from '@salesforce/label/c.Amount_per_item';
import Estimated_delivery_date from '@salesforce/label/c.Estimated_delivery_date';
import ContractFieldRequired from '@salesforce/label/c.ContractFieldRequired';
import New_Quantity from '@salesforce/label/c.New_Quantity';
import New_Amount_per_item from '@salesforce/label/c.New_Amount_per_item';
import Product_English_Name from '@salesforce/label/c.Product_English_Name';
import New_Price from '@salesforce/label/c.New_Price';
import Quote_Price from '@salesforce/label/c.Quote_Price';
import Add_Order_Contract_Detail from '@salesforce/label/c.Add_Order_Contract_Detail';
import Pack_Size from '@salesforce/label/c.Pack_Size';
import Edit_Order_Contracts_Detail_Header from '@salesforce/label/c.Edit_Order_Contracts_Detail_Header';
import New_Delivery_Date from '@salesforce/label/c.New_Delivery_Date';
import Toxicity_Classification from '@salesforce/label/c.Toxicity_Classification';
export default class EditContractsOrderDetailLWC extends LightningElement {
    customLabel = {
        Toxicity_Classification,
        Sales_Unit,
        Action,
        FOB_Price,
        Net_Weight,
        QuoteDetail,
        QuoteDetailHeader,
        Price_List_Name,
        Search_Product,
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
        Order_Qnty,
        Product_Code,
        Currency,
        Delivery_Date,        
        Product_Name,
        Amount_per_item,       
        Quantity,
        Price,
        Estimated_delivery_date,
        ContractFieldRequired,
        New_Quantity,
        New_Amount_per_item,
        Product_English_Name,
        New_Price,
        Quote_Price,
        Add_Order_Contract_Detail,
        Pack_Size,
        Edit_Order_Contracts_Detail_Header,
        New_Delivery_Date

    }
    @api recordId;
    @api label;
    @track lengthData = {};
    @track isPC;
    @track isShowSpinner;
    @track deleteIdList = [];
    @track searchText = '';
    @track productItemList = [];
    @track priceListList=[];
    @track Error = ErrorMSG;
    @track cu = '';
    @track showSearchPage = false;
    @track isShowFiled = false;
    @track isShowUsage = false;
    @track iscornReq = false;
    @track quoteDetailList;
    @track isHQContract;
    @track isProductUsage;
    @track exchangeRate;
    @track paymentTermCostRate;
    @track isRetrograde;
    @track pickProductList;
    @track pickProductNameList=[];
    @track unitOption = [];
    @track productUsageOption = [];
    @track ifDesignatedProductOption = [];
    @track ifPalletOption = [];
    @track recheckMarginOption = [];
    @track isSaleContract;
    @track isBaseQuote;
    @track paymentTermCostRate;
    @track isOrderChange;
    @track isCreateOrderItem;
    @track isMX = false;
    @track toxicityList = [];
    shooMoreMe(event) {
        let index = event.target.name;
        console.log('index',index);
        this.quoteDetailList[index].quoteDetailData.Show_More__c=true;
    }

    shooLessMe(event) {
        let index = event.target.name;
        this.quoteDetailList[index].quoteDetailData.Show_More__c=false;
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
    connectedCallback() {
        console.log('进入init方法');
        // window.addEventListener('keydown', this.handleKeyDown.bind(this));
        this.lengthData.big = 'width: 300px;';
        this.lengthData.small = 'width: 50px;';
        this.lengthData.medium = 'width: 200px;';
        this.lengthData.mediumSmall = 'width: 100px;';
        this.lengthData.mediumBig = 'width: 150px;';
        this.lengthData.Commodity = '8%';
        this.lengthData.Quantity = '10%';
        this.lengthData.Price = '10%';
        this.lengthData.SalesUnit = '10%';
        this.lengthData.Amountperitem = '10%';
        this.lengthData.DeliveryDate = '10%';
        this.lengthData.Corn = '10%';
        this.lengthData.Action = '2%';
        this.lengthData.num = '5%';
        this.lengthData.grossWeight = '10%';
        this.lengthData.netWeight = '10%';
        this.lengthData.objectFlied = '10%';
        console.log('this.formFactorPropertyName',formFactorPropertyName);
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        this.isShowSpinner = true;
		init({
            orderId : this.recordId,
            type  : this.label
        }).then(result => {
            if (result.isSucess) {
                console.log('result=====>',JSON.stringify(result));
            	this.quoteDetailList = result.orderDetailList;
            	console.log('quoteDetailList=====>',JSON.stringify(this.quoteDetailList));
                let opMap = [];
                opMap.push({label: null,value: ''});
                for(let key in result.unitMap){
                    opMap.push({label: result.unitMap[key],value: key});
                }
                //opMap.push({label: 'KG',value: 'KG'});
                //opMap.push({label: 'L',value: 'L'});
                this.unitOption = opMap;
                let opMap1 = [];
                opMap1.push({label: null,value: ''});
                for(let key in result.productUsageMap){
                    opMap1.push({label: result.productUsageMap[key],value: key});
                }
                this.productUsageOption = opMap1;
                this.isOrderChange = this.label === 'Order Change';
                console.log('isOrderChange',this.isOrderChange);
                this.isCreateOrderItem=result.isCreateOrderItem;
                console.log('isCreateOrderItem',this.isCreateOrderItem);
                this.isProductUsage=result.isProductUsage;
                console.log('isProductUsage',this.isProductUsage);       
                this.isMX = result.isMX;
                this.toxicityList = result.toxicityList;
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

    // disconnectedCallback() {
    //     // Remove event listener when component is destroyed
    //     window.removeEventListener('keydown', this.handleKeyDown.bind(this));
    // }

    // handleKeyDown(event) {
    //     if (event.key === 'Tab') {
    //         event.preventDefault();
    //     }
    // }

    close(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    addProduct(event) {
        let item = {};   
        item.Order__c=  this.recordId;
        item.SAP_Item_Num__c=this.quoteDetailList.length*10+10;
        let conDetail = {};
        conDetail.ordDetailData = item;
        conDetail.index=this.quoteDetailList.length;
        console.log('conDetail:'+JSON.stringify(conDetail));
        this.quoteDetailList.push(conDetail);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Add Success',
            variant: 'Success',
        }));
    }
    mapProductChange(event){
        let currenRecord;
        currenRecord=event.currentTarget.dataset.record;
        this.quoteDetailList[event.currentTarget.dataset.record].ordDetailData[event.target.name] = event.target.value;
        /*if(this.quoteDetailList[event.currentTarget.dataset.record].ordDetailData.Product__c && this.quoteDetailList[event.currentTarget.dataset.record].ordDetailData.Commodity__c)
        {
            this.isShowSpinner = true;
            mapProduct({
                productId : this.quoteDetailList[event.currentTarget.dataset.record].ordDetailData.Product__c,
                orderId : this.recordId,
                commodityId : this.quoteDetailList[event.currentTarget.dataset.record].ordDetailData.Commodity__c
            }).then(result => {
                console.log('方法调用了',JSON.stringify(result));
                if (result.isSucess) {
                    console.log('进入if');
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    this.quoteDetailList[currenRecord].ordDetailData.Commodity__c=null;
                    
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.customLabel.LWC_Data_Translate_171 + error.body,
                    variant: 'error',
                }));
            }); 
        }*/
    }

    vertifyProduct(event){
        let currenRecord;
        currenRecord=event.currentTarget.dataset.record;
        this.quoteDetailList[currenRecord].ordDetailData[event.target.name] = event.target.value;
        if(this.quoteDetailList[currenRecord].ordDetailData.Product__c)
        {
            this.isShowSpinner = true;
            vertifyProduct({
                productId : this.quoteDetailList[currenRecord].ordDetailData.Product__c,
                orderId : this.recordId
            }).then(result => {
                console.log('方法调用了',JSON.stringify(result));
                if (result.isSucess) {
                    this.quoteDetailList[currenRecord].proNameList=result.proNameList;
                    this.quoteDetailList[currenRecord].proUnitList=result.proUnitList;
                    console.log('进入if');  
                    console.log('this.quoteDetailList[currenRecord].proNameList',this.quoteDetailList[currenRecord].proNameList);                  
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    this.quoteDetailList[currenRecord].ordDetailData.Commodity__c = null;
                    this.quoteDetailList[currenRecord].ordDetailData.Sales_Unit_Text__c = null;
                    let opMap = [];
                    opMap.push({label: '',value: ''});
                    this.quoteDetailList[currenRecord].proNameList = opMap;
                     let opMap1 = [];
                    opMap1.push({label: '',value: ''});
                    this.quoteDetailList[currenRecord].proUnitList = opMap1;
                   
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.customLabel.LWC_Data_Translate_171 + error.body,
                    variant: 'error',
                }));
            }); 
        }else{
            let opMap = [];
            opMap.push({label: '',value: ''});
            this.quoteDetailList[currenRecord].proNameList = opMap;
             let opMap1 = [];
            opMap1.push({label: '',value: ''});
            this.quoteDetailList[currenRecord].proUnitList = opMap1;
            this.quoteDetailList[currenRecord].ordDetailData.Commodity__c = null;
            this.quoteDetailList[currenRecord].ordDetailData.Sales_Unit_Text__c = null;
        }
    }

    deleteDetailData(event) {
        let index = event.currentTarget.dataset.record;
        if (this.quoteDetailList[index].ordDetailData.Id) 
        {
            this.deleteIdList.push(this.quoteDetailList[index].ordDetailData.Id);
        }
        this.quoteDetailList.splice(index,1);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Delete Success',
            variant: 'Success',
        }));
    }

    copyData(event) {
        let index = event.currentTarget.dataset.record;
        //let copyData = this.quoteDetailList[index];
        let copyData = JSON.parse(JSON.stringify(this.quoteDetailList[index]));
        copyData.ordDetailData.Id=null;
        copyData.ordDetailData.SAP_Item_Num__c=this.quoteDetailList.length*10+10;
        copyData.index=this.quoteDetailList.length;
        this.quoteDetailList.push(copyData);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Copy Success',
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
        let allValid3 = true;
        this.template.querySelectorAll('lightning-select').forEach(element => {
            if(!element.reportValidity()){
                allValid3 = false;
            }
        });
         let allValid4 = true;
        this.template.querySelectorAll('input').forEach(element => {
            if(!element.reportValidity()){
                allValid4 = false;
            }
        });
        if(!allValid1 || !allValid2 || !allValid3 || !allValid4) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                //message: 'Input Required',
                message: this.customLabel.ContractFieldRequired,
                variant: 'error',
            }));

            return;
        }
        this.isShowSpinner = true;
        console.log('this.quoteDetailList'+JSON.stringify(this.quoteDetailList));
        save({
            ordDetailList : this.quoteDetailList,
            deleteList : this.deleteIdList,
            isOrderChange :this.isOrderChange,
            orderId : this.recordId
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

     //水平方向滚动
    // tableOuterDivScrolled(event) {
    //     this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
    //     if (this._tableViewInnerDiv) {
    //         if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
    //             this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
    //         }
    //         this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth+10) + "px;height:380px;" + this.tableBodyStyle;
    //     }

    //     this._tableViewInnerDiv1 = this.template.querySelector(".tableViewInnerDiv1");
    //     if (this._tableViewInnerDiv1) {
    //         if (!this._tableViewInnerDiv1OffsetWidth || this._tableViewInnerDiv1OffsetWidth === 0) {
    //             this._tableViewInnerDiv1OffsetWidth = this._tableViewInnerDiv1.offsetWidth;
    //         }
    //         this._tableViewInnerDiv1.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDiv1OffsetWidth+10) + "px;height:380px;" + this.tableBodyStyle;
    //     }
    // }

    productChange(event) {
        let index = event.currentTarget.dataset.record;
        let filedName = event.target.name;
        console.log("index:",index);
        console.log("filedName:",filedName);
        console.log("event.target.value:",event.target.value);
        this.quoteDetailList[index].ordDetailData[filedName]=event.target.value;
        if(this.isOrderChange)
        {
            if(this.quoteDetailList[index].ordDetailData.New_Quantity__c && this.quoteDetailList[index].ordDetailData.New_Price__c)
            {
                this.quoteDetailList[index].ordDetailData.New_Amount__c=parseFloat(this.quoteDetailList[index].ordDetailData.New_Quantity__c*this.quoteDetailList[index].ordDetailData.New_Price__c).toFixed(5);
            }
            else if(this.quoteDetailList[index].ordDetailData.Quantity__c && this.quoteDetailList[index].ordDetailData.New_Price__c)
            {
                this.quoteDetailList[index].ordDetailData.New_Amount__c=parseFloat(this.quoteDetailList[index].ordDetailData.Quantity__c*this.quoteDetailList[index].ordDetailData.New_Price__c).toFixed(5);
            }else if(this.quoteDetailList[index].ordDetailData.New_Quantity__c && this.quoteDetailList[index].ordDetailData.Price__c)
            {
                this.quoteDetailList[index].ordDetailData.New_Amount__c=parseFloat(this.quoteDetailList[index].ordDetailData.New_Quantity__c*this.quoteDetailList[index].ordDetailData.Price__c).toFixed(5);
            }else
            {
                this.quoteDetailList[index].ordDetailData.New_Amount__c=null;
            }
        }
        else
        {
            if(this.quoteDetailList[index].ordDetailData.Quantity__c && this.quoteDetailList[index].ordDetailData.Price__c)
            {
                this.quoteDetailList[index].ordDetailData.Amount_per_item__c=parseFloat(this.quoteDetailList[index].ordDetailData.Quantity__c*this.quoteDetailList[index].ordDetailData.Price__c).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].ordDetailData.Amount_per_item__c=null;
            }
        }
        
        console.log('this.quoteDetailList[index]'+JSON.stringify(this.quoteDetailList[index]));
    }

}