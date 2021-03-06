FactoryGirl.define do

  factory :user do
    full_name "Volodymyr Barna"
    sequence(:email) { |n| "foo#{n}@example.com" }
    password "password"

    factory :admin do
      admin true
    end

    factory :user_with_address do
      after(:create){ |user| create_list(:address, 1, customer: user) }
    end
  end

  factory :customer do
    full_name "Guest"
    sequence(:email) { |n| "guest#{n}@example.com" }
    addresses { [build(:address)] }
  end

  factory :address do
    sequence(:line_1) { |n| "Ruska 1#{n}/3#{n}" }
    line_2 "2 floor, from backdoor"
    city "Ternopil"
    country "Ukraine"
    postcode 12345
    phone_number "+380970377658"

    factory :address_with_user do
      customer_id { create(:user).id }
    end
  end

  factory :order do
    address
    pay_type "Check"
    shipping_type "Express"

    factory :order_with_user do
      association :address, factory: :address_with_user
    end
  end

  factory :category do
    sequence(:name) { |n| "Category#{n}" }
  end

  factory :product do
    sequence(:title) { |n| "Intel Core i5-375#{n}k BOX" }
    description "OMGWTFBBQ"
    image_url 'ruby.jpg'
    category_id { create(:category).id }
    price 25.39
  end

  factory :line_item do
    product
  end

  factory :cart do

    factory :cart_with_items do
      after(:build){ |cart| create_list(:line_item, 10, cart: cart) }
    end
  end

  factory :review do
    product
    user
    sequence(:comment) { |n| "LOL! NICE! #{Faker::Lorem.sentence}" }
    sequence(:rating) { |n| 1 + n % 5 }
  end
end
