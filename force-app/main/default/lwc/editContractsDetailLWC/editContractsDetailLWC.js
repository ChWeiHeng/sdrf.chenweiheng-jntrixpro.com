/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-22-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   05-19-2025   Gerry   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import init from '@salesforce/apex/EditContractDetailController.initData';
import save from '@salesforce/apex/EditContractDetailController.saveData';
import mapProduct from '@salesforce/apex/EditContractDetailController.mapProduct';
import vertifyProduct from '@salesforce/apex/EditContractDetailController.vertifyProduct';
import getProductName from '@salesforce/apex/EditContractDetailController.getProductName';
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
import Unit from '@salesforce/label/c.Unit';
import Delivery_Time from '@salesforce/label/c.Delivery_Time';
import Total_Amount from '@salesforce/label/c.Total_Amount';
import Product_Name from '@salesforce/label/c.Product_Name';
import BU_Sales_Price from '@salesforce/label/c.BU_Sales_Price';
import Inland_Cost_Including_Insurance from '@salesforce/label/c.Inland_Cost_Including_Insurance';
import Qnty from '@salesforce/label/c.Qnty';
import Discount_Unit_Price from '@salesforce/label/c.Discount_Unit_Price';
import Unit_Price from '@salesforce/label/c.Unit_Price';
import Product_English_Name from '@salesforce/label/c.Product_English_Name';
import Product_Name_Print from '@salesforce/label/c.Product_Name_Print';
import If_Designated_Products from '@salesforce/label/c.If_Designated_Products';
import If_Pallet from '@salesforce/label/c.If_Pallet';
import Packing_Size_Description from '@salesforce/label/c.Packing_Size_Description';
import Recheck_Margin from '@salesforce/label/c.Recheck_Margin';
import Other_Issue from '@salesforce/label/c.Other_Issue';
import EditContractDetailHeader from '@salesforce/label/c.EditContractDetailHeader';
import ContractFieldRequired from '@salesforce/label/c.ContractFieldRequired';
import HQ_Contract_Unit_Price from '@salesforce/label/c.HQ_Contract_Unit_Price';
import Add_Contract_Detail from '@salesforce/label/c.Add_Contract_Detail';
import Tracking_Code from '@salesforce/label/c.Tracking_Code';
import File from '@salesforce/label/c.File';
// import TargetArrivalDate from '@salesforce/label/c.TargetArrivalDate';
export default class EditContractsDetailLWC extends LightningElement {
    customLabel = {
        // TargetArrivalDate,
        File,
        Tracking_Code,
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
        Product_Code,
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
        Total_Amount,
        Product_Name,
        BU_Sales_Price,
        Inland_Cost_Including_Insurance,
        Qnty,
        Unit_Price,
        Product_English_Name,
        Product_Name_Print,
        If_Designated_Products,
        If_Pallet,
        Packing_Size_Description,
        Recheck_Margin,
        Other_Issue,
        ContractFieldRequired,
        EditContractDetailHeader,
        HQ_Contract_Unit_Price,
        Add_Contract_Detail
    }
    @track recordDetailId;
    @track showFile = false;
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
    @track isHQContract;
    @track exchangeRate;
    @track paymentTermCostRate;
    @track isRetrograde;
    @track pickProductList;
    @track pickProductNameList=[];
    @track unitOption = [];
    @track ifDesignatedProductOption = [];
    @track ifPalletOption = [];
    @track recheckMarginOption = [];
    @track isSaleContract;
    @track isBaseQuote;
    @track paymentTermCostRate;
    @track isEditHqPrice;
    @track isAR;
    @track productName;
    @track data = [];
    @track fileData = [];
    @track deleteFileId = [];
    @track dataIndex;
    closeFile() {
        this.showFile = false;
        let data = this.template.querySelector('c-upload-file-l-w-c');
        if (data) {
            let d = data.uploadData();
            console.log('data',JSON.stringify(d));
            this.quoteDetailList[this.dataIndex].fileData = d.fileData;

            for (var j = 0; j < d.deleteData.length; j++) {
                this.deleteFileId.push(d.deleteData[j]);
            }   
            
        }
    }
    showFileMe(event) {
        this.showFile = true;
        this.recordDetailId = event.currentTarget.dataset.record;
        this.dataIndex = event.target.value;
        this.fileData = this.quoteDetailList[event.target.value].fileData;
        this.productName = this.quoteDetailList[event.target.value].productEnglishName;
    }
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

    /*queryData() {
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
    }*/
    connectedCallback() {
        
        console.log('进入init方法');
        // window.addEventListener('keydown', this.handleKeyDown.bind(this));
        this.lengthData.big = 'width: 300px;';
        this.lengthData.small = 'width: 50px;';
        this.lengthData.medium = 'width: 200px;';
        this.lengthData.mediumSmall = 'width: 100px;';
        this.lengthData.mediumBig = 'width: 150px;';
        console.log('this.formFactorPropertyName',formFactorPropertyName);
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        this.isShowSpinner = true;
		init({
            contractId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                console.log('result=====>',JSON.stringify(result));
            	this.quoteDetailList = result.conDetailList;
                this.isHQContract=result.isHQContract;
                console.log('this.isHQContract',this.isHQContract);
                this.isSaleContract=result.isSaleContract;
                console.log('this.isSaleContract',this.isSaleContract);
                this.isBaseQuote=result.isBaseQuote;
                console.log('this.isBaseQuote',this.isBaseQuote);
                this.paymentTermCostRate=result.paymentTermCostRate;
                console.log('this.paymentTermCostRate=====>',this.paymentTermCostRate);
                this.isEditHqPrice=result.isEditHqPrice;
                console.log('this.isEditHqPrice=====>',this.isEditHqPrice);
                let opMap = [];
                opMap.push({label: null,value: ''});
                //for(let key in result.unitMap){
                    //opMap.push({label: result.unitMap[key],value: key});
                //}
                opMap.push({label: 'KG',value: 'KG'});
                opMap.push({label: 'L',value: 'L'});
                this.unitOption = opMap;
                let opMap1 = [];
                opMap1.push({label: null,value: ''});
                for(let key in result.ifDesignatedProductMap){
                    opMap1.push({label: result.ifDesignatedProductMap[key],value: key});
                }
                this.ifDesignatedProductOption = opMap1;
                let opMap2 = [];
                opMap2.push({label: null,value: ''});
                console.log('result.ifPalletMap'+result.ifPalletMap);
                for(let key in result.ifPalletMap){
                    opMap2.push({label: result.ifPalletMap[key],value: key});
                }
                this.ifPalletOption = opMap2;
                let opMap3 = [];
                opMap3.push({label: null,value: ''});
                for(let key in result.recheckMarginMap){
                    opMap3.push({label: result.recheckMarginMap[key],value: key});
                }
                this.recheckMarginOption = opMap3;
                this.isAR = result.isAR;
               
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
        item.Contracts__c=  this.recordId;
        item.If_Designated_Products__c='N';  
        item.Recheck_Margin__c= 'N';  
        let conDetail = {};
        conDetail.conDetailData = item;
        conDetail.index=this.quoteDetailList.length;
        conDetail.fileData = [];
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
        this.quoteDetailList[event.currentTarget.dataset.record].conDetailData[event.target.name] = event.target.value;
        if(this.quoteDetailList[event.currentTarget.dataset.record].conDetailData.Product__c && this.quoteDetailList[event.currentTarget.dataset.record].conDetailData.Commodity__c)
        {
            this.isShowSpinner = true;
            mapProduct({
                productId : this.quoteDetailList[event.currentTarget.dataset.record].conDetailData.Product__c,
                contractId : this.recordId,
                commodityId : this.quoteDetailList[event.currentTarget.dataset.record].conDetailData.Commodity__c
            }).then(result => {
                console.log('方法调用了',JSON.stringify(result));
                if (result.isSucess) {
                    console.log('进入if');
                    //this.quoteDetailList[currenRecord].conDetailData.Commodity__c=result.commodityId;
                    this.quoteDetailList[currenRecord].price=result.price;
                    if(this.isSaleContract)
                    {
                        let sumAmout=0;
                        if(this.quoteDetailList[currenRecord].price && this.quoteDetailList[currenRecord].price != null)
                        {
                            sumAmout=sumAmout+parseFloat(this.quoteDetailList[currenRecord].price);
                        }
                        if(this.quoteDetailList[currenRecord].conDetailData.BU_Sales_Price__c )
                        {
                            sumAmout=sumAmout+parseFloat(this.quoteDetailList[currenRecord].conDetailData.BU_Sales_Price__c);
                        }
                        this.quoteDetailList[currenRecord].conDetailData.Discount_Unit_Price__c=sumAmout.toFixed(5);
                    }
                    
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    //this.quoteDetailList[currenRecord].conDetailData.Product__c = null;
                    this.quoteDetailList[currenRecord].conDetailData.Commodity__c=null;
                    this.quoteDetailList[currenRecord].price=0;
                    if(this.isSaleContract)
                    {
                        this.quoteDetailList[currenRecord].conDetailData.Discount_Unit_Price__c=this.quoteDetailList[currenRecord].conDetailData.BU_Sales_Price__c;
                    }
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
        }
        else{
            //this.quoteDetailList[currenRecord].conDetailData.Product__c = null;
            //this.quoteDetailList[currenRecord].conDetailData.Commodity__c=null;
            this.quoteDetailList[currenRecord].price=0;
            if(this.isSaleContract)
            {
                console.log('330',this.quoteDetailList[currenRecord].conDetailData.BU_Sales_Price__c);
                this.quoteDetailList[currenRecord].conDetailData.Discount_Unit_Price__c=this.quoteDetailList[currenRecord].conDetailData.BU_Sales_Price__c;      
            }
            
        }
    }

    vertifyProduct(event){
        let currenRecord;
        currenRecord=event.currentTarget.dataset.record;
        this.quoteDetailList[currenRecord].conDetailData[event.target.name] = event.target.value;
        if(this.quoteDetailList[currenRecord].conDetailData.Product__c &&  this.quoteDetailList[currenRecord].conDetailData.Quote_Detail__c)
        {
            this.isShowSpinner = true;
            vertifyProduct({
                productId : event.target.value,
                quoteDetailId : this.quoteDetailList[currenRecord].conDetailData.Quote_Detail__c
            }).then(result => {
                console.log('方法调用了',JSON.stringify(result));
                if (result.isSucess) {
                    console.log('进入if');
                    //this.quoteDetailList[currenRecord].conDetailData.Product__c=event.target.value;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    this.quoteDetailList[currenRecord].conDetailData.Product__c = null;
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
        }
    }

    getProductNameMap(event){
        let currenRecord;
        currenRecord=event.currentTarget.dataset.record;
        this.quoteDetailList[currenRecord].conDetailData[event.target.name] = event.target.value;
        if(this.quoteDetailList[currenRecord].conDetailData.Product__c)
        {
            this.isShowSpinner = true;
            getProductName({
                productId : this.quoteDetailList[currenRecord].conDetailData.Product__c,
                contractId : this.recordId
            }).then(result => {
                console.log('方法调用了',JSON.stringify(result));
                if (result.isSucess) {
                    this.quoteDetailList[currenRecord].proNameList=result.proNameList;
                    this.quoteDetailList[currenRecord].proUnitList=result.proUnitList;
                    this.quoteDetailList[currenRecord].conDetailData.Unit_Label__c= result.defaultUnit;
                    console.log('进入if');  
                    console.log('this.quoteDetailList[currenRecord].proNameList',this.quoteDetailList[currenRecord].proNameList);                  
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    //this.quoteDetailList[currenRecord].conDetailData.Product__c = null;
                    this.quoteDetailList[currenRecord].conDetailData.Commodity__c = null;
                    let opMap = [];
                    opMap.push({label: '',value: ''});
                    this.quoteDetailList[currenRecord].proNameList= opMap;
                    let opMap1 = [];
                    opMap1.push({label: '',value: ''});
                    this.quoteDetailList[currenRecord].proUnitList= opMap1;
                    
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
        }
        else{
            let opMap = [];
            opMap.push({label: '',value: ''});
            this.quoteDetailList[currenRecord].proNameList = opMap;
            let opMap1 = [];
            opMap1.push({label: '',value: ''});
            this.quoteDetailList[currenRecord].proUnitList = opMap1;
            this.quoteDetailList[currenRecord].conDetailData.Commodity__c = null;
        }
    }

    /*selectChange(event) {
        if(this.isHQSubClient)
        {
            let product = this.priceListList[event.currentTarget.dataset.record];
            for (var i = 0; i < this.pickProductList.length; i++) 
            {
                if(product.priceListData.Id===this.pickProductList[i])
                {
                    this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: 'This Product Already Added ',
                    variant: 'error',
                    }));
                    return ;
                }
            }
            //console.log('product:'+JSON.stringify(product));
            let item = {}; 
            item.Price_List__c=  product.priceListData.Id; 
            item.Unit__c=product.priceListData.Unit__c; 
            item.FOB_Price__c=  product.priceListData.FOB_Price__c; 
            if(item.FOB_Price__c != null && item.FOB_Price__c && this.exchangeRate)
            {
                item.FOB_Price__c=item.FOB_Price__c*this.exchangeRate.toFixed(2);
            }
            item.Quote__c=  this.recordId;   
            item.Payment_Terms__c=this.paymentTermCostRate;         
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
            for (var i = 0; i < this.pickProductList.length; i++) 
            {
                if(product.productData.Id===this.pickProductList[i])
                {
                    this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: 'This Product Already Added ',
                    variant: 'error',
                    })); 
                    return ;
                }
            }
            console.log('product:'+JSON.stringify(product));
            let item = {}; 
            item.Contract_Processing_Product__c=  product.productData.Id;  
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
    }*/

    deleteDetailData(event) {
        let index = event.currentTarget.dataset.record;
        if (this.quoteDetailList[index].conDetailData.Id) 
        {
            this.deleteIdList.push(this.quoteDetailList[index].conDetailData.Id);
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
        copyData.conDetailData.Id=null;
        for(var i=0;i<copyData.fileData.length;i++){//去除复制功能的附件id 以及附件关联id
            copyData.fileData[i].Id=null;
            copyData.fileData[i].ContentDocumentId=null;
        }
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
        if(!allValid1 || !allValid2 || !allValid3) {
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
            conDetailList : this.quoteDetailList,
            deleteList : this.deleteIdList,
            deleteFileList : this.deleteFileId
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
        this.quoteDetailList[index].conDetailData[filedName]=event.target.value;
        console.log('this.quoteDetailList[index]'+JSON.stringify(this.quoteDetailList[index]));
        if(filedName==='BU_Sales_Price__c' && this.isSaleContract)
        {
            let sumAmout=0;
            if(this.quoteDetailList[index].price)
            {
                sumAmout=sumAmout+parseFloat(this.quoteDetailList[index].price);
            }
            if(this.quoteDetailList[index].conDetailData.BU_Sales_Price__c )
            {
                sumAmout=sumAmout+parseFloat(this.quoteDetailList[index].conDetailData.BU_Sales_Price__c);
            }
            this.quoteDetailList[index].conDetailData.Discount_Unit_Price__c=sumAmout.toFixed(5);
        }
        if(this.isHQContract)
        {
            let sumCost=0;
            if(this.quoteDetailList[index].conDetailData.FOB_Price__c && this.quoteDetailList[index].conDetailData.FOB_Price__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.FOB_Price__c);
            }
            if(this.quoteDetailList[index].conDetailData.Packing_cost__c && this.quoteDetailList[index].conDetailData.Packing_cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.Packing_cost__c);
            }
            if(this.quoteDetailList[index].conDetailData.Pallet_Cost__c && this.quoteDetailList[index].conDetailData.Pallet_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.Pallet_Cost__c);
            }
            if(this.quoteDetailList[index].conDetailData.Freight_Cost__c && this.quoteDetailList[index].conDetailData.Freight_Cost__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.Freight_Cost__c);
            }
            if(this.quoteDetailList[index].conDetailData.Inland_Cost_Including_Insurance__c && this.quoteDetailList[index].conDetailData.Inland_Cost_Including_Insurance__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.Inland_Cost_Including_Insurance__c);
            }
            if(this.quoteDetailList[index].conDetailData.Commission_Unit_Price__c && this.quoteDetailList[index].conDetailData.Commission_Unit_Price__c != null)
            {
                sumCost=sumCost+parseFloat(this.quoteDetailList[index].conDetailData.Commission_Unit_Price__c);
            }
            console.log("sumCost:",sumCost);
            this.quoteDetailList[index].conDetailData.Unit_Price__c=sumCost.toFixed(5);
            if(this.quoteDetailList[index].conDetailData.Unit_Price__c && this.paymentTermCostRate)
            {
                this.quoteDetailList[index].conDetailData.Unit_Price__c=(this.quoteDetailList[index].conDetailData.Unit_Price__c*this.paymentTermCostRate).toFixed(5);
            }
            /*if(this.quoteDetailList[index].conDetailData.Unit_Price__c && this.quoteDetailList[index].conDetailData.Clearance_Cost_Percentage__c)
            {
                this.quoteDetailList[index].conDetailData.Unit_Price__c=(this.quoteDetailList[index].conDetailData.Unit_Price__c*(1+this.quoteDetailList[index].conDetailData.Clearance_Cost_Percentage__c/100)).toFixed(5);
            }*/
            //this.quoteDetailList[index].conDetailData.HQ_Contract_Unit_Price__c=this.quoteDetailList[index].conDetailData.Unit_Price__c;
            if(this.quoteDetailList[index].conDetailData.Qnty__c && this.quoteDetailList[index].conDetailData.Unit_Price__c)
            {
                this.quoteDetailList[index].conDetailData.Total_Amount__c=parseFloat(this.quoteDetailList[index].conDetailData.Qnty__c*this.quoteDetailList[index].conDetailData.Unit_Price__c).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].conDetailData.Total_Amount__c=null;
            }
        }
        else
        {
            let sumCost=0;
            if(this.quoteDetailList[index].conDetailData.Qnty__c && this.quoteDetailList[index].conDetailData.BU_Sales_Price__c)
            {
                this.quoteDetailList[index].conDetailData.Total_Amount__c=parseFloat(this.quoteDetailList[index].conDetailData.Qnty__c*this.quoteDetailList[index].conDetailData.BU_Sales_Price__c).toFixed(5);
            }
            else
            {
                this.quoteDetailList[index].conDetailData.Total_Amount__c=null;
            }
        }

    }

}