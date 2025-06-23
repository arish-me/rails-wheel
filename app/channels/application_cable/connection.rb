# In connection.rb (or an initializer)
# Make sure you're identifying your user for ActionCable
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if current_user = env["warden"].user # Or your session lookup
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
