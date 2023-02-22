FactoryBot.define do
  factory :download do
    page { "MyString" }
    belongs_to_pro { false }
    user_id { 1 }
    text_requested { false }
    images_requested { false }
    links_requested { false }
    download_completed { false }
  end
end
