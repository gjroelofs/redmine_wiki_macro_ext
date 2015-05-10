require 'redmine'
require 'open-uri'
require 'wikimacroext/patches/application_helper_patch'

ApplicationHelper.send(:include, WikiMacroExt::Patches::ApplicationHelperPatch)  unless    ApplicationHelper.included_modules.include? WikiMacroExt::Patches::ApplicationHelperPatch

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

			page = nil
			if args.size >= 1
				page = Wiki.find_page(args.first.to_s, :project => @project)
			else
				raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
			end

			args, options = extract_macro_options(args, :header)

			n = options[:header]
                        raise 'Invalid header parameter' unless n.nil? || n.match(/^-?\d+$/)
			n = n.to_i

			# Match to the text between the first and second header. (nclude header)
			@included_wiki_pages ||= []

		        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
		        @included_wiki_pages << page.title
               	 	
			text = page.content.text[/(h[1-6]\..*?)(^h[1-6]\.|\Z)/sm, 1]

			# Create the fake TOC without the title section
                        pagelink = " [[" + args.first + "#"
			tocRaw = page.content.text.scan(/^h([1-6])\. +(.+?)\s*$/)
			tocDeduct = tocRaw.first.first.to_i
			toc = tocRaw.drop(1).map{
			    |i| "*" * (i.first.to_i - tocDeduct) + pagelink + i.last + "|" + i.last + "]]\n"
			}.join

			# Transpose the section headers
			text = text.gsub(/h([1-6])\./) {"h" + ([6,[1, $1.to_i + n].max].min).to_s + "."}
                        text = text + "\n" + toc

	 	      	out = textilizable(text, :object => page, :attachments => page.attachments, :headings => true, :edit_first => true, :edit_section_links => (true && {:controller => 'wiki', :action => 'edit', :project_id => page.project, :id => page.title}))
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

        page = Wiki.find_page(args.first.to_s, :project => @project)
        raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
        
	args, options = extract_macro_options(args, :header)
	n = options[:header]
                        raise 'Invalid header parameter' unless n.nil? || n.match(/\d+$/)
        n = n.to_i

        @included_wiki_pages ||= []
        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
        @included_wiki_pages << page.title
        text = page.content.text.gsub(/h([1-6])\./) {"h" + ([6,[1, $1.to_i + n].max].min).to_s + "."}
        
        out = textilizable(text, :object => page, :attachments => page.attachments, :headings => true, :edit_first => true, :edit_section_links => (true && {:controller => 'wiki', :action => 'edit', :project_id => page.project, :id => page.title}))
        @included_wiki_pages.pop
        out
      		end 
	end 
       
end

