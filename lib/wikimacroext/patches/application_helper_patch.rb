require_dependency 'application_helper'

module WikiMacroExt
  module Patches

    module ApplicationHelperPatch
     def self.included(base) # :nodoc:     
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :parse_sections, :custom_parse
      end
     end

      module InstanceMethods

	HEADING_RE = /(<h(\d)( [^>]+)?>(.+?)<\/h(\d)>)/i unless const_defined?(:HEADING_RE)

        def parse_sections_with_custom_parse(text, project, obj, attr, only_path, options)
          return unless options[:edit_section_links]
          text.gsub!(HEADING_RE) do
            heading = $1
            @current_section += 1
            if ((options[:edit_first] && @current_section > 0) || (@current_section > 1))
              content_tag('div',
              link_to(image_tag('edit.png'), options[:edit_section_links].merge(:section => @current_section)),
              :class => 'contextual',
              :title => l(:button_edit_section),
              :id => "section-#{@current_section}") + heading.html_safe
            else
              heading
            end
          end
        end
      end

    end
  end
end
