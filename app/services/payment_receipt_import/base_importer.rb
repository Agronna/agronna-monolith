# frozen_string_literal: true

module PaymentReceiptImport
  # Base para importadores de comprovantes a partir de arquivos bancários (OFX, CSV, etc.).
  # Implementações futuras: OfxImporter, CsvBancoDoBrasilImporter, etc.
  #
  # Uso esperado:
  #   result = PaymentReceiptImport::OfxImporter.new(file: uploaded_file, tenant: tenant, service_order: os).call
  #   result.success? => true/false
  #   result.payment_receipts => [...]
  #   result.errors => [...]
  #
  class BaseImporter
    attr_reader :file, :tenant, :service_order, :secretary, :errors, :payment_receipts

    def initialize(file:, tenant:, service_order:, secretary: nil)
      @file = file
      @tenant = tenant
      @service_order = service_order
      @secretary = secretary || service_order.secretary
      @errors = []
      @payment_receipts = []
    end

    def call
      raise NotImplementedError, "Subclasses must implement #call"
    end

    def success?
      errors.empty?
    end

    protected

    def build_receipt(attrs)
      PaymentReceipt.new(
        tenant: tenant,
        service_order: service_order,
        secretary: secretary,
        source: :bank_import,
        status: :pending,
        **attrs
      )
    end
  end
end
