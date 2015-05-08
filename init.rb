require 'redmine'
require 'open-uri'

Redmine::Plugin.register :redmine_wiki_macro_ext do
  name 'Redmine Wiki Macro extensions plugin'
  author 'CodePoKE'
  description 'Contains various macro extensions for Redmine Wiki, such as: {{summary()}}'
  version '0.0.1'
  url 'https://github.com/gjroelofs/redmine_wiki_macro_ext.git'
  author_url 'gj.roelofs@codepoke.net'

	Redmine::WikiFormatting::Macros.register do
		desc "Provide a summary of the parameter page. \n"+
			"Usage: <pre>\n" +
			"{{summary(<page>)}} \n" +
			"{{summary(<page>, header=N}} to adjust the header number by N \n"
			"</pre>"

		macro :summary do |obj, args|

			args, options = extract_macro_options(args, :header)

			page = nil
			if args.size == 1
				page = Wiki.find_page(args.first.to_s, :project => @project)
			else
				raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
			end

			n = options[:header]
                        raise 'Invalid header parameter' unless n.nil? || n.match(/\d+$/)
			n = n.to_i

			# Match to the text between the first and second header. (nclude header)
			@included_wiki_pages ||= []

		        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
		        @included_wiki_pages << page.title
               	 	#content = page.content[/^(h[1-6]\.*)/sm]
			text = page.content.text[/(h[1-6]\..*?)(^h[1-6]\.|\Z)/sm, 1]
			text = text.gsub(/h([1-6])\./) {"h" + ([6,[1, $1.to_i + n].max].min).to_s + "."}
	 	      	out = textilizable(text, :attachments => page.attachments, :headings => false)
	        	@included_wiki_pages.pop
	        	out

		end 
	end
     
      Redmine::WikiFormatting::Macros.register do
	desc "Includes a wiki page. Examples:\n\n" +
             "{{include(Foo)}}\n" +
             "{{include(projectname:Foo)}} -- to include a page of a specific project wiki\n" +
             "{{include(Foo, header=N)}} -- to adjust the header number by N"
      macro :include do |obj, args|

        args, options = extract_macro_options(args, :header)
        page = Wiki.find_page(args.first.to_s, :project => @project)
        raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
        n = options[:header]
                        raise 'Invalid header parameter' unless n.nil? || n.match(/\d+$/)
        n = n.to_i

        @included_wiki_pages ||= []
        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
        @included_wiki_pages << page.title
        text = page.content.text.gsub(/h([1-6])\./) {"h" + ([6,[1, $1.to_i + n].max].min).to_s + "."}
        out = textilizable(text, :attachments => page.attachments, :headings => false)
        @included_wiki_pages.pop
        out
      		end 
	end 
       
end
