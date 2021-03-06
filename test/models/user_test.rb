require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar" ,password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "  "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "name should be not too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should be not too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "有効なemailアドレスチェック" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn shouya.hoshino@bigtreetc.com]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?,"#{valid_address.inspect} should be valid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = "Foo@ExAMPle.CoM"
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with null digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    user1 = users(:test_user)
    user2 = users(:test_user2)
    assert_not user1.following?(user2)
    user1.follow(user2)
    assert user1.following?(user2)
    assert user2.followers.include?(user1)
    user1.unfollow(user2)
    assert_not user1.following?(user2)
  end

  test "feed should have the right posts" do
    user1 = users(:test_user)
    user2 = users(:test_user2)
    user3 = users(:test_user3)
    #フォローしているユーザーの投稿確認
    user3.microposts.each do |post_following|
      assert user1.feed.include?(post_following)
    end
    #自分自身の投稿を確認
    user1.microposts.each do |post_self|
      assert user1.feed.include?(post_self)
    end
    #フォローしていないユーザーの投稿確認
    user2.microposts.each do |post_unfollowed|
      assert_not user1.feed.include?(post_unfollowed)
    end
  end

end
