class Message < ApplicationRecord
    belongs_to :user


def next_created
   user =  User.find_by_id(self.user_id)
    index = user.my_messages.index self
    user.my_messages[index + 1]
end

def prev_created
    user =  User.find_by_id(self.user_id)
     index = user.my_messages.index self
     user.my_messages[index - 1]
     
 end

    def make_read
        self.update(read: true)
    end

    def task
        Task.find_by(name: self.task_id)
    end

    def nomination?
       return true if self.subject == 'Altama Posititon Nomination'
    end

    def rejected?
        
        position_id = self.content.scan(/\d/).join('')
        nomination = PositionNomination.find_by(position_id: position_id, nominee_id: self.user_id)
        return true if nomination.blank?
    end

    def already_accepted?
      return true if  user_position = UserPosition.find_by(position_id: position.id, user_id: user.id)
    end

    def position
        position_id = self.content.scan(/\d/).join('')
        Position.find_by_id(position_id)
    end



    def sender
        if self.sender_id
            User.find_by_id(self.sender_id)
        else
            self.task.name
        end
    end

end