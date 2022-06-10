class Usership < ApplicationRecord
    belongs_to :user
    belongs_to :ship
    has_one_attached :attachment
    include ActiveModel::Serializers::JSON

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
