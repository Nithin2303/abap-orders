@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESTRICTED VIEW FOR  ORDER'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_R_ORDER
  as select from ZI_ORDER
  composition[0..*] of ZI_R_ORDERITEMS as _items
  association[1..*] to ZI_STATUS as _status on $projection.Status = _status.value
{
  key Orderid,
      Customerid,
      Orderdate,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      Amount,
      Status,
      Comments,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdat,
      @Semantics.user.lastChangedBy: true
      Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      Changedat,
      _items ,// Make association public
      _status
}
