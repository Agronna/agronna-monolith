# frozen_string_literal: true

class UserPerformanceRecord < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :user, inverse_of: :user_performance_records

  validates :recorded_on, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validate :user_belongs_to_same_tenant

  before_validation :normalize_rating

  private

  def normalize_rating
    self.rating = nil if rating.blank?
  end

  def user_belongs_to_same_tenant
    return if user.blank? || tenant_id.blank?
    return if user.tenant_id == tenant_id

    errors.add(:user_id, :invalid)
  end
end
