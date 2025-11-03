class EventoAuditoria
  include Mongoid::Document
  include Mongoid::Timestamps

  field :evento, type: String
  field :timestamp, type: DateTime, default: -> { DateTime.current }
  field :servicio, type: String
  field :entidad_tipo, type: String
  field :entidad_id, type: String
  field :usuario_id, type: String
  field :datos, type: Hash, default: {}

  validates :evento, presence: true
  validates :servicio, presence: true
  validates :entidad_tipo, presence: true
  validates :entidad_id, presence: true

  index({ evento: 1 })
  index({ servicio: 1 })
  index({ entidad_tipo: 1, entidad_id: 1 })
  index({ timestamp: -1 })
end

