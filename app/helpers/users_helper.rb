module UsersHelper
    def user_status_image(user)
        formatted_status = (user.online_status || "offline").split.map(&:capitalize).join(' ')
        image_tag(user.status_image_path, alt: formatted_status) + "  " + formatted_status
      end

      def user_image(user)
        formatted_status = (user.online_status || "offline").split.map(&:capitalize).join(' ')
        image_tag(user.status_image_path, alt: formatted_status) + " " + user.username
      end
  end