class Product < ActiveRecord::Base
  include PgSearch

  has_many :line_items
  has_many :orders, through: :line_items
  has_many :reviews, -> { order(created_at: :asc) }, inverse_of: :product,
            dependent: :destroy
  belongs_to :category

  validates_presence_of :title, :description, :image_url, :price, :category

  before_destroy :ensure_not_referenced_by_any_line_item

  after_save :average_rating

  pg_search_scope :search_by_title, against: :title,
    using: {
            trigram: {prefix: true},
            dmetaphone: {
              any_word: true,
              dictionary: "english",
              tsvector_columnt: 'tsv',
              prefix: true}
           }


  def self.title_search(query)
    if query.present?
      search_by_title(query)
    else
      all
    end
  end

  self.per_page = 10

  def average_rating
    average = (self.reviews.average(:rating) || 0).round
    update_attribute(:rating, average) unless average == self.rating
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

private

  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      true
    else
      errors.add(:base, 'Line Items Present')
      false
    end
  end
end
