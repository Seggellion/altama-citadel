class Rfa < ApplicationRecord


    def self.all_tickets
        self.all.count
    end

end
