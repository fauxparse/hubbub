namespace :basecamp do
  desc "import data from Basecamp"
  task :import => :environment do
    domain, username, password = ENV['DOMAIN'], ENV['USERNAME'], ENV['PASSWORD']
    raise ArgumentError, "must supply DOMAIN" if domain.blank?
    raise ArgumentError, "must supply USERNAME" if username.blank?
    raise ArgumentError, "must supply PASSWORD" if password.blank?
    
    basecamp = Basecamp.new domain, username, password

    account_name = domain.sub /\..*$/, ''
    account = Account.find_or_initialize_by_subdomain account_name
    if account.new_record?
      account.name = account_name.titleize
      account.save
    end
    
    projects_from_basecamp = returning(Hash.new) { |h| basecamp.projects.each { |p| h[p.id] = p } }
    companies_from_basecamp = Hash[*projects_from_basecamp.values.collect { |p| [ p.company.id, p.company.name ] }.uniq.flatten]
    companies_from_basecamp.each_pair do |id, name|
      puts "Importing #{name}..."
      company = account.companies.find_or_create_by_name name
      company.id = id if company.new_record?
      basecamp.people(id).each do |person|
        user = company.users.find_or_initialize_by_id person.id
        user.password    = user.password_confirmation = "temporary" if user.new_record?
        user.login     ||= person["user-name"].parameterize.gsub('-', '_')
        user.name        = person["first-name"] + " " + person["last-name"]
        user.email     ||= person["email-address"]
        user.phone     ||= person["phone-number-office"] || person["phone-number-home"]
        user.mobile    ||= person["phone-number-mobile"]
        user.extension ||= person["phone-number-office-ext"]
        user.admin       = person["administrator"]
        unless user.save
          puts user.errors.inspect
        end
      end
      
      projects_from_basecamp.values.select { |p| p.company.id == id }.each do |p|
        project = company.projects.find_or_initialize_by_id p.id
        project.name       ||= p["name"]
        project.created_at ||= (p["created-on"] || Time.now).to_datetime
        project.updated_at ||= (p["last-changed-on"] || Time.now).to_datetime
        project.save
        
        basecamp.lists(project.id).each do |todo_list|
          list = project.task_lists.find_or_initialize_by_id todo_list["id"]
          list.name     ||= todo_list["name"]
          list.position ||= todo_list["position"]
          list.complete if list.open? and todo_list["complete"]
          list.save
          
          todo_items = basecamp.get_list(list.id)["todo-items"]
          todo_items = [ todo_items["todo_item"] ] if todo_items.is_a?(Basecamp::Record)
          unless todo_items.blank?
            todo_items.each do |todo_item|
              task = list.tasks.find_or_initialize_by_id todo_item["id"]
              task.name         ||= todo_item["content"]
              task.position     ||= todo_item["position"]
              task.created_at   ||= (todo_item["created-on"] || Date.today).to_datetime
              if task.name =~ /[\(\[]est\.?\s*([0-9\.]+)\s*([hd]).*[\)\]]\s*$/i
                estimated_hours = case $2.downcase
                when "h" then Hour[$1]
                when "d" then Hour[($1.to_f * 8).to_i]
                end
              else
                estimated_hours = nil
              end
              if todo_item["responsible-party-type"] == "Person"
                task.assignments.build :user_id => todo_item["responsible-party-id"], :task => task, :estimated_minutes => (estimated_hours && estimated_hours.minutes) unless task.assignments.collect(&:user_id).collect(&:to_i).include?(todo_item["responsible-party-id"].to_i)
              end
              if todo_item["completed"]
                task.complete if task.open?
                task.completed_on = todo_item["completed-on"]
              end
              unless task.valid?
                puts task.errors.inspect
                exit
              end
              task.save
            end
          end
        end
      end
    end

    d = Date.today - 1.year
    while d < Date.today
      from_date, to_date = d, d + 1.month - 1.day
      puts "Importing time records (#{from_date} to #{to_date})..."
      entries = basecamp.records "time-entry", "/time/report/0/#{from_date.strftime '%Y%m%d'}/#{to_date.strftime '%Y%m%d'}"
      entries.each do |entry|
        Assignment.find_or_create_by_task_id_and_user_id entry["todo-item-id"], entry["person-id"] if entry["todo-item-id"]
        t = TimeSlice.new(
          :user_id    => entry["person-id"],
          :task_id    => entry["todo-item-id"],
          :project    => Project.find(entry["project-id"]),
          :date       => entry["date"],
          :hours      => entry["hours"],
          :summary    => entry["description"]
        )
        unless t.save
          puts t.errors.inspect
          exit
        end
      end
      d += 1.month
    end
  end
end
