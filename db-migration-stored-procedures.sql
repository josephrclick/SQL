--Procedures written for Napa.14 - Napa.15, not compatible with Quality module.

declare c number;
begin
   select count(*) into c from user_tables where table_name = 'ROLLUPLOG';
   if c > 0 then
      execute immediate 'drop table rolluplog';
      execute immediate 'drop sequence rollup_seq';
   end if;
end;
/

create table rolluplog (logid varchar(50), logtext varchar(500));

create sequence rollup_seq
MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  CACHE 200;
commit;

create or replace function NextSeqNoByTablename(sTableName in varchar2) return number
  authid current_user is
  Result number; dTableColID VARCHAR2(50);
begin

  SELECT TABLECOLID INTO dTableColID FROM data_dictionary
  WHERE COLUMNTYPE = 'pk' and lower(TABLENAME) = lower(sTableName);
  execute immediate 'select seq_' || dTableColID || '.nextval from dual' into Result;

  return(Result);
end NextSeqNoByTablename;
/

CREATE OR REPLACE PROCEDURE remove_duplicate_propvals AUTHID CURRENT_USER IS
CURSOR c_main_cursor IS SELECT materialid, propertyid, count(deleted) cnt FROM properties_values WHERE deleted = '0' GROUP BY materialid, propertyid HAVING count(deleted) > 1;
BEGIN
	FOR rec IN c_main_cursor
		LOOP
		
			UPDATE properties_values SET deleted = '1' WHERE materialid = rec.materialid AND propertyid = rec.propertyid AND NOT propertiesvaluesid = (SELECT MAX(propertiesvaluesid) FROM 
				properties_values WHERE materialid = rec.materialid AND propertyid = rec.propertyid AND deleted = '0');
			COMMIT;
		
		END LOOP;
COMMIT;
END;
/

create or replace PROCEDURE remove_vendor_nocontainer (v_id in number, verbose in varchar) AUTHID CURRENT_USER IS
contcount decimal;
BEGIN
	select count(containerid) into contcount from containers where deleted='0' and containerclass='container' and
		packdetailid in (select packdetailid from packdetail where deleted='0' and packageid in (select 
		packageid from packages where deleted='0' and (manufacturerid = v_id or supplierid = v_id)));

	if (contcount = 0) then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing package+packdetail+vendor for vendorid ' || v_id);
		end if; -- End of verbose output
		
		update packdetail set deleted='1' where packageid in (select packageid from packages where deleted='0' and (manufacturerid = v_id or supplierid = v_id));
		update packages set deleted='1' where deleted='0' and (manufacturerid = v_id or supplierid = v_id);
		update vendors set deleted='1' where deleted='0' and vendorid = v_id;
	else
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Vendor ID ' || v_id || ' has active dependencies, skipping');
		end if; -- End of verbose output
	end if;
commit;
END;
/

create or replace procedure merge_dupe_vendors authid current_user as
cursor c_main_cursor is select vendorid, vendorname, nvl(division,'*blank*') as division from vendors where deleted='0' order by vendorname;
lowID number;

begin
  for rec in c_main_cursor
    loop
      select min(vendorid) into lowID from vendors where deleted='0' and lower(vendorname)=lower(rec.vendorname) and lower(nvl(division,'*blank*'))=lower(rec.division);
      
      if (lowID <> rec.vendorid) then
        
        update packages set manufacturerid=lowID where manufacturerid=rec.vendorid;
        update packages set supplierid=lowID where supplierid=rec.vendorid;
        --Remove old vendor IDs
        update vendors set deleted='1' where vendorid = rec.vendorid;
      end if;
     END LOOP;
  commit;
end;
/


create or replace PROCEDURE remove_uom (uom_id in number, verbose in varchar) AUTHID CURRENT_USER IS
uomcount decimal;
BEGIN
	select count(containerid) into uomcount from containers where deleted='0' and packdetailid in (select packdetailid from packdetail where unitofmeasureid=uom_id);

	if (uomcount = 0) then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing unit of measure ' || uom_id);
		end if; -- End of verbose output
		update dispensed_unit set deleted='1' where unitofmeasureid=uom_id;
		update requisitions_items set deleted='1' where unitofmeasureid=uom_id;
		update packdetail set deleted='1' where unitofmeasureid=uom_id;
		update methods set deleted='1' where unitofmeasureid=uom_id;
		update samples set deleted='1' where unitofmeasureid=uom_id;
		update dispensed_qtykg set deleted='1' where unitofmeasureid=uom_id;
		update dispensed set deleted='1' where unitofmeasureid=uom_id;
		update regulated_casnos set deleted='1' where unitofmeasureid=uom_id;
		update receipt_lots set deleted='1' where unitofmeasureid=uom_id;
		update maxinventory_basic set deleted='1' where unitofmeasureid=uom_id;
		update units_of_measure set deleted='1' where unitofmeasureid=uom_id;
	else
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Unit of measure ' || uom_id || ' in use, skipping');
		end if; -- End of verbose output
	end if;
commit;
END;
/

create or replace PROCEDURE merge_uom (uom_old in number, uom_new in number,verbose in varchar) AUTHID CURRENT_USER IS
uomcount decimal;
BEGIN
	if (verbose = 1) then
	  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Merging unit of measure ' || uom_old || ' into ' || uom_new);
	end if; -- End of verbose output

	update dispensed_unit set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update requisitions_items set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update packdetail set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update methods set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update samples set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update dispensed_qtykg set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update dispensed set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update regulated_casnos set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update receipt_lots set unitofmeasureid=uom_new where unitofmeasureid=uom_old;
	update maxinventory_basic set unitofmeasureid=uom_new where unitofmeasureid=uom_old;

	update units_of_measure set deleted='1' where unitofmeasureid=uom_old;


commit;
END;
/

CREATE OR REPLACE PROCEDURE remove_property (prop_id in number, verbose in varchar) AUTHID CURRENT_USER IS
objtype varchar(25);


BEGIN
  select objecttype into objtype from properties where propertyid=prop_id;

	if upper(objtype) = 'MATERIAL' then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing material prop ' || prop_id);
		end if; -- End of verbose output
		update properties set deleted='1' where propertyid=prop_id;
		update properties_values set deleted='1' where propertyid=prop_id;

	elsif upper(objtype) = 'CONTAINER' then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing container prop ' || prop_id);
		end if; -- End of verbose output
		update properties set deleted='1' where propertyid=prop_id;
		update properties_values_cont set deleted='1' where propertyid=prop_id;
	
	elsif upper(objtype) = 'USER' then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing user prop ' || prop_id);
		end if; -- End of verbose output
		update properties set deleted='1' where propertyid=prop_id;
		update properties_values_user set deleted='1' where propertyid=prop_id;

	elsif upper(objtype) = 'LOT' then
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Removing lot prop ' || prop_id);
		end if; -- End of verbose output
		update properties set deleted='1' where propertyid=prop_id;
		update properties_values_lot set deleted='1' where propertyid=prop_id;
	
	else
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Invalid object type ' || objtype);
		end if; -- End of verbose output

	end if;
COMMIT;
END;
/

create or replace procedure update_reglist authid current_user is
matcount decimal;

begin
for rec in (select rl.regulatorylistid,m.materialid from regulatory_lists rl inner join regulated_casnos rc on (rc.regulatorylistid=rl.regulatorylistid) inner join materials m on (m.casno=rc.casno) where rl.deleted=0 and rl.matchtype=0 and rc.deleted=0 and m.deleted=0)
  loop
  select count(regulatorylistsmaterialsid) into matcount from jct_regulatorylists_materials where materialid=rec.materialid and regulatorylistid=rec.regulatorylistid and jct_regulatorylists_materials.deleted=0;
  if (matcount =0) then
     insert into jct_regulatorylists_materials (deleted,materialid,regulatorylistid,regulatorylistsmaterialsid) values (0,rec.materialid,rec.regulatorylistid, nextseqnobytablename('jct_regulatorylists_materials'));
  end if;
  end loop;
for rec in (select rl.regulatorylistid,m.materialid from regulatory_lists rl inner join regulated_casnos rc on (rc.regulatorylistid=rl.regulatorylistid) inner join materials m on (m.casno <> rc.casno) where rl.deleted=0 and rl.matchtype=1 and rc.deleted=0 and m.deleted=0)
  loop
  select count(regulatorylistsmaterialsid) into matcount from jct_regulatorylists_materials where materialid=rec.materialid and regulatorylistid=rec.regulatorylistid and jct_regulatorylists_materials.deleted=0;
  if (matcount =0) then
     insert into jct_regulatorylists_materials (deleted,materialid,regulatorylistid,regulatorylistsmaterialsid) values (0,rec.materialid,rec.regulatorylistid, nextseqnobytablename('jct_regulatorylists_materials'));
  end if;
  end loop;
for rec in (select rl.regulatorylistid,m.materialid from regulatory_lists rl join regulatory_lists_arielcodes rla on (rl.regulatorylistid=rla.regulatorylistid and rla.deleted='0') join ariel_detail ad on (rla.fmtname=ad.fmtname and ad.deleted='0') join materials m on (m.casno = ad.cas and m.deleted='0') where rl.deleted=0 and rl.matchtype=0)
  loop
  select count(regulatorylistsmaterialsid) into matcount from jct_regulatorylists_materials where materialid=rec.materialid and regulatorylistid=rec.regulatorylistid and jct_regulatorylists_materials.deleted=0;
  if (matcount =0) then
     insert into jct_regulatorylists_materials (deleted,materialid,regulatorylistid,regulatorylistsmaterialsid) values (0,rec.materialid,rec.regulatorylistid, nextseqnobytablename('jct_regulatorylists_materials'));
  end if;
  end loop;
commit;
end;
/

create or replace procedure make_mat_global (mat_id in number, verbose in varchar) authid current_user is
begin
  
  if (nvl(mat_id, 0) > 0) then
    --Valid material ID check
    if (verbose = 1) then
      insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Updating material ID ' || mat_id || ' to Global');
    end if; -- End of verbose output
    
    --Update material to Global scope
    update materials set pendingupdate=1, reviewstatusname='Global - site reviewed' where materialid=mat_id;
    commit;
  else
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---ERROR: Material ID > 0 required. ' || mat_id || ' provided.');
  end if;
end;
/

create or replace procedure merge_vendor (oldvid in number, newvid in number) authid current_user is
 verbose number(1) := 1;
begin
  
  if (oldvid <> newvid) then
	  
	  if (nvl(oldvid, 0) > 0 and nvl(newvid, 0) > 0) then
		--Valid material ID check
		if (verbose = 1) then
		  insert into rolluplog (logid, logtext) values (rollup_seq.nextval, 'Merging vendor ID ' || oldvid || ' into ID ' || newvid);
		end if; -- End of verbose output
		--Update packages
		update packages set manufacturerid=newvid where manufacturerid=oldvid;
		update packages set supplierid=newvid where supplierid=oldvid;
		--Remove old vendor ID
		update vendors set deleted='1' where vendorid=oldvid;	
		commit;
	  else
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, 'ERROR: Vendor IDs > 0 required. ' || oldvid || '&' || newvid || ' provided.');
	  end if;
  else
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, 'ERROR: Matching Vendor IDs ' || oldvid || '&' || newvid || ' provided.');
  end if;
end;
/

create or replace procedure purge_site (sid in number) authid current_user is
 verbose number(1) := 1;
begin
  
  if (nvl(sid, 0) > 0) then
    --Valid Site ID check
    if (verbose = 1) then
      insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '-Removing site ID ' || sid);
    end if; -- End of verbose output
	
    --Update work_units
	update work_units set deleted='1' where siteid=sid;

	--update inventory groups
	update inventory_groups set deleted='1' where workunitid in (select workunitid from work_units where siteid=sid);
	
	--Delete materials and children
    if (verbose = 1) then
      insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Removing site ID ' || sid || ' materials, packages, standards');
    end if; -- End of verbose output

	update materials set deleted='1' where creationsiteid=sid and reviewstatusname='Local';
	update materials_synonyms set deleted='1' where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local');
	update materials_casnos set deleted='1' where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local');
	update properties_values set deleted='1' where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local');
	update standards set deleted='1' where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local');
	update packages set deleted='1' where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local');
	update packdetail set deleted='1' where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local'));
	update approved_vendors set deleted='1' where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local'));
    if (verbose = 1) then
      insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Removing site ID ' || sid || ' container, lots, cont props');
    end if; -- End of verbose output

	update containers set deleted='1' where packdetailid in (select packdetailid from packdetail where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local')));
	update receipt_lots set deleted='1' where receiptlotid in (select distinct(receiptlotid) from containers where packdetailid in (select packdetailid from packdetail where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local'))));
	update dispensed set deleted='1' where sourcecontainerid in (select containerid from containers where packdetailid in (select packdetailid from packdetail where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local'))));
	update properties_values_cont set deleted='1' where containerid in (select containerid from containers where packdetailid in (select packdetailid from packdetail where packageid in (select packageid from packages where materialid in (select materialid from materials where creationsiteid=sid and reviewstatusname='Local'))));
    if (verbose = 1) then
      insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Removing site ID ' || sid || ' locations');
    end if; -- End of verbose output

	--Delete locations
	update locations_level2 set deleted='1' where locationlevel2id in (select locationlevel2id from locations where locationlevel1id in (select locationlevel1id from locations_level1 where siteid=sid));
	update locations_level3 set deleted='1' where locationlevel3id in (select locationlevel3id from locations where locationlevel1id in (select locationlevel1id from locations_level1 where siteid=sid));
	update locations_level4 set deleted='1' where locationlevel4id in (select locationlevel4id from locations where locationlevel1id in (select locationlevel1id from locations_level1 where siteid=sid));
	update locations_level5 set deleted='1' where locationlevel5id in (select locationlevel5id from locations where locationlevel1id in (select locationlevel1id from locations_level1 where siteid=sid));
	update locations_level1 set deleted='1' where siteid=sid;
	update locations set deleted='1' where locationlevel1id in (select locationlevel1id from locations_level1 where siteid=sid);
	
	
	update sites set deleted='1' where siteid=sid;
		
    commit;
  else
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, 'ERROR: Site ID > 0 required. ' || sid || ' provided.');
  end if;
end;
/

create or replace procedure fixup_packvendors authid current_user is
 minvid number(10);
begin
  
  for rec in (select p.packageid, p.manufacturerid, p.supplierid, vm.vendorname as manufname, vs.vendorname as suppname from packages p
    join vendors vm on (p.manufacturerid=vm.vendorid) join vendors vs on (p.supplierid=vs.vendorid) where p.deleted='0')
	loop
		select min(vendorid) into minvid from vendors where lower(vendorname)=lower(rec.manufname) and deleted='0';
    
    if (minvid <> rec.manufacturerid) then
      update packages set manufacturerid=minvid where packageid=rec.packageid;
    end if;
    
    select min(vendorid) into minvid from vendors where lower(vendorname)=lower(rec.suppname) and deleted='0';
    
    if (minvid <> rec.supplierid) then
      update packages set supplierid=minvid where packageid=rec.packageid;
    end if;
    
	end loop;
end;
/




create or replace procedure merge_mat (s_mat_id in number, t_mat_id in number, verbose in varchar) authid current_user is

matchcount number;
matchrecord number;

begin
  dbms_output.enable(NULL);
  if (nvl(s_mat_id, 0) > 0 and nvl(t_mat_id, 0) > 0) then
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---Merging ID ' || s_mat_id || ' into ID ' || t_mat_id);

    --MERGE COMPONENTS
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging Components');
	end if; -- End of verbose output
			
	for rec in (select componentcasnoid, componentmaterialid, lower(componentname) as componentname from component_casnos where deleted='0' and materialid=s_mat_id)
	loop
		select count(componentcasnoid) into matchcount from component_casnos where deleted='0' and materialid=t_mat_id and (componentmaterialid=rec.componentmaterialid or lower(componentname)=rec.componentname);
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving component_cas ID ' || rec.componentcasnoid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update component_casnos set materialid=t_mat_id where componentcasnoid=rec.componentcasnoid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding duplicate component_cas ID ' || rec.componentcasnoid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update component_casnos set deleted='1' where componentcasnoid=rec.componentcasnoid;
		end if;     
	end loop;
	for rec in (select componentcasnoid, componentmaterialid, lower(componentname) as componentname from components where deleted='0' and materialid=s_mat_id)
	loop
		select count(componentcasnoid) into matchcount from components where deleted='0' and materialid=t_mat_id and (componentmaterialid=rec.componentmaterialid or lower(componentname)=rec.componentname);
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving component ID ' || rec.componentcasnoid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update components set materialid=t_mat_id where componentcasnoid=rec.componentcasnoid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding duplicate component ID ' || rec.componentcasnoid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update components set deleted='1' where componentcasnoid=rec.componentcasnoid;
		end if;     
	end loop;
	--END MERGE COMPONENTS
	
	--MERGE CAS VALUES
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging CAS');
	end if; -- End of verbose output
 	for rec in (select materialcasnoid, lower(casno) as casno from materials_casnos where deleted='0' and materialid=s_mat_id)
	loop
		select count(materialcasnoid) into matchcount from materials_casnos where deleted='0' and materialid=t_mat_id and lower(casno)=rec.casno;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving CAS ID ' || rec.materialcasnoid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update materials_casnos set materialid=t_mat_id where materialcasnoid=rec.materialcasnoid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding duplicate CAS ID ' || rec.materialcasnoid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update materials_casnos set deleted='1' where materialcasnoid=rec.materialcasnoid;
		end if;     
	end loop;
	--END CAS MERGE
	
    --MERGE SYNONYMS
 	for rec in (select materialsynonymid, lower(synonymname) as synonymname from materials_synonyms where deleted='0' and materialid=s_mat_id)
	loop
		if (verbose = 1) then
			insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging Synonyms');
		end if; -- End of verbose output
		select count(materialsynonymid) into matchcount from materials_synonyms where deleted='0' and materialid=t_mat_id and lower(synonymname)=rec.synonymname;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving synonym ID ' || rec.materialsynonymid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update materials_synonyms set materialid=t_mat_id where materialsynonymid=rec.materialsynonymid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding duplicate synonym ID ' || rec.materialsynonymid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update materials_synonyms set deleted='1' where materialsynonymid=rec.materialsynonymid;
			update containers set materialsynonymid=(select materialsynonymid from materials_synonyms where deleted='0' and materialid=t_mat_id and lower(synonymname)=rec.synonymname)
				where materialsynonymid=rec.materialsynonymid;
		end if;     
	end loop;
	--END SYNONYMS MERGE
 
    --MOVE PACKAGES
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving Packages');
	end if; -- End of verbose output
	if (verbose = 1) then
        insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving packages from mat ID ' || s_mat_id || ' to ' || t_mat_id);
	end if; -- End of verbose output
	update packages set materialid=t_mat_id where materialid=s_mat_id;
	--END PACKAGES MOVE

    --MERGE DOCUMENTS
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging Documents');
	end if; -- End of verbose output
    select count(documentid) into matchcount from documents where deleted='0' and materialid=t_mat_id and packageid is null and doctype='MSDS';
       if (matchcount = 0) then
         if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving SDS from mat ID ' || s_mat_id || ' to ' || t_mat_id);
		 end if; -- End of verbose output
	     update documents set materialid=t_mat_id where materialid=s_mat_id and packageid is null and doctype='MSDS';
       else
         if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----SDS exists on mat ID ' || t_mat_id || ' archiving');
         end if; -- End of verbose output
	     update documents set deleted='1' where materialid=s_mat_id and packageid is null and doctype='MSDS';
       end if;
    ---MOVE ALL OTHER DOCS
    if (verbose = 1) then
        insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving non-SDS docs from mat ID ' || s_mat_id || ' to ' || t_mat_id);
    end if; -- End of verbose output
	update documents set materialid=t_mat_id where materialid=s_mat_id;
    --END DOCUMENTS MERGE

    --MOVE STANDARDS
    if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving Standards');
        insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving standards from mat ID ' || s_mat_id || ' to ' || t_mat_id);
    end if; -- End of verbose
	update standards set isdefault=0, obsolete=1, materialid=t_mat_id where materialid=s_mat_id;
	--END STANDARDS MOVE

    --MERGE GHS
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging GHS');
    end if; -- End of verbose
	
	for rec in (select ghsphrasematsiteid, siteid, ghsphraseid from jct_ghsphrase_matsite where deleted='0' and materialid=s_mat_id)
	loop
		select count(ghsphrasematsiteid) into matchcount from jct_ghsphrase_matsite where deleted='0' and materialid=t_mat_id and ghsphraseid=rec.ghsphraseid and siteid=rec.siteid;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving Phrase ID ' || rec.ghsphrasematsiteid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_ghsphrase_matsite set materialid=t_mat_id where ghsphrasematsiteid=rec.ghsphrasematsiteid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding duplicate phrase ID ' || rec.ghsphrasematsiteid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_ghsphrase_matsite set deleted='1' where ghsphrasematsiteid=rec.ghsphrasematsiteid;
		end if;     
	end loop;

	for rec in (select ghspictomatsiteid, siteid, ghspictoid from jct_ghspictos_matsite where deleted='0' and materialid=s_mat_id)
	loop
		select count(ghspictomatsiteid) into matchcount from jct_ghspictos_matsite where deleted='0' and materialid=t_mat_id and ghspictoid=rec.ghspictoid and siteid=rec.siteid;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving picto ID ' || rec.ghspictoid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_ghspictos_matsite set materialid=t_mat_id where ghspictomatsiteid=rec.ghspictomatsiteid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding picto ID ' || rec.ghspictoid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_ghspictos_matsite set deleted='1' where ghspictomatsiteid=rec.ghspictomatsiteid;
		end if;     
	end loop;

	for rec in (select ghssignalmatsiteid, siteid, ghssignalid from jct_ghssignal_matsite where deleted='0' and materialid=s_mat_id)
	loop
		select count(ghssignalmatsiteid) into matchcount from jct_ghssignal_matsite where deleted='0' and materialid=t_mat_id and ghssignalid=rec.ghssignalid and siteid=rec.siteid;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving picto ID ' || rec.ghssignalid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_ghssignal_matsite set materialid=t_mat_id where ghssignalmatsiteid=rec.ghssignalmatsiteid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding picto ID ' || rec.ghssignalid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_ghssignal_matsite set deleted='1' where ghssignalmatsiteid=rec.ghssignalmatsiteid;
		end if;     
	end loop;
	--END GHS MERGE

    --MERGE PROPERTIES
	for rec in (select propertiesvaluesid, propertyid from properties_values where deleted='0' and materialid=s_mat_id)
	loop
		if (verbose = 1) then
			insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging Properties');
		end if; -- End of verbose
		select count(propertiesvaluesid) into matchcount from properties_values where deleted='0' and materialid=t_mat_id and propertyid=rec.propertyid and deleted='0'
		and (propvaltext is not null 
			or propvaldate is not null 
			or propvalnumber is not null 
			or field1 is not null 
			or field2 is not null 
			or field3 is not null 
			or field4 is not null 
			or field5 is not null);
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving propval ID ' || rec.propertiesvaluesid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update properties_values set deleted='1' where deleted='0' and materialid=t_mat_id and propertyid=rec.propertyid;
			update properties_values set materialid=t_mat_id where propertiesvaluesid=rec.propertiesvaluesid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding propval ID ' || rec.propertiesvaluesid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update properties_values set deleted='1' where propertiesvaluesid=rec.propertiesvaluesid;
		end if;     
	end loop;
	--END MERGE PROPERTIES

    --MERGE FIRE REPORTING
	for rec in (select hazdataid from cispro_hazdata where deleted='0' and materialid=s_mat_id)
	loop
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging Hazard Data Values');
    end if; -- End of verbose
		select count(hazdataid) into matchcount from cispro_hazdata where deleted='0' and materialid=t_mat_id and deleted='0'
		and (classes is not null or categories is not null);
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving Hazard Data ID ' || rec.hazdataid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update cispro_hazdata set deleted='1' where deleted='0' and materialid=t_mat_id;
			update cispro_hazdata set materialid=t_mat_id where hazdataid=rec.hazdataid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding Hazard Data ID ' || rec.hazdataid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update cispro_hazdata set deleted='1' where hazdataid=rec.hazdataid;
		end if;     
	end loop;
	--END MERGE FIRE REPORTING
    
	--MERGE JUNCTIONS
	if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging any misc junction records');
    end if; -- End of verbose
	
	for rec in (select jctrsphrasesmaterialid, rsphraseid from jct_rsphrases_materials where deleted='0' and materialid=s_mat_id)
	loop
		select count(jctrsphrasesmaterialid) into matchcount from jct_rsphrases_materials where materialid=t_mat_id and deleted='0' and rsphraseid=rec.rsphraseid;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving phrase ID ' || rec.rsphraseid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_rsphrases_materials set materialid=t_mat_id where jctrsphrasesmaterialid=rec.jctrsphrasesmaterialid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding phrase ID ' || rec.rsphraseid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_rsphrases_materials set deleted='1' where jctrsphrasesmaterialid=rec.jctrsphrasesmaterialid;
		end if;     
	end loop;
	
	for rec in (select jctpictogramsmaterialid, pictogramid from jct_pictograms_materials where deleted='0' and materialid=s_mat_id)
	loop
		select count(jctpictogramsmaterialid) into matchcount from jct_pictograms_materials where materialid=t_mat_id and deleted='0' and pictogramid=rec.pictogramid;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving picto ID ' || rec.pictogramid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_pictograms_materials set materialid=t_mat_id where jctpictogramsmaterialid=rec.jctpictogramsmaterialid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding picto ID ' || rec.pictogramid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_pictograms_materials set deleted='1' where jctpictogramsmaterialid=rec.jctpictogramsmaterialid;
		end if;     
	end loop;
	
	for rec in (select jctgraphicsmaterialid, graphicsetid, graphicsettype from jct_graphics_materials where deleted='0' and materialid=s_mat_id)
	loop
		select count(jctgraphicsmaterialid) into matchcount from jct_graphics_materials where materialid=t_mat_id and deleted='0' and graphicsetid=rec.graphicsetid and graphicsettype=rec.graphicsettype;
		if (matchcount=0) then
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving graphic type/ID ' || rec.graphicsettype || '/' || rec.graphicsetid || ' from mat ID ' || s_mat_id || ' to ' || t_mat_id);
			end if; -- End of verbose output
			update jct_graphics_materials set materialid=t_mat_id where jctgraphicsmaterialid=rec.jctgraphicsmaterialid;
		else
			if (verbose = 1) then
				insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding safety resource ID ' || rec.graphicsettype || '/' || rec.graphicsetid || ' from mat ID ' || s_mat_id);
			end if; -- End of verbose output
			update jct_graphics_materials set deleted='1' where jctgraphicsmaterialid=rec.jctgraphicsmaterialid;
		end if;     
	end loop;
	--END JUNCTION MERGES
	

	--MERGE STRUCTURE SKEYS
	select count(skeyrowid) into matchcount from skeys_rows where materialid=t_mat_id and deleted='0';
	if (matchcount=0) then
		if (verbose = 1) then
			insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving skeys from mat ID ' || s_mat_id || ' to ' || t_mat_id);
		end if; -- End of verbose output
		update skeys_rows set materialid=t_mat_id;
	else
		if (verbose = 1) then
			insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding skeys from mat ID ' || s_mat_id);
		end if; -- End of verbose output
		update skeys_rows set deleted='1' where materialid=s_mat_id;
	end if;  

	
	--MOVE MAX INVENTORY LEVELS
	update maxinventory_basic set materialid=t_mat_id where materialid=s_mat_id;

	--MERGE MATERIAL ATTRIBUTES
	for rec in (select 
	casno,
	expireinterval,
	expireintervalunits,
	istier2,
	healthcode,
	firecode,
	reactivecode,
	specific_code,
	nfpacode,
	storage_conditions,
	struct_pict,
	ctab,
	valid_ctab,
	ppe,
	target_organs,
	formula,
	physical_description,
	physical_state,
	has_activity,
	molecular_weight,
	specific_gravity,
	ph,
	boiling_point,
	melting_point,
	aqueous_solubility,
	flash_point,
	vapor_pressure,
	vapor_density,
  LOB_TYPE,
	BIOSAFETY,
	COLOR,
	COMPRESSED_GAS,
	DOT_CODE,
	EXPOSURE_LIMITS,
	GOI,
	HAZARDS,
	INVENTORYREQUIRED,
	KEEPATSTATUS,
	KEYWORDS,
	MODEL,
	OPENEXPIREINTERVAL,
	OPENEXPIREINTERVALUNITS,
	OTHERREFERENCENO,
	PRODUCTBRAND,
	PRODUCTCATEGORY,
	PRODUCTTYPE,
	REFNO,
	RESEARCH_NOTES,
	SAFETY_NOTES,
	SPEC_NO,
	SPECIES,
	TRANSGENIC,
	TYPE,
	VARIETY,
	VECTORS,
	SMILES,
	ASSETCREATIONNAME
	from materials where materialid=s_mat_id)
	loop
	
	update materials set casno=rec.casno where materialid=t_mat_id and casno is null;
	update materials set expireinterval=rec.expireinterval where materialid=t_mat_id and expireinterval is null;
	update materials set expireintervalunits=rec.expireintervalunits where materialid=t_mat_id and expireintervalunits is null;
	update materials set istier2=rec.istier2 where materialid=t_mat_id and istier2 is null;
	update materials set healthcode=rec.healthcode where materialid=t_mat_id and healthcode is null;
	update materials set firecode=rec.firecode where materialid=t_mat_id and firecode is null;
	update materials set reactivecode=rec.reactivecode where materialid=t_mat_id and reactivecode is null;
	update materials set specific_code=rec.specific_code where materialid=t_mat_id and specific_code is null;
	update materials set nfpacode=rec.nfpacode where materialid=t_mat_id and nfpacode is null;
	update materials set storage_conditions=rec.storage_conditions where materialid=t_mat_id and storage_conditions is null;
	update materials set struct_pict=rec.struct_pict where materialid=t_mat_id and struct_pict is null;
	update materials set ctab=rec.ctab where materialid=t_mat_id and ctab is null;
	update materials set valid_ctab=rec.valid_ctab where materialid=t_mat_id and valid_ctab is null;
	update materials set ppe=rec.ppe where materialid=t_mat_id and ppe is null;
	update materials set target_organs=rec.target_organs where materialid=t_mat_id and target_organs is null;
	update materials set formula=rec.formula where materialid=t_mat_id and formula is null;
	update materials set physical_description=rec.physical_description where materialid=t_mat_id and physical_description is null;
	update materials set physical_state=rec.physical_state where materialid=t_mat_id and physical_state is null;
	update materials set has_activity=rec.has_activity where materialid=t_mat_id and has_activity is null;
	update materials set molecular_weight=rec.molecular_weight where materialid=t_mat_id and molecular_weight is null;
	update materials set ph=rec.ph where materialid=t_mat_id and ph is null;
	update materials set boiling_point=rec.boiling_point where materialid=t_mat_id and boiling_point is null;
	update materials set melting_point=rec.melting_point where materialid=t_mat_id and melting_point is null;
	update materials set aqueous_solubility=rec.aqueous_solubility where materialid=t_mat_id and aqueous_solubility is null;
	update materials set flash_point=rec.flash_point where materialid=t_mat_id and flash_point is null;
	update materials set vapor_pressure=rec.vapor_pressure where materialid=t_mat_id and vapor_pressure is null;
	update materials set vapor_density=rec.vapor_density where materialid=t_mat_id and vapor_density is null;
	update materials set BIOSAFETY=rec.BIOSAFETY where materialid=t_mat_id and BIOSAFETY is null;
	update materials set COLOR=rec.COLOR where materialid=t_mat_id and COLOR is null;
	update materials set COMPRESSED_GAS=rec.COMPRESSED_GAS where materialid=t_mat_id and COMPRESSED_GAS is null;
	update materials set DOT_CODE=rec.DOT_CODE where materialid=t_mat_id and DOT_CODE is null;
	update materials set EXPOSURE_LIMITS=rec.EXPOSURE_LIMITS where materialid=t_mat_id and EXPOSURE_LIMITS is null;
	update materials set GOI=rec.GOI where materialid=t_mat_id and GOI is null;
	update materials set HAZARDS=rec.HAZARDS where materialid=t_mat_id and HAZARDS is null;
	update materials set INVENTORYREQUIRED=rec.INVENTORYREQUIRED where materialid=t_mat_id and INVENTORYREQUIRED is null;
	update materials set KEEPATSTATUS=rec.KEEPATSTATUS where materialid=t_mat_id and KEEPATSTATUS is null;
	update materials set KEYWORDS=rec.KEYWORDS where materialid=t_mat_id and KEYWORDS is null;
	update materials set MODEL=rec.MODEL where materialid=t_mat_id and MODEL is null;
	update materials set OPENEXPIREINTERVAL=rec.OPENEXPIREINTERVAL where materialid=t_mat_id and OPENEXPIREINTERVAL is null;
	update materials set OPENEXPIREINTERVALUNITS=rec.OPENEXPIREINTERVALUNITS where materialid=t_mat_id and OPENEXPIREINTERVALUNITS is null;
	update materials set OTHERREFERENCENO=rec.OTHERREFERENCENO where materialid=t_mat_id and OTHERREFERENCENO is null;
	update materials set PRODUCTBRAND=rec.PRODUCTBRAND where materialid=t_mat_id and PRODUCTBRAND is null;
	update materials set PRODUCTCATEGORY=rec.PRODUCTCATEGORY where materialid=t_mat_id and PRODUCTCATEGORY is null;
	update materials set PRODUCTTYPE=rec.PRODUCTTYPE where materialid=t_mat_id and PRODUCTTYPE is null;
	update materials set REFNO=rec.REFNO where materialid=t_mat_id and REFNO is null;
	update materials set RESEARCH_NOTES=rec.RESEARCH_NOTES where materialid=t_mat_id and RESEARCH_NOTES is null;
	update materials set SAFETY_NOTES=rec.SAFETY_NOTES where materialid=t_mat_id and SAFETY_NOTES is null;
	update materials set SPEC_NO=rec.SPEC_NO where materialid=t_mat_id and SPEC_NO is null;
	update materials set TARGET_ORGANS=rec.TARGET_ORGANS where materialid=t_mat_id and TARGET_ORGANS is null;
	update materials set TRANSGENIC=rec.TRANSGENIC where materialid=t_mat_id and TRANSGENIC is null;
	update materials set TYPE=rec.TYPE where materialid=t_mat_id and TYPE is null;
	update materials set VARIETY=rec.VARIETY where materialid=t_mat_id and VARIETY is null;
	update materials set VECTORS=rec.VECTORS where materialid=t_mat_id and VECTORS is null;
	update materials set SMILES=rec.SMILES where materialid=t_mat_id and SMILES is null;
	update materials set ASSETCREATIONNAME=rec.ASSETCREATIONNAME where materialid=t_mat_id and ASSETCREATIONNAME is null;
	update materials set LOB_TYPE=rec.LOB_TYPE where materialid=t_mat_id and LOB_TYPE is null;
	update materials set specific_gravity=rec.specific_gravity where materialid=t_mat_id and (specific_gravity is null or specific_gravity=1);
	
	end loop;

	
	
	
	update materials set pendingupdate=1, lastupdated=SYSDATE where materialid=t_mat_id;
	
	--LAY OLD MATERIAL TO REST
	update materials set deleted='1' where materialid=s_mat_id;
	
	
	-- Omitted obsolete or quality related tables
	--- constituent_mil
	--- regional_names
	--- standards_templates
	--- clearances
	--- container_totals
	--- req_import_view
	--- jct_ghs_materials
	--- jct_tier2_site
	
	-- Unused module tables
	--- requisitions_items
	--- dispensed

	commit;
  else
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '---ERROR: Source and target material ID > 0 required. ' || s_mat_id || ' and ' || t_mat_id || ' provided.');
  end if;
end;
/

create or replace procedure auto_merge_packages (verbose in number) authid current_user is

newpackid decimal;
newpdid decimal;
matchcount decimal;

begin
if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging packages');
	end if; -- End of verbose output
  
for rec in (select materialid, packageid, manufacturerid, supplierid, lower(nvl(productno,'novalue')) as productno, lower(nvl(package_group,'novalue')) as package_group, lower(nvl(un_no, 'novalue')) as un_no from packages where deleted='0' order by materialid, manufacturerid, productno)
  loop
	  
    select min(packageid) into newpackid from packages where
      deleted='0'
	  and materialid=rec.materialid
      and lower(nvl(productno, 'novalue'))=rec.productno
      and manufacturerid=rec.manufacturerid
      and supplierid=rec.supplierid
      and lower(nvl(package_group, 'novalue'))=rec.package_group
      and lower(nvl(un_no, 'novalue'))=rec.un_no;

    if (rec.packageid <> newpackid) then
          if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving packdetails from package id ' || rec.packageid || ' to ' || newpackid);
          end if; -- End of verbose output
       update packdetail set packageid=newpackid where packageid=rec.packageid;

       select count(documentid) into matchcount from documents where packageid=newpackid and doctype='MSDS' and deleted='0';
       if (matchcount = 0) then
          if (verbose = 1) then
              insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving SDS from package id ' || rec.packageid || ' to ' || newpackid);
          end if; -- End of verbose output
          update documents set packageid=newpackid where packageid=rec.packageid and doctype='MSDS';
        else
          if (verbose = 1) then
              insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Discarding SDS from package id ' || rec.packageid || ', existing SDS found');
          end if; -- End of verbose output
          update documents set deleted='1' where packageid=rec.packageid and doctype='MSDS';
       end if;

       	if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Removing package id ' || rec.packageid);
        end if; -- End of verbose output

          update packages set deleted='1' where packageid=rec.packageid;
          update approved_vendors set deleted='1' where packageid=rec.packageid;

    end if; -- End of update loop
  end loop;
commit;

  if (verbose = 1) then
		insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Merging packdetails');
	end if; -- End of verbose output

for rec in (select packdetailid, packageid, lower(nvl(catalogno,'novalue')) as catalogno, capacity, unitofmeasureid, lower(nvl(packagedescription,'novalue')) as packagedescription, lower(nvl(containertype,'novalue')) as containertype from packdetail where deleted='0' order by packageid, catalogno, unitofmeasureid)
  loop

    select nvl(min(packdetailid),0) into newpdid from packdetail where 
        deleted='0'
		and packageid=rec.packageid
        and lower(nvl(catalogno,'novalue'))=rec.catalogno
        and unitofmeasureid=rec.unitofmeasureid
        and capacity=rec.capacity
        and lower(nvl(packagedescription,'novalue'))=rec.packagedescription
        and lower(nvl(containertype,'novalue'))=rec.containertype;

    if (rec.packdetailid <> newpdid and newpdid <> 0) then
      if (verbose = 1) then
        insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Moving containers from packdetail id ' || rec.packdetailid || ' to ' || newpdid);
        insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '----Removing packdetail id ' || rec.packdetailid);
      end if; -- End of verbose output
      
      update containers set packdetailid=newpdid where packdetailid=rec.packdetailid;
      update packdetail set deleted='1' where packdetailid=rec.packdetailid;
    
    end if; -- End of container packdetail move
    
  end loop; -- end of update loop
commit;
end;
/

CREATE OR REPLACE PROCEDURE approved_vendors_fix AUTHID CURRENT_USER IS
matsynid int;
manufid int;
suppid int;
seqid int;


BEGIN
FOR sids in (select siteid from sites where deleted='0')
LOOP
	FOR units IN (SELECT wu.workunitid FROM sites s JOIN work_units wu ON (s.siteid = wu.siteid AND wu.deleted = '0') WHERE s.deleted = '0' AND s.siteid = sids.siteid)
  LOOP
		FOR rec IN (SELECT standardid, materialid FROM standards WHERE workunitid = units.workunitid AND isdefault = '1' AND deleted = '0' AND standardid NOT IN (SELECT standardid FROM approved_vendors WHERE deleted = '0'))
		LOOP
			SELECT min(materialsynonymid) INTO matsynid FROM materials_synonyms WHERE 
				deleted = '0' AND materialid = rec.materialid AND synonymname = (SELECT materialname FROM materials WHERE materialid = rec.materialid AND deleted = '0');

			FOR pkg IN (SELECT packageid FROM packages WHERE materialid = rec.materialid AND deleted = '0' AND obsolete = '0')
			LOOP
				SELECT manufacturerid INTO manufid FROM packages WHERE packageid = pkg.packageid AND deleted = '0';
				SELECT supplierid INTO suppid FROM packages WHERE packageid = pkg.packageid AND deleted = '0';
				INSERT INTO approved_vendors (approvedvendorid, deleted, manufacturerid, materialsynonymid, packageid, standardid, supplierid) VALUES
					(nextseqnobytablename('approved_vendors'),'0',manufid,matsynid,pkg.packageid,rec.standardid,suppid);
			END LOOP;
		END LOOP;
	END LOOP;
END LOOP;
	COMMIT;
END;
/



create or replace procedure material_rollup (site_id in number, verbose in varchar) authid current_user is
--Global declarations
match_mat_id number;

begin
  dbms_output.enable(NULL);
  
  --Start of optional target site material processing
  if (site_id is not null) then
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '-Promoting/merging active target site materials to Global');
    for rec_target in (select materialid, lower(materialname) as materialname, creationsiteid, lower(reviewstatusname) as reviewstatusname from materials where deleted='0' and creationsiteid=site_id)
    loop
      if (rec_target.reviewstatusname = 'local') then
        --Local material, check for existing Global material
        select nvl(min(materialid),0) into match_mat_id from materials where deleted='0' and lower(materialname)=rec_target.materialname and reviewstatusname like 'Global%';
        if (nvl(match_mat_id,0) > 0) then
          --Existing Global match found, merge path
          if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Merging material ID ' || rec_target.materialid || ' into Global ID ' || match_mat_id);
          end if; -- End of verbose output
          merge_mat(rec_target.materialid, match_mat_id, verbose);
        else
          --No Global match found, promotion path
          if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Promoting material ID ' || rec_target.materialid || ' to Global');
          end if; -- End of verbose output
          make_mat_global(rec_target.materialid, verbose);
        end if; -- End of promote/merge
      else
        --Already Global material, take no action
        if (verbose = 1) then
          insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Skipping material ID ' || rec_target.materialid || ', already Global scope');
        end if; -- End of verbose output
      end if;
    end loop;
    commit;
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '-Completed promoting/merging active target site materials to Global');
  end if;
  --End of optional target site material processing
  
  --Start of local materials processing
  for rec_locals in  (select materialid, lower(materialname) as materialname, creationsiteid from materials where deleted='0' and lower(reviewstatusname)='local' order by materialname, materialid)
  loop
    insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '-Promoting/merging active local materials to Global');
    
    select nvl(min(materialid),0) into match_mat_id from materials where deleted='0' and lower(materialname)=rec_locals.materialname and reviewstatusname like 'Global%';
    if (nvl(match_mat_id,0) > 0) then
          --Existing Global match found, merge path
          if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Merging material ID ' || rec_locals.materialid || ' into Global ID ' || match_mat_id);
          end if; -- End of verbose output
          merge_mat(rec_locals.materialid, match_mat_id, verbose);
        else
          --No Global match found, promotion path
          if (verbose = 1) then
            insert into rolluplog (logid, logtext) values (rollup_seq.nextval, '--Promoting material ID ' || rec_locals.materialid || ' to Global');
          end if; -- End of verbose output
          make_mat_global(rec_locals.materialid, verbose);
        end if; -- End of promote/merge
  end loop;
  commit;
  --End of local materials processing

  --Merge package/packdetails
  if (verbose=1) then
    auto_merge_packages(1);
	else
	auto_merge_packages(0);
	end if;
  
  --update regulatory lists
  update_reglist;
  
  --add missing approved_vendors table entries
  approved_vendors_fix;
end;
/

commit;
