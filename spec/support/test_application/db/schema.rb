# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table "dogs", force: :cascade do |t|
    t.string "name", null: false

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "toys", force: :cascade do |t|
    t.integer "dog_id", null: false
    t.string "name", null: false

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
