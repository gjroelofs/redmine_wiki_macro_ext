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

			# Match to the text between the first and second header. (nclude header)
			var match = page.content.to_s[/^(h[1-6]\..*)^h[1-6]\./sm, 1]


        	out = textilizable(match, :text, :headings => false)
        	out
		end 
	end
        
end