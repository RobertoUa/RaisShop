class User < ActiveRecord::Base

  #default_scope includes(:addresses)

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  attr_accessible :full_name, :email, :password, :password_confirmation,
    :remember_me, :addresses_attributes

  has_many :addresses, dependent: :destroy
  has_many :orders, through: :addresses
  has_many :reviews, dependent: :nullify
  accepts_nested_attributes_for :addresses

  before_validation :check_if_guest

  validates_presence_of :email, unless: :guest?
  validates_presence_of :full_name
  validates :email, uniqueness: true,
    format: { with: Devise.email_regexp }, allow_blank: true, if: :email_changed?
  validates :password, presence: true, confirmation: true,
            length: { within: Devise.password_length }, unless: :guest?

  def can_write_review?(product)
    product.reviews.where(user_id: id).count == 0
  end

private

  def check_if_guest
    if new_record?
      can_be_guest = password.blank? && !addresses.blank?
      write_attribute(:guest, can_be_guest)
    end
    true
  end
end
