class Task < ApplicationRecord
    belongs_to :task_manager

    def mail(user)
        binding.break
        Message.where(task_name: self.name, user_id: user.id)
    end
end
