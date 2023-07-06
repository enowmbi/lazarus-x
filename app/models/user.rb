class User < ApplicationRecord
  attr_accessor :password, :role, :old_password, :new_password, :confirm_password

  validates     :username, uniqueness: { scope: [:is_deleted], unless: :is_deleted }
  validates     :username, length: { within: 1..20 }
  validates     :password, length: { within: 4..40, allow_nil: true }
  validates     :username, format: { with: /\A[A-Z0-9_-]*\z/i,
                                     message: I18n.t('must_contain_only_letters').to_s }
  validates     :email, format: { with: /\A[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i, allow_blank: true,
                                  message: I18n.t('must_be_a_valid_email_address').to_s }
  validates   :role, presence: { on: :create }
  validates   :password, presence: { on: :create }

  has_and_belongs_to_many :privileges
  has_many  :user_events
  has_many  :events, through: :user_events
  has_one :student_record, class_name: "Student"
  has_one :employee_record, class_name: "Employee"

  scope :active, -> { where(is_deleted: false) }
  scope :inactive, -> { where(is_deleted: true) }

  def before_save
    self.salt = random_string(8) if salt.nil?
    self.hashed_password = Digest::SHA1.hexdigest(salt + password) unless password.nil?
    if new_record?
      self.admin = false
      self.student = false
      self.employee = false
      self.admin    = true if role == 'Admin'
      self.student  = true if role == 'Student'
      self.employee = true if role == 'Employee'
      self.parent = true if role == 'Parent'
      self.is_first_login = true
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def check_reminders
    reminders = []
    reminders = Reminder.find(:all, conditions: ["recipient = '#{id}'"])
    count = 0
    reminders.each do |r|
      count += 1 unless r.is_read
    end
    count
  end

  def self.authenticate?(_username, password)
    u = User.find_by username:
    u.hashed_password == Digest::SHA1.hexdigest(u.salt + password)
  end

  def random_string(len)
    randstr = ""
    chars = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a
    len.times { randstr << chars[rand(chars.size - 1)] }
    randstr
  end

  def role_name
    return I18n.t('admin').to_s if admin?
    return I18n.t('student_text').to_s if student?
    return I18n.t('employee_text').to_s if employee?
    return I18n.t('parent').to_s if parent?

    nil
  end

  def role_symbols
    prv = []
    @privilge_symbols ||= privileges.map { |privilege| prv << privilege.name.underscore.to_sym }

    if admin?
      [:admin] + prv
    elsif student?
      [:student] + prv
    elsif employee?
      employee = employee_record
      unless employee.nil?
        if employee.subjects.present?
          prv << :subject_attendance if Configuration.get_config_value('StudentAttendanceType') == 'SubjectWise'
          prv << :subject_exam
        end
        prv << :view_results if Batch.active.collect(&:employee_id).include?(employee.id.to_s)
      end
      [:employee] + prv
    elsif parent?
      [:parent] + prv
    else
      prv
    end
  end

  def clear_menu_cache
    Rails.cache.delete("user_main_menu#{id}")
    Rails.cache.delete("user_autocomplete_menu#{id}")
  end

  def parent_record
    Student.find_by(admission_no: username[1..username.length])
  end

  def has_subject_in_batch(b)
    employee_record.subjects.collect(&:batch_id).include? b.id
  end

  def days_events(date)
    all_events = []
    case role_name
    when "Admin"
      all_events = Event.find(:all,
                              conditions: ["? between date(events.start_date) and date(events.end_date)", date])
    when "Student"
      all_events += events.all(conditions: ["? between date(events.start_date) and date(events.end_date)", date])
      all_events += student_record.batch.events.all(conditions: [
                                                      "? between date(events.start_date) and date(events.end_date)", date
                                                    ])
      all_events += Event.all(conditions: [
                                "(? between date(events.start_date) and date(events.end_date)) and is_common = true", date
                              ])
    when "Parent"
      all_events += events.all(conditions: ["? between date(events.start_date) and date(events.end_date)", date])
      all_events += parent_record.user.events.all(conditions: [
                                                    "? between date(events.start_date) and date(events.end_date)", date
                                                  ])
      all_events += parent_record.batch.events.all(conditions: [
                                                     "? between date(events.start_date) and date(events.end_date)", date
                                                   ])
      all_events += Event.all(conditions: [
                                "(? between date(events.start_date) and date(events.end_date)) and is_common = true", date
                              ])
    when "Employee"
      all_events += events.all(conditions: ["? between events.start_date and events.end_date", date])
      all_events += employee_record.employee_department.events.all(conditions: [
                                                                     "? between date(events.start_date) and date(events.end_date)", date
                                                                   ])
      all_events += Event.all(conditions: [
                                "(? between date(events.start_date) and date(events.end_date)) and is_exam = true", date
                              ])
      all_events += Event.all(conditions: [
                                "(? between date(events.start_date) and date(events.end_date)) and is_common = true", date
                              ])
    end
    all_events
  end

  def next_event(date)
    all_events = []
    case role_name
    when "Admin"
      all_events = Event.find(:all, conditions: ["? < date(events.end_date)", date], order: "start_date")
    when "Student"
      all_events += events.all(conditions: ["? < date(events.end_date)", date])
      all_events += student_record.batch.events.all(conditions: ["? < date(events.end_date)", date],
                                                    order: "start_date")
      all_events += Event.all(conditions: ["(? < date(events.end_date)) and is_common = true", date],
                              order: "start_date")
    when "Parent"
      all_events += events.all(conditions: ["? < date(events.end_date)", date])
      all_events += parent_record.user.events.all(conditions: ["? < date(events.end_date)", date])
      all_events += parent_record.batch.events.all(conditions: ["? < date(events.end_date)", date],
                                                   order: "start_date")
      all_events += Event.all(conditions: ["(? < date(events.end_date)) and is_common = true", date],
                              order: "start_date")
    when "Employee"
      all_events += events.all(conditions: ["? < date(events.end_date)", date], order: "start_date")
      all_events += employee_record.employee_department.events.all(conditions: ["? < date(events.end_date)", date],
                                                                   order: "start_date")
      all_events += Event.all(conditions: ["(? < date(events.end_date)) and is_exam = true", date],
                              order: "start_date")
      all_events += Event.all(conditions: ["(? < date(events.end_date)) and is_common = true", date],
                              order: "start_date")
    end
    start_date = all_events.collect(&:start_date).min
    if start_date
      (start_date.to_date <= date ? date + 1.day : start_date)

    else
      ""
    end
  end

  def soft_delete
    update(is_deleted: true)
  end
end
