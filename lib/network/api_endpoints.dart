class APIEndpoint {
  static String get baseUrl => 'dev.dawaadost.com';

  static String get v1 => '/api';

  // Public Api
  static String get homeUrl => '$v1/public/home';
  static String get getStoresUrl => '$v1/public/getStores';
  static String get searchUrl => '$v1/medicine/vertexSearch';
  static String get ddMedicineUrl => '$v1/medicine/ddSuggestion';
  static String get productNotifiedMeUrl => '$v1/buyer/productNotifiedMe';

  // Auth Api
  static String get loginUrl => '$v1/checkout/sendOTP';
  static String get verifyOtpUrl => '$v1/checkout/verifyOTP';
  static String get getBuyerAddressUrl => '$v1/checkout/getBuyerAddress';
  static String get deleteBuyerAddressUrl => '$v1/checkout/deleteAddress';
  static String get getStatesUrls => '$v1/checkout/getStates';
  static String get getCitiesByStateUrl => '$v1/checkout/getCitiesByState';
  static String get createAddressUrl => '$v1/checkout/createAddress';
  static String get editAddressUrl => '$v1/checkout/editAddress';
  static String get uploadFilesUrl => '$v1/storage/uploadFilesToGCS';
  static String get checkShippingUrl => '$v1/checkout/checkShipping';
  static String get calculateShippingPriceUrl =>
      '$v1/checkout/calculateShippingPrice';
  static String get getMFMCitiesUrl => '$v1/checkout/getMFMCities';
  static String get checkMFMUrl => '$v1/checkout/checkMFM';
  static String get getMedicineDiscountUrl =>
      '$v1/checkout/getMedicineDiscount';
  static String get getDiscountCodeUrl => '$v1/checkout/getDiscountCode';
  static String get verifyDiscountCodeUrl => '$v1/checkout/verifyDiscountCode';
  static String get createIndentUrl => '$v1/checkout/createIndent';
  static String get makeCallDialShreeUrl => '$v1/checkout/makeCallDialShree';
  static String get createPaymentUrl => '$v1/checkout/createPayment';
  static String get orderToIzoleapUrl => '$v1/izoleap/orderToIzoleap';
  static String get generatePaymentTokenUrl =>
      '$v1/checkout/generatePaymentToken';
}
