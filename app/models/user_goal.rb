# frozen_string_literal: true

class UserGoal < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :user, inverse_of: :user_goals

  enum :status, {
    pending: 0,
    in_progress: 1,
    achieved: 2,
    cancelled: 3
  }, prefix: true

  validates :title, presence: true
  validate :user_belongs_to_same_tenant

  private

  def user_belongs_to_same_tenant
    return if user.blank? || tenant_id.blank?
    return if user.tenant_id == tenant_id

    errors.add(:user_id, :invalid)
  end
end
