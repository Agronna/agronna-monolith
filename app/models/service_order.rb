# frozen_string_literal: true

class ServiceOrder < ApplicationRecord
  audited

  include BelongsToTenant

  # Relacionamentos obrigatórios
  belongs_to :secretary

  # Relacionamentos opcionais
  belongs_to :property, optional: true
  belongs_to :producer, optional: true
  belongs_to :service_provider, optional: true
  belongs_to :requested_by, class_name: "User", optional: true
  belongs_to :assigned_to, class_name: "User", optional: true

  # Equipamentos (many-to-many)
  has_many :service_order_machines, dependent: :destroy
  has_many :machines, through: :service_order_machines

  has_many :payment_receipts, dependent: :restrict_with_error
  has_many :schedules, dependent: :restrict_with_error

  accepts_nested_attributes_for :service_order_machines, allow_destroy: true, reject_if: :all_blank

  # Validações
  validates :code, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :title, presence: true
  validates :deadline, presence: true
  validates :secretary_id, presence: true
  validates :tenant_id, presence: true

  # Enums
  enum :status, {
    pending: 0,
    scheduled: 1,
    in_progress: 2,
    completed: 3,
    cancelled: 4
  }, prefix: true

  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }, prefix: true

  # Normalizações
  normalizes :code, with: ->(code) { code.to_s.strip.upcase }
  normalizes :title, with: ->(title) { title.to_s.strip }

  # Scopes
  scope :overdue, -> { where(status: [ :pending, :scheduled, :in_progress ]).where("deadline < ?", Date.current) }
  scope :due_today, -> { where(deadline: Date.current) }
  scope :due_this_week, -> { where(deadline: Date.current..Date.current.end_of_week) }

  # Callbacks
  before_validation :generate_code, on: :create

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[code title status priority deadline description]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[secretary property producer service_provider assigned_to requested_by machines tenant]
  end

  # Métodos de instância
  def overdue?
    deadline < Date.current && !status_completed? && !status_cancelled?
  end

  # Regra de negócio: é necessário ao menos um comprovante de pagamento aprovado para iniciar a OS
  def payment_receipt_approved?
    payment_receipts.status_approved.exists?
  end

  def start!(at: nil)
    return false unless status_pending? || status_scheduled?
    return false unless payment_receipt_approved?

    ts = at.presence || Time.current
    update(status: :in_progress, started_at: ts)
  end

  def complete!(at: nil)
    return false unless status_in_progress?

    ts = at.presence || Time.current
    update(status: :completed, completed_at: ts)
  end

  def cancel!
    return false if status_completed?

    update(status: :cancelled)
  end

  def status_badge_class
    case status
    when "pending" then "bg-secondary"
    when "scheduled" then "bg-info"
    when "in_progress" then "bg-primary"
    when "completed" then "bg-success"
    when "cancelled" then "bg-danger"
    else "bg-secondary"
    end
  end

  def priority_badge_class
    case priority
    when "low" then "bg-secondary"
    when "normal" then "bg-info"
    when "high" then "bg-warning text-dark"
    when "urgent" then "bg-danger"
    else "bg-secondary"
    end
  end

  private

  def generate_code
    return if code.present?

    year = Date.current.year
    last_order = ServiceOrder.unscoped
                             .where(tenant_id: tenant_id)
                             .where("code LIKE ?", "OS-#{year}-%")
                             .order(code: :desc)
                             .first

    if last_order&.code
      last_number = last_order.code.split("-").last.to_i
      next_number = last_number + 1
    else
      next_number = 1
    end

    self.code = format("OS-%d-%04d", year, next_number)
  end
end
