FactoryGirl.define do
	factory :user do
		name	"Troy Rosenberg"
		email	"troy@roirevolution.com"
		password "foobar"	
		password_confirmation "foobar"
	end
end