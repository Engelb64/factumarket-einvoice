class Cliente < ApplicationRecord
  validates :nit, presence: true, uniqueness: true
  validates :nombre, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :activos, -> { where(activo: true) }
  scope :inactivos, -> { where(activo: false) }

  def desactivar!
    update(activo: false)
  end

  def activar!
    update(activo: true)
  end
end

