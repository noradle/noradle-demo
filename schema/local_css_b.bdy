create or replace package body local_css_b is

	procedure d is
		procedure component1(name varchar2) is
		begin
			-- css rule only for this component1
			if r.is_lack('lcss$component1') then
				r.setn('lcss$component1', 1);
				x.p('<style>', '.c1{color:red;}');
			end if;
			x.p('<p.c1>', name);
		end;
	
		procedure component2(name varchar2) is
		begin
			-- css rule only for this component2
			if r.is_lack('lcss$component2') then
				r.setn('lcss$component2', 1);
				x.p('<style>', '.c2{color:blue;}');
			end if;
			x.p('<p.c2>', name);
		end;
	begin
		src_b.header;
	
		if r.getb('reorder') then
			x.o('<script#buffer type=text>');
		end if;
	
		x.p('<p>', 'note: css rule set just before usage of them, print only once, no repeat');
		x.p('<h3>', 'include component1 with each package names');
		for i in (select a.object_name
								from user_objects a
							 where a.object_type = 'PACKAGE'
								 and rownum < 4) loop
			component1(i.object_name);
		end loop;
		x.p('<h3>', 'include component2 with each none-package object names');
		for i in (select a.object_name
								from user_objects a
							 where a.object_type != 'PACKAGE'
								 and rownum < 4) loop
			component2(i.object_name);
		end loop;
	
		if r.getb('reorder') then
			x.c('</script>');
			x.p('<script>',
					'(function(){
		var text = document.getElementById("buffer").innerText
		 , re = /<style>[^<>]*<\/style>\n?/gm
		 , body = text.replace(re,"")
		 , style = text.match(re).join("\n").replace(/(<style>|<\/style>)/g,"")
		 ;
		document.head.insertAdjacentHTML("beforeEnd","<style>" + style + "</style>");
		document.body.insertAdjacentHTML("beforeEnd",body);
		})();');
		end if;
	
	end;
end local_css_b;
/
