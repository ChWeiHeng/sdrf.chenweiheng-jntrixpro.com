/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-07-2026
 * @last modified by  : Gerry 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-07-2026   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import init from '@salesforce/apex/AddQuoteDetailController.initData';
import save from '@salesforce/apex/AddQuoteDetailController.saveData';
import search from '@salesforce/apex/AddQuoteDetailController.searchDataMe';
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
import Product from '@salesforce/label/c.Product';
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
import Unit from '@salesforce/label/c.Unit';
import Delivery_Time from '@salesforce/label/c.Delivery_Time';
import Contract_Processing_Product_Name from '@salesforce/label/c.Contract_Processing_Product_Name';
import Quote_Product_Name from '@salesforce/label/c.Quote_Product_Name';
import Inland_Cost_Including_Insurance from '@salesforce/label/c.Inland_Cost_Including_Insurance';
import Clearance_Cost_Percentage from '@salesforce/label/c.Clearance_Cost_Percentage';
import CIF_Price_Include_Commission from '@salesforce/label/c.CIF_Price_Include_Commission';
import Contract_Processing_Product from '@salesforce/label/c.Contract_Processing_Product';
import Cost from '@salesforce/label/c.Cost';
import Processing_Cost from '@salesforce/label/c.Processing_Cost';
export default class AddQuoteDetailLWC extends LightningElement {
    customLabel = {
        Sales_Unit,
        Quantity,
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
        Product,
        FOB_Bulking_Price,
        Packing_Cost,
        Pallet,
        Freight_Cost,
        Payment_Terms,
        Commission,
        CIF_Price,
        BU_Margin_Rate,
        CIF_Price_Without_Margin,
        Packing_Size,
        Commission_Percent,
        Currency,
        Unit,
        Delivery_Time,
        Contract_Processing_Product_Name,
        Quote_Product_Name,
        Inland_Cost_Including_Insurance,
        Clearance_Cost_Percentage,
        CIF_Price_Include_Commission,
        Contract_Processing_Product,
        Cost,
        Processing_Cost
    }
    @api recordId;
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
    @track isHQSubClient;
    @track exchangeRate;
    @track paymentTermCostRate;
    @track isRetrograde;
    @track pickProductList;
    @track pickProductNameList=[];
    @track unit = [];
    @track isMXDAPORDDP = false;
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
                searchData : this.searchText,
                isHQSubClient : this.isHQSubClient
            }).then(result => {
                if (result.isSucess) {
                    this.priceListList = [];
                    this.priceListList = result.priceListList;
                    console.log('this.priceListList',JSON.stringify(this.priceListList));
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
        console.log('进入init方法');
        window.addEventListener('keydown', this.handleKeyDown.bind(this));
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
            quoteRecordId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                this.isMXDAPORDDP = result.isMXDAPORDDP;
                console.log('result=====>',JSON.stringify(result));
            	//this.orderItemList = result.orderItemList;
            	this.quoteDetailList = result.quoteDetailList;
            	this.priceListList= result.priceListList;
                this.isHQSubClient=result.isHQSubClient;
                console.log('this.isHQSubClient=====>',this.isHQSubClient);
                this.exchangeRate=result.exchangeRate;
                console.log('this.exchangeRate=====>',this.exchangeRate);
                this.paymentTermCostRate=result.paymentTermCostRate;
                console.log('this.paymentTermCostRate=====>',this.paymentTermCostRate);
                this.isRetrograde=result.isRetrograde;
                console.log('this.isRetrograde=====>',this.isRetrograde);
                this.pickProductList= result.productNameList;
                console.log('this.pickProductList=====>',JSON.stringify(this.pickProductList));
                let opMap = [];
                opMap.push({label: null,value: null});
                opMap.push({label: 'KG' ,value: 'KG'});
                opMap.push({label: 'L',value: 'L'});
                this.unitOption = opMap;

                
                /*this.cu = result.cuCode;
                this.isShowFiled = result.isConsignmentShipment;
                this.isShowUsage = result.showProductusage;
                this.iscornReq = result.cornReq;
                if(this.isShowUsage) {
                    this.lengthData.Corn = '8%';
                    this.lengthData.Usage = '9%';
                    this.lengthData.grossWeight = '7%';
                    this.lengthData.netWeight = '7%';
                    this.lengthData.SalesUnit = '9%';
                }
                console.log('cu===========>',this.cu);*/
                //this.productItemList = result.productNameList;
                //console.log('this.orderItemList',JSON.stringify(this.orderItemList));
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
    disconnectedCallback() {
        // Remove event listener when component is destroyed
        window.removeEventListener('keydown', this.handleKeyDown.bind(this));
    }

    handleKeyDown(event) {
        if (event.key === 'Tab') {
            event.preventDefault();
        }
    }

    close(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    addProduct(event) {
        let item = {};   
        item.Quote__c=  this.recordId;
        item.Is_Hand_Add__c=true;
        item.Payment_Terms__c=this.paymentTermCostRate;         
        let quoteDetail = {};
        quoteDetail.quoteDetailData = item;
        quoteDetail.isNotEdit=false;
        console.log('quoteDetail:'+JSON.stringify(quoteDetail));
        this.quoteDetailList.push(quoteDetail);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Add Success',
            variant: 'Success',
        }));
    }

    selectChange(event) {
        if(this.isHQSubClient)
        {
            let product = this.priceListList[event.currentTarget.dataset.record];
            // for (var i = 0; i < this.pickProductList.length; i++) 
            // {
            //     if(product.priceListData.Id===this.pickProductList[i])
            //     {
            //         this.dispatchEvent(new ShowToastEvent({
            //         title: 'error',
            //         message: 'This Product Already Added ',
            //         variant: 'error',
            //         }));
            //         return ;
            //     }
            // }
            //console.log('product:'+JSON.stringify(product));
            let item = {}; 
            item.Price_List__c=  product.priceListData.Id;
            item.Quote_Product_Name__c=product.priceListData.Name;
            item.Unit__c=product.priceListData.Unit__c; 
            item.FOB_Price__c=  product.priceListData.FOB_Price__c; 
            if(item.FOB_Price__c != null && item.FOB_Price__c && this.exchangeRate)
            {
                item.FOB_Price__c=item.FOB_Price__c*this.exchangeRate.toFixed(2);
            }
            item.Quote__c=  this.recordId;   
            item.Payment_Terms__c=this.paymentTermCostRate;   
            if(this.isMXDAPORDDP){
                item.Clearance_Cost_Percentage__c = 3.5;
            }
            let quoteDetail = {};
            quoteDetail.quoteDetailData = item;
            quoteDetail.isNotEdit=true;
            console.log('quoteDetail:'+JSON.stringify(quoteDetail));
            this.quoteDetailList.push(quoteDetail);
            this.pickProductList.push(product.priceListData.Id);
        }
        else
        {
            let product = this.priceListList[event.currentTarget.dataset.record];
            // for (var i = 0; i < this.pickProductList.length; i++) 
            // {
            //     if(product.productData.Id===this.pickProductList[i])
            //     {
            //         this.dispatchEvent(new ShowToastEvent({
            //         title: 'error',
            //         message: 'This Product Already Added ',
            //         variant: 'error',
            //         })); 
            //         return ;
            //     }
            // }
            console.log('product:'+JSON.stringify(product));
            let item = {}; 
            item.Contract_Processing_Product__c=  product.productData.Id;
            item.Quote_Product_Name__c=product.productData.Name;
            //item.FOB_Price__c=  100; 
            item.Quote__c=  this.recordId;
            item.Payment_Terms__c=this.paymentTermCostRate;              
            let quoteDetail = {};
            quoteDetail.quoteDetailData = item;
            console.log('quoteDetail:'+JSON.stringify(quoteDetail));
            this.pickProductList.push(product.productData.Id);
            this.quoteDetailList.push(quoteDetail);
        }
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Add Success',
            variant: 'Success',
        }));
    }

    deleteDetailData(event) {
        let index = event.currentTarget.dataset.record;
        console.log('this.quoteDetailList[index].Id',this.quoteDetailList[index].quoteDetailData.Id);
        if (this.quoteDetailList[index].quoteDetailData.Id) {
			this.deleteIdList.push(this.quoteDetailList[index].quoteDetailData.Id);
		}
        if(this.isHQSubClient)
        {
            this.pickProductList = this.pickProductList.filter(item => item !== this.quoteDetailList[index].quoteDetailData.Price_List__c);
        }
        else
        {
            this.pickProductList = this.pickProductList.filter(item => item !== this.quoteDetailList[index].quoteDetailData.Contract_Processing_Product__c);
        }
        
        this.quoteDetailList.splice(index, 1);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Delete Success',
            variant: 'Success',
        }));
    }

    confirmData() {
        console.log("359");
        /*if(this.isHQSubClient)
        {
        for (var i = 0; i < this.quoteDetailList.length; i++)
        {
            if(this.quoteDetailList[i].quoteDetailData.Quote_Product_Name__c)
            {
                this.pickProductNameList.push(this.quoteDetailList[i].quoteDetailData.Quote_Product_Name__c);
            }
        }
        console.log("this.pickProductNameList",JSON.stringify(this.pickProductNameList));
        for (var i = 0; i < this.pickProductNameList.length; i++)
        {
            var count=0;
            console.log("i:",i);
            for (var j = 0; j < this.quoteDetailList.length; j++) 
            {
                console.log("j:",j);
                if(this.quoteDetailList[j].quoteDetailData.Quote_Product_Name__c===this.pickProductNameList[i])
                {
                    console.log("进入if:");
                    count++;
                    if(count>1)
                    {
                        
                        this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: 'This Product '+this.quoteDetailList[j].quoteDetailData.Quote_Product_Name__c+' Already Added ',
                        variant: 'error',
                        }));
                        return ;
                    }
                }
            }
        }
        }*/
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
        if(!allValid1 || !allValid2 || !allValid3) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: 'Input Required',
                variant: 'error',
            }));

            return;
        }
        this.isShowSpinner = true;
        console.log('this.quoteDetailList'+JSON.stringify(this.quoteDetailList));
        save({
            quoteDetailList : this.quoteDetailList,
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

     //水平方向滚动
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth+10) + "px;height:380px;" + this.tableBodyStyle;
        }

        
        // const tableInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        // if (tableInnerDiv) {
        //     // Cache the initial width if not already set
        //     if (!this._tableInnerDivWidth) {
        //         this._tableInnerDivWidth = tableInnerDiv.offsetWidth;
        //     }
            
        //     // Update the width based on scroll position
        //     const newWidth = event.currentTarget.scrollLeft + this._tableInnerDivWidth + 10;
        //     tableInnerDiv.style.width = `${newWidth}px`;
        // }
        // this._tableViewInnerDiv1 = this.template.querySelector(".tableViewInnerDiv1");
        // if (this._tableViewInnerDiv1) {
        //     if (!this._tableViewInnerDiv1OffsetWidth || this._tableViewInnerDiv1OffsetWidth === 0) {
        //         this._tableViewInnerDiv1OffsetWidth = this._tableViewInnerDiv1.offsetWidth;
        //     }
        //     this._tableViewInnerDiv1.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDiv1OffsetWidth+10) + "px;" + this.tableBodyStyle;
        // }
    }

    productChange(event) {
        let index = event.currentTarget.dataset.record;
        let filedName = event.target.name;
        console.log("index:",index);
        console.log("filedName:",filedName);
        console.log("event.target.value:",event.target.value);
        this.quoteDetailList[index].quoteDetailData[filedName]=event.target.value;
        /*var count=0;
        if(filedName==='Quote_Product_Name__c')
            {
                for (var i = 0; i < this.quoteDetailList.length; i++) 
                {
                    if(this.quoteDetailList[index].quoteDetailData.Quote_Product_Name__c===event.target.value)
                    {
                        count++;
                        if(count>1)
                        {
                            console.log('this.quoteDetailList[index]'+JSON.stringify(this.quoteDetailList[index]));
                            this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: 'This Product '+event.target.value+' Already Added ',
                            variant: 'error',
                            }));
                            return ;
                        }
                        
                    }
                }
            }*/
        if(this.isHQSubClient)
        {
            /*if(filedName==='Quote_Product_Name__c')
            {
                for (var i = 0; i < this.pickProductList.length; i++) 
                {
                    if(this.quoteDetailList[index].quoteDetailData.Quote_Product_Name__c===this.pickProductList[i])
                    {
                        //this.quoteDetailList[index].quoteDetailData.Quote_Product_Name__c=null;
                        console.log('this.quoteDetailList[index]'+JSON.stringify(this.quoteDetailList[index]))
                        this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: 'This Product Already Added ',
                        variant: 'error',
                        }));
                        return ;
                    }
                }
            }*/
            let sumCost=0;
            if(this.quoteDetailList[index].quoteDetailData.FOB_Price__c && this.quoteDetailList[index].quoteDetailData.FOB_Price__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.FOB_Price__c);
            }
            if(this.quoteDetailList[index].quoteDetailData.Packing_Cost__c && this.quoteDetailList[index].quoteDetailData.Packing_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Packing_Cost__c);
            }
            if(this.quoteDetailList[index].quoteDetailData.Pallet__c && this.quoteDetailList[index].quoteDetailData.Pallet__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Pallet__c);
            }
            if(this.quoteDetailList[index].quoteDetailData.Freight_Cost__c && this.quoteDetailList[index].quoteDetailData.Freight_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Freight_Cost__c);
            }
            // if(this.quoteDetailList[index].quoteDetailData.Inland_Cost_Including_Insurance__c && this.quoteDetailList[index].quoteDetailData.Inland_Cost_Including_Insurance__c != null)
            // {
            //     sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Inland_Cost_Including_Insurance__c);
            // }
            if(this.quoteDetailList[index].quoteDetailData.Commission__c && this.quoteDetailList[index].quoteDetailData.Commission__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Commission__c);
            }
            console.log("sumCost:",sumCost);
            this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=sumCost.toFixed(5);
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Payment_Terms__c)
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c*this.quoteDetailList[index].quoteDetailData.Payment_Terms__c).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Clearance_Cost_Percentage__c)
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c*(1+this.quoteDetailList[index].quoteDetailData.Clearance_Cost_Percentage__c/100)).toFixed(5);
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Inland_Cost_Including_Insurance__c  && this.quoteDetailList[index].quoteDetailData.Payment_Terms__c)
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)+parseFloat((this.quoteDetailList[index].quoteDetailData.Inland_Cost_Including_Insurance__c*this.quoteDetailList[index].quoteDetailData.Payment_Terms__c))).toFixed(5);
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)
            {
               this.quoteDetailList[index].quoteDetailData.BU_Profit_Rate__c=(100*(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)-parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c))/parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)).toFixed(2);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.BU_Profit_Rate__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)
            {
                this.quoteDetailList[index].quoteDetailData.Item_Cost__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)*parseFloat(this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.Item_Cost__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c && this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)
            {
                this.quoteDetailList[index].quoteDetailData.Item_Price__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)*parseFloat(this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.Item_Price__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c && this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)
            {
                this.quoteDetailList[index].quoteDetailData.Gross_Margin__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)-parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.Gross_Margin__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.Commission__c && this.quoteDetailList[index].quoteDetailData.FOB_Price__c)
            {
                this.quoteDetailList[index].quoteDetailData.Commission_Percent__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.Commission__c)/parseFloat(this.quoteDetailList[index].quoteDetailData.FOB_Price__c)*100).toFixed(2);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.Commission_Percent__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.Commission__c && this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)
            {
                this.quoteDetailList[index].quoteDetailData.CIF_Price_Include_Commission__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.Commission__c)+parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.CIF_Price_Include_Commission__c=null;
            }
        }
        else
        {
            let sumCost=0;
            if(this.quoteDetailList[index].quoteDetailData.Packing_Cost__c && this.quoteDetailList[index].quoteDetailData.Packing_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Packing_Cost__c);
            }
            if(this.quoteDetailList[index].quoteDetailData.Cost__c && this.quoteDetailList[index].quoteDetailData.Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Cost__c);
            }
            if(this.quoteDetailList[index].quoteDetailData.Process_Cost__c && this.quoteDetailList[index].quoteDetailData.Process_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].quoteDetailData.Process_Cost__c);
            }
            console.log("sumCost:",sumCost);
            this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=sumCost.toFixed(5);
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Payment_Terms__c)
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c*this.quoteDetailList[index].quoteDetailData.Payment_Terms__c).toFixed(5)
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c=null;
            }
            if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)
            {
               this.quoteDetailList[index].quoteDetailData.BU_Profit_Rate__c=(100*(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)-parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c))/parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)).toFixed(2);
            }
            else
            {
                this.quoteDetailList[index].quoteDetailData.BU_Profit_Rate__c=null;
            }
        }
        if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c && this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)
        {
            this.quoteDetailList[index].quoteDetailData.Item_Cost__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)*parseFloat(this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)).toFixed(5);
        }
        else
        {
            this.quoteDetailList[index].quoteDetailData.Item_Cost__c=null;
        }
        if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c && this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)
        {
            this.quoteDetailList[index].quoteDetailData.Item_Price__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)*parseFloat(this.quoteDetailList[index].quoteDetailData.Order_Qnty__c)).toFixed(5);
        }
        else
        {
            this.quoteDetailList[index].quoteDetailData.Item_Price__c=null;
        }
        if(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c && this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)
        {
            this.quoteDetailList[index].quoteDetailData.Gross_Margin__c=(parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days__c)-parseFloat(this.quoteDetailList[index].quoteDetailData.CIF_90_Days_Without_Margin__c)).toFixed(5);
        }
        else
        {
            this.quoteDetailList[index].quoteDetailData.Gross_Margin__c=null;
        }
        console.log('this.quoteDetailList[index]'+JSON.stringify(this.quoteDetailList[index]))
    }

    
}