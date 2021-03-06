create or replace package body src_b is

	-- print package source
	procedure pack is
		n varchar2(30) := upper(r.getc('p'));
	begin
		h.content_type('text/plain');
		h.header('_convert', 'marked');
		x.o('<head>');
		x.l('<link>', '[highlight.css]');
		x.c('</head>');
		x.p('<h3>', 'PL/SQL UNIT: ' || n);
		x.p('<h4>', x.a('<a>', 'show subprocedures', './src_b.proc_list?pack=' || n));
		b.line('```plsql');
		b.set_line_break('');
		for i in (select a.text
								from user_source a
							 where a.name = n
								 and a.type = 'PACKAGE BODY'
							 order by a.line) loop
			b.line(replace(i.text, chr(9), '  '));
		end loop;
		b.line('```');
	end;

	-- print package.procedure source
	procedure proc is
		v_prog st;
		v_pack varchar2(30);
		v_proc varchar2(99);
		v_sts  boolean := false;
	begin
		t.split(v_prog, r.getc('p', 'src_b.proc'), '.');
		v_pack := upper(v_prog(1));
		-- v_proc := chr(9) || 'procedure ' || v_prog(2) || ' is' || chr(10);
		v_proc := chr(9) || 'procedure ' || v_prog(2) || '%' || chr(10);
		h.content_type('text/plain');
		h.header('_convert', 'marked');
		x.o('<head>');
		x.l('<link>', '[highlight.css]');
		x.c('</head>');
		x.p('<p>', x.a('<a>', 'execute', r.prog));
		b.line('```plsql');
		b.set_line_break('');
		for i in (select a.text
								from user_source a
							 where a.name = v_pack
								 and a.type = 'PACKAGE BODY'
							 order by a.line) loop
			if not v_sts then
				if i.text like v_proc and regexp_like(i.text, '\s' || v_prog(2) || '(\s|\()') then
					v_sts := true;
				end if;
			end if;
			if v_sts then
				b.line(substrb(replace(i.text, chr(9), '  '), 3));
				if i.text = chr(9) || 'end;' || chr(10) then
					exit;
				end if;
			end if;
		end loop;
		b.line('```');
	end;

	-- print links to all sub procedures
	procedure proc_list is
		v_pack varchar2(30) := r.getc('pack', r.pack);
	begin
		x.t('<!DOCTYPE html>');
		x.o('<html>');
		x.o('<head>');
		x.l(' <link>', '[bootstrap.css]');
		x.l(' <link>', '[animate.css]');
		x.p(' <style>', 'body{padding-top:1em;}');
		x.c('</head>');
		x.o('<body>');
		x.o('<div.container-fluid>');
		x.o('<div.panel.panel-default.animated.bounceInDown>');
		x.p(' <div.panel-heading>', v_pack);
		--x.p(' <div.panel-body>', 'all sub procedure list');
		x.o(' <ul.list-group>');
		for i in (select *
								from user_procedures a
							 where a.object_name like upper(v_pack)
								 and a.procedure_name is not null
							 order by a.subprogram_id asc) loop
			x.p('<li.list-group-item>', x.a('<a>', i.procedure_name, lower(v_pack || '.' || i.procedure_name)));
		end loop;
	end;

	-- print link to package source
	procedure link_pack(pack varchar2 := null) is
	begin
		b.line(t.ps('<a href="src_b.pack?p=:1" target=":1">view pl/sql source pack ":1" in new window</a></br>',
								st(nvl(pack, r.pack))));
	end;

	-- print link to package.procedure source
	procedure link_proc(proc varchar2 := null) is
	begin
		b.line(t.ps('<a href="src_b.proc?p=:1" target=":1">view pl/sql source proc ":1" in new window</a><br/><br/>',
								st(nvl(proc, r.prog))));
	end;

	-- give link to show source or show source in markdown(plain or converted)
	procedure header is
		v_pos  pls_integer;
		v_type varchar2(100) := h.mime_type;
	begin
		if r.call_type in ('DATA', 'NDBC') then
			return;
		end if;
		v_pos  := instrb(v_type, '/');
		v_type := substrb(v_type, v_pos + 1);
		if r.pack = 'db_src_b' then
			v_type := 'text'; -- text/resultsets
		end if;
		if r.is_lack('inspect') then
			--link_proc;
			if v_type != 'html' then
				return;
			end if;
			b.l('<meta name="viewport" content="width=device-width, initial-scale=1"/>');
			x.a('<a target=_blank>', 'inspect(plain) ' || r.prog, r.url || t.tf(r.qstr is null, '?', '&') || 'inspect');
			x.t('<br/><br/>');
			x.a('<a target=_blank>',
					'inspect(highlight) ' || r.prog,
					r.url || t.tf(r.qstr is null, '?', '&') || 'inspect&markdown');
			x.t('<br/><br/>');
			return;
		end if;
		h.content_type('text/plain');
		if r.not_lack('markdown') then
			h.header('_convert', 'marked');
			x.o('<head>');
			x.l('<link>', '[highlight.css]');
			x.c('</head>');
			x.p('<p>', x.a('<a>', 'execute', r.prog));
		end if;
	
		r.setc('p', r.getc('x$prog'));
		b.line('```plsql');
		src_b.proc;
		b.line('```');
	
		b.set_line_break(chr(10));
		b.line;
		b.line;
		b.line('produce');
		b.line;
		b.line('```' || v_type);
	end;

	procedure footer is
	begin
		if not r.is_lack('inspect') then
			b.line('```');
			h.content_type('text/plain');
		end if;
	end;

end src_b;
/
