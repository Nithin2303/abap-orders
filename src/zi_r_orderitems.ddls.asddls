@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RESTRICTED VIEW FOR OREDR(ITEMS)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_R_ORDERITEMS
  as select from ZI_ORDERITEMS
  association to parent ZI_R_ORDER as _header on $projection.Orderid = _header.Orderid
{
  key Orderitemid,
      Orderid,
      Productname,
      Unitfield,
      @Semantics.quantity.unitOfMeasure: 'Unitfield'
      Quantity,
      Currfield,
      @Semantics.amount.currencyCode: 'Currfield'
      Unitprice,
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      Createdat,
      @Semantics.user.lastChangedBy: true
      Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      Changedat,
      _header // Make association public
}
