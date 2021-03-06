class AddGpaCwaIndices < ActiveRecord::Migration[7.0]
  def self.up
    add_index :grouped_exams, %i[batch_id exam_group_id]
    add_index :previous_exam_scores, %i[student_id exam_id]
  end

  def self.down
    remove_index :grouped_exams, %i[batch_id exam_group_id]
    remove_index :previous_exam_scores, %i[student_id exam_id]
  end
end
