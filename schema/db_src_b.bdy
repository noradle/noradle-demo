create or replace package body db_src_b is

	procedure example is
		cur sys_refcursor;
		v1  varchar2(50) := 'psp.web';
		v2  number := 123456;
		v3  date := date '1976-10-26';
	begin
		if not r.is_null('template') then
			h.convert_json_template(r.getc('template'), r.getc('engine'));
		end if;
	
		rs.use_remarks;
		h.line('# a stardard psp.web result sets example page');
		h.line('# It can be used in browser or NodeJS');
		h.line('# You can use some standard parser or write your own ' ||
					 'parsers to convert the raw resultsets to javascript data object');
		h.line('# see PL/SQL source at ' || r.dir_full || '/src_b.proc/' || r.prog);
	
		open cur for
			select a.object_name, a.subobject_name, a.object_type, a.created
				from user_objects a
			 where rownum <= r.getn('limit', 8);
		rs.print('objects', cur);
	
		open cur for
			select v1 as name, v2 as val, v3 as ctime, r.getc('param1') p1, r.getc('param2') p2, r.getc('__parse') pnull
				from dual;
		rs.print('namevals', cur);
	
	end;

	procedure pack_proc is
		cur sys_refcursor;
	begin
		open cur for
			select a.object_name pack, a.created, a.status
				from user_objects a
			 where a.object_type = 'PACKAGE'
			 order by 1 asc;
		rs.print('packages', cur);
	
		open cur for
			select a.object_name pack, a.procedure_name proc
				from user_procedures a
			 where a.object_type = 'PACKAGE'
				 and a.procedure_name is not null
			 order by a.object_name asc, a.subprogram_id asc;
		rs.print('procedures/-pack|packages/pack', cur);
	
		open cur for
			select a.object_name pack, a.procedure_name "_"
				from user_procedures a
			 where a.object_type = 'PACKAGE'
				 and a.procedure_name is not null
			 order by a.object_name asc, a.subprogram_id asc;
		rs.print('procs|packages', cur);
	end;
	end;
	procedure scalars is
	begin
		h.convert_json;
		rs.nv('name', 'kaven276');
		rs.nv('age', 39);
		rs.nv('birth', sysdate - 39);
		rs.nv('married', true);
	end;

end db_src_b;
/
