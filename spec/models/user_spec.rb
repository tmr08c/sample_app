# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean         default(FALSE)
#

require 'spec_helper'


describe User do

  before { @user = User.new(name: "Example User", email: "user@example.com",
							password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:name)  }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  # password and password_confirmation will be virtual attributes
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token)}

  it {should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  # Micropost Association
  it { should respond_to(:microposts) }

  it { should be_valid } # just making sure the initial user ^ is valid
  it { should_not be_admin}

  describe "accessible attributes" do
	it "should not allow access to admin" do
	  expect do
		User.new(admin: true)
	  end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
	end
  end

  describe "with admin attribute set to 'true'" do
	before { @user.toggle!(:admin)}

	it { should be_admin}
  end

  # Testing Validations

  #NAME

  # Name Presence  Validations
  describe "when name is not present" do
	before { @user.name = "" }
	it { should_not be_valid }
  end

  # Choosing 50 as maximum name length
  describe "when name is too long" do
	before { @user.name = "a" * 51 }
	it { should_not be_valid }
  end

  # end NAME

  #EMAIL
  describe "when email is not present" do
	before { @user.email = "" }
	it { should_not be_valid }
  end

  describe "when email format is invalid" do
	it "should be invalid" do
	  addresses = %w[ user@foo,com user_at_foo.org
		example.user@foo. foo@bar_baz.com fpp@bar+bas.com ]
	  addresses.each do |invalid_addr|
		@user.email = invalid_addr
		@user.should_not be_valid
	  end
	end
  end

  describe "when email format is valid" do
	it "should be valid" do
	  addresses = %w[ user@foo.COM A_US-ER@f.b.org frst.lst@fo.jp a+b@baz.cn ]
	  addresses.each do |valid_addr|
		@user.email = valid_addr
		@user.should be_valid
	  end
	end
  end

  describe "when email address is already taken" do
	before do
	  user_with_same_email = @user.dup
	  #user_with_same_email.email = @user.email.upcase
	  user_with_same_email.save
	end

	it { should_not be_valid }
  end

  describe "email address with mixed case" do
	let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

	it "should be saved as all lower-case" do
	  @user.email = mixed_case_email
	  @user.save
	  @user.reload.email.should == mixed_case_email.downcase
	end
  end
  # end EMAIL

  # PASSWORD
  describe "when password is NOT present" do
	before { @user.password = @user.password_confirmation =  " "}
	it { should_not be_valid }
  end

  describe "when password does NOT match confirmation" do
	before { @user.password_confirmation = "mismatch" }
	it  { should_not be_valid }
  end

  describe "when password confirmation is nil" do
	before { @user.password_confirmation = nil }
	it { should_not be_valid }
  end

  describe "return value of authenticate method" do
	before { @user.save }
	let(:found_user) { User.find_by_email(@user.email) }

	describe "with valid password" do
	  it { should == found_user.authenticate(@user.password) }
	end

	describe "with invalid password" do
	  let(:user_for_invalid_password) { found_user.authenticate("invalid") }
	  it { should_not == user_for_invalid_password }
	  specify { user_for_invalid_password.should be_false}
	end
  end

  describe "with a password that's too short" do
	before { @user.password = @user.password_confirmation = 'a' * 5 }
	it { should be_invalid }
  end
  # end PASSWORD

  describe "remember token" do
	before { @user.save }
	its(:remember_token) { should_not be_blank}
  end

  # Micropost
  describe "micropost associations" do
	before { @user.save }
	let!(:older_micropost) do
	  FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
	end
	let!(:newer_micropost) do
	  FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
	end

	it "should have the new micropost come first" do
	  @user.microposts.should == [newer_micropost, older_micropost]
	end

	it "should destroy assoicated microposts" do
	  microposts = @user.microposts
	  @user.destroy
	  microposts.each do |micropost|
		lambda do
			Micropost.find(micropost.id)
		end.should raise_error(ActiveRecord::RecordNotFound)
		# Micropost.find_by_id(micropost.id).should be_nil
	  end
	end

	describe "status" do
		let(:unfollowed_post) do
			FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
		end

		its(:feed) { should include(newer_micropost)}
		its(:feed) { should include(older_micropost)}
		its(:feed) { should_not include(unfollowed_post)}
	end
  end
end
