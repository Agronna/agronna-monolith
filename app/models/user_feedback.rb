# frozen_string_literal: true

class UserFeedback < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :user, inverse_of: :user_feedbacks
  belongs_to :given_by, class_name: "User", optional: true, inverse_of: :feedbacks_given

  enum :kind, {
    general: 0,
    positive: 1,
    improvement: 2
  }, prefix: true

  validates :feedback_on, :content, presence: true
  validate :user_belongs_to_same_tenant
  validate :given_by_same_tenant

  private

  def user_belongs_to_same_tenant
    return if user.blank? || tenant_id.blank?
    return if user.tenant_id == tenant_id

    errors.add(:user_id, :invalid)
  end

  def given_by_same_tenant
    return if given_by_id.blank?

    g = given_by_id.is_a?(User) ? given_by : User.find_by(id: given_by_id)
    return if g&.tenant_id == tenant_id

    errors.add(:given_by_id, :invalid)
  end
end
