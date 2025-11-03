class Cliente < ApplicationRecord
  validates :nit, presence: true, uniqueness: true, length: { minimum: 8, maximum: 20 }
  validates :nombre, presence: true, length: { minimum: 3, maximum: 200 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, length: { maximum: 255 }
  validates :telefono, length: { maximum: 20 }, allow_blank: true
  validates :direccion, length: { maximum: 500 }, allow_blank: true
  validate :nit_formato_valido

  scope :activos, -> { where(activo: true) }
  scope :inactivos, -> { where(activo: false) }

  def desactivar!
    update(activo: false)
  end

  def activar!
    update(activo: true)
  end

  def activo?
    activo == true
  end

  private

  def nit_formato_valido
    return unless nit.present?

    # Validar formato básico: solo números y guiones
    unless nit.match?(/\A[\d\-]+\z/)
      errors.add(:nit, "debe contener solo números y guiones")
    end
  end
end

