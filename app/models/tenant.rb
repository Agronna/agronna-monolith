# frozen_string_literal: true

class Tenant < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :users, dependent: :restrict_with_error
  has_many :secretaries, dependent: :restrict_with_error

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }
  validates :subdomain, format: { with: /\A[a-z0-9][a-z0-9\-]*[a-z0-9]\z/i, message: :invalid_subdomain },
                        length: { minimum: 2, maximum: 63 },
                        exclusion: { in: %w[www admin api mail ftp app] }

  before_validation :normalize_subdomain

  def self.find_by_subdomain(subdomain)
    return nil if subdomain.blank?
    find_by("LOWER(subdomain) = ?", subdomain.to_s.downcase)
  end

  private

  def normalize_subdomain
    self.subdomain = subdomain.to_s.downcase.strip if subdomain.present?
  end
end
