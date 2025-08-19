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

ActiveRecord::Schema[8.0].define(version: 2025_08_19_193957) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "candidate_role_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "candidate_roles", force: :cascade do |t|
    t.string "name"
    t.bigint "candidate_role_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_role_group_id"], name: "index_candidate_roles_on_candidate_role_group_id"
  end

  create_table "candidate_skills", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id", "skill_id"], name: "index_candidate_skills_on_candidate_id_and_skill_id", unique: true
    t.index ["candidate_id"], name: "index_candidate_skills_on_candidate_id"
    t.index ["skill_id"], name: "index_candidate_skills_on_skill_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "candidate_role_id"
    t.string "public_profile_key"
    t.integer "search_status"
    t.string "headline"
    t.integer "experience"
    t.decimal "hourly_rate"
    t.integer "response_rate", default: 0, null: false
    t.integer "search_score", default: 0, null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_role_id"], name: "index_candidates_on_candidate_role_id"
    t.index ["user_id"], name: "index_candidates_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.string "website"
    t.text "description"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "trial_ends_at"
  end

  create_table "company_subscriptions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.string "status"
    t.datetime "trial_start"
    t.datetime "trial_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.text "admin_notes"
    t.integer "updated_by_admin"
    t.index ["company_id"], name: "index_company_subscriptions_on_company_id"
    t.index ["subscription_plan_id"], name: "index_company_subscriptions_on_subscription_plan_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.string "company_name"
    t.string "job_title"
    t.date "start_date"
    t.date "end_date"
    t.boolean "current_job", default: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_experiences_on_candidate_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "candidate_id", null: false
    t.bigint "user_id", null: false
    t.string "status", default: "applied"
    t.text "status_notes"
    t.text "cover_letter"
    t.text "portfolio_url"
    t.text "additional_notes"
    t.boolean "is_quick_apply", default: false
    t.datetime "applied_at"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.string "external_id"
    t.string "external_source"
    t.jsonb "external_data"
    t.integer "view_count", default: 0
    t.datetime "last_viewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applied_at"], name: "index_job_applications_on_applied_at"
    t.index ["candidate_id", "status"], name: "index_job_applications_on_candidate_id_and_status"
    t.index ["candidate_id"], name: "index_job_applications_on_candidate_id"
    t.index ["external_data"], name: "index_job_applications_on_external_data", using: :gin
    t.index ["external_id"], name: "index_job_applications_on_external_id"
    t.index ["external_source"], name: "index_job_applications_on_external_source"
    t.index ["job_id", "candidate_id"], name: "index_job_applications_on_job_and_candidate", unique: true
    t.index ["job_id", "status"], name: "index_job_applications_on_job_id_and_status"
    t.index ["job_id"], name: "index_job_applications_on_job_id"
    t.index ["reviewed_at"], name: "index_job_applications_on_reviewed_at"
    t.index ["reviewed_by_id"], name: "index_job_applications_on_reviewed_by_id"
    t.index ["status"], name: "index_job_applications_on_status"
    t.index ["user_id", "status"], name: "index_job_applications_on_user_id_and_status"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "job_board_integrations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "provider"
    t.string "api_key"
    t.string "api_secret"
    t.string "webhook_url"
    t.jsonb "settings"
    t.string "status"
    t.datetime "last_sync_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_job_board_integrations_on_company_id"
  end

  create_table "job_board_providers", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "api_documentation_url"
    t.string "logo_url"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_board_sync_logs", force: :cascade do |t|
    t.bigint "job_board_integration_id", null: false
    t.bigint "job_id"
    t.string "action"
    t.string "status"
    t.text "message"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_board_integration_id"], name: "index_job_board_sync_logs_on_job_board_integration_id"
    t.index ["job_id"], name: "index_job_board_sync_logs_on_job_id"
  end

  create_table "job_skills", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "skill_id"], name: "index_job_skills_on_job_id_and_skill_id", unique: true
    t.index ["job_id"], name: "index_job_skills_on_job_id"
    t.index ["skill_id"], name: "index_job_skills_on_skill_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "created_by_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "requirements"
    t.text "benefits"
    t.string "role_type"
    t.string "role_level"
    t.string "remote_policy"
    t.decimal "salary_min", precision: 10, scale: 2
    t.decimal "salary_max", precision: 10, scale: 2
    t.string "salary_currency", default: "USD"
    t.string "salary_period"
    t.string "location"
    t.string "city"
    t.string "state"
    t.string "country"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "status", default: "draft"
    t.boolean "featured", default: false
    t.datetime "published_at"
    t.datetime "expires_at"
    t.boolean "allow_cover_letter", default: true
    t.boolean "require_portfolio", default: false
    t.text "application_instructions"
    t.string "external_id"
    t.string "external_source"
    t.jsonb "external_data"
    t.integer "views_count", default: 0
    t.integer "applications_count", default: 0
    t.boolean "worldwide", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "candidate_role_id"
    t.string "slug"
    t.integer "job_applications_count", default: 0, null: false
    t.index ["candidate_role_id"], name: "index_jobs_on_candidate_role_id"
    t.index ["company_id", "status"], name: "index_jobs_on_company_id_and_status"
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id"
    t.index ["expires_at"], name: "index_jobs_on_expires_at"
    t.index ["external_data"], name: "index_jobs_on_external_data", using: :gin
    t.index ["external_id"], name: "index_jobs_on_external_id"
    t.index ["external_source"], name: "index_jobs_on_external_source"
    t.index ["featured"], name: "index_jobs_on_featured"
    t.index ["job_applications_count"], name: "index_jobs_on_job_applications_count"
    t.index ["published_at"], name: "index_jobs_on_published_at"
    t.index ["remote_policy"], name: "index_jobs_on_remote_policy"
    t.index ["role_level"], name: "index_jobs_on_role_level"
    t.index ["role_type"], name: "index_jobs_on_role_type"
    t.index ["slug"], name: "index_jobs_on_slug", unique: true
    t.index ["status", "published_at"], name: "index_jobs_on_status_and_published_at"
    t.index ["status"], name: "index_jobs_on_status"
  end

  create_table "locations", force: :cascade do |t|
    t.string "locatable_type", null: false
    t.bigint "locatable_id", null: false
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "country_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "time_zone", null: false
    t.integer "utc_offset", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locatable_type", "locatable_id"], name: "index_locations_on_locatable"
    t.index ["locatable_type", "locatable_id"], name: "index_locations_on_locatable_type_and_locatable_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.string "resource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "role_levels", force: :cascade do |t|
    t.bigint "candidate_id"
    t.boolean "junior"
    t.boolean "mid"
    t.boolean "senior"
    t.boolean "principal"
    t.boolean "c_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_role_levels_on_candidate_id", unique: true
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.integer "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_role_permissions_on_company_id"
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "role_types", force: :cascade do |t|
    t.bigint "candidate_id"
    t.boolean "part_time_contract"
    t.boolean "full_time_contract"
    t.boolean "full_time_employment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_role_types_on_candidate_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "social_links", force: :cascade do |t|
    t.string "linkable_type", null: false
    t.bigint "linkable_id", null: false
    t.string "github"
    t.string "linked_in"
    t.string "website"
    t.string "twitter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linkable_type", "linkable_id"], name: "index_social_links_on_linkable"
    t.index ["linkable_type", "linkable_id"], name: "index_social_links_on_linkable_type_and_linkable_id"
  end

  create_table "specializations", force: :cascade do |t|
    t.string "specializable_type", null: false
    t.bigint "specializable_id", null: false
    t.bigint "candidate_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_role_id"], name: "index_specializations_on_candidate_role_id"
    t.index ["specializable_type", "specializable_id"], name: "index_specializations_on_specializable"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.string "tier"
    t.jsonb "features"
    t.boolean "active"
    t.integer "trial_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_user_roles_on_company_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.integer "user_type"
    t.integer "gender"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.date "date_of_birth"
    t.string "locale", default: "en"
    t.boolean "active", default: true, null: false
    t.datetime "onboarded_at"
    t.text "goals", default: [], array: true
    t.datetime "set_onboarding_preferences_at"
    t.datetime "set_onboarding_goals_at"
    t.bigint "company_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["onboarded_at"], name: "index_users_on_onboarded_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "candidate_roles", "candidate_role_groups"
  add_foreign_key "candidate_skills", "candidates"
  add_foreign_key "candidate_skills", "skills"
  add_foreign_key "candidates", "candidate_roles"
  add_foreign_key "candidates", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "company_subscriptions", "companies"
  add_foreign_key "company_subscriptions", "subscription_plans"
  add_foreign_key "experiences", "candidates"
  add_foreign_key "job_applications", "candidates"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "users"
  add_foreign_key "job_applications", "users", column: "reviewed_by_id"
  add_foreign_key "job_board_integrations", "companies"
  add_foreign_key "job_board_sync_logs", "job_board_integrations"
  add_foreign_key "job_board_sync_logs", "jobs", on_delete: :cascade
  add_foreign_key "job_skills", "jobs"
  add_foreign_key "job_skills", "skills"
  add_foreign_key "jobs", "candidate_roles"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "users", column: "created_by_id"
  add_foreign_key "role_levels", "candidates"
  add_foreign_key "role_permissions", "companies"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "role_types", "candidates"
  add_foreign_key "roles", "companies"
  add_foreign_key "specializations", "candidate_roles"
  add_foreign_key "user_roles", "companies"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "companies"
end
