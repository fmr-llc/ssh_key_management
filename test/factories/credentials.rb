FactoryGirl.define do
  factory :credential do
    factory :alice_credential do
      association :user, factory: :alice
      public_key { SSHKey.generate.ssh_public_key }
      host "mail.google.com"
      username "alice"
    end

    factory :bob_credential do
      association :user, factory: :bob
      public_key { SSHKey.generate.ssh_public_key }
      host "finance.google.com"
      username "root"
    end

    trait :default_key do
      host nil
    end

    trait :different_key do
      public_key { SSHKey.generate.ssh_public_key }
    end

    trait :expired do
      created_at { (Time.zone.now - 4.years).to_s :db }
    end

    trait :expiring do
      created_at { (Time.zone.now - 330.days).to_s :db }
    end

    trait :public_key_with_newlines do
      public_key "   ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAw0MSd/96JL37Dt1Hl\nxc9kTj/81sQY8cUeI3T770hIq0Fwc5t2IEJq\nllTZuqx+GQquiTvvoNQ17VONjSA\nPAaAzvWHkKE2VRMj4zV5jYw8hVEpOYetPg14uYaE3s8/VFnA5f73ulm/vfeJy5oNcWDOuaynMLy7u3P9g4uk7aaUGryir197sT0l3NYyczvrVk+pdWuvsqpvC2df9xpUKdlWzluT7qnc0Xc3grUsurSvw4Fb1J6n/Ps/wn76/uR5JseUU/bLasS/WbSdOJWLQO/UylgxWy8B+KIw5HtEf1odLeYE\n3zgXkOm1hQlupR3Tfkd40KD4AmsijNkrzi8lsO2sjw== rsa-key-20150306   "
    end

    trait :public_key_that_is_too_short do
      public_key "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAATj/81sQY8cUeI3T770hIq0Fwc5t2IEJqllTMj4zV5jYw8hVEpOYetPg14uYaE3s8/VFnA5f73ulm/vfeJy5oNcWDOuaynMLy7u3P9g4uk7aaUGryir197sT0l3NYyczvrVk+pdWuvsqpvC2df9xpUKdlWzluT7qnc0Xc3grUsurSvw4Fb1J6n/Ps/wn76/uR5JseUU/bLasS/WbSdOJWLQO/UylgxWy8B+KIw5HtEf1odLeYE3zgXkOm1hQlupR3Tfkd40KD4AmsijNkrzi8lsO2sjw== rsa-key-20150306"
    end

    trait :without_user do
      user nil
      username "root"
    end

    trait :without_public_key do
      public_key nil
    end

    trait :without_host do
      host nil
    end

    trait :without_username do
      username nil
    end
  end
end
