@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for orders'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_ORDER
  provider contract transactional_query
  as projection on ZI_R_ORDER
{
  key Orderid,
      Customerid,
      Orderdate,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      Amount,
      @Search.defaultSearchElement: true
      Status,
      Comments,
      Createdby,
      Createdat,
      Lastchangedby,
      Changedat,
      /* Associations */
      _items : redirected to composition child ZC_ORDERITEMS
}
