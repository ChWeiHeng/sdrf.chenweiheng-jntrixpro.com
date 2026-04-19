/**
 * @description       : 
 * @author            : Gerry
 * @group             : 
 * @last modified on  : 01-20-2026
 * @last modified by  : Gerry
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-15-2026   Gerry   Initial Version
**/
import { LightningElement,api, track } from 'lwc';
import initMe from '@salesforce/apex/OrderItemLWCController.init';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactorPropertyName from '@salesforce/client/formFactor';
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
import ProductCode from '@salesforce/label/c.Product_Code';

export default class OrderItemMarginLWC extends LightningElement {
    customLabel = {
        ProductCode,
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
    @api infoDataPar;
    @track infoData;
    @track isPC;
    @track lengthData = {};
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
        console.log('this.isPC'+this.isPC);
        this.infoData = JSON.parse(JSON.stringify(this.infoDataPar));
        console.log('this.infoData====>'+JSON.stringify(this.infoData));
    }
}