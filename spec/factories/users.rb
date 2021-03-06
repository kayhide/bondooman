FactoryGirl.define do
  factory :user do
    provider 'bondooman'
    sequence(:uid) { |i| i }

    transient do
      sequence(:id) { |i| i }
      sequence(:email) { |i| "user#{i}@bondooman.test" }
      sequence(:name) { |i| "User #{i}" }
      role :member
      sequence(:letter) { |i| "U#{i}" }
      color '#f38'
      created_at Time.current
      updated_at Time.current
    end

    trait :admin do
      role :admin
    end

    after :build do |m, evaluator|
      m.raw = evaluator.attribute_lists.last.names.map do |k|
        [k.to_s, evaluator.send(k)]
      end.to_h
      m.id = evaluator.id
    end
  end
end
