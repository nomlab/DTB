require 'test_helper'

class UnifiedHistoriesControllerTest < ActionController::TestCase
  setup do
    @unified_history = unified_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unified_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unified_history" do
    assert_difference('UnifiedHistory.count') do
      post :create, unified_history: { end_time: @unified_history.end_time, path: @unified_history.path, r_path: @unified_history.r_path, start_time: @unified_history.start_time, title: @unified_history.title, type: @unified_history.type }
    end

    assert_redirected_to unified_history_path(assigns(:unified_history))
  end

  test "should show unified_history" do
    get :show, id: @unified_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @unified_history
    assert_response :success
  end

  test "should update unified_history" do
    patch :update, id: @unified_history, unified_history: { end_time: @unified_history.end_time, path: @unified_history.path, r_path: @unified_history.r_path, start_time: @unified_history.start_time, title: @unified_history.title, type: @unified_history.type }
    assert_redirected_to unified_history_path(assigns(:unified_history))
  end

  test "should destroy unified_history" do
    assert_difference('UnifiedHistory.count', -1) do
      delete :destroy, id: @unified_history
    end

    assert_redirected_to unified_histories_path
  end
end
