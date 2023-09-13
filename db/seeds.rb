Rails.logger.debug "Beginning seeding process ..."
[
  { "config_key" => "InstitutionName", "config_value" => "" },
  { "config_key" => "InstitutionAddress", "config_value" => "" },
  { "config_key" => "InstitutionPhoneNo", "config_value" => "" },
  { "config_key" => "StudentAttendanceType", "config_value" => "Daily" },
  { "config_key" => "CurrencyType", "config_value" => "$" },
  { "config_key" => "Locale", "config_value" => "en" },
  { "config_key" => "AdmissionNumberAutoIncrement", "config_value" => "1" },
  { "config_key" => "EmployeeNumberAutoIncrement", "config_value" => "1" },
  { "config_key" => "TotalSmsCount", "config_value" => "0" },
  { "config_key" => "NetworkState", "config_value" => "Online" },
  { "config_key" => "FinancialYearStartDate", "config_value" => Date.current },
  { "config_key" => "FinancialYearEndDate", "config_value" => Date.current + 1.year },
  { "config_key" => "AutomaticLeaveReset", "config_value" => "0" },
  { "config_key" => "LeaveResetPeriod", "config_value" => "4" },
  { "config_key" => "LastAutoLeaveReset", "config_value" => nil },
  { "config_key" => "GPA", "config_value" => "0" },
  { "config_key" => "CWA", "config_value" => "0" },
  { "config_key" => "CCE", "config_value" => "0" },
  { "config_key" => "DefaultCountry", "config_value" => "76" },
  { "config_key" => "FirstTimeLoginEnable", "config_value" => "0" }
].each do |param|
  Configuration.find_or_create_by(config_key: param["config_key"], config_value: param["config_value"])
end

[
  { "config_key" => "AvailableModules", "config_value" => "HR" },
  { "config_key" => "AvailableModules", "config_value" => "Finance" }
].each do |param|
  Configuration.find_or_create_by(config_key: param["config_key"], config_value: param["config_value"])
end

# TODO: create a course

# TODO: create a batch

if GradingLevel.count.zero?
  [
    { "name" => "A", "min_score" => 90 },
    { "name" => "B", "min_score" => 80 },
    { "name" => "C", "min_score" => 70 },
    { "name" => "D", "min_score" => 60 },
    { "name" => "E", "min_score" => 50 },
    { "name" => "F", "min_score" => 0 }
  ].each do |param|
    GradingLevel.create(param)
  end
end

if User.where(admin: true).first.blank?

  employee_category = Hr::EmployeeCategory.find_or_create_by(prefix: 'Admin', name: 'System Admin', status: true)

  employee_position = Hr::EmployeePosition.find_or_create_by(name: 'System Admin',
                                                             employee_category_id: employee_category.id, status: true)

  employee_department = Hr::EmployeeDepartment.find_or_create_by(code: 'Admin', name: 'System Admin', status: true)

  employee_grade = Hr::EmployeeGrade.find_or_create_by(name: 'System Admin', priority: 0, status: true,
                                                       max_hours_day: nil, max_hours_week: nil)

  employee = Hr::Employee.find_or_create_by(employee_number: 'admin',
                                            joining_date: Date.current,
                                            first_name: 'Admin',
                                            last_name: 'User',
                                            employee_department_id: employee_department.id,
                                            employee_grade_id: employee_grade.id,
                                            employee_position_id: employee_position.id,
                                            employee_category_id: employee_category.id,
                                            status: true, nationality_id: '76',
                                            date_of_birth: Date.current - 365,
                                            email: 'noreply@fedena.com')

  employee.user.update(admin: true, employee: false)

end

[
  { "name" => 'Salary', "description" => ' ', "is_income" => false },
  { "name" => 'Donation', "description" => ' ', "is_income" => true },
  { "name" => 'Fee', "description" => ' ', "is_income" => true }
].each do |param|
  Finance::FinanceTransactionCategory.find_or_create_by(name: param["name"],
                                                        description: param["description"],
                                                        is_income: param["is_income"])
end

if Weekday.count.zero?
  [
    { "batch_id" => nil, "weekday" => "1", "day_of_week" => "1", "is_deleted" => false },
    { "batch_id" => nil, "weekday" => "2", "day_of_week" => "2", "is_deleted" => false },
    { "batch_id" => nil, "weekday" => "3", "day_of_week" => "3", "is_deleted" => false },
    { "batch_id" => nil, "weekday" => "4", "day_of_week" => "4", "is_deleted" => false },
    { "batch_id" => nil, "weekday" => "5", "day_of_week" => "5", "is_deleted" => false }
  ].each do |param|
    Weekday.create(param)
  end
end

[
  { "settings_key" => "ApplicationEnabled", "is_enabled" => false },
  { "settings_key" => "ParentSmsEnabled", "is_enabled" => false },
  { "settings_key" => "EmployeeSmsEnabled", "is_enabled" => false },
  { "settings_key" => "StudentSmsEnabled", "is_enabled" => false },
  { "settings_key" => "ResultPublishEnabled", "is_enabled" => false },
  { "settings_key" => "StudentAdmissionEnabled", "is_enabled" => false },
  { "settings_key" => "ExamScheduleResultEnabled", "is_enabled" => false },
  { "settings_key" => "AttendanceEnabled", "is_enabled" => false },
  { "settings_key" => "NewsEventsEnabled", "is_enabled" => false }
].each do |param|
  SmsSetting.find_or_create_by(settings_key: param["settings_key"])
end

Event.all.each do |e|
  e.destroy if e.origin_type == "AdditionalExam"
end

# insert record in privilege_tags table
[
  { "name_tag" => "system_settings", "priority" => 5 },
  { "name_tag" => "administration_operations", "priority" => 1 },
  { "name_tag" => "academics", "priority" => 3 },
  { "name_tag" => "student_management", "priority" => 2 },
  { "name_tag" => "social_other_activity", "priority" => 4 }
].each do |param|
  PrivilegeTag.find_or_create_by(name_tag: param["name_tag"], priority: param["priority"])
end

# add priorities to student additional fields with nil priority, if any
addl_fields = StudentAdditionalField.all
unless addl_fields.empty?
  priority = 1
  last_priority = addl_fields.collect(&:priority).compact.max
  priority = last_priority + 1 unless last_priority.nil?
  nil_priority_fields = addl_fields.select { |f| f.priority.nil? }
  nil_priority_fields.each do |p|
    p.update(priority:)
    priority += 1
  end
end

# add priorities to employee additional fields with nil priority, if any
addl_fields = AdditionalField.all
unless addl_fields.empty?
  priority = 1
  last_priority = addl_fields.collect(&:priority).compact.max
  priority = last_priority + 1 unless last_priority.nil?
  nil_priority_fields = addl_fields.select { |f| f.priority.nil? }
  nil_priority_fields.each do |p|
    p.update(priority:)
    priority += 1
  end
end

# add privilege_tag_id, priority in privileges table
# system_settings
Privilege.reset_column_information
system_settings_tag = PrivilegeTag.find_by(name_tag: 'system_settings')

Privilege.create name: 'GeneralSettings', description: 'general_settings_privilege',
                 privilege_tag_id: system_settings_tag.id, priority: 10
Privilege.create name: 'AddNewBatch', description: 'add_new_batch_privilege',
                 privilege_tag_id: system_settings_tag.id, priority: 20
Privilege.create name: 'SubjectMaster', description: 'subject_master_privilege',
                 privilege_tag_id: system_settings_tag.id, priority: 30
Privilege.create name: 'SMSManagement', description: 'sms_management_privilege',
                 privilege_tag_id: system_settings_tag.id, priority: 40

# administration_operations
administration_operations_tag = PrivilegeTag.find_by(name_tag: 'administration_operations')

Privilege.create name: 'HrBasics', description: 'hr_basics_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 50
Privilege.create name: 'EmployeeSearch', description: 'employee_search_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 60
Privilege.create name: 'EmployeeAttendance', description: 'employee_attendance_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 70
Privilege.create name: 'PayslipPowers', description: 'payslip_powers_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 80
Privilege.create name: 'FinanceControl', description: 'finance_control_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 90
Privilege.create name: 'EventManagement', description: 'event_management_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 100
Privilege.create name: 'ManageNews', description: 'manage_news_privilege',
                 privilege_tag_id: administration_operations_tag.id, priority: 110

# academics
academics_tag = PrivilegeTag.find_by(name_tag: 'academics')
Privilege.create name: 'ExaminationControl', description: 'examination_control_privilege',
                 privilege_tag_id: academics_tag.id, priority: 230
Privilege.create name: 'EnterResults', description: 'enter_results_privilege',
                 privilege_tag_id: academics_tag.id, priority: 240
Privilege.create name: 'ViewResults', description: 'view_results_privilege',
                 privilege_tag_id: academics_tag.id, priority: 250
Privilege.create name: 'ManageTimetable', description: 'manage_timetable_privilege',
                 privilege_tag_id: academics_tag.id, priority: 260
Privilege.create name: 'TimetableView', description: 'timetable_view_privilege',
                 privilege_tag_id: academics_tag.id, priority: 270

# student_management
student_management_tag = PrivilegeTag.find_by(name_tag: 'student_management')
Privilege.create name: 'Admission', description: 'admission_privilege',
                 privilege_tag_id: student_management_tag.id, priority: 280
Privilege.create name: 'StudentsControl', description: 'students_control_privilege',
                 privilege_tag_id: student_management_tag.id, priority: 290
Privilege.create name: 'StudentView', description: 'student_view_privilege',
                 privilege_tag_id: student_management_tag.id, priority: 300
Privilege.create name: 'StudentAttendanceRegister', description: 'student_attendance_register_privilege',
                 privilege_tag_id: student_management_tag.id, priority: 310
Privilege.create name: 'StudentAttendanceView', description: 'student_attendance_view_privilege',
                 privilege_tag_id: student_management_tag.id, priority: 320

Privilege.all.each do |p|
  p.update(description: "#{p.name.underscore}_privilege")
end

# update gender as string
Hr::Employee.all.each do |e|
  case e.gender.to_s
  when "1"
    e.update(gender: "m")
  when "0"
    e.update(gender: "f")
  end
end

ArchivedEmployee.all.each do |e|
  case e.gender.to_s
  when "1"
    e.update(gender: "m")
  when "0"
    e.update(gender: "f")
  end
end

# add country
["Afghanistan",
 "Albania",
 "Algeria",
 "Andorra",
 "Angola",
 "Antigua & Deps",
 "Argentina",
 "Armenia",
 "Australia",
 "Austria",
 "Azerbaijan",
 "Bahamas",
 "Bahrain",
 "Bangladesh",
 "Barbados",
 "Belarus",
 "Belgium",
 "Belize",
 "Benin",
 "Bhutan",
 "Bolivia",
 "Bosnia Herzegovina",
 "Botswana",
 "Brazil",
 "Brunei",
 "Bulgaria",
 "Burkina",
 "Burundi",
 "Cambodia",
 "Cameroon",
 "Canada",
 "Cape Verde",
 "Central African Rep",
 "Chad",
 "Chile",
 "China",
 "Colombia",
 "Comoros",
 "Congo",
 "Congo {Democratic Rep}",
 "Costa Rica",
 "Croatia",
 "Cuba",
 "Cyprus",
 "Czech Republic",
 "Denmark",
 "Djibouti",
 "Dominica",
 "Dominican Republic",
 "East Timor",
 "Ecuador",
 "Egypt",
 "El Salvador",
 "Equatorial Guinea",
 "Eritrea",
 "Estonia",
 "Ethiopia",
 "Fiji",
 "Finland",
 "France",
 "Gabon",
 "Gambia",
 "Georgia",
 "Germany",
 "Ghana",
 "Greece",
 "Grenada",
 "Guatemala",
 "Guinea",
 "Guinea-Bissau",
 "Guyana",
 "Haiti",
 "Honduras",
 "Hungary",
 "Iceland",
 "India",
 "Indonesia",
 "Iran",
 "Iraq",
 "Ireland {Republic}",
 "Israel",
 "Italy",
 "Ivory Coast",
 "Jamaica",
 "Japan",
 "Jordan",
 "Kazakhstan",
 "Kenya",
 "Kiribati",
 "Korea North",
 "Korea South",
 "Kosovo",
 "Kuwait",
 "Kyrgyzstan",
 "Laos",
 "Latvia",
 "Lebanon",
 "Lesotho",
 "Liberia",
 "Libya",
 "Liechtenstein",
 "Lithuania",
 "Luxembourg",
 "Macedonia",
 "Madagascar",
 "Malawi",
 "Malaysia",
 "Maldives",
 "Mali",
 "Malta",
 "Montenegro",
 "Marshall Islands",
 "Mauritania",
 "Mauritius",
 "Mexico",
 "Micronesia",
 "Moldova",
 "Monaco",
 "Mongolia",
 "Morocco",
 "Mozambique",
 "Myanmar, {Burma}",
 "Namibia",
 "Nauru",
 "Nepal",
 "Netherlands",
 "New Zealand",
 "Nicaragua",
 "Niger",
 "Nigeria",
 "Norway",
 "Oman",
 "Pakistan",
 "Palau",
 "Panama",
 "Papua New Guinea",
 "Paraguay",
 "Peru",
 "Philippines",
 "Poland",
 "Portugal",
 "Qatar",
 "Romania",
 "Russian Federation",
 "Rwanda",
 "St Kitts & Nevis",
 "St Lucia",
 "Saint Vincent & the Grenadines",
 "Samoa",
 "San Marino",
 "Sao Tome & Principe",
 "Saudi Arabia",
 "Senegal",
 "Serbia",
 "Seychelles",
 "Sierra Leone",
 "Singapore",
 "Slovakia",
 "Slovenia",
 "Solomon Islands",
 "Somalia",
 "South Africa",
 "Spain",
 "Sri Lanka",
 "Sudan",
 "Suriname",
 "Swaziland",
 "Sweden",
 "Switzerland",
 "Syria",
 "Taiwan",
 "Tajikistan",
 "Tanzania",
 "Thailand",
 "Togo",
 "Tonga",
 "Trinidad & Tobago",
 "Tunisia",
 "Turkey",
 "Turkmenistan",
 "Tuvalu",
 "Uganda",
 "Ukraine",
 "United Arab Emirates",
 "United Kingdom",
 "United States",
 "Uruguay",
 "Uzbekistan",
 "Vanuatu",
 "Vatican City",
 "Venezuea",
 "Vietnam",
 "Yemen",
 "Zambia",
 "Zimbabwe",
 "Palestine"].each do |param|
  Country.find_or_create_by(name: param)
end
Rails.logger.debug "Finished seeding data successfully"
