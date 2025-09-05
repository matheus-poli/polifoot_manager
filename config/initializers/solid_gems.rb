# Configure solid gems to use primary database connection
Rails.application.configure do
  # Ensure solid gems use the primary database in production
  if Rails.env.production?
    config.after_initialize do
      # Load solid gems schemas into primary database if tables don't exist
      unless ActiveRecord::Base.connection.table_exists?("solid_cache_entries")
        load Rails.root.join("db", "cache_schema.rb")
      end

      unless ActiveRecord::Base.connection.table_exists?("solid_queue_jobs")
        load Rails.root.join("db", "queue_schema.rb")
      end

      unless ActiveRecord::Base.connection.table_exists?("solid_cable_messages")
        load Rails.root.join("db", "cable_schema.rb")
      end
    end
  end
end
