require 'rails/generators'

module PasswordlessAuth
  module Generators
    class AddAuthenticationGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      # This generator is used to add authentication
      def add_authentication
        gem "devise"
        generate "devise:install"
        model_name = ask("What would you like the user model to be called? [user]")
        generate "devise", model_name
        rake "db:migrate"
        copy_file 'application_controller.rb', 'app/controllers/cm_admin/application_controller.rb'
        gsub_file 'app/controllers/cm_admin/application_controller.rb', 'authenticate_user', "authenticate_#{model_name}"
        copy_file 'authentication.rb', 'app/controllers/concerns/authentication.rb'
        gsub_file 'app/controllers/concerns/authentication.rb', 'current_user', "current_#{model_name}"
        copy_file 'current.rb', 'app/models/current.rb'
        inject_into_file "app/models/#{model_name.underscore}.rb", before: "end\n" do <<-'RUBY'
        RUBY
        end
      end
    end
  end
end
