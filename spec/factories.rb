FactoryGirl.define do
	factory :user do
		sequence(:name) { |n| "Person #{n}" }
		sequence(:email) { |n| "person_#{n}@exmaple.com"}
		password "foobar"
		password_confirmation "foobar"

		factory :admin do
			admin true
		end
	end

	factory :micropost do
		content "Lorem ipsum"
		#this tells factory girl about the user <--> micropost relationship
		user
	end
end