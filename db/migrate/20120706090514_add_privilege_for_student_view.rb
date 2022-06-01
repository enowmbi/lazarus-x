class AddPrivilegeForStudentView < ActiveRecord::Migration[7.0]
  def self.up
    Privilege.find_or_create_by_name :name => "StudentView",:description => 'student_view'
  end

  def self.down
    privilege = Privilege.find_by_name("StudentView")
    privilege.destroy unless privilege.nil?
  end
end
