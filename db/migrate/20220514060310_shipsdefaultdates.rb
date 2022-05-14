class Shipsdefaultdates < ActiveRecord::Migration[7.0]
  def change
    change_column_default :userships, :created_at, from: nil, to: ->{ 'now()' }
    change_column_default :userships, :updated_at, from: nil, to: ->{ 'now()' }
  end
end
