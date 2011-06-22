require 'test_helper'
require 'action_controller'
require 'shoulda'

require File.dirname(__FILE__) + '/../lib/fahim/tabs.rb'
require File.dirname(__FILE__) + '/../init'

class ParentController < ActionController::Base
  setup_tabs do
    tab :home, "Home", lambda { root_path }
    tab :archive, "Past Music", lambda { archive_path }
  end
end

class ChildController < ParentController
  current_tab :home
  
  def archive
    current_tab :archive
  end
end

class TabsTest < ActiveSupport::TestCase
  def setup
    @controller = ParentController.new
    @tabs = @controller.class.read_inheritable_attribute(:tabs)
  end
  
  should "create tabs instance variable" do
    assert_kind_of Array, @tabs
  end
end
