class Usership < ApplicationRecord
    belongs_to :user
   # belongs_to :ship, foreign_key: 'ship_name', primary_key: 'model'
    belongs_to :ship
    has_one_attached :attachment
    include ActiveModel::Serializers::JSON
    after_update_commit {broadcast_replace_to 'usership_details', partial: '/my_hangar/usership_details', locals: { usership_details: self }}
    has_many :usership_components, dependent: :destroy

    def fid_processor(id1, id2)
        
        
        ship = ''
        code = self.ship.code
        fid = code + id1.to_s.upcase + '-' + id2.to_s.upcase
        fid
    end

    def generate_fid(digits)
        SecureRandom.base64.delete('/+=')[0, digits]
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
