class Secretary < ApplicationRecord
  validates :cnpj, presence: true, uniqueness: { case_sensitive: false }
  validates :corporate_name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :prefecture_name, presence: true, uniqueness: { case_sensitive: false }

  enum :status, { inativo: 0, ativo: 1 }, prefix: true
  normalizes :cnpj, with: ->(cnpj) { cnpj.to_s.strip.gsub(/[^0-9]/, "") }
  normalizes :corporate_name, with: ->(corporate_name) { corporate_name.to_s.strip }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :prefecture_name, with: ->(prefecture_name) { prefecture_name.to_s.strip }
end
