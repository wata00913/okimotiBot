# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :observed_members, dependent: :destroy
  has_many :channel_members, through: :observed_members

  validates :name, presence: true, length: { maximum: 15 }
  validates :email, length: { maximum: 254 }
end
