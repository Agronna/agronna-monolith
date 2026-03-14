# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_14_184241) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "addressable_id", null: false
    t.string "addressable_type", null: false
    t.string "city"
    t.string "complement"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "neighborhood"
    t.string "number"
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "machines", force: :cascade do |t|
    t.string "chassis", null: false
    t.datetime "created_at", null: false
    t.string "function", null: false
    t.integer "manufacturing_year", null: false
    t.string "name", null: false
    t.string "plate", null: false
    t.bigint "secretary_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["secretary_id"], name: "index_machines_on_secretary_id"
    t.index ["tenant_id"], name: "index_machines_on_tenant_id"
  end

  create_table "producers", force: :cascade do |t|
    t.date "birth_date", null: false
    t.string "cpf", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_producers_on_tenant_id"
  end

  create_table "properties", force: :cascade do |t|
    t.text "activity", null: false
    t.datetime "created_at", null: false
    t.string "incra"
    t.string "localization"
    t.string "name", null: false
    t.bigint "producer_id", null: false
    t.string "registration"
    t.integer "status", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["producer_id"], name: "index_properties_on_producer_id"
    t.index ["tenant_id"], name: "index_properties_on_tenant_id"
  end

  create_table "secretaries", force: :cascade do |t|
    t.string "cnpj", null: false
    t.string "corporate_name", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "prefecture_name", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_secretaries_on_tenant_id"
  end

  create_table "service_providers", force: :cascade do |t|
    t.string "cnpj"
    t.string "corporate_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.bigint "secretary_id", null: false
    t.string "service_type"
    t.integer "status"
    t.string "telephone"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["secretary_id"], name: "index_service_providers_on_secretary_id"
    t.index ["tenant_id"], name: "index_service_providers_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "owner_id"
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_tenants_on_owner_id"
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.bigint "secretary_id"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["secretary_id"], name: "index_users_on_secretary_id"
    t.index ["tenant_id", "email"], name: "index_users_on_tenant_id_and_email", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "machines", "secretaries"
  add_foreign_key "machines", "tenants"
  add_foreign_key "producers", "tenants"
  add_foreign_key "properties", "producers"
  add_foreign_key "properties", "tenants"
  add_foreign_key "secretaries", "tenants"
  add_foreign_key "service_providers", "secretaries"
  add_foreign_key "service_providers", "tenants"
  add_foreign_key "tenants", "users", column: "owner_id"
  add_foreign_key "users", "secretaries"
  add_foreign_key "users", "tenants"
end
