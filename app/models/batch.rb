# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Batch < ApplicationRecord
  GRADINGTYPES = { "1" => "GPA", "2" => "CWA", "3" => "CCE" }.freeze

  belongs_to :course

  has_many :students
  has_many :grouped_exam_reports
  has_many :grouped_batches
  has_many :archived_students
  has_many :grading_levels, -> { where(is_deleted: false) }
  has_many :subjects, -> { where(is_deleted: false) }
  has_many :employees_subjects, through: :subjects
  has_many :exam_groups
  has_many :fee_category, class_name: "FinanceFeeCategory"
  has_many :elective_groups
  has_many :finance_fee_collections
  has_many :finance_transactions, through: :students
  has_many :batch_events
  has_many :events, through: :batch_events
  has_many :batch_fee_discounts, foreign_key: 'receiver_id'
  has_many :student_category_fee_discounts, foreign_key: 'receiver_id'
  has_many :attendances
  has_many :subject_leaves
  has_many :timetable_entries
  has_many :cce_reports
  has_many :assessment_scores

  has_and_belongs_to_many :graduated_students, class_name: 'Student', join_table: 'batch_students'

  delegate :course_name, :section_name, :code, to: :course
  delegate :grading_type, :cce_enabled?, :observation_groups, :cce_weightages, to: :course

  validates :name, :start_date, :end_date, presence: true

  attr_accessor :job_type

  scope :active, lambda {
    where(is_deleted: false, is_active: true)
      .joins(:course)
      .select("`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name")
      .order("course_full_name")
  }

  scope :inactive, lambda {
    where(is_deleted: false, is_active: false)
      .joins(:course)
      .select("`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name")
      .order("course_full_name")
  }

  scope :deleted, lambda {
    where(is_deleted: true)
      .joins(:course)
      .select("`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name")
      .order("course_full_name")
  }

  scope :cce, lambda {
    select("batches.*")
      .joins(:course)
      .where(["courses.grading_type = #{GRADINGTYPES.invert['CCE']}"])
      .order(code: :desc)
  }

  def validate
    errors.add(:start_date, "#{t('should_be_before_end_date')}.") if start_date && end_date && (start_date > end_date)
  end

  def full_name
    "#{code} - #{name}"
  end

  def course_section_name
    "#{course_name} - #{section_name}"
  end

  def inactivate
    update(:is_deleted, true)
    employees_subjects.destroy_all
  end

  def grading_level_list
    levels = grading_levels
    levels.empty? ? GradingLevel.default : levels
  end

  def fee_collection_dates
    FinanceFeeCollection.find_all_by_batch_id(id, conditions: "is_deleted = false")
  end

  def all_students
    Student.find_all_by_batch_id(id)
  end

  def normal_batch_subject
    Subject.find_all_by_batch_id(id, conditions: ["elective_group_id IS NULL AND is_deleted = false"])
  end

  def elective_batch_subject(elect_group)
    Subject.find_all_by_batch_id_and_elective_group_id(id, elect_group,
                                                       conditions: ["elective_group_id IS NOT NULL AND is_deleted = false"])
  end

  def all_elective_subjects
    elective_groups.map(&:subjects).compact.flatten.select { |subject| subject.is_deleted == false }
  end

  def own_weekday?
    Weekday.find_all_by_batch_id(id, conditions: { is_deleted: false }).present?
  end

  def allow_exam_acess(user)
    flag = true
    if user.employee? && user.role_symbols.include?(:subject_exam) && user.employee_record.subjects.where("batch_id = '#{id}'").blank?
      flag = false
    end
    flag
  end

  def a_holiday_for_batch?(day)
    return true if Event.holidays.count(:all, conditions: ["start_date <=? AND end_date >= ?", day, day]).positive?

    false
  end

  def holiday_event_dates
    @common_holidays ||= Event.holidays.is_common
    @batch_holidays = events.holidays
    all_holiday_events = @batch_holidays + @common_holidays
    event_holidays = []
    all_holiday_events.each do |event|
      event_holidays += event.dates
    end
    event_holidays # array of holiday event dates
  end

  def return_holidays(start_date, end_date)
    @common_holidays ||= Event.holidays.is_common
    @batch_holidays = events(:all, conditions: { is_holiday: true })
    all_holiday_events = @batch_holidays + @common_holidays
    all_holiday_events.select! { |h| (h.start_date >= start_date and h.end_date <= end_date) }
    event_holidays = []
    all_holiday_events.each do |event|
      event_holidays += event.dates
    end
    event_holidays # array of holiday event dates
  end

  def find_working_days(start_date, end_date)
    start = []
    start << self.start_date.to_date
    start << start_date.to_date
    stop = []
    stop << self.end_date.to_date
    stop << end_date.to_date
    all_days = start.max..stop.min
    weekdays = Weekday.weekday_by_day(id).keys
    holidays = return_holidays(start_date, end_date)
    non_holidays = all_days.to_a - holidays
    non_holidays.select { |d| weekdays.include? d.wday }
  end

  def working_days(date)
    start = []
    start << start_date.to_date
    start << date.beginning_of_month.to_date
    stop = []
    stop << end_date.to_date
    stop << date.end_of_month.to_date
    all_days = start.max..stop.min
    weekdays = Weekday.weekday_by_day(id).keys
    holidays = holiday_event_dates
    non_holidays = all_days.to_a - holidays
    non_holidays.select { |d| weekdays.include? d.wday }
  end

  def academic_days
    all_days = start_date.to_date..Date.today
    weekdays = Weekday.weekday_by_day(id).keys
    holidays = holiday_event_dates
    non_holidays = all_days.to_a - holidays
    non_holidays.select { |d| weekdays.include? d.wday }
  end

  def total_subject_hours(subject_id)
    days = academic_days
    count = 0
    if subject_id.zero?
      days.each do |d|
        count += Timetable.tte_for_the_day(self, d).count
      end
    else
      subject = Subject.find subject_id
      days.each do |d|
        count += Timetable.subject_tte(subject_id, d).count
      end
    end
    count
  end

  def find_batch_rank
    @students = Student.find_all_by_batch_id(id)
    @grouped_exams = GroupedExam.find_all_by_batch_id(id)
    ordered_scores = []
    student_scores = []
    ranked_students = []
    @students.each do |student|
      score = GroupedExamReport.find_by(student_id: student.id, batch_id: student.batch_id, score_type: "c")
      marks = 0
      marks = score.marks unless score.nil?
      ordered_scores << marks
      student_scores << [student.id, marks]
    end
    ordered_scores = ordered_scores.compact.uniq.sort.reverse
    @students.each do |student|
      marks = 0
      student_scores.each do |student_score|
        marks = student_score[1] if student_score[0] == student.id
      end
      ranked_students << [(ordered_scores.index(marks) + 1), marks, student.id, student]
    end
    ranked_students = ranked_students.sort
  end

  def find_attendance_rank(start_date, end_date)
    @students = Student.find_all_by_batch_id(id)
    ranked_students = []
    unless @students.empty?
      working_days = find_working_days(start_date, end_date).count
      unless working_days.zero?
        ordered_percentages = []
        student_percentages = []
        @students.each do |student|
          leaves = Attendance.find(:all,
                                   conditions: ["student_id = ? and month_date >= ? and month_date <= ?",
                                                student.id, start_date, end_date])
          absents = 0
          unless leaves.empty?
            leaves.each do |leave|
              absents = if (leave.forenoon == true) && (leave.afternoon == true)
                          absents + 1
                        else
                          absents + 0.5
                        end
            end
          end
          percentage = ((working_days.to_f - absents).to_f / working_days) * 100
          ordered_percentages << percentage
          student_percentages << [student.id, (working_days - absents), percentage]
        end
        ordered_percentages = ordered_percentages.compact.uniq.sort.reverse
        @students.each do |student|
          stu_percentage = 0
          attended = 0
          working_days
          student_percentages.each do |student_percentage|
            if student_percentage[0] == student.id
              attended = student_percentage[1]
              stu_percentage = student_percentage[2]
            end
          end
          ranked_students << [(ordered_percentages.index(stu_percentage) + 1), stu_percentage, student.first_name,
                              working_days, attended, student]
        end
      end
    end
    ranked_students
  end

  def gpa_enabled?
    Configuration.gpa? and grading_type == "1"
  end

  def cwa_enabled?
    Configuration.cwa? and grading_type == "2"
  end

  def normal_enabled?
    grading_type.nil? or grading_type == "0"
  end

  def generate_batch_reports
    grading_type = self.grading_type
    students = self.students
    grouped_exams = exam_groups.select { |e| GroupedExam.exists?(batch_id: id, exam_group_id: e.id) }
    unless grouped_exams.empty?
      subjects = self.subjects(conditions: { is_deleted: false })
      unless students.empty?
        st_scores = GroupedExamReport.find_all_by_student_id_and_batch_id(students, id)
        st_scores.map(&:destroy) unless st_scores.empty?
        subject_marks = []
        exam_marks = []
        grouped_exams.each do |exam_group|
          subjects.each do |subject|
            exam = Exam.find_by(exam_group_id: exam_group.id, subject_id: subject.id)
            next if exam.nil?

            students.each do |student|
              is_assigned_elective = 1
              unless subject.elective_group_id.nil?
                assigned = StudentsSubject.find_by(student_id: student.id, subject_id: subject.id)
                is_assigned_elective = 0 if assigned.nil?
              end
              next if is_assigned_elective.zero?

              percentage = 0
              marks = 0
              score = ExamScore.find_by(exam_id: exam.id, student_id: student.id)
              if grading_type.nil? || normal_enabled?
                unless score.nil? || score.marks.nil?
                  percentage = ((score.marks.to_f / exam.maximum_marks) * 100) * (exam_group.weightage.to_f / 100)
                  marks = score.marks.to_f
                end
              elsif gpa_enabled?
                unless score.nil? || score.grading_level_id.nil?
                  percentage = score.grading_level.credit_points.to_f * (exam_group.weightage.to_f / 100)
                  marks = score.grading_level.credit_points.to_f * subject.credit_hours.to_f
                end
              elsif cwa_enabled?
                unless score.nil? || score.marks.nil?
                  percentage = ((score.marks.to_f / exam.maximum_marks) * 100) * (exam_group.weightage.to_f / 100)
                  marks = ((score.marks.to_f / exam.maximum_marks) * 100) * subject.credit_hours.to_f
                end
              end
              flag = 0
              subject_marks.each do |s|
                if (s[0] == student.id) && (s[1] == subject.id)
                  s[2] << percentage.to_f
                  flag = 1
                end
              end

              subject_marks << [student.id, subject.id, [percentage.to_f]] unless flag == 1
              e_flag = 0
              exam_marks.each do |e|
                next unless (e[0] == student.id) && (e[1] == exam_group.id)

                e[2] << marks.to_f
                if grading_type.nil? || normal_enabled?
                  e[3] << exam.maximum_marks.to_f
                elsif gpa_enabled? || cwa_enabled?
                  e[3] << subject.credit_hours.to_f
                end
                e_flag = 1
              end
              unless e_flag == 1
                if grading_type.nil? || normal_enabled?
                  exam_marks << [student.id, exam_group.id, [marks.to_f], [exam.maximum_marks.to_f]]
                elsif gpa_enabled? || cwa_enabled?
                  exam_marks << [student.id, exam_group.id, [marks.to_f], [subject.credit_hours.to_f]]
                end
              end
            end
          end
        end
        subject_marks.each do |subject_mark|
          student_id = subject_mark[0]
          subject_id = subject_mark[1]
          marks = subject_mark[2].sum.to_f
          prev_marks = GroupedExamReport.find_by(student_id: student_id, subject_id:
subject_id, batch_id: id, score_type: "s")
          if prev_marks.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: marks, score_type: "s",
                                     subject_id: subject_id)
          else
            prev_marks.update(marks: marks)
          end
        end
        exam_totals = []
        exam_marks.each do |exam_mark|
          student_id = exam_mark[0]
          exam_group = ExamGroup.find(exam_mark[1])
          score = exam_mark[2].sum
          max_marks = exam_mark[3].sum
          tot_score = 0
          percent = 0
          unless max_marks.to_f.zero?
            if grading_type.nil? || normal_enabled?
              tot_score = ((score.to_f / max_marks) * 100)
              percent = ((score.to_f / max_marks) * 100) * (exam_group.weightage.to_f / 100)
            elsif gpa_enabled? || cwa_enabled?
              tot_score = (score.to_f / max_marks)
              percent = (score.to_f / max_marks) * (exam_group.weightage.to_f / 100)
            end
          end
          prev_exam_score = GroupedExamReport.find_by(student_id: student_id, exam_group_id:
exam_group.id, score_type: "e")
          if prev_exam_score.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: tot_score, score_type: "e",
                                     exam_group_id: exam_group.id)
          else
            prev_exam_score.update(marks: tot_score)
          end
          exam_flag = 0
          exam_totals.each do |total|
            if total[0] == student_id
              total[1] << percent.to_f
              exam_flag = 1
            end
          end
          exam_totals << [student_id, [percent.to_f]] unless exam_flag == 1
        end
        exam_totals.each do |exam_total|
          student_id = exam_total[0]
          total = exam_total[1].sum.to_f
          prev_total_score = GroupedExamReport.find_by(student_id: student_id, batch_id: id, score_type: "c")
          if prev_total_score.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: total, score_type: "c")
          else
            prev_total_score.update(marks: total)
          end
        end
      end
    end
  end

  def generate_previous_batch_reports
    grading_type = self.grading_type
    students = []
    batch_students = BatchStudent.find_all_by_batch_id(id)
    batch_students.each do |bs|
      stu = Student.find_by(id: bs.student_id)
      students.push stu unless stu.nil?
    end
    grouped_exams = exam_groups.select { |e| GroupedExam.exists?(batch_id: id, exam_group_id: e.id) }
    unless grouped_exams.empty?
      subjects = self.subjects(conditions: { is_deleted: false })
      unless students.empty?
        st_scores = GroupedExamReport.find_all_by_student_id_and_batch_id(students, id)
        st_scores.map(&:destroy) unless st_scores.empty?
        subject_marks = []
        exam_marks = []
        grouped_exams.each do |exam_group|
          subjects.each do |subject|
            exam = Exam.find_by(exam_group_id: exam_group.id, subject_id: subject.id)
            next if exam.nil?

            students.each do |student|
              is_assigned_elective = 1
              unless subject.elective_group_id.nil?
                assigned = StudentsSubject.find_by(student_id: student.id, subject_id: subject.id)
                is_assigned_elective = 0 if assigned.nil?
              end
              next if is_assigned_elective.zero?

              percentage = 0
              marks = 0
              score = ExamScore.find_by(exam_id: exam.id, student_id: student.id)
              if grading_type.nil? || normal_enabled?
                unless score.nil? || score.marks.nil?
                  percentage = ((score.marks.to_f / exam.maximum_marks) * 100) * (exam_group.weightage.to_f / 100)
                  marks = score.marks.to_f
                end
              elsif gpa_enabled?
                unless score.nil? || score.grading_level_id.nil?
                  percentage = score.grading_level.credit_points.to_f * (exam_group.weightage.to_f / 100)
                  marks = score.grading_level.credit_points.to_f * subject.credit_hours.to_f
                end
              elsif cwa_enabled?
                unless score.nil? || score.marks.nil?
                  percentage = ((score.marks.to_f / exam.maximum_marks) * 100) * (exam_group.weightage.to_f / 100)
                  marks = ((score.marks.to_f / exam.maximum_marks) * 100) * subject.credit_hours.to_f
                end
              end
              flag = 0
              subject_marks.each do |s|
                if (s[0] == student.id) && (s[1] == subject.id)
                  s[2] << percentage.to_f
                  flag = 1
                end
              end

              subject_marks << [student.id, subject.id, [percentage.to_f]] unless flag == 1
              e_flag = 0
              exam_marks.each do |e|
                next unless (e[0] == student.id) && (e[1] == exam_group.id)

                e[2] << marks.to_f
                if grading_type.nil? || normal_enabled?
                  e[3] << exam.maximum_marks.to_f
                elsif gpa_enabled? || cwa_enabled?
                  e[3] << subject.credit_hours.to_f
                end
                e_flag = 1
              end
              unless e_flag == 1
                if grading_type.nil? || normal_enabled?
                  exam_marks << [student.id, exam_group.id, [marks.to_f], [exam.maximum_marks.to_f]]
                elsif gpa_enabled? || cwa_enabled?
                  exam_marks << [student.id, exam_group.id, [marks.to_f], [subject.credit_hours.to_f]]
                end
              end
            end
          end
        end
        subject_marks.each do |subject_mark|
          student_id = subject_mark[0]
          subject_id = subject_mark[1]
          marks = subject_mark[2].sum.to_f
          prev_marks = GroupedExamReport.find_by(student_id: student_id, subject_id:
subject_id, batch_id: id, score_type: "s")
          if prev_marks.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: marks, score_type: "s",
                                     subject_id: subject_id)
          else
            prev_marks.update(marks: marks)
          end
        end
        exam_totals = []
        exam_marks.each do |exam_mark|
          student_id = exam_mark[0]
          exam_group = ExamGroup.find(exam_mark[1])
          score = exam_mark[2].sum
          max_marks = exam_mark[3].sum
          if grading_type.nil? || normal_enabled?
            tot_score = ((score.to_f / max_marks) * 100)
            percent = ((score.to_f / max_marks) * 100) * (exam_group.weightage.to_f / 100)
          elsif gpa_enabled? || cwa_enabled?
            tot_score = (score.to_f / max_marks)
            percent = (score.to_f / max_marks) * (exam_group.weightage.to_f / 100)
          end
          prev_exam_score = GroupedExamReport.find_by(student_id: student_id, exam_group_id:
exam_group.id, score_type: "e")
          if prev_exam_score.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: tot_score, score_type: "e",
                                     exam_group_id: exam_group.id)
          else
            prev_exam_score.update(marks: tot_score)
          end
          exam_flag = 0
          exam_totals.each do |total|
            if total[0] == student_id
              total[1] << percent.to_f
              exam_flag = 1
            end
          end
          exam_totals << [student_id, [percent.to_f]] unless exam_flag == 1
        end
        exam_totals.each do |exam_total|
          student_id = exam_total[0]
          total = exam_total[1].sum.to_f
          prev_total_score = GroupedExamReport.find_by(student_id: student_id, batch_id: id, score_type: "c")
          if prev_total_score.nil?
            GroupedExamReport.create(batch_id: id, student_id: student_id, marks: total, score_type: "c")
          else
            prev_total_score.update(marks: total)
          end
        end
      end
    end
  end

  def subject_hours(starting_date, ending_date, subject_id)
    if subject_id.zero?
      entries = TimetableEntry.includes(:weekday).joins(:timetable)
        .where("((? BETWEEN start_date AND end_date) OR (? BETWEEN start_date AND end_date) OR (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)) AND timetable_entries.batch_id = ?", starting_date, ending_date, starting_date, ending_date, starting_date, ending_date, id).group_by(&:timetable_id)
    else
      subject = Subject.find(subject_id)
      subject = subject.elective_group.subjects.first unless subject.elective_group.nil?
      #          Timetable.all(:conditions=>["('#{starting_date}' BETWEEN start_date AND end_date) OR ('#{ending_date}' BETWEEN start_date AND end_date) OR (start_date BETWEEN '#{starting_date}' AND #{ending_date}) OR (end_date BETWEEN '#{starting_date}' AND '#{ending_date}')"])
      entries = TimetableEntry.includes(:weekday).joins(:timetable)
        .where("((? BETWEEN start_date AND end_date) OR (? BETWEEN start_date AND end_date) OR (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)) AND timetable_entries.subject_id = ? AND timetable_entries.batch_id = ?", starting_date, ending_date, starting_date, ending_date, starting_date, ending_date, subject.id, id).group_by(&:timetable_id)
    end
    timetable_ids = entries.keys
    hsh2 = {}
    holidays = holiday_event_dates
    unless timetable_ids.nil?
      timetables = Timetable.find(timetable_ids)
      hsh = {}
      entries.each do |k, val|
        hsh[k] = val.group_by(&:day_of_week)
      end
      timetables.each do |tt|
        ([starting_date, start_date.to_date,
          tt.start_date].max..[tt.end_date, end_date.to_date, ending_date,
                               Configuration.default_time_zone_present_time.to_date].min).each do |d|
          hsh2[d] = hsh[tt.id][d.wday]
        end
      end
    end
    holidays.each do |h|
      hsh2.delete(h)
    end
    hsh2
  end

  def create_coscholastic_reports
    report_hash = {}
    observation_groups.scoped(include: [{ observations: :assessment_scores },
                                        { cce_grade_set: :cce_grades }]).each do |og|
      og.observations.each do |o|
        report_hash[o.id] = {}
        o.assessment_scores.scoped(conditions: { exam_id: nil,
                                                 batch_id: id }).group_by(&:student_id).each do |k, v|
          report_hash[o.id][k] = (v.sum(&:grade_points) / v.count.to_f).round
        end
        report_hash[o.id].each do |key, val|
          o.cce_reports.build(student_id: key, grade_string: og.cce_grade_set.grade_string_for(val),
                              batch_id: id)
        end
        o.save
      end
    end
  end

  def delete_coscholastic_reports
    CceReport.delete_all({ batch_id: id, exam_id: nil })
  end

  def fa_groups
    FaGroup.all(joins: :subjects, conditions: { subjects: { batch_id: id } }).uniq
  end

  def create_scholastic_reports
    report_hash = {}
    fa_groups.each do |fg|
      fg.fa_criterias.all(include: :assessment_scores).find_each do |f|
        report_hash[f.id] = {}
        f.assessment_scores.scoped(conditions: ["exam_id IS NOT NULL AND batch_id = ?",
                                                id]).group_by(&:exam_id).each do |k1, v1|
          report_hash[f.id][k1] = {}
          v1.group_by(&:student_id).each do |k2, v2|
            report_hash[f.id][k1][k2] = (v2.sum(&:grade_points) / v2.count.to_f)
          end
        end
        report_hash[f.id].each do |k1, v1|
          v1.each do |k2, v2|
            f.cce_reports.build(student_id: k2, grade_string: v2, exam_id: k1, batch_id: id)
          end
        end
        f.save
      end
    end
  end

  def delete_scholastic_reports
    CceReport.delete_all(["batch_id = ? AND exam_id > 0", id])
  end

  def generate_cce_reports
    CceReport.transaction do
      delete_scholastic_reports
      create_scholastic_reports
      delete_coscholastic_reports
      create_coscholastic_reports
    end
  end

  def employees
    if employee_id.nil?
      []
    else
      employee_ids = employee_id.split(",")
      Employee.find(employee_ids)
    end
  end

  def perform
    # this is for cce_report_generation use flags if need job for other works

    case job_type
    when "1"
      generate_batch_reports
    when "2"
      generate_previous_batch_reports
    else
      generate_cce_reports
    end
    prev_record = Configuration.find_by(config_key: "job/Batch/#{job_type}")
    if prev_record.present?
      prev_record.update(config_value: Time.zone.now)
    else
      Configuration.create(config_key: "job/Batch/#{job_type}", config_value: Time.zone.now)
    end
  end

  def delete_student_cce_report_cache
    students.all(select: "id, batch_id").find_each(&:delete_individual_cce_report_cache)
  end

  def check_credit_points
    grading_level_list.select { |g| g.credit_points.nil? }.empty?
  end

  def user_is_authorized?(user)
    employees.collect(&:user_id).include? user.id
  end
end
