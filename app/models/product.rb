class Product < ActiveRecord::Base
  include PgSearch

  attr_accessible :title, :description, :image_url, :price, :category_id, :rating

  has_many :line_items
  has_many :reviews, dependent: :destroy, order: "reviews.created_at ASC"
  belongs_to :category

  validates_presence_of :title, :description, :image_url, :price, :category
  validates :title, uniqueness: true

  before_destroy :ensure_not_referenced_by_any_line_item
  before_save :average_rating


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
      scoped
    end
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

private

  def average_rating
    write_attribute(:rating, (reviews.average(:rating) || 0).round)
    true
  end

  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      true
    else
      errors.add(:base, 'Line Items Present')
      false
    end
  end
end
