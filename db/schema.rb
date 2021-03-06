# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_23_142332) do

  create_table "application_chats", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "client_application_id"
    t.integer "identifier_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "modifiable_attribute"
    t.integer "lock_version"
    t.integer "message_count", default: 0
    t.index ["client_application_id"], name: "index_application_chats_on_client_application_id"
    t.index ["identifier_number"], name: "index_application_chats_on_identifier_number"
  end

  create_table "chat_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "application_chat_id"
    t.integer "identifier_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text"
    t.integer "lock_version"
    t.index ["application_chat_id"], name: "index_chat_messages_on_application_chat_id"
    t.index ["identifier_number"], name: "index_chat_messages_on_identifier_number"
  end

  create_table "client_applications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "identifier_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_count", default: 0
  end

end
