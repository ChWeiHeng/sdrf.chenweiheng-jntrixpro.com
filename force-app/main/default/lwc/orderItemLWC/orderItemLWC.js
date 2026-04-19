/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 04-07-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   07-18-2025   Gerry   Initial Version
**/
import { LightningElement,api, track } from 'lwc';
import initMe from '@salesforce/apex/OrderItemLWCController.init';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactorPropertyName from '@salesforce/client/formFactor';
import ErrorMSG from '@salesforce/label/c.Error';
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
import GuidePrice from '@salesforce/label/c.GuidePrice';
import PriceRate from '@salesforce/label/c.PriceRate';
import cost from '@salesforce/label/c.Product_Cost';
import marginRate from '@salesforce/label/c.Margin_Rate';
import MinPrice from '@salesforce/label/c.Min_Price';
import SAP_Remain_Stock from '@salesforce/label/c.SAP_Remain_Stock';
import LatestMinSalesPrice from '@salesforce/label/c.LatestMinSalesPrice';
import CashPrice from '@salesforce/label/c.CashPrice';
import MarginLevel from '@salesforce/label/c.MarginLevel';
import PriceRateHelpText from '@salesforce/label/c.PriceRateHelpText';
import EstimateCost from '@salesforce/label/c.EstimateCost';
import EstimateGM from '@salesforce/label/c.EstimateGM';
export default class OrderItemLWC extends LightningElement {
    customLabel = {
        EstimateCost,
        EstimateGM,
        CashPrice,
        LatestMinSalesPrice,
        MinPrice,
        cost,marginRate,
        GuidePrice,
        PriceRate,
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
        SAP_Remain_Stock,
        MarginLevel,
        PriceRateHelpText
    }
    @api recordId;
    @track show;
    @track orderItemList;
    @track isPC;
    @track lengthData = {};
    @track modelB;
    @track isShowMargin;
    @track isARC;
    @track showCashPrice;
    @track isZARE;
    connectedCallback() {
        this.lengthData.num = '5%';
        this.lengthData.Commodity = '10%';
        this.lengthData.Quantity = '10%';
        this.lengthData.unit = '5%';
        this.lengthData.Price = '10%';
        this.lengthData.GuidePrice = '10%';
        this.lengthData.PriceRate = '10%';
        this.lengthData.Amountperitem = '10%';
        this.lengthData.DeliveryDate = '10%';
        this.lengthData.SAPRemainStock = '10%';
        this.lengthData.cost = '10%';
        this.lengthData.marginRate = '10%';
        if(formFactorPropertyName==='Small') {
            this.isPC = false;
        }else{
            this.isPC = true;
        }
        console.log('recordId'+this.recordId);
        initMe({
            dataId : this.recordId
        }).then(result => {
            this.isZARE = result.isZARE;
            if(this.isZARE){
                this.customLabel.GuidePrice = 'ZARB Price';
            }
            this.showCashPrice = result.isShowCashPrice;
            this.show = result.flag;
            this.orderItemList = result.orderItemList;
            this.modelB = result.modelB;
            this.isShowMargin = result.isShowMargin;
            this.isARC = result.isARC;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: JSON.stringify(error),
                variant: 'error',
            }));
        });
    }
    shooMoreMe(event) {
        let index = event.target.name;
        console.log('index',index);
        this.orderItemList[index].orderItemData.Show_More__c=true;
    }

    shooLessMe(event) {
        let index = event.target.name;
        this.orderItemList[index].orderItemData.Show_More__c=false;
    }
}