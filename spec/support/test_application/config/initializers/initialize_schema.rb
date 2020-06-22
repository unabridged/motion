# frozen_string_literal: true

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Tasks::DatabaseTasks.load_schema_current
end
