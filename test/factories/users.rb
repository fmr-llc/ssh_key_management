FactoryGirl.define do
  factory :user do
    factory :alice do
      first_name "Alice"
      factory :alice_with_credentials do
        transient do
         credentials_count 5
        end

        after(:create) do |user, evaluator|
          create_list(:alice_credential, evaluator.credentials_count, user: user)
        end
      end
    end

    factory :bob do
      first_name "Bob"
    end

    username { first_name.downcase }
    last_name "Smith"
    email  { "#{first_name}.#{last_name}@example.com".downcase }
  end
end
