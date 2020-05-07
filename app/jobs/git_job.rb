class GitJob < ActiveJob::Base
	queue_as :default

  def perform(*args)
  	Rails.logger.info("GitJob : #{args.first}")
  	options = args.first
  	# 1) checkout to tagger branch
  	`git checkout #{Tagger.git_branch}`

  	Rails.logger.info("GitJob : step-1 : checkout success ===========================================")

  	# 2) pull master changes
  	# `git pull origin master`

  	if changes_available?(options[:file_directory_path]) && !Rails.env.development?
  		Rails.logger.info("GitJob : step-2 : changes found ===========================================")

	  	# 3) Add Source Directory Files
	  	`git add #{options[:file_directory_path]}`

  		Rails.logger.info("GitJob : step-3 : File added ===========================================")


	  	# 4) commit changes
	  	`git commit -m "#{commit_message(options)}"`

  		Rails.logger.info("GitJob : step-3 : changes committed ===========================================")


	  	# 5) push changes
	  	`git push origin #{Tagger.git_branch}`
  		
  		Rails.logger.info("GitJob : step-3 : changes pushed ===========================================")

  	end
  end

  def commit_message(options)
  	if options[:added_words].present?
	    "LOCALIZER VERSION UPGRADE(#{options[:instance_name]}-#{options[:locale]}), INFO: Added Words: #{options[:added_words]}, Removed Words: #{options[:removed_words]}"
  	else
  		"LOCALIZER - UPDATING DELTA POINTS"
  	end
  end

  def changes_available?(file_directory_path)
  	`git status #{file_directory_path}`.exclude?('nothing to commit, working directory clean')
  end
end