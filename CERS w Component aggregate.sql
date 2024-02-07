select
to_char(sysdate,'mm/dd/yyyy') as RunDate,
replace(c.location,' > ','-') as location,
'''' ||c.barcode as barcode,
c.owner,
ch.tradename,
ch.supplier,
ch.casno as casno,
ch.specificgravity,
ch.hazardclasses,
ch.nfpa,
cc.HC1Name,
cc.HC1CAS,
cc.HC2Name,
cc.HC2CAS,
cc.HC3Name,
cc.HC3CAS,
cc.HC4Name,
cc.HC4CAS,
cc.HC5Name,
cc.HC5CAS,
to_char(c.datecreated,'mm/dd/yyyy') as datecreated,
substr(c.expirationdate,1,10) as expirationdate,
ch.physicalstate,
s.containertype,
s.initialquantity as LargestConatinerQuantity,
c.quantity,
c.v1constantturnover as CT,
NULL as SDS
from
container c
join chemical ch on (c.material_id=ch.nodeid)
join size1 s on (c.size1_id=s.nodeid)
  join vwgetinvgrpidforlocation v1 on v1.nodeid=c.location_id
  join vwViewableinvGrpByUser v2 on (v2.invgrpid=v1.invgrpid and v2.viewable='Y' and v2.userid= {userid} )
left outer join regulatorylistmember calosha on (ch.nodeid=calosha.chemical_id and calosha.regulatorylist_name='CA Regulated Carcinogens')
left outer join regulatorylistmember ahm on (ch.nodeid=ahm.chemical_id and ahm.regulatorylist_name='CA Acutely Hazardous Materials')

left outer join (--CERS Component data aggregated onto a single row per mixture
    select x.mixture_id,
      x.mixture_name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 1) as HC1PercentByWeight,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 2) as HC1Name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 3) as HC1EHS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 4) as HC1CAS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 5) as HC2PercentByWeight,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 6) as HC2Name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 7) as HC2EHS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 8) as HC2CAS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 9) as HC3PercentByWeight,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 10) as HC3Name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 11) as HC3EHS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 12) as HC3CAS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 13) as HC4PercentByWeight,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 14) as HC4Name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 15) as HC4EHS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 16) as HC4CAS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 17) as HC5PercentByWeight,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 18) as HC5Name,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 19) as HC5EHS,
      REGEXP_SUBSTR (x.component_string, '[^|]+', 1, 20) as HC5CAS
    from 
      (select
        mcomp.mixture_id,
        max(mcomp.mixture_name) as mixture_name, 
        listagg (	case 
            when percentagerange_target is not null then percentagerange_target
            when percentagerange_lower is null then percentagerange_upper
            when percentagerange_upper is null then percentagerange_lower
            else (percentagerange_lower + percentagerange_upper) /2 
          end ||' | '||
          mcomp.constituent_name||' | '||
          CASE
            WHEN con.nodeid is null THEN null
            WHEN con.ehsname is null THEN 'N'
            ELSE 'Y'
          END||' | '||
          con.casno||' |') 
      within group(order by mcomp.nodeid) as component_string
      from 
        materialcomponent mcomp
        left join constituent con on (mcomp.constituent_id = con.nodeid and con.obsolete = 0)
      where mcomp.obsolete = 0
      group by mcomp.mixture_id)x) cc on (cc.mixture_id = ch.nodeid)

where
c.disposed <> 'Y' and c.obsolete <> 1 
  and lower(c.location) like lower( '%{Location Name Contains}%' )
order by lower(ch.tradename)
