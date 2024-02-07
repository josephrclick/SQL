SELECT DISTINCT 
  mat.material_id,
  '{CERSID}' AS CERSID,  --:CERSID
  c.ChemicalLocation as ChemicalLocation,  --building name
  'N' AS CLConfidential,
  '85070803' AS MapNumber,
  '98' as GridNumber,
  ch.tradename AS ChemicalName,
  CASE 
    WHEN lower(ch.specialflags) like '%trade secret%' THEN 'Y'  
    ELSE 'N'
  END AS TradeSecret,
  ch.tradename as CommonName,
  CASE
    WHEN rlm.regulatorylist_name is not null THEN 'Y'
    ELSE 'N'
  END AS EHS,
  ch.casno AS CASNumber,
  case haz.class1
    when 'Carc' then 1
    when 'Corr' then 5
    when 'H.T.' then 13
    when 'Irr' then 14
    when 'OHH' then 27
    when 'RAD-alpha' then 29
    when 'RAD-beta' then 29
    when 'RAD-gamma' then 29
    when 'Sens' then 30
    when 'Tox' then 31
    when 'Aero-1' then 39
    when 'Aero-2' then 39
    when 'Aero-3' then 39
    when 'CF/D (balled)' then 39
    when 'CF/D (loose)' then 39
    when 'CL-II' then 2
    when 'CL-IIIA' then 3
    when 'CL-IIIB' then 4
    when 'CRY-FG' then 6
    when 'CRY-OXY' then 6
    when 'Exp' then 7
    when 'FG (liquified)' then 8
    when 'FG (gaseous)' then 8
    when 'FL-1A' then 9
    when 'FL-1B' then 10
    when 'FL-1C' then 11
    when 'FS' then 12
    when 'Perox-Det' then 39
    when 'Perox-I' then 23
    when 'Perox-II' then 24
    when 'Perox-III' then 25
    when 'Perox-IV' then 26
    when 'Perox-V' then 26
    when 'Oxy-1' then 17
    when 'Oxy-2' then 18
    when 'Oxy-3' then 19
    when 'Oxy-4' then 20
    when 'Oxy-Gas (liquid)' then 22
    when 'oxy-gas' then 21
    when 'Pyro' then 28
    when 'UR-1' then 32
    when 'UR-2' then 33
    when 'UR-3' then 34
    when 'UR-4' then 35
    when 'WR-1' then 36
    when 'WR-2' then 37
    when 'WR-3' then 38
  end as PFCodeHazardClass,
  case haz.class2
    when 'Carc' then 1
    when 'Corr' then 5
    when 'H.T.' then 13
    when 'Irr' then 14
    when 'OHH' then 27
    when 'RAD-alpha' then 29
    when 'RAD-beta' then 29
    when 'RAD-gamma' then 29
    when 'Sens' then 30
    when 'Tox' then 31
    when 'Aero-1' then 39
    when 'Aero-2' then 39
    when 'Aero-3' then 39
    when 'CF/D (balled)' then 39
    when 'CF/D (loose)' then 39
    when 'CL-II' then 2
    when 'CL-IIIA' then 3
    when 'CL-IIIB' then 4
    when 'CRY-FG' then 6
    when 'CRY-OXY' then 6
    when 'Exp' then 7
    when 'FG (liquified)' then 8
    when 'FG (gaseous)' then 8
    when 'FL-1A' then 9
    when 'FL-1B' then 10
    when 'FL-1C' then 11
    when 'FS' then 12
    when 'Perox-Det' then 39
    when 'Perox-I' then 23
    when 'Perox-II' then 24
    when 'Perox-III' then 25
    when 'Perox-IV' then 26
    when 'Perox-V' then 26
    when 'Oxy-1' then 17
    when 'Oxy-2' then 18
    when 'Oxy-3' then 19
    when 'Oxy-4' then 20
    when 'Oxy-Gas (liquid)' then 22
    when 'oxy-gas' then 21
    when 'Pyro' then 28
    when 'UR-1' then 32
    when 'UR-2' then 33
    when 'UR-3' then 34
    when 'UR-4' then 35
    when 'WR-1' then 36
    when 'WR-2' then 37
    when 'WR-3' then 38
  end as SFCodeHazardClass,
  case haz.class3
    when 'Carc' then 1
    when 'Corr' then 5
    when 'H.T.' then 13
    when 'Irr' then 14
    when 'OHH' then 27
    when 'RAD-alpha' then 29
    when 'RAD-beta' then 29
    when 'RAD-gamma' then 29
    when 'Sens' then 30
    when 'Tox' then 31
    when 'Aero-1' then 39
    when 'Aero-2' then 39
    when 'Aero-3' then 39
    when 'CF/D (balled)' then 39
    when 'CF/D (loose)' then 39
    when 'CL-II' then 2
    when 'CL-IIIA' then 3
    when 'CL-IIIB' then 4
    when 'CRY-FG' then 6
    when 'CRY-OXY' then 6
    when 'Exp' then 7
    when 'FG (liquified)' then 8
    when 'FG (gaseous)' then 8
    when 'FL-1A' then 9
    when 'FL-1B' then 10
    when 'FL-1C' then 11
    when 'FS' then 12
    when 'Perox-Det' then 39
    when 'Perox-I' then 23
    when 'Perox-II' then 24
    when 'Perox-III' then 25
    when 'Perox-IV' then 26
    when 'Perox-V' then 26
    when 'Oxy-1' then 17
    when 'Oxy-2' then 18
    when 'Oxy-3' then 19
    when 'Oxy-4' then 20
    when 'Oxy-Gas (liquid)' then 22
    when 'oxy-gas' then 21
    when 'Pyro' then 28
    when 'UR-1' then 32
    when 'UR-2' then 33
    when 'UR-3' then 34
    when 'UR-4' then 35
    when 'WR-1' then 36
    when 'WR-2' then 37
    when 'WR-3' then 38
  end as TFCodeHazardClass,
  case haz.class4
    when 'Carc' then 1
    when 'Corr' then 5
    when 'H.T.' then 13
    when 'Irr' then 14
    when 'OHH' then 27
    when 'RAD-alpha' then 29
    when 'RAD-beta' then 29
    when 'RAD-gamma' then 29
    when 'Sens' then 30
    when 'Tox' then 31
    when 'Aero-1' then 39
    when 'Aero-2' then 39
    when 'Aero-3' then 39
    when 'CF/D (balled)' then 39
    when 'CF/D (loose)' then 39
    when 'CL-II' then 2
    when 'CL-IIIA' then 3
    when 'CL-IIIB' then 4
    when 'CRY-FG' then 6
    when 'CRY-OXY' then 6
    when 'Exp' then 7
    when 'FG (liquified)' then 8
    when 'FG (gaseous)' then 8
    when 'FL-1A' then 9
    when 'FL-1B' then 10
    when 'FL-1C' then 11
    when 'FS' then 12
    when 'Perox-Det' then 39
    when 'Perox-I' then 23
    when 'Perox-II' then 24
    when 'Perox-III' then 25
    when 'Perox-IV' then 26
    when 'Perox-V' then 26
    when 'Oxy-1' then 17
    when 'Oxy-2' then 18
    when 'Oxy-3' then 19
    when 'Oxy-4' then 20
    when 'Oxy-Gas (liquid)' then 22
    when 'oxy-gas' then 21
    when 'Pyro' then 28
    when 'UR-1' then 32
    when 'UR-2' then 33
    when 'UR-3' then 34
    when 'UR-4' then 35
    when 'WR-1' then 36
    when 'WR-2' then 37
    when 'WR-3' then 38
  end as FFCodeHazardClass,
  case haz.class5
    when 'Carc' then 1
    when 'Corr' then 5
    when 'H.T.' then 13
    when 'Irr' then 14
    when 'OHH' then 27
    when 'RAD-alpha' then 29
    when 'RAD-beta' then 29
    when 'RAD-gamma' then 29
    when 'Sens' then 30
    when 'Tox' then 31
    when 'Aero-1' then 39
    when 'Aero-2' then 39
    when 'Aero-3' then 39
    when 'CF/D (balled)' then 39
    when 'CF/D (loose)' then 39
    when 'CL-II' then 2
    when 'CL-IIIA' then 3
    when 'CL-IIIB' then 4
    when 'CRY-FG' then 6
    when 'CRY-OXY' then 6
    when 'Exp' then 7
    when 'FG (liquified)' then 8
    when 'FG (gaseous)' then 8
    when 'FL-1A' then 9
    when 'FL-1B' then 10
    when 'FL-1C' then 11
    when 'FS' then 12
    when 'Perox-Det' then 39
    when 'Perox-I' then 23
    when 'Perox-II' then 24
    when 'Perox-III' then 25
    when 'Perox-IV' then 26
    when 'Perox-V' then 26
    when 'Oxy-1' then 17
    when 'Oxy-2' then 18
    when 'Oxy-3' then 19
    when 'Oxy-4' then 20
    when 'Oxy-Gas (liquid)' then 22
    when 'oxy-gas' then 21
    when 'Pyro' then 28
    when 'UR-1' then 32
    when 'UR-2' then 33
    when 'UR-3' then 34
    when 'UR-4' then 35
    when 'WR-1' then 36
    when 'WR-2' then 37
    when 'WR-3' then 38
  end as FifthFireCodeHazardClass,
  NULL AS SixthFireCodeHazardClass,
  NULL AS SeventhFireCodeHazardClass,
  NULL AS EighthFireCodeHazardClass,
  CASE
    WHEN ch.materialtype = 'Pure' and (lower(ch.specialflags) is null or lower(ch.specialflags) not like '%waste%') THEN 'a' 
    WHEN ch.materialtype = 'Mixture' and (lower(ch.specialflags) is null or lower(ch.specialflags) not like '%waste%') THEN 'b' 
    WHEN lower(ch.specialflags) like '%waste%' THEN 'c'
  END AS HMType,
  CASE
    WHEN ch.isotope is not null THEN 'Y'  --This is a slight change from the CAF report since there is no radioactive flag in NBT.  Need to enter an Isotope in order to have this flag = Y
    ELSE 'N'
  END AS RadioActive,
  NULL AS Curies,
  CASE
    WHEN lower(ch.physicalstate_value) = 'solid' THEN 'a'
    WHEN lower(ch.physicalstate_value) = 'liquid' THEN 'b'
    WHEN lower(ch.physicalstate_value) = 'gas' THEN 'c'
  END AS PhysicalState,
  round (max
  (case 
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'gas' then ((s.initialquantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent)) * ch.specificgravity * 2.20462)
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'solid' then s.initialquantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'liquid' then s.initialquantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * ch.specificgravity * 2.20462
	else
		case
			when lower(ch.physicalstate_value) = 'gas' then ((s.initialquantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent))*0.0353147)
			when lower(ch.physicalstate_value) = 'solid' then s.initialquantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462
			when lower(ch.physicalstate_value) = 'liquid' then s.initialquantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 0.264172
			end
		end)
		over (partition by ch.tradename, c.building_id, c.containertype_value, c.storagepressure, c.storagetemperature) ,4) AS LargestContainer,
  CASE
    WHEN 
      haz.class1 IN ('FL-1A','FL-1B','FL-1C','FS','CL-II','CL-IIIA','CL-IIIB','Pyro','Oxy-1','Oxy-2','Oxy-3','Oxy-4','Oxy-Gas (liquid)','oxy-gas','CF/D (balled)','CF/D (loose)','FG (liquified)','FG (gaseous)') 
      OR
      haz.class2 IN ('FL-1A','FL-1B','FL-1C','FS','CL-II','CL-IIIA','CL-IIIB','Pyro','Oxy-1','Oxy-2','Oxy-3','Oxy-4','Oxy-Gas (liquid)','oxy-gas','CF/D (balled)','CF/D (loose)','FG (liquified)','FG (gaseous)') 
      OR
      haz.class3 IN ('FL-1A','FL-1B','FL-1C','FS','CL-II','CL-IIIA','CL-IIIB','Pyro','Oxy-1','Oxy-2','Oxy-3','Oxy-4','Oxy-Gas (liquid)','oxy-gas','CF/D (balled)','CF/D (loose)','FG (liquified)','FG (gaseous)') 
      OR
      haz.class4 IN ('FL-1A','FL-1B','FL-1C','FS','CL-II','CL-IIIA','CL-IIIB','Pyro','Oxy-1','Oxy-2','Oxy-3','Oxy-4','Oxy-Gas (liquid)','oxy-gas','CF/D (balled)','CF/D (loose)','FG (liquified)','FG (gaseous)') 
      OR
      haz.class5 IN ('FL-1A','FL-1B','FL-1C','FS','CL-II','CL-IIIA','CL-IIIB','Pyro','Oxy-1','Oxy-2','Oxy-3','Oxy-4','Oxy-Gas (liquid)','oxy-gas','CF/D (balled)','CF/D (loose)','FG (liquified)','FG (gaseous)') 
    THEN 'Y'
    ELSE 'N'
  END AS FHCFire,
  CASE
    WHEN haz.class1 IN ('RAD-alpha','RAD-beta','RAD-gamma','Perox-Det','Perox-I','Perox-II','Perox-III','Perox-IV','Perox-V','UR-1','UR-2','UR-3','UR-4','WR-1','WR-2','WR-3')
    OR haz.class2 IN ('RAD-alpha','RAD-beta','RAD-gamma','Perox-Det','Perox-I','Perox-II','Perox-III','Perox-IV','Perox-V','UR-1','UR-2','UR-3','UR-4','WR-1','WR-2','WR-3')
    OR haz.class3 IN ('RAD-alpha','RAD-beta','RAD-gamma','Perox-Det','Perox-I','Perox-II','Perox-III','Perox-IV','Perox-V','UR-1','UR-2','UR-3','UR-4','WR-1','WR-2','WR-3')
    OR haz.class4 IN ('RAD-alpha','RAD-beta','RAD-gamma','Perox-Det','Perox-I','Perox-II','Perox-III','Perox-IV','Perox-V','UR-1','UR-2','UR-3','UR-4','WR-1','WR-2','WR-3')
    OR haz.class5 IN ('RAD-alpha','RAD-beta','RAD-gamma','Perox-Det','Perox-I','Perox-II','Perox-III','Perox-IV','Perox-V','UR-1','UR-2','UR-3','UR-4','WR-1','WR-2','WR-3')
    THEN 'Y'
    ELSE 'N'
  END AS FHCReactive,
  CASE
    WHEN haz.class1 IN ('Aero-1','Aero-2','Aero-3','Exp')
    OR haz.class2 IN ('Aero-1','Aero-2','Aero-3','Exp')
    OR haz.class3 IN ('Aero-1','Aero-2','Aero-3','Exp')
    OR haz.class4 IN ('Aero-1','Aero-2','Aero-3','Exp')
    OR haz.class5 IN ('Aero-1','Aero-2','Aero-3','Exp')
    THEN 'Y'
    ELSE 'N'
  END AS FHCPressureRelease,
  CASE
    WHEN haz.class1 IN ('Corr','H.T.','Irr','Sens','Tox')
    OR haz.class2 IN ('Corr','H.T.','Irr','Sens','Tox')
    OR haz.class3 IN ('Corr','H.T.','Irr','Sens','Tox')
    OR haz.class4 IN ('Corr','H.T.','Irr','Sens','Tox')
    OR haz.class5 IN ('Corr','H.T.','Irr','Sens','Tox')
    OR haz.class1 = 'OHH' AND haz.categ1 = 'I = Immediate (acute)'
    OR haz.class2 = 'OHH' AND haz.categ2 = 'I = Immediate (acute)'
    OR haz.class3 = 'OHH' AND haz.categ3 = 'I = Immediate (acute)'
    OR haz.class4 = 'OHH' AND haz.categ4 = 'I = Immediate (acute)'
    OR haz.class5 = 'OHH' AND haz.categ5 = 'I = Immediate (acute)'
    THEN 'Y'
    ELSE 'N'
  END AS FHCAcuteHealth,
  CASE
    WHEN haz.class1 = 'Carc'
    OR haz.class2 = 'Carc'
    OR haz.class3 = 'Carc'
    OR haz.class4 = 'Carc'
    OR haz.class5 = 'Carc'
    OR haz.class1 = 'OHH' AND haz.categ1 = 'C = Chronic (delayed)'
    OR haz.class2 = 'OHH' AND haz.categ2 = 'C = Chronic (delayed)'
    OR haz.class3 = 'OHH' AND haz.categ3 = 'C = Chronic (delayed)'
    OR haz.class4 = 'OHH' AND haz.categ4 = 'C = Chronic (delayed)'
    OR haz.class5 = 'OHH' AND haz.categ5 = 'C = Chronic (delayed)'
    THEN 'Y'
    ELSE 'N'
  END AS FHCChronicHealth,
  NULL as "FHCPhysicalFlammable",
  NULL as "FHCPhysicalGasUnderPressure",
  NULL as "FHCPhysicalExplosive",
  NULL as "FHCPhysicalSelfHeating",
  NULL as "FHCPhysicalPyrophoric",
  NULL as "FHCPhysicalOxidizer",
  NULL as "FHCPhysicalOrganicPeroxide",
  NULL as "FHCPhysicalSelfReactive",
  NULL as "FHCPhysicalPyrophoricGas",
  NULL as "FHCPhysicalCorrosiveToMetal",
  NULL as "FHCPhysContWaterEmitsFlamGas",
  NULL as "FHCPhysicalCombustibleDust",
  NULL as "FHCPhysHazardNotClassified",
  NULL as "FHCHealthCarcinogenicity",
  NULL as "FHCHealthAcuteToxicity",
  NULL as "FHCHealthReproductiveToxicity",
  NULL as "FHCHealthSkinCorrIrritation",
  NULL as "FHCHealthRespiratorySkinSens",
  NULL as "FHCHealthSeriousEyeDmgEyeIrr",
  NULL as "FHCHealthSpecTargetOrganTox",
  NULL as "FHCHealthAspirationHazard",
  NULL as "FHCHealthGermCellMutagenicity",
  NULL as "FHCHealthSimpleAsphyxiant",
  NULL as "FHCHealthHazNotClassified",
  round(sum
    (case 
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'gas' then ((c.quantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent)) * ch.specificgravity * 2.20462 / 2)
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'solid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462 / 2
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'liquid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * ch.specificgravity * 2.20462 / 2
	else
		(case
			when lower(ch.physicalstate_value) = 'gas' then ((c.quantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent))*0.0353147)
			when lower(ch.physicalstate_value) = 'solid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462 / 2
			when lower(ch.physicalstate_value) = 'liquid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 0.264172 / 2
			end)
	end)
		over (partition by ch.tradename, c.building_id, c.containertype_value, c.storagepressure, c.storagetemperature) ,4) AS AverageDailyAmount,
  round(sum
  (case 
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'gas' then (c.quantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent)) * ch.specificgravity * 2.20462
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'solid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462
	WHEN rlm.regulatorylist_name is not null and lower(ch.physicalstate_value) = 'liquid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * ch.specificgravity * 2.20462
	else
			(case
			when lower(ch.physicalstate_value) = 'gas' then ((c.quantity_val*conversionfactor_base*power(10.00000000000000000000,uom.conversionfactor_exponent))*0.0353147)
			when lower(ch.physicalstate_value) = 'solid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 2.20462
			when lower(ch.physicalstate_value) = 'liquid' then c.quantity_val * uom.conversionfactor_base * power(10.00000000000000000000,uom.conversionfactor_exponent) * 0.264172
			end)
		end)
		over (partition by ch.tradename, c.building_id, c.containertype_value, c.storagepressure, c.storagetemperature) ,4) AS MaximumDailyAmount,
  NULL AS AnnualWasteAmount,
  NULL AS StateWasteCode,
  case
	WHEN rlm.regulatorylist_name is not null then 'c'
	else
	case
	when lower(ch.physicalstate_value) = 'gas' then 'b'
	when lower(ch.physicalstate_value) = 'solid' then 'c'
	when lower(ch.physicalstate_value) = 'liquid' then 'a'
	end 
	end AS Units,
  '365' AS DaysOnSite,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'A' THEN 'Y'
    ELSE 'N'
  END AS SCAboveGroundTank,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'B' THEN 'Y'
    ELSE 'N'
  END AS SCUnderGroundTank,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'C' THEN 'Y'
    ELSE 'N'
  END AS SCTankInsideBuilding,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'D' THEN 'Y'
    ELSE 'N'
  END AS SCSteelDrum,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'E' THEN 'Y'
    ELSE 'N'
  END AS SCPlasticNonMetallicDrum,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'F' OR c.containertype_value IS NULL THEN 'Y'
    ELSE 'N'
  END AS SCCan,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'G' THEN 'Y'
    ELSE 'N'
  END AS SCCarboy,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'H' THEN 'Y'
    ELSE 'N'
  END AS SCSilo,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'I' THEN 'Y'
    ELSE 'N'
  END AS SCFiberDrum,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'J' THEN 'Y'
    ELSE 'N'
  END AS SCBag,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'K' THEN 'Y'
    ELSE 'N'
  END AS SCBox,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'L' THEN 'Y'
    ELSE 'N'
  END AS SCCylinder,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'M' THEN 'Y'
    ELSE 'N'
  END AS SCGlassBottle,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'N' THEN 'Y'
    ELSE 'N'
  END AS SCPlasticBottle,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'O' THEN 'Y'
    ELSE 'N'
  END AS SCToteBin,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'P' THEN 'Y'
    ELSE 'N'
  END AS SCTankTruckTankWagon,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'P' THEN 'Y'
    ELSE 'N'
  END AS SCTankCarRailCar,
  CASE
    WHEN SUBSTR(c.containertype_value,length(c.containertype_value)-1,1) = 'P' THEN 'Y'
    ELSE 'N'
  END AS SCOther,
  NULL as OtherStorageContainer,
  CASE
    WHEN SUBSTR(c.storagepressure_value,1,1) = '1' THEN 'a'
    WHEN SUBSTR(c.storagepressure_value,1,1) = '2' THEN 'b'
    WHEN SUBSTR(c.storagepressure_value,1,1) = '3' THEN 'c'
    ELSE NULL
  END AS StoragePressure,
  CASE
    WHEN SUBSTR(c.storagetemperature_value,1,1) = '4' THEN 'a'
    WHEN SUBSTR(c.storagetemperature_value,1,1) = '5' THEN 'b'
    WHEN SUBSTR(c.storagetemperature_value,1,1) = '6' THEN 'c'
    WHEN SUBSTR(c.storagetemperature_value,1,1) = '7' THEN 'd'
    ELSE NULL
  END AS StorageTemperature,
  cc.HC1PercentByWeight,
  cc.HC1Name,
  cc.HC1EHS,
  cc.HC1CAS,
  cc.HC2PercentByWeight,
  cc.HC2Name,
  cc.HC2EHS,
  cc.HC2CAS,
  cc.HC3PercentByWeight,
  cc.HC3Name,
  cc.HC3EHS,
  cc.HC3CAS,
  cc.HC4PercentByWeight,
  cc.HC4Name,
  cc.HC4EHS,
  cc.HC4CAS,
  cc.HC5PercentByWeight,
  cc.HC5Name,
  cc.HC5EHS,
  cc.HC5CAS,
  NULL AS ChemicalDescriptionComment,
  NULL AS AdditionalMixtureComponents,
  NULL AS CCLID,
  NULL AS USEPASRSNumber,
  ch.DOTCODE AS DOTHazClassID,
  ch.nfpa_f as "NFPA Fire",
  ch.nfpa_h as "NFPA Health",
  ch.nfpa_r as "NFPA Reactive",
  ch.nfpa_s as "NFPA Special",
  ch.v1hmisfire as "HMIS - Fire",
  ch.v1hmishealth as "HMIS - Health",
  ch.v1hmisphysical as "HMIS - Physical"  
FROM 
  (--extract builing name from container and get distinct container information
  select c.barcode, c.size1_id, c.material_id, b.nodeid as building_id, REGEXP_SUBSTR(REGEXP_REPLACE(max(c.location), ' > ', '>'), '[^>]+', 1, 2) as ChemicalLocation, 
    c.containertype_value, c.storagepressure, c.storagetemperature, c.quantity_uomid, c.SPECIFICGRAVITY_VALUE, c.quantity_val, c.storagepressure_value, c.STORAGETEMPERATURE_VALUE, r.name		
  from container c
    join building b on (case when instr(c.location, ' >',1,2) = 0 then c.location else substr(c.location,1,INSTR(c.location, ' >', 1, 2)-1) end = b.fullpath) 
	left outer join room r on (substr(c.location,1,INSTR(c.location, ' >', 1, 2)-1) || ' > ' ||
		case 
		when instr(c.location,' > ',1,2)>0 and instr(c.location,' > ',1,3)=0 then substr(c.location,instr(c.location,' > ',1,2)+3)
		when instr(c.location,' > ',1,2)>0 and instr(c.location,' > ',1,3)>0 then substr(c.location,instr(c.location,' > ',1,2)+3,(instr(c.location,' > ',1,3)-1)-(instr(c.location,' > ',1,2)+2))
		else null
		end = r.fullpath)
	--join vwgetinvgrpidforlocation v1 on (v1.nodeid=c.location_id) join vwViewableinvGrpByUser v2 on (v2.invgrpid=v1.invgrpid and v2.viewable='Y' and v2.userid={userid})  --filter by InvGroup
  where c.obsolete='0' and c.disposed<>'Y' and lower(c.location) like 'drum%'
    group by c.barcode, c.size1_id, c.material_id,  b.nodeid, c.containertype_value, c.storagepressure, c.storagetemperature,c.quantity_uomid, c.SPECIFICGRAVITY_VALUE, c.quantity_val, c.storagepressure_value,c.STORAGETEMPERATURE_VALUE,r.name) c
  join chemical ch on c.material_id=ch.nodeid 
  join unitofmeasureclass uom on (c.quantity_uomid = uom.nodeid)
  join size1 s on (c.size1_id=s.nodeid)
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
        and (mcomp.cersreport  = '1' or mcomp.cersreport  = 'Yes' or lower(mcomp.cersreport) = 'y')
      group by mcomp.mixture_id)x) cc on (cc.mixture_id = ch.nodeid)
  join (select  --split chemical hazard class and hazard category data
	  nodeid,
	  regexp_substr(hazardclasses,'[^,]+', 1, 1) as class1,
	  regexp_substr(hazardclasses,'[^,]+', 1, 2) as class2,
	  regexp_substr(hazardclasses,'[^,]+', 1, 3) as class3,
	  regexp_substr(hazardclasses,'[^,]+', 1, 4) as class4,
	  regexp_substr(hazardclasses,'[^,]+', 1, 5) as class5,
	  regexp_substr(hazardcategories,'[^,]+', 1, 1) as categ1,
	  regexp_substr(hazardcategories,'[^,]+', 1, 2) as categ2,
	  regexp_substr(hazardcategories,'[^,]+', 1, 3) as categ3,
	  regexp_substr(hazardcategories,'[^,]+', 1, 4) as categ4,
	  regexp_substr(hazardcategories,'[^,]+', 1, 5) as categ5
	  from chemical) haz on (haz.nodeid = ch.nodeid)
  join (select listagg (nodeid, ', ') within group (order by tradename) as material_id, tradename
    from chemical
    where obsolete = 0
    group by tradename) mat on (mat.tradename = ch.tradename)
left outer join regulatorylistmember rlm on (ch.nodeid=rlm.chemical_id and lower(rlm.regulatorylist_name)='ca acutely hazardous materials')
ORDER BY
  ch.tradename, c.ChemicalLocation