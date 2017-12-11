require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path,params: { user: {name: "",
                                       email: "user@invalid",
                                       password: "foo",
                                       password_confirmation: "bar"}}
    end
    assert_template 'users/new'
    assert_select "form[action=?]", signup_path
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count',1 do
      post users_path,params: { user: {name: "hogehoge",
                                       email: "sample@gmail.com",
                                       password: "foobar",
                                       password_confirmation: "foobar"}}
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash[:success].empty?
  end
end
