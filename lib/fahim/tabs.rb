require 'ostruct'

#
# In the controllers:
#
# class ApplicationController
#   setup_tabs do
#     tab :home,  "Home",  'root_path'
#     tab :songs, "Songs", 'songs_path'
#   end
# end
#
# class SongsController < ApplicationController
#   current_tab :songs
# end
#
#
# In the view:
#
# <% @the_tabs.each do |tab| %>
#   <li<% if tab.current? %> class="current"<% end %> id="tab-<%= tab.id %>">
#     <%= link_to tab.name, tab_url(tab) %>
#   </li>
# <% end %>
#
#
# Data is stored in @the_tabs
#

module Fahim
  module Tabs
    module ClassMethods
      def setup_tabs
        class_inheritable_accessor :tabs
        self.tabs = []
        
        yield
      end
      
      def current_tab(id)
        before_filter do
          self.tabs.each do |tab|
            tab.current = (tab.id.to_s == id.to_s)
          end
        end
      end
      
      def tab(id, name, url, options = {})
        tabs = read_inheritable_attribute(:tabs)

        tab = Tab.new(id, name, url, options)
        tab.current = true if tabs.empty? 
        tabs << tab

        write_inheritable_attribute(:tabs, tabs)
      end
      
      class Tab
        attr_accessor :id, :name, :url, :current, :options

        def initialize(id, name, url, options = {})
          @id = id
          @name = name
          @url = url # String that is evaluated in in the view.
          @current = false
          @options = options
        end
        
        def current?
          current
        end
      end
    end  
    
    module InstanceMethods
      def setup_tab_variables
        @the_tabs = self.class.read_inheritable_attribute(:tabs)
      end
      
      def current_tab(id)
        self.class.read_inheritable_attribute(:tabs).each do |tab|
          tab.current = (tab.id == id)
        end
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.before_filter :setup_tab_variables
    end
  end
  
  module TabsHelper
    def tabs
      @the_tabs
    end
    
    def tabs?
      tabs && tabs.size > 0
    end 
    
    # I want to move this to the Tab class.
    def tab_url(tab)
      instance_eval(&tab.url)
    end
  end
end