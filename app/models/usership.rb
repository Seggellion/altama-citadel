class Usership < ApplicationRecord
    belongs_to :user
   # belongs_to :ship, foreign_key: 'ship_name', primary_key: 'model'
    belongs_to :ship
    has_one_attached :attachment
    include ActiveModel::Serializers::JSON

before_validation :assign_fid, if: -> { fid.blank? }
  # 2. Propagate FID to related records after the Usership is saved
after_save :propagate_fid, if: :saved_change_to_fid?
after_save :propagate_ship_name, if: :saved_change_to_ship_name?

    after_update_commit {broadcast_replace_to 'usership_details', partial: '/my_hangar/usership_details', locals: { usership_details: self }}
    has_many :usership_components, dependent: :destroy
has_many :event_ships, dependent: :destroy


def assign_fid
    # We generate two random 4-digit strings for id1 and id2
    part_1 = generate_random_string(4)
    part_2 = generate_random_string(4)
    
    self.fid = fid_processor(part_1, part_2)
  end

    def fid_processor(id1, id2)
        
        
        ship = ''
        code = self.ship.code
        fid = code + id1.to_s.upcase + '-' + id2.to_s.upcase
        fid
    end

    def generate_fid(digits)
        SecureRandom.base64.delete('/+=')[0, digits]
    end

    def generate_random_string(digits)
    # Refined your generate_fid method to be more reusable
    SecureRandom.base64.delete('/+=')[0, digits].upcase
  end

def propagate_ship_name

    event_ships.update_all(ship_name: self.ship_name)
  end

    def propagate_fid
    # 1. Update EventShips associated with this usership
    # We use update_all for efficiency (one SQL query)
    event_ships.update_all(ship_fid: self.fid)

    # 2. Update EventUser (assuming EventIser was a typo)
    # We look for EventUsers matching this usership_id
    # Note: Adjust the class name 'EventUser' if it is actually 'EventIser'
    EventUser.where(usership_id: self.id).update_all(ship_fid: self.fid)
  end


    def filter


        filter_type = "|#{params[:filter_type]}"
        filter_option = "|#{params[:filter_option]}"
        @myships = Usership.where(user_id: current_user.id)
        if params[:filter_type] == 'manufacturer'
        @myships_filtered = []
        @myships.each_with_index do | usership, i |
        if usership.ship.manufacturer.name.downcase.include? params[:filter_option]
        @myships_filtered << usership
        end
        end
        # @filtered_ships = @myships.joins(:manufacturers).where(:manufacturers => {:name => "Origin Jumpworks (ORIG)"})
        #@myships.joins(:ship).where('manufacturers.name = ?', "Origin Jumpworks (ORIG)")
        end

    end

end
