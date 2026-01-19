@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW FOR THE DOMAIN STATUS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_STATUS as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZDEMO_STATUS' )
{
    key domain_name,
    key value_position,
    @Semantics.language: true
    key language,
    value_low as value,
    @Semantics.text: true
    text as description
}
