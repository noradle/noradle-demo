create or replace package body charset_b is

	-- utl_i18n.string_to_raw(n'none-ascii string', 'AL32UTF8')

	procedure form is
		v_src varchar2(200) := 'E3818DCEA609D8A6D985D8B9D8AAD8AFD984E184ACE1B4ABE1BC8EE3818EE3839E';
		ncstr nvarchar2(100) := utl_i18n.raw_to_nchar(hextoraw(v_src), 'AL32UTF8');
		v_ch  nvarchar2(100) := utl_i18n.raw_to_nchar('E4B8ADE69687', 'AL32UTF8');
		v_raw raw(4000);
		vc    varchar2(100);
		nvc   nvarchar2(100);
	begin
	
		ncstr := utl_i18n.raw_to_nchar(hextoraw(v_src), 'AL32UTF8');
	
		-- h.content_type(charset => 'GBK');
		h.allow_get_post;
		--h.header_close;
		pc.h(title => ncstr);
		src_b.link_proc;
		x.t('<br/>');
	
		x.p('<style>', 'div { border:1px dotted gray;margin:1em;padding:1em;}');
	
		x.p('<h3>', 'basic output API for nvarchar2');
		x.o('<div>');
	
		b.write('b.write : ');
		b.write(ncstr);
		b.line('<br/>');
	
		b.write('b.writeln : ');
		b.writeln(ncstr);
		b.line('<br/>');
	
		b.write('b.string : ');
		b.string(ncstr);
		b.line('<br/>');
	
		b.write('b.line : ');
		b.line(ncstr);
		b.line('<br/>');
	
		b.write('x.t : ');
		x.t(ncstr);
		b.line('<br/>');
	
		x.c('</div>');
	
		x.p('<h3>', 'other tag API using nvarchar2');
		x.o('<div>');
		b.write('x.p : ');
		x.p('<p>', ncstr);
		x.c('</div>');
	
		x.p('<h3>', 'function tag API using nvarchar2');
		x.o('<div>');
		b.write('x.p using function API: ');
		x.p('<p>', x.p('<span>', ncstr));
		b.write('x.a using function API: ');
		x.p('<p>', x.a('<a>', ncstr, n'form?a=' || ncstr));
		x.c('</div>');
	
		x.t('<br/>');
		x.p('<p>', utl_raw.cast_to_raw(substr(ncstr, 1, 1)));
		--x.p('<p>', utl_raw.cast_to_raw(convert(substr(v_str, 1, 1), 'AL32UTF8')));
	
		-- r.req_charset_utf8;
		x.p('<h3>', 'request parameters');
		x.o('<div>');
		x.p(' <p>', n'url = ' || r.getc('url', 'null'));
		x.p(' <p>', n'ch = ' || r.getc('ch', 'null'));
		x.p(' <p>', n'en = ' || r.getc('en', 'null'));
		x.p(' <p>', n'utf r.getc() func = ' || r.getc('utf', 'null'));
		vc := r.getc('utf', 'null');
		x.p(' <p>', n'utf r.getc() procedure varchar2 = ' || vc);
		nvc := r.getnc('utf', 'null');
		x.p(' <p>', n'utf r.getc() procedure nvarchar2 = ' || nvc);
		x.c('</div>');
	
		x.p('<h3>', 'APIs that can specify what charset to use for request parameter parsing');
		x.o('<div>');
		x.p(' <p>', 'h.content_type(charset) : set both the output charset and request charset.');
		x.p(' <p>', 'r.req_charset(cs) : set request charset by "cs".');
		x.p(' <p>', 'r.req_charset_utf8 : set request charset by "utf-8", it''s the default.');
		x.p(' <p>', 'r.req_charset_db : set request charset as the db varchar2 used charset.');
		x.p(' <p>', 'You can use form''s accept-charset=xxx attribure to specify what charset will the form submit use.');
		x.c('</div>');
	
		-- basic_io_b.req_info
		x.f('<form name=f,method=post>', '@b.form'); -- accept-charset="gbk"
		x.v(' <input type=text,name=url>', 'http://www.google.com?q=HELLO');
		x.v(' <input type=ch,name=url>', v_ch);
		x.v(' <input type=text,name=en>', 'english');
		x.v(' <input type=text,name=utf>', ncstr);
		x.s(' <input type=submit>');
		x.c('</form>');
	
		x.p('<script>', 'f.onsubmit = function(){}');
	end;

	procedure test is
		v_liyong nvarchar2(100) := utl_i18n.raw_to_nchar('E69D8EE58B87', 'AL32UTF8');
	begin
		--h.content_type('text/html', 'utf-8');
		h.content_type('text/html', 'GBK');
		-- h.content_encoding_try_zip;
		h.content_encoding_identity;
		pc.h;
		x.p('<p>', v_liyong);
		x.a('<a>', v_liyong, '@b.test?name=' || v_liyong);
		x.f('<form method=get>', '@b.test');
		x.v(' <input type=submit,name=name>', v_liyong);
		x.c('</form>');
		return;
		for i in 1 .. 1000 loop
			for j in 1 .. 20 loop
				x.p('<p>', v_liyong);
			end loop;
			b.line('<br/>');
			-- b.flush;
			if false and mod(i, 100) = 0 then
				dbms_lock.sleep(1);
			end if;
		end loop;
	end;

end charset_b;
/
