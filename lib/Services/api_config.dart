library APIConstants;

const String SUCCESS_MESSAGE = " You will be contacted by us very soon.";

var baseUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/";

var post_Login = "Account/Login";
var GetWarehouse = 'Account/GetWarehousesByUserandCompany/';
var GetAllDealersBySlpCode = "Party/GetDealersBySlpCode/";
//api/Account/GetAllDealersBySlpCode/{CompanyId}/{SlpCode}
var GetBanners = 'Banner/GetBannersDataInfo/';

var FetchCreateOrderapi = 'Item/GetItemGroups/';

var SubmitCreateOrderapi = 'Order/AddOrder';
var GetVirtualCode = 'SAP/GetVertualCodesByPartyCode/';
var addCollections = 'Collections/AddUpdateCollections';
var GetPaymentMode = 'Master/GetAllTypeCdDmt/2';
var GetPurpose = 'Collections/GetPurposes/';
var GetbankDetails = 'SAP/GetBankDetails/';
var GetProductbyItemcode = 'Item/GetAllItemsByItemGroupCode';
var GetProductName = 'Item/GetItemGroups/';
var GetLedgerReport = 'Party/GetCustomerLedgerReport';
var GetCustomerLedgerReport = 'Party/GetCustomerLedgerReport';
var changePassword = "Account/ChangePassword";
var getCompanies = "Account/GetCompanies/null";
var getAllTypeCdDmt = "Master/GetAllTypeCdDmt/2";
var GetAllItemsByItemGroupCode = "Item/GetAllItemsByItemGroupCode";
var ForgotPassword = "Account/ForgotPassword";

var UpdateInvoiceStatus = "Order/UpdateInvoiceStatus";
var UpdateOrderStatus = "Order/UpdateOrderStatus";
var getPreviousOrderBookingByPartyCode = "Order/GetPreviousOrderBookingByPartyCode/";
var GetReturnOrderDetailsById = "ReturnOrder/GetReturnOrderDetailsById/";
var addReturnOrder = "ReturnOrder/AddReturnOrder";
var GetCollectionsbyMobileSearch = "Collections/GetCollectionsbyMobileSearch";
var GetAllTypeCdDmt = "Master/GetAllTypeCdDmt/3";
var GetAppReturnOrdersBySearch = "ReturnOrder/GetAppReturnOrdersBySearch";
var GetAppOrdersBySearch = "Order/GetAppOrdersBySearch";
var GetReturnOrderImagesById = "ReturnOrder/GetReturnOrderImagesById/";
var GetReturnOrderCreditById = "ReturnOrder/GetReturnOrderCreditById/";
var addOrder = "/Order/AddOrder";
var GetInvoiceDetailsByOrderNumber = "Order/GetInvoiceDetailsByOrderNumber/";
var GetOrderDetailsById = "Order/GetOrderDetailsById/";
var GetItemGroups = "Item/GetItemGroups/";
var AddReturnorder = 'ReturnOrder/AddReturnOrder';
var GetAppOrderbySearch = 'Order/GetAppOrdersBySearch';
var addUpdateCollections = "Collections/AddUpdateCollections";
