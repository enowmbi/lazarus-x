class AddPrivilegeForStudentView < ActiveRecord::Migration[7.0]
  def self.up
    Privilege.find_or_create_by(name: "StudentView", description: 'student_view')
  end

  def self.down
    privilege = Privilege.find_by(name: "StudentView")
    privilege&.destroy
  end
end
