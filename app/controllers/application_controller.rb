class ApplicationController < ActionController::Base
  # TODO: before_action :authenticate_user!

  # helper :all
  # TODO: helper_method :can_access_request?
  # protect_from_forgery # :secret => '434571160a81b5595319c859d32060c1'
  # filter_parameter_logging :password

  # TODO: before_action { |c| Authorization.current_user = c.current_user }
  before_action :message_user
  before_action :set_user_language
  before_action :set_variables
  before_action :login_check

  before_action :dev_mode
  include CustomInPlaceEditing

  def login_check
    if session[:user_id].present? && !((controller_name == "user") && %w[first_login_change_password login logout
                                                                         forgot_password].include?(action_name))
      user = User.active.find(session[:user_id])
      setting = ::Configuration.get_config_value('FirstTimeLoginEnable')
      if setting == "1" && user.is_first_login != false
        flash[:notice] = t('first_login_attempt').to_s
        redirect_to controller: "user", action: "first_login_change_password", id: user.username
      end
    end
  end

  def dev_mode
    Rails.env.development?
  end

  def set_variables
    unless @current_user.nil?
      @attendance_type = ::Configuration.get_config_value('StudentAttendanceType') unless @current_user.student?
      @modules = ::Configuration.available_modules
    end
  end

  def set_language
    session[:language] = params[:language]
    @current_user.clear_menu_cache
    render :update, &:reload
  end

  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound do |exception|
      flash[:notice] = "#{t('flash_msg2')} , #{exception} ."
      logger.info "[FedenaRescue] AR-Record_Not_Found #{exception}"
      log_error exception
      redirect_to controller: :user, action: :dashboard
    end

    rescue_from NoMethodError do |exception|
      flash[:notice] = t('flash_msg3').to_s
      logger.info "[FedenaRescue] No method error #{exception}"
      log_error exception
      redirect_to controller: :user, action: :dashboard
    end

    rescue_from ActionController::InvalidAuthenticityToken do |exception|
      flash[:notice] = t('flash_msg43').to_s
      logger.info "[FedenaRescue] Invalid Authenticity Token #{exception}"
      log_error exception
      if request.xhr?
        render(:update) do |page|
          page.redirect_to controller: 'user', action: 'dashboard'
        end
      else
        redirect_to controller: 'user', action: 'dashboard'
      end
    end
  end

  def only_assigned_employee_allowed
    @privilege = @current_user.privileges.map(&:name)
    if @current_user.employee?
      @employee_subjects = @current_user.employee_record.subjects
      if @employee_subjects.empty? && !@privilege.include?("StudentAttendanceView") && !@privilege.include?("StudentAttendanceRegister")
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      else
        @allow_access = true
      end
    end
  end

  def restrict_employees_from_exam
    if @current_user.employee?
      @employee_subjects = @current_user.employee_record.subjects
      if @employee_subjects.empty? && !Batch.active.collect(&:employee_id).include?(@current_user.employee_record.id.to_s) && !@current_user.privileges.map(&:name).include?("ExaminationControl") && !@current_user.privileges.map(&:name).include?("EnterResults") && !@current_user.privileges.map(&:name).include?("ViewResults")
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end

  def block_unauthorised_entry
    if @current_user.employee?
      @employee_subjects = @current_user.employee_record.subjects
      if @employee_subjects.empty? && !@current_user.privileges.map(&:name).include?("ExaminationControl")
        flash[:notice] = t('flash_msg4').to_s
        redirect_to controller: 'user', action: 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end

  def initialize
    @title = FedenaSetting.company_details[:company_name]
  end

  def message_user
    @current_user = current_user
  end

  def current_user
    User.active.find(session[:user_id]) unless session[:user_id].nil?
  end

  def find_finance_managers
    Privilege.find_by(name: 'FinanceControl').users
  end

  def permission_denied
    flash[:notice] = t('flash_msg4').to_s
    redirect_to controller: 'user', action: 'dashboard'
  end

  protected

  def login_required
    unless session[:user_id]
      session[:back_url] = request.url
      redirect_to '/'
    end
  end

  def check_if_loggedin
    redirect_to controller: 'users', action: 'dashboard' if session[:user_id]
  end

  def configuration_settings_for_hr
    hr = Configuration.find_by(config_value: "HR")
    if hr.nil?
      redirect_to controller: 'user', action: 'dashboard'
      flash[:notice] = t('flash_msg4').to_s
    end
  end

  def configuration_settings_for_finance
    finance = Configuration.find_by(config_value: "Finance")
    if finance.nil?
      redirect_to controller: 'user', action: 'dashboard'
      flash[:notice] = t('flash_msg4').to_s
    end
  end

  def only_admin_allowed
    redirect_to controller: 'user', action: 'dashboard' unless current_user.admin?
  end

  def protect_other_student_data
    if current_user.student? || current_user.parent?
      student = current_user.student_record if current_user.student?
      student = current_user.parent_record if current_user.parent?
      render text: student.id and return
      unless (params[:id].to_i == student.id) || (params[:student].to_i == student.id) || (params[:student_id].to_i == student.id)
        flash[:notice] = t('flash_msg5').to_s
        redirect_to controller: "user", action: "dashboard"
      end
    end
  end

  def protect_user_data
    if !current_user.admin? && params[:id].to_s != current_user.username
      flash[:notice] = t('flash_msg5').to_s
      redirect_to controller: "user", action: "dashboard"
    end
  end

  def limit_employee_profile_access
    if !@current_user.employee && params[:id] != @current_user.employee_record.id
      priv = @current_user.privileges.map(&:name)
      unless current_user.admin? || priv.include?("HrBasics") || priv.include?("EmployeeSearch")
        flash[:notice] = t('flash_msg5').to_s
        redirect_to controller: "user", action: "dashboard"
      end
    end
  end

  def protect_other_employee_data
    if current_user.employee?
      employee = current_user.employee_record
      pri = Privilege.find(:all, select: "privilege_id",
                           conditions: "privileges_users.user_id = #{current_user.id}", joins: 'INNER JOIN `privileges_users` ON `privileges`.id = `privileges_users`.privilege_id')
      #    privilege =[]
      #    pri.each do |p|
      #      privilege.push p.privilege_id
      #    end
      #    unless privilege.include?('9') or privilege.include?('14') or privilege.include?('17') or privilege.include?('18') or privilege.include?('19')
      unless (params[:id].to_i == employee.id) || current_user.role_symbols.include?("payslip_powers".to_sym)
        flash[:notice] = t('flash_msg5').to_s
        redirect_to controller: "user", action: "dashboard"
      end
    end
  end

  def protect_leave_history
    if current_user.employee?
      employee = Employee.find(params[:id])
      employee_user = employee.user
      if employee_user.id != current_user.id && !(current_user.role_symbols.include?(:hr_basics) || current_user.role_symbols.include?(:employee_attendance))
        flash[:notice] = t('flash_msg6').to_s
        redirect_to controller: "user", action: "dashboard"
      end
    end
  end

  # reminder filters
  def protect_view_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.recipient == current_user.id
      flash[:notice] = t('flash_msg5').to_s
      redirect_to controller: "reminder", action: "index"
    end
  end

  def protect_sent_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.sender == current_user.id
      flash[:notice] = t('flash_msg5').to_s
      redirect_to controller: "reminder", action: "index"
    end
  end

  # employee_leaves_filters
  def protect_leave_dashboard
    employee = Employee.find(params[:id])
    employee_user = employee.user
    #    unless permitted_to? :employee_attendance_pdf, :employee_attendance
    unless employee_user.id == current_user.id
      flash[:notice] = t('flash_msg6').to_s
      redirect_to controller: "user", action: "dashboard"
      #    end
    end
  end

  def protect_applied_leave
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employee_user = applied_employee.user
    unless applied_employee_user.id == current_user.id
      flash[:notice] = t('flash_msg5').to_s
      redirect_to controller: "user", action: "dashboard"
    end
  end

  def protect_manager_leave_application_view
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employees_manager = Employee.find(applied_employee.reporting_manager_id)
    applied_employees_manager_user = applied_employees_manager.user
    unless applied_employees_manager_user.id == current_user.id
      flash[:notice] = t('flash_msg5').to_s
      redirect_to controller: "user", action: "dashboard"
    end
  end

  # TODO  def render(options = nil, extra_options = {}, &block)
    # if RTL_LANGUAGES.include?(I18n.locale.to_sym) && !options.nil? && (!request.xhr? && (options[:pdf]))
      # options ||= {}
      # options = options.merge(zoom: 0.68)
    # end
    # super(options, extra_options, &block)
  # end

  def default_time_zone_present_time
    server_time = Time.zone.now
    server_time_to_gmt = server_time.getgm
    @local_tzone_time = server_time
    time_zone = Configuration.find_by(config_key: "TimeZone")
    if !time_zone.nil? && !time_zone.config_value.nil?
      zone = TimeZone.find(time_zone.config_value)
      @local_tzone_time = if zone.difference_type == "+"
                            server_time_to_gmt + zone.time_difference
                          else
                            server_time_to_gmt - zone.time_difference
                          end
    end
    @local_tzone_time
  end

  def can_access_request?(action, controller)
    permitted_to?(action, controller)
  end

  private

  def set_user_language
    lan = ::Configuration.find_by(config_key: "Locale")
    I18n.default_locale = :en
    # TODO: Translator.fallback(true)
    I18n.locale = if session[:language].nil?
                    lan.config_value
                  else
                    session[:language]
                  end
    News.new.reload_news_bar
  end
end
