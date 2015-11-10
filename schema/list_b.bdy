create or replace package body list_b is

	procedure user_objects is
	begin
		x.p('<style>', 'table{border:1px solid;}th,td{padding:8px;}');
		src_b.header;
		x.p('<h2>', 'use table list(tl) and m.w(head,items,tail) in for SQL loop');
		tb.cfg_init('table');
		tb.cfg_add('oname', 'obj_name', 'left', '360px');
		tb.cfg_add('otype', 'obj_type', 'left', '200px');
		x.o('<table rules=all>');
		x.p(' <caption>', 'table list format API example');
		tb.cfg_cols_thead;
		x.o(' <tbody>');
		for i in (select *
								from user_objects a
							 where a.object_name not like 'BIN$%'
								 and a.object_type not like '%PARTITION'
								 and rownum <= 3
							 order by a.object_type, a.object_name) loop
			x.p('<tr>', m.w('<td>', st(i.object_name, i.object_type), '</td>'));
		end loop;
		x.c(' </tbody>');
		x.c('</table>');
	end;

	procedure user_objects_cur is
		cur sys_refcursor;
	begin
		x.p('<h2>', 'use table list(tl) and m.c(tpl,sys_refcursor)');
		src_b.header;
		open cur for
			select a.object_name, a.object_type
				from user_objects a
			 where a.object_name not like 'BIN$%'
				 and a.object_type not like '%PARTITION'
				 and rownum <= 3
			 order by a.object_type, a.object_name;
		tb.cfg_init('table');
		tb.cfg_add('oname', 'obj_name', 'left', '360px');
		tb.cfg_add('otype', 'obj_type', 'left', '200px');
		x.p('<style>', 'table{border:1px solid;}th,td{padding:8px;}');
		x.o('<table rules=all>');
		x.p(' <caption>', 'table list format API example');
		tb.cfg_cols_thead;
		x.o(' <tbody>');
		m.prc('<tr><td>@</td><td>@</td></tr>', cur);
		x.c(' </tbody>');
		x.c('</table>');
	end;

	procedure user_procedures is
		c sys_refcursor;
	begin
		x.p('<style>', 'table{border:1px solid;}th,td{padding:8px;}');
		src_b.header;
		x.p('<h2>', 'use table list(tl) and tb.cfg_content(sys_refcursor)');
		open c for
			select a.object_name, a.procedure_name, a.object_id
				from user_procedures a
			 where rownum <= 3
			 order by a.object_type, a.object_name;
		tb.cfg_init('table');
		tb.cfg_add('pack', 'package', null, '30ex');
		tb.cfg_add('proc', 'procedure');
		tb.cfg_add('objid', 'objid');
		x.o('<table rules=all>');
		x.p(' <caption>', 'table list for sys_refcursor example');
		tb.cfg_content(c);
		x.c('</table>');
	end;

end list_b;
/
