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

ActiveRecord::Schema[7.0].define(version: 2023_07_05_063817) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "additional_exam_groups", force: :cascade do |t|
    t.string "name"
    t.bigint "batch_id"
    t.string "exam_type"
    t.boolean "is_published", default: false
    t.boolean "result_published", default: false
    t.string "students_list"
    t.date "exam_date"
    t.index ["batch_id"], name: "index_additional_exam_groups_on_batch_id"
  end

  create_table "additional_exam_scores", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "additional_exam_id"
    t.decimal "marks", precision: 7, scale: 2
    t.bigint "grading_level_id"
    t.string "remarks"
    t.boolean "is_failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_exam_id"], name: "index_additional_exam_scores_on_additional_exam_id"
    t.index ["grading_level_id"], name: "index_additional_exam_scores_on_grading_level_id"
    t.index ["student_id"], name: "index_additional_exam_scores_on_student_id"
  end

  create_table "additional_exams", force: :cascade do |t|
    t.bigint "additional_exam_group_id"
    t.bigint "subject_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "maximum_marks"
    t.integer "minimum_marks"
    t.bigint "grading_level_id"
    t.integer "weightage", default: 0
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_exam_group_id"], name: "index_additional_exams_on_additional_exam_group_id"
    t.index ["event_id"], name: "index_additional_exams_on_event_id"
    t.index ["grading_level_id"], name: "index_additional_exams_on_grading_level_id"
    t.index ["subject_id"], name: "index_additional_exams_on_subject_id"
  end

  create_table "additional_field_options", force: :cascade do |t|
    t.integer "additional_field_id"
    t.string "field_option"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_field_id"], name: "index_additional_field_options_on_additional_field_id"
  end

  create_table "additional_fields", force: :cascade do |t|
    t.string "name"
    t.boolean "status"
    t.boolean "is_mandatory", default: false
    t.string "input_type"
    t.integer "priority"
    t.index ["name"], name: "index_additional_fields_on_name", unique: true
  end

  create_table "apply_leaves", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "employee_leave_types_id"
    t.boolean "is_half_day"
    t.date "start_date"
    t.date "end_date"
    t.string "reason"
    t.boolean "approved", default: false
    t.boolean "viewed_by_manager", default: false
    t.string "manager_remark"
    t.index ["employee_id"], name: "index_apply_leaves_on_employee_id"
    t.index ["employee_leave_types_id"], name: "index_apply_leaves_on_employee_leave_types_id"
  end

  create_table "archived_employee_additional_details", force: :cascade do |t|
    t.bigint "additional_field_id"
    t.string "additional_info"
    t.bigint "archived_employee_id"
    t.index ["additional_field_id"], name: "archived_emp_additional_details_additional_field"
    t.index ["archived_employee_id"], name: "archived_emp_additional_details_employee"
  end

  create_table "archived_employee_bank_details", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "bank_field_id"
    t.string "bank_info"
    t.index ["bank_field_id"], name: "index_archived_employee_bank_details_on_bank_field_id"
    t.index ["employee_id"], name: "index_archived_employee_bank_details_on_employee_id"
  end

  create_table "archived_employee_salary_structures", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "payroll_category_id"
    t.string "amount"
    t.index ["employee_id"], name: "archived_emp_sal_struct_employee"
    t.index ["payroll_category_id"], name: "archived_emp_sal_struct_payroll_category"
  end

  create_table "archived_employees", force: :cascade do |t|
    t.bigint "employee_category_id"
    t.string "employee_number"
    t.date "joining_date"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "gender"
    t.string "job_title"
    t.bigint "employee_position_id"
    t.bigint "employee_department_id"
    t.integer "reporting_manager_id"
    t.bigint "employee_grade_id"
    t.string "qualification"
    t.text "experience_detail"
    t.integer "experience_year"
    t.integer "experience_month"
    t.boolean "status"
    t.string "status_description"
    t.date "date_of_birth"
    t.string "marital_status"
    t.integer "children_count"
    t.string "father_name"
    t.string "mother_name"
    t.string "husband_name"
    t.string "blood_group"
    t.bigint "nationality_id"
    t.string "home_address_line1"
    t.string "home_address_line2"
    t.string "home_city"
    t.string "home_state"
    t.integer "home_country_id"
    t.string "home_pin_code"
    t.string "office_address_line1"
    t.string "office_address_line2"
    t.string "office_city"
    t.string "office_state"
    t.integer "office_country_id"
    t.string "office_pin_code"
    t.string "office_phone1"
    t.string "office_phone2"
    t.string "mobile_phone"
    t.string "home_phone"
    t.string "email"
    t.string "fax"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.binary "photo_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "photo_file_size"
    t.string "former_id"
    t.integer "user_id"
    t.index ["employee_category_id"], name: "index_archived_employees_on_employee_category_id"
    t.index ["employee_department_id"], name: "index_archived_employees_on_employee_department_id"
    t.index ["employee_grade_id"], name: "index_archived_employees_on_employee_grade_id"
    t.index ["employee_position_id"], name: "index_archived_employees_on_employee_position_id"
    t.index ["nationality_id"], name: "index_archived_employees_on_nationality_id"
  end

  create_table "archived_exam_scores", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "exam_id"
    t.decimal "marks", precision: 7, scale: 2
    t.bigint "grading_level_id"
    t.string "remarks"
    t.boolean "is_failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_id"], name: "index_archived_exam_scores_on_exam_id"
    t.index ["grading_level_id"], name: "index_archived_exam_scores_on_grading_level_id"
    t.index ["student_id", "exam_id"], name: "index_archived_exam_scores_on_student_id_and_exam_id"
    t.index ["student_id"], name: "index_archived_exam_scores_on_student_id"
  end

  create_table "archived_guardians", force: :cascade do |t|
    t.bigint "ward_id"
    t.string "first_name"
    t.string "last_name"
    t.string "relation"
    t.string "email"
    t.string "office_phone1"
    t.string "office_phone2"
    t.string "mobile_phone"
    t.string "office_address_line1"
    t.string "office_address_line2"
    t.string "city"
    t.string "state"
    t.bigint "country_id"
    t.date "dob"
    t.string "occupation"
    t.string "income"
    t.string "education"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_archived_guardians_on_country_id"
    t.index ["ward_id"], name: "index_archived_guardians_on_ward_id"
  end

  create_table "archived_students", force: :cascade do |t|
    t.string "admission_no"
    t.string "class_roll_no"
    t.date "admission_date"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.bigint "batch_id"
    t.date "date_of_birth"
    t.string "gender"
    t.string "blood_group"
    t.string "birth_place"
    t.integer "nationality_id"
    t.string "language"
    t.string "religion"
    t.bigint "student_category_id"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "pin_code"
    t.integer "country_id"
    t.string "phone1"
    t.string "phone2"
    t.string "email"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.binary "photo_data"
    t.string "status_description"
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.bigint "immediate_contact_id"
    t.boolean "is_sms_enabled", default: true
    t.string "former_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "photo_file_size"
    t.integer "user_id"
    t.index ["batch_id"], name: "index_archived_students_on_batch_id"
    t.index ["immediate_contact_id"], name: "index_archived_students_on_immediate_contact_id"
    t.index ["student_category_id"], name: "index_archived_students_on_student_category_id"
  end

  create_table "assessment_scores", force: :cascade do |t|
    t.integer "student_id"
    t.integer "grade_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exam_id"
    t.integer "batch_id"
    t.integer "descriptive_indicator_id"
    t.index ["student_id", "batch_id", "descriptive_indicator_id", "exam_id"], name: "score_index"
  end

  create_table "assets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "amount"
    t.boolean "is_inactive", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "period_table_entry_id"
    t.boolean "forenoon", default: false
    t.boolean "afternoon", default: false
    t.string "reason"
    t.date "month_date"
    t.integer "batch_id"
    t.index ["month_date", "batch_id"], name: "index_attendances_on_month_date_and_batch_id"
    t.index ["period_table_entry_id"], name: "index_attendances_on_period_table_entry_id"
    t.index ["student_id", "batch_id"], name: "index_attendances_on_student_id_and_batch_id"
    t.index ["student_id"], name: "index_attendances_on_student_id"
  end

  create_table "bank_fields", force: :cascade do |t|
    t.string "name"
    t.boolean "status"
  end

  create_table "batch_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "batch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_batch_events_on_batch_id"
    t.index ["event_id"], name: "index_batch_events_on_event_id"
  end

  create_table "batch_groups", force: :cascade do |t|
    t.integer "course_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "batch_students", id: false, force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "batch_id"
    t.index ["batch_id", "student_id"], name: "index_batch_students_on_batch_id_and_student_id"
    t.index ["batch_id"], name: "index_batch_students_on_batch_id"
    t.index ["student_id"], name: "index_batch_students_on_student_id"
  end

  create_table "batches", force: :cascade do |t|
    t.string "name"
    t.bigint "course_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.string "employee_id"
    t.index ["course_id"], name: "index_batches_on_course_id"
  end

  create_table "cce_exam_categories", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cce_grade_sets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cce_grades", force: :cascade do |t|
    t.string "name"
    t.float "grade_point"
    t.integer "cce_grade_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cce_grade_set_id"], name: "index_cce_grades_on_cce_grade_set_id"
  end

  create_table "cce_reports", force: :cascade do |t|
    t.integer "observable_id"
    t.string "observable_type"
    t.integer "student_id"
    t.integer "batch_id"
    t.string "grade_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exam_id"
    t.index ["observable_id", "student_id", "batch_id", "exam_id", "observable_type"], name: "cce_report_join_index"
  end

  create_table "cce_weightages", force: :cascade do |t|
    t.integer "weightage"
    t.string "criteria_type"
    t.integer "cce_exam_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cce_weightages_courses", id: false, force: :cascade do |t|
    t.integer "cce_weightage_id"
    t.integer "course_id"
    t.index ["cce_weightage_id"], name: "index_cce_weightages_courses_on_cce_weightage_id"
    t.index ["course_id", "cce_weightage_id"], name: "index_for_join_table_cce_weightage_courses"
    t.index ["course_id"], name: "index_cce_weightages_courses_on_course_id"
  end

  create_table "class_designations", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "cgpa", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "marks", precision: 15, scale: 2
    t.integer "course_id"
  end

  create_table "class_timings", force: :cascade do |t|
    t.bigint "batch_id"
    t.string "name"
    t.time "start_time"
    t.time "end_time"
    t.boolean "is_break"
    t.boolean "is_deleted", default: false
    t.index ["batch_id", "start_time", "end_time"], name: "index_class_timings_on_batch_id_and_start_time_and_end_time"
    t.index ["batch_id"], name: "index_class_timings_on_batch_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.string "config_key"
    t.string "config_value"
    t.index ["config_key"], name: "index_configurations_on_config_key"
    t.index ["config_value"], name: "index_configurations_on_config_value"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
  end

  create_table "courses", force: :cascade do |t|
    t.string "course_name"
    t.string "code"
    t.string "section_name"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "grading_type"
    t.index ["grading_type"], name: "index_courses_on_grading_type"
  end

  create_table "courses_observation_groups", id: false, force: :cascade do |t|
    t.integer "course_id"
    t.integer "observation_group_id"
    t.index ["course_id"], name: "index_courses_observation_groups_on_course_id"
    t.index ["observation_group_id"], name: "index_courses_observation_groups_on_observation_group_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locked_by"], name: "index_delayed_jobs_on_locked_by"
  end

  create_table "descriptive_indicators", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.integer "describable_id"
    t.string "describable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order"
    t.index ["describable_id", "describable_type", "sort_order"], name: "describable_index"
  end

  create_table "elective_groups", force: :cascade do |t|
    t.string "name"
    t.bigint "batch_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_elective_groups_on_batch_id"
  end

  create_table "electives", force: :cascade do |t|
    t.bigint "elective_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["elective_group_id"], name: "index_electives_on_elective_group_id"
  end

  create_table "employee_additional_details", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "additional_field_id"
    t.string "additional_info"
    t.index ["additional_field_id"], name: "index_employee_additional_details_on_additional_field_id"
    t.index ["employee_id"], name: "index_employee_additional_details_on_employee_id"
  end

  create_table "employee_attendances", force: :cascade do |t|
    t.date "attendance_date"
    t.bigint "employee_id"
    t.bigint "employee_leave_type_id"
    t.string "reason"
    t.boolean "is_half_day"
    t.index ["employee_id"], name: "index_employee_attendances_on_employee_id"
    t.index ["employee_leave_type_id"], name: "index_employee_attendances_on_employee_leave_type_id"
  end

  create_table "employee_bank_details", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "bank_field_id"
    t.string "bank_info"
    t.index ["bank_field_id"], name: "index_employee_bank_details_on_bank_field_id"
    t.index ["employee_id"], name: "index_employee_bank_details_on_employee_id"
  end

  create_table "employee_categories", force: :cascade do |t|
    t.string "name"
    t.string "prefix"
    t.boolean "status"
    t.index ["name"], name: "index_employee_categories_on_name", unique: true
    t.index ["prefix"], name: "index_employee_categories_on_prefix", unique: true
  end

  create_table "employee_department_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "employee_department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_department_id"], name: "index_employee_department_events_on_employee_department_id"
    t.index ["event_id"], name: "index_employee_department_events_on_event_id"
  end

  create_table "employee_departments", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.boolean "status"
  end

  create_table "employee_grades", force: :cascade do |t|
    t.string "name"
    t.integer "priority"
    t.boolean "status"
    t.integer "max_hours_day"
    t.integer "max_hours_week"
  end

  create_table "employee_leave_types", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.boolean "status"
    t.string "max_leave_count"
    t.boolean "carry_forward", default: false, null: false
  end

  create_table "employee_leaves", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "employee_leave_type_id"
    t.decimal "leave_count", precision: 5, scale: 1, default: "0.0"
    t.decimal "leave_taken", precision: 5, scale: 1, default: "0.0"
    t.date "reset_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_leaves_on_employee_id"
    t.index ["employee_leave_type_id"], name: "index_employee_leaves_on_employee_leave_type_id"
  end

  create_table "employee_positions", force: :cascade do |t|
    t.string "name"
    t.bigint "employee_category_id"
    t.boolean "status"
    t.index ["employee_category_id"], name: "index_employee_positions_on_employee_category_id"
  end

  create_table "employee_salary_structures", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "payroll_category_id"
    t.string "amount"
    t.index ["employee_id"], name: "index_employee_salary_structures_on_employee_id"
    t.index ["payroll_category_id"], name: "index_employee_salary_structures_on_payroll_category_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "employee_category_id"
    t.string "employee_number"
    t.date "joining_date"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "gender"
    t.string "job_title"
    t.bigint "employee_position_id"
    t.bigint "employee_department_id"
    t.integer "reporting_manager_id"
    t.bigint "employee_grade_id"
    t.string "qualification"
    t.text "experience_detail"
    t.integer "experience_year"
    t.integer "experience_month"
    t.boolean "status"
    t.string "status_description"
    t.date "date_of_birth"
    t.string "marital_status"
    t.integer "children_count"
    t.string "father_name"
    t.string "mother_name"
    t.string "husband_name"
    t.string "blood_group"
    t.bigint "nationality_id"
    t.string "home_address_line1"
    t.string "home_address_line2"
    t.string "home_city"
    t.string "home_state"
    t.integer "home_country_id"
    t.string "home_pin_code"
    t.string "office_address_line1"
    t.string "office_address_line2"
    t.string "office_city"
    t.string "office_state"
    t.integer "office_country_id"
    t.string "office_pin_code"
    t.string "office_phone1"
    t.string "office_phone2"
    t.string "mobile_phone"
    t.string "home_phone"
    t.string "email"
    t.string "fax"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.binary "photo_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "photo_file_size"
    t.integer "user_id"
    t.index ["employee_category_id"], name: "index_employees_on_employee_category_id"
    t.index ["employee_department_id"], name: "index_employees_on_employee_department_id"
    t.index ["employee_grade_id"], name: "index_employees_on_employee_grade_id"
    t.index ["employee_number"], name: "index_employees_on_employee_number"
    t.index ["employee_position_id"], name: "index_employees_on_employee_position_id"
    t.index ["nationality_id"], name: "index_employees_on_nationality_id"
  end

  create_table "employees_subjects", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "subject_id"
    t.index ["employee_id"], name: "index_employees_subjects_on_employee_id"
    t.index ["subject_id"], name: "index_employees_subjects_on_subject_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "is_common", default: false
    t.boolean "is_holiday", default: false
    t.boolean "is_exam", default: false
    t.boolean "is_due", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "origin_id"
    t.string "origin_type"
    t.index ["is_common", "is_holiday", "is_exam"], name: "index_events_on_is_common_and_is_holiday_and_is_exam"
  end

  create_table "exam_groups", force: :cascade do |t|
    t.string "name"
    t.bigint "batch_id"
    t.string "exam_type"
    t.boolean "is_published", default: false
    t.boolean "result_published", default: false
    t.date "exam_date"
    t.boolean "is_final_exam", default: false, null: false
    t.integer "cce_exam_category_id"
    t.index ["batch_id"], name: "index_exam_groups_on_batch_id"
  end

  create_table "exam_scores", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "exam_id"
    t.decimal "marks", precision: 7, scale: 2
    t.bigint "grading_level_id"
    t.string "remarks"
    t.boolean "is_failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_id"], name: "index_exam_scores_on_exam_id"
    t.index ["grading_level_id"], name: "index_exam_scores_on_grading_level_id"
    t.index ["student_id", "exam_id"], name: "index_exam_scores_on_student_id_and_exam_id"
    t.index ["student_id"], name: "index_exam_scores_on_student_id"
  end

  create_table "exams", force: :cascade do |t|
    t.bigint "exam_group_id"
    t.bigint "subject_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "maximum_marks", precision: 10, scale: 2
    t.decimal "minimum_marks", precision: 10, scale: 2
    t.bigint "grading_level_id"
    t.integer "weightage", default: 0
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_exams_on_event_id"
    t.index ["exam_group_id", "subject_id"], name: "index_exams_on_exam_group_id_and_subject_id"
    t.index ["exam_group_id"], name: "index_exams_on_exam_group_id"
    t.index ["grading_level_id"], name: "index_exams_on_grading_level_id"
    t.index ["subject_id"], name: "index_exams_on_subject_id"
  end

  create_table "fa_criteria", force: :cascade do |t|
    t.string "fa_name"
    t.string "desc"
    t.integer "fa_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order"
    t.boolean "is_deleted", default: false
    t.index ["fa_group_id"], name: "index_fa_criteria_on_fa_group_id"
  end

  create_table "fa_groups", force: :cascade do |t|
    t.string "name"
    t.text "desc"
    t.integer "cce_exam_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cce_grade_set_id"
    t.float "max_marks", default: 100.0
    t.boolean "is_deleted", default: false
  end

  create_table "fa_groups_subjects", id: false, force: :cascade do |t|
    t.integer "subject_id"
    t.integer "fa_group_id"
    t.index ["fa_group_id"], name: "index_fa_groups_subjects_on_fa_group_id"
    t.index ["subject_id"], name: "index_fa_groups_subjects_on_subject_id"
  end

  create_table "fee_collection_discounts", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.bigint "receiver_id"
    t.bigint "finance_fee_collection_id"
    t.decimal "discount", precision: 15, scale: 2
    t.boolean "is_amount", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finance_fee_collection_id"], name: "index_fee_collection_discounts_on_finance_fee_collection_id"
    t.index ["receiver_id"], name: "index_fee_collection_discounts_on_receiver_id"
  end

  create_table "fee_collection_particulars", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "amount", precision: 12, scale: 2
    t.bigint "finance_fee_collection_id"
    t.bigint "student_category_id"
    t.string "admission_no"
    t.bigint "student_id"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finance_fee_collection_id"], name: "index_fee_collection_particulars_on_finance_fee_collection_id"
    t.index ["student_category_id"], name: "index_fee_collection_particulars_on_student_category_id"
    t.index ["student_id"], name: "index_fee_collection_particulars_on_student_id"
  end

  create_table "fee_discounts", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.bigint "receiver_id"
    t.bigint "finance_fee_category_id"
    t.decimal "discount", precision: 15, scale: 2
    t.boolean "is_amount", default: false
    t.index ["finance_fee_category_id"], name: "index_fee_discounts_on_finance_fee_category_id"
    t.index ["receiver_id"], name: "index_fee_discounts_on_receiver_id"
  end

  create_table "finance_donations", force: :cascade do |t|
    t.string "donor"
    t.string "description"
    t.decimal "amount", precision: 15, scale: 2
    t.bigint "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "transaction_date"
    t.index ["transaction_id"], name: "index_finance_donations_on_transaction_id"
  end

  create_table "finance_fee_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "batch_id"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "is_master", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_finance_fee_categories_on_batch_id"
  end

  create_table "finance_fee_collections", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.date "due_date"
    t.bigint "fee_category_id"
    t.bigint "batch_id"
    t.boolean "is_deleted", default: false, null: false
    t.index ["batch_id"], name: "index_finance_fee_collections_on_batch_id"
    t.index ["fee_category_id"], name: "index_finance_fee_collections_on_fee_category_id"
  end

  create_table "finance_fee_particulars", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "amount", precision: 15, scale: 2
    t.bigint "finance_fee_category_id"
    t.bigint "student_category_id"
    t.string "admission_no"
    t.bigint "student_id"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["finance_fee_category_id"], name: "index_finance_fee_particulars_on_finance_fee_category_id"
    t.index ["student_category_id"], name: "index_finance_fee_particulars_on_student_category_id"
    t.index ["student_id"], name: "index_finance_fee_particulars_on_student_id"
  end

  create_table "finance_fee_structure_elements", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.string "label"
    t.bigint "batch_id"
    t.bigint "student_category_id"
    t.bigint "student_id"
    t.bigint "parent_id"
    t.bigint "fee_collection_id"
    t.boolean "deleted", default: false
    t.index ["batch_id"], name: "index_finance_fee_structure_elements_on_batch_id"
    t.index ["fee_collection_id"], name: "index_finance_fee_structure_elements_on_fee_collection_id"
    t.index ["parent_id"], name: "index_finance_fee_structure_elements_on_parent_id"
    t.index ["student_category_id"], name: "index_finance_fee_structure_elements_on_student_category_id"
    t.index ["student_id"], name: "index_finance_fee_structure_elements_on_student_id"
  end

  create_table "finance_fees", force: :cascade do |t|
    t.bigint "fee_collection_id"
    t.string "transaction_id"
    t.bigint "student_id"
    t.boolean "is_paid", default: false
    t.index ["fee_collection_id", "student_id"], name: "index_finance_fees_on_fee_collection_id_and_student_id"
    t.index ["fee_collection_id"], name: "index_finance_fees_on_fee_collection_id"
    t.index ["student_id"], name: "index_finance_fees_on_student_id"
  end

  create_table "finance_transaction_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_income"
    t.boolean "deleted", default: false, null: false
  end

  create_table "finance_transaction_triggers", force: :cascade do |t|
    t.bigint "finance_category_id"
    t.decimal "percentage", precision: 8, scale: 2
    t.string "title"
    t.string "description"
    t.index ["finance_category_id"], name: "index_finance_transaction_triggers_on_finance_category_id"
  end

  create_table "finance_transactions", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.decimal "amount", precision: 15, scale: 2
    t.boolean "fine_included", default: false
    t.bigint "category_id"
    t.bigint "student_id"
    t.bigint "finance_fees_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "transaction_date"
    t.decimal "fine_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "master_transaction_id", default: 0
    t.integer "finance_id"
    t.string "finance_type"
    t.integer "payee_id"
    t.string "payee_type"
    t.string "receipt_no"
    t.string "voucher_no"
    t.index ["category_id"], name: "index_finance_transactions_on_category_id"
    t.index ["finance_fees_id"], name: "index_finance_transactions_on_finance_fees_id"
    t.index ["student_id"], name: "index_finance_transactions_on_student_id"
  end

  create_table "grading_levels", force: :cascade do |t|
    t.string "name"
    t.bigint "batch_id"
    t.integer "min_score"
    t.integer "order"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "credit_points", precision: 15, scale: 2
    t.string "description"
    t.index ["batch_id", "is_deleted"], name: "index_grading_levels_on_batch_id_and_is_deleted"
    t.index ["batch_id"], name: "index_grading_levels_on_batch_id"
    t.index ["name"], name: "index_grading_levels_on_name", unique: true
  end

  create_table "grouped_batches", force: :cascade do |t|
    t.integer "batch_group_id"
    t.integer "batch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_group_id"], name: "index_grouped_batches_on_batch_group_id"
  end

  create_table "grouped_exam_reports", force: :cascade do |t|
    t.integer "batch_id"
    t.integer "student_id"
    t.integer "exam_group_id"
    t.decimal "marks", precision: 15, scale: 2
    t.string "score_type"
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id", "student_id", "score_type"], name: "by_batch_student_and_score_type"
  end

  create_table "grouped_exams", force: :cascade do |t|
    t.bigint "exam_group_id"
    t.bigint "batch_id"
    t.decimal "weightage", precision: 15, scale: 2
    t.index ["batch_id", "exam_group_id"], name: "index_grouped_exams_on_batch_id_and_exam_group_id"
    t.index ["batch_id"], name: "index_grouped_exams_on_batch_id"
    t.index ["exam_group_id"], name: "index_grouped_exams_on_exam_group_id"
  end

  create_table "guardians", force: :cascade do |t|
    t.bigint "ward_id"
    t.string "first_name"
    t.string "last_name"
    t.string "relation"
    t.string "email"
    t.string "office_phone1"
    t.string "office_phone2"
    t.string "mobile_phone"
    t.string "office_address_line1"
    t.string "office_address_line2"
    t.string "city"
    t.string "state"
    t.bigint "country_id"
    t.date "dob"
    t.string "occupation"
    t.string "income"
    t.string "education"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["country_id"], name: "index_guardians_on_country_id"
    t.index ["ward_id"], name: "index_guardians_on_ward_id"
  end

  create_table "individual_payslip_categories", force: :cascade do |t|
    t.bigint "employee_id"
    t.date "salary_date"
    t.string "name"
    t.string "amount"
    t.boolean "is_deduction"
    t.boolean "include_every_month"
    t.index ["employee_id"], name: "index_individual_payslip_categories_on_employee_id"
  end

  create_table "liabilities", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "amount"
    t.boolean "is_solved", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_payslips", force: :cascade do |t|
    t.date "salary_date"
    t.bigint "employee_id"
    t.bigint "payroll_category_id"
    t.string "amount"
    t.boolean "is_approved", default: false, null: false
    t.bigint "approver_id"
    t.boolean "is_rejected", default: false, null: false
    t.integer "rejector_id"
    t.string "reason"
    t.string "remark"
    t.index ["approver_id"], name: "index_monthly_payslips_on_approver_id"
    t.index ["employee_id"], name: "index_monthly_payslips_on_employee_id"
    t.index ["payroll_category_id"], name: "index_monthly_payslips_on_payroll_category_id"
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_news_on_author_id"
  end

  create_table "news_comments", force: :cascade do |t|
    t.text "content"
    t.bigint "news_id"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_approved", default: false
    t.index ["author_id"], name: "index_news_comments_on_author_id"
    t.index ["news_id"], name: "index_news_comments_on_news_id"
  end

  create_table "observation_groups", force: :cascade do |t|
    t.string "name"
    t.string "header_name"
    t.string "desc"
    t.string "cce_grade_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "observation_kind"
    t.float "max_marks"
    t.boolean "is_deleted", default: false
  end

  create_table "observations", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.boolean "is_active"
    t.integer "observation_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order"
    t.index ["observation_group_id"], name: "index_observations_on_observation_group_id"
  end

  create_table "payroll_categories", force: :cascade do |t|
    t.string "name"
    t.float "percentage"
    t.bigint "payroll_category_id"
    t.boolean "is_deduction"
    t.boolean "status"
    t.index ["payroll_category_id"], name: "index_payroll_categories_on_payroll_category_id"
  end

  create_table "period_entries", force: :cascade do |t|
    t.date "month_date"
    t.bigint "batch_id"
    t.bigint "subject_id"
    t.bigint "class_timing_id"
    t.bigint "employee_id"
    t.index ["batch_id"], name: "index_period_entries_on_batch_id"
    t.index ["class_timing_id"], name: "index_period_entries_on_class_timing_id"
    t.index ["employee_id"], name: "index_period_entries_on_employee_id"
    t.index ["month_date", "batch_id"], name: "index_period_entries_on_month_date_and_batch_id"
    t.index ["subject_id"], name: "index_period_entries_on_subject_id"
  end

  create_table "previous_exam_scores", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "exam_id"
    t.decimal "marks", precision: 7, scale: 2
    t.integer "grading_level_id"
    t.string "remarks"
    t.boolean "is_failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_id"], name: "index_previous_exam_scores_on_exam_id"
    t.index ["student_id", "exam_id"], name: "index_previous_exam_scores_on_student_id_and_exam_id"
    t.index ["student_id"], name: "index_previous_exam_scores_on_student_id"
  end

  create_table "privilege_tags", force: :cascade do |t|
    t.string "name_tag"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "privileges", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "privilege_tag_id"
    t.integer "priority"
  end

  create_table "privileges_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "privilege_id"
    t.index ["privilege_id"], name: "index_privileges_users_on_privilege_id"
    t.index ["user_id"], name: "index_privileges_users_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.jsonb "skus", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ranking_levels", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "gpa", precision: 15, scale: 2
    t.decimal "marks", precision: 15, scale: 2
    t.integer "subject_count"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "full_course", default: false
    t.integer "course_id"
    t.string "subject_limit_type"
    t.string "marks_limit_type"
  end

  create_table "reminders", force: :cascade do |t|
    t.integer "sender"
    t.integer "recipient"
    t.string "subject"
    t.text "body"
    t.boolean "is_read", default: false
    t.boolean "is_deleted_by_sender", default: false
    t.boolean "is_deleted_by_recipient", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient"], name: "index_reminders_on_recipient"
  end

  create_table "school_details", force: :cascade do |t|
    t.integer "school_id"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.string "logo_file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sms_logs", force: :cascade do |t|
    t.string "mobile"
    t.string "gateway_response"
    t.string "sms_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sms_messages", force: :cascade do |t|
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sms_settings", force: :cascade do |t|
    t.string "settings_key"
    t.boolean "is_enabled", default: false
  end

  create_table "student_additional_details", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "additional_field_id"
    t.string "additional_info"
    t.index ["additional_field_id"], name: "index_student_additional_details_on_additional_field_id"
    t.index ["student_id"], name: "index_student_additional_details_on_student_id"
  end

  create_table "student_additional_field_options", force: :cascade do |t|
    t.integer "student_additional_field_id"
    t.string "field_option"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_additional_fields", force: :cascade do |t|
    t.string "name"
    t.boolean "status"
    t.boolean "is_mandatory", default: false
    t.string "input_type"
    t.integer "priority"
    t.index ["name"], name: "index_student_additional_fields_on_name", unique: true
  end

  create_table "student_categories", force: :cascade do |t|
    t.string "name"
    t.boolean "is_deleted", default: false, null: false
  end

  create_table "student_previous_datas", force: :cascade do |t|
    t.bigint "student_id"
    t.string "institution"
    t.string "year"
    t.string "course"
    t.string "total_mark"
    t.index ["student_id"], name: "index_student_previous_datas_on_student_id"
  end

  create_table "student_previous_subject_marks", force: :cascade do |t|
    t.bigint "student_id"
    t.string "subject"
    t.string "mark"
    t.index ["student_id"], name: "index_student_previous_subject_marks_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "admission_no"
    t.string "class_roll_no"
    t.date "admission_date"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.bigint "batch_id"
    t.date "date_of_birth"
    t.string "gender"
    t.string "blood_group"
    t.string "birth_place"
    t.integer "nationality_id"
    t.string "language"
    t.string "religion"
    t.bigint "student_category_id"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "state"
    t.string "pin_code"
    t.integer "country_id"
    t.string "phone1"
    t.string "phone2"
    t.string "email"
    t.bigint "immediate_contact_id"
    t.boolean "is_sms_enabled", default: true
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.binary "photo_data"
    t.string "status_description"
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_paid_fees", default: false
    t.integer "photo_file_size"
    t.integer "user_id"
    t.index ["admission_no"], name: "index_students_on_admission_no"
    t.index ["batch_id"], name: "index_students_on_batch_id"
    t.index ["first_name", "middle_name", "last_name"], name: "index_students_on_first_name_and_middle_name_and_last_name"
    t.index ["immediate_contact_id"], name: "index_students_on_immediate_contact_id"
    t.index ["nationality_id", "immediate_contact_id", "student_category_id"], name: "student_data_index"
    t.index ["student_category_id"], name: "index_students_on_student_category_id"
  end

  create_table "students_subjects", force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "subject_id"
    t.bigint "batch_id"
    t.index ["batch_id"], name: "index_students_subjects_on_batch_id"
    t.index ["student_id", "subject_id"], name: "index_students_subjects_on_student_id_and_subject_id"
    t.index ["student_id"], name: "index_students_subjects_on_student_id"
    t.index ["subject_id"], name: "index_students_subjects_on_subject_id"
  end

  create_table "subject_amounts", force: :cascade do |t|
    t.bigint "course_id"
    t.decimal "amount"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_subject_amounts_on_course_id"
  end

  create_table "subject_leaves", force: :cascade do |t|
    t.integer "student_id"
    t.date "month_date"
    t.integer "subject_id"
    t.integer "employee_id"
    t.integer "class_timing_id"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "batch_id"
    t.index ["month_date", "subject_id", "batch_id"], name: "index_subject_leaves_on_month_date_and_subject_id_and_batch_id"
    t.index ["student_id", "batch_id"], name: "index_subject_leaves_on_student_id_and_batch_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "batch_id"
    t.boolean "no_exams", default: false
    t.integer "max_weekly_classes"
    t.bigint "elective_group_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "credit_hours", precision: 15, scale: 2
    t.boolean "prefer_consecutive", default: false
    t.decimal "amount", precision: 15, scale: 2
    t.index ["batch_id", "elective_group_id", "is_deleted"], name: "index_subjects_on_batch_id_and_elective_group_id_and_is_deleted"
    t.index ["batch_id"], name: "index_subjects_on_batch_id"
    t.index ["elective_group_id"], name: "index_subjects_on_elective_group_id"
  end

  create_table "time_zones", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "difference_type"
    t.integer "time_difference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetable_entries", force: :cascade do |t|
    t.bigint "batch_id"
    t.bigint "weekday_id"
    t.bigint "class_timing_id"
    t.bigint "subject_id"
    t.bigint "employee_id"
    t.integer "timetable_id"
    t.index ["batch_id"], name: "index_timetable_entries_on_batch_id"
    t.index ["class_timing_id"], name: "index_timetable_entries_on_class_timing_id"
    t.index ["employee_id"], name: "index_timetable_entries_on_employee_id"
    t.index ["subject_id"], name: "index_timetable_entries_on_subject_id"
    t.index ["timetable_id"], name: "index_timetable_entries_on_timetable_id"
    t.index ["weekday_id"], name: "index_timetable_entries_on_weekday_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_date", "end_date"], name: "by_start_and_end"
  end

  create_table "user_events", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_user_events_on_event_id"
    t.index ["user_id"], name: "index_user_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.boolean "admin"
    t.boolean "student"
    t.boolean "employee"
    t.string "hashed_password"
    t.string "salt"
    t.string "reset_password_code"
    t.datetime "reset_password_code_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weekdays", force: :cascade do |t|
    t.bigint "batch_id"
    t.string "weekday"
    t.string "name"
    t.integer "sort_order"
    t.integer "day_of_week"
    t.boolean "is_deleted", default: false
    t.index ["batch_id"], name: "index_weekdays_on_batch_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
