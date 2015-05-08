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
		desc "Provide a summary of the parameter page. \nUsage:\n<pre>{{summary(<page>)}}</pre>"

		macro :summary do |obj, args|

			page = nil
			if args.size == 1
				page = Wiki.find_page(args.first.to_s, :project => @project)
			else
				raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
			end

			# Match to the text between the first and second header. (nclude header)
			@included_wiki_pages ||= []
	        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
	        @included_wiki_pages << page.title
                #content = page.content[/^(h[1-6]\.*)/sm]
		#out = page.content.text
	        out = textilizable(page.content.text[/(h[1-6]\..*?)(^h[1-6]\.|\Z)/sm, 1], :attachments => page.attachments, :headings => false)
	        @included_wiki_pages.pop
	        out

		end 
	end
        
end
