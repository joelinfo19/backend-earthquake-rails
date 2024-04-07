class Earthquake
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: String
  field :mag, type: Float
  field :place, type: String
  field :time, type: Time
  field :url, type: String
  field :tsunami, type: Mongoid::Boolean
  field :mag_type, type: String
  field :title, type: String
  field :latitude, type: Float
  field :longitude, type: Float

  validates :id, presence: true, uniqueness: true
  validates :mag, presence: true, numericality: { greater_than_or_equal_to: -1.0, less_than_or_equal_to: 10.0 }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90.0, less_than_or_equal_to: 90.0 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180.0, less_than_or_equal_to: 180.0 }
  validates :place, :url, :mag_type, :title, presence: true
  embeds_many :comments
  def as_json(options={})
    super(options.merge({ except: [:_id] }))
  end

end


class Comment
  include Mongoid::Document

  field :body, type: String

  embedded_in :earthquake

  validates :body, presence: true

end