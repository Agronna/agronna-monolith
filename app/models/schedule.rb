# frozen_string_literal: true

class Schedule < ApplicationRecord
  audited

  include BelongsToTenant

  belongs_to :secretary
  belongs_to :service_order

  has_many :schedule_machines, dependent: :destroy
  has_many :machines, through: :schedule_machines

  has_many :schedule_assignments, dependent: :destroy
  has_many :assigned_users, through: :schedule_assignments, source: :user

  accepts_nested_attributes_for :schedule_machines, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :schedule_assignments, allow_destroy: true, reject_if: :all_blank

  validates :scheduled_at, presence: true
  validates :secretary_id, presence: true
  validates :service_order_id, presence: true
  validates :tenant_id, presence: true
  validate :service_order_must_have_approved_receipt
  validate :scheduled_end_at_after_scheduled_at

  enum :status, {
    scheduled: 0,
    confirmed: 1,
    in_progress: 2,
    completed: 3,
    cancelled: 4
  }, prefix: true

  scope :for_calendar, ->(start_date, end_date) {
    s = start_date.respond_to?(:beginning_of_day) ? start_date : start_date.to_time.beginning_of_day
    e = end_date.respond_to?(:end_of_day) ? end_date : end_date.to_time.end_of_day
    where(scheduled_at: s..e)
  }

  def self.ransackable_attributes(auth_object = nil)
    %w[scheduled_at status observations]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[secretary service_order machines assigned_users tenant]
  end

  def status_badge_class
    case status
    when "scheduled" then "bg-info"
    when "confirmed" then "bg-primary"
    when "in_progress" then "bg-warning text-dark"
    when "completed" then "bg-success"
    when "cancelled" then "bg-danger"
    else "bg-secondary"
    end
  end

  def title_for_calendar
    service_order.title
  end

  def end_time
    scheduled_end_at.presence || scheduled_at + 1.hour
  end

  def assigned_user_ids
    assigned_users.pluck(:id)
  end

  def assigned_user_ids=(ids)
    ids = Array(ids).reject(&:blank?).map(&:to_i).uniq
    self.assigned_users = User.where(id: ids)
  end

  private

  def service_order_must_have_approved_receipt
    return if service_order_id.blank?

    order = service_order_id.is_a?(ServiceOrder) ? service_order : ServiceOrder.find_by(id: service_order_id)
    return unless order

    unless order.payment_receipt_approved?
      errors.add(:service_order_id, "deve possuir ao menos um comprovante de pagamento aprovado para agendamento")
    end
  end

  def scheduled_end_at_after_scheduled_at
    return if scheduled_end_at.blank? || scheduled_at.blank?
    return if scheduled_end_at > scheduled_at

    errors.add(:scheduled_end_at, "deve ser posterior ao início")
  end
end
