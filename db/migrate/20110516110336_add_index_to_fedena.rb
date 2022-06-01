class AddIndexToFedena < ActiveRecord::Migration[7.0]
  def self.up
    add_index :users, [:username], length: 10
    # add_index :finance_fee_collections, [:fee_category_id]
    add_index :finance_fees, %i[fee_collection_id student_id]
    add_index :batch_students, %i[batch_id student_id]
    add_index :subjects, %i[batch_id elective_group_id is_deleted]
    add_index :configurations, [:config_key], length: 10
    add_index :exam_scores, %i[student_id exam_id]
    add_index :archived_exam_scores, %i[student_id exam_id]
    add_index :exams, %i[exam_group_id subject_id]
    # add_index :grouped_exams, [:batch_id]
    add_index :grading_levels, %i[batch_id is_deleted]
    add_index :students_subjects, %i[student_id subject_id]
    add_index :period_entries, %i[month_date batch_id]
    add_index :timetable_entries, %i[weekday_id batch_id class_timing_id], name: 'by_timetable'
    # add_index :employees_subjects, [:subject_id]
    # add_index :weekdays, [:batch_id]
    add_index :events, %i[is_common is_holiday is_exam]
    # add_index :batch_events, [:batch_id]
    add_index :class_timings, %i[batch_id start_time end_time]
  end

  def self.down
    remove_index :users, [:username]
    # remove_index :finance_fee_collections, [:fee_category_id]
    remove_index :finance_fees, %i[fee_collection_id student_id]
    remove_index :batch_students, %i[batch_id student_id]
    remove_index :subjects, %i[batch_id elective_group_id is_deleted]
    remove_index :configurations, [:config_key]
    remove_index :exam_scores, %i[student_id exam_id]
    remove_index :exams, %i[exam_group_id subject_id]
    remove_index :archived_exam_scores, %i[student_id exam_id]
    # remove_index :grouped_exams, [:batch_id]
    remove_index :grading_levels, %i[batch_id is_deleted]
    remove_index :students_subjects, %i[student_id subject_id]
    remove_index :period_entries, %i[month_date batch_id]
    remove_index :timetable_entries, name: 'by_timetable'
    # remove_index :employees_subjects, [:subject_id]
    # remove_index :weekdays, [:batch_id]
    remove_index :events, %i[is_common is_holiday is_exam]
    # remove_index :batch_events, [:batch_id]
    remove_index :class_timings, %i[batch_id start_time end_time]
  end
end
