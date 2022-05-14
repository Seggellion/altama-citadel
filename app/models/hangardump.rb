class Hangardump < ActiveRecord::Base
   #mount_uploader :attachment, AttachmentUploader # Tells rails to use this uploader for this model.
   validates :name, :attachment, presence: true # Make sure the owner's name is present.
   has_one_attached :attachment
   #has_many_attached :attachment, :content_type => %w(csv)
end
