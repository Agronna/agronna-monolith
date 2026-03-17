# frozen_string_literal: true

class PaymentReceipt < ApplicationRecord
  audited

  include BelongsToTenant

  # Anexo do comprovante (imagem ou PDF). Variants só para imagens (usar em view com file_image?).
  has_one_attached :file

  belongs_to :secretary
  belongs_to :service_order
  belongs_to :producer, optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  # Validações
  validates :payment_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :secretary_id, presence: true
  validates :service_order_id, presence: true
  validates :tenant_id, presence: true
  validate :file_required_for_manual
  validate :file_content_type_allowed
  validate :file_size_limit

  # Enums
  enum :source, {
    manual: 0,
    bank_import: 1
  }, prefix: true

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }, prefix: true

  # Normalizações
  normalizes :reference, with: ->(r) { r.to_s.strip.presence }
  normalizes :bank_name, with: ->(b) { b.to_s.strip.presence }
  normalizes :bank_code, with: ->(b) { b.to_s.strip.presence }
  normalizes :transaction_code, with: ->(t) { t.to_s.strip.presence }
  normalizes :external_id, with: ->(e) { e.to_s.strip.presence }

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[payment_date amount reference status source bank_name transaction_code]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[secretary service_order producer tenant]
  end

  # Aprovar comprovante
  def approve!(user)
    return false unless status_pending?

    update(status: :approved, approved_by: user, approved_at: Time.current, rejection_reason: nil)
  end

  # Rejeitar comprovante
  def reject!(user, reason = nil)
    return false unless status_pending?

    update(status: :rejected, approved_by: user, approved_at: Time.current, rejection_reason: reason)
  end

  def status_badge_class
    case status
    when "pending" then "bg-warning text-dark"
    when "approved" then "bg-success"
    when "rejected" then "bg-danger"
    else "bg-secondary"
    end
  end

  def source_badge_class
    source_manual? ? "bg-info" : "bg-secondary"
  end

  def file_image?
    return false unless file.attached?

    file.content_type.start_with?("image/")
  end

  private

  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg image/png image/gif image/webp
    application/pdf
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  def file_content_type_allowed
    return unless file.attached?

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      errors.add(:file, "deve ser imagem (JPEG, PNG, GIF, WebP) ou PDF")
    end
  end

  def file_size_limit
    return unless file.attached?

    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "não pode ser maior que #{MAX_FILE_SIZE / 1.megabyte} MB")
    end
  end

  def file_required_for_manual
    return unless source_manual?
    return if file.attached?

    errors.add(:file, "é obrigatório para cadastro manual")
  end
end
