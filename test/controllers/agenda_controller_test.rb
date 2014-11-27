require 'test_helper'

class AgendaControllerTest < ActionController::TestCase
  test "should get calendar" do
    get :calendar
    assert_response :success
  end

  test "should get tree" do
    get :tree
    assert_response :success
  end

end
