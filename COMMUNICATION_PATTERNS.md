# Comunicación y Consistencia entre Microservicios

## 📋 Índice

- [Estrategia de Comunicación](#estrategia-de-comunicación)
- [Garantía de Consistencia](#garantía-de-consistencia)
- [Resumen](#resumen)

---

## 🎯 Estrategia de Comunicación

**Decisión:** Comunicación síncrona HTTP REST (MVP)

**¿Por qué REST síncrono?**
- ✅ Simplicidad: No requiere message broker
- ✅ Desarrollo rápido: MVP sin sobre-ingeniería
- ✅ Validaciones críticas: Necesitan respuesta inmediata
- ✅ Debugging fácil: Request/response directos
- ⏳ Asíncrono: Reservado para futuras mejoras cuando el volumen lo requiera

---

## 🔄 Comunicación Síncrona (REST)

### Flujos

#### 1. Invoice Service → Client Service (Crítico)

**Tipo:** Síncrono bloqueante  
**Propósito:** Validar cliente antes de crear factura

- ✅ Bloquea hasta validar
- ✅ Si falla, rechaza la operación
- ⚠️ Timeout: 5 segundos

#### 2. Invoice Service → Audit Service (No Crítico)

**Tipo:** Síncrono no bloqueante  
**Propósito:** Registrar eventos de auditoría

- ✅ No bloquea si falla
- ✅ Errores se loggean pero no interrumpen
- ⚠️ Timeout: 3 segundos

---

## ⏳ Comunicación Asíncrona (Futuro)

**Cuando implementar:**
- Alto volumen de transacciones
- Mayor resiliencia requerida
- Operaciones de larga duración

**Opciones:** RabbitMQ (recomendado) o Kafka (alto volumen)

---

## 🔒 Garantía de Consistencia

**Estrategia:** Consistencia fuerte para validaciones críticas, consistencia eventual para auditoría.

### 1. Consistencia Fuerte (Validaciones Críticas)

**Ejemplo:** Invoice Service → Client Service

- ✅ Validación síncrona bloqueante
- ✅ Si cliente inválido, operación se rechaza
- ✅ No se puede crear factura con datos inconsistentes

### 2. Consistencia Eventual (Auditoría)

**Ejemplo:** Invoice Service → Audit Service

- ⏳ Eventos se registran eventualmente
- ✅ Si falla, no afecta operación principal
- ✅ Se loggea error pero factura se crea exitosamente

### Mecanismos

1. **Transacciones ACID locales:** Cada microservicio garantiza consistencia interna
2. **Validaciones síncronas:** Antes de crear, valida con otros servicios
3. **Idempotencia:** Operaciones repetidas no crean duplicados
4. **Retry en auditoría:** Para recuperar eventos perdidos (futuro)

---

## 📊 Resumen

### Comunicación

**Actual:** REST síncrono para todo
- Validación cliente: Bloqueante (crítico)
- Auditoría: No bloqueante (opcional)

**Futuro:** Híbrida
- Validaciones críticas: Síncronas
- Auditoría y eventos: Asíncronos (RabbitMQ/Kafka)

### Consistencia

**Validaciones críticas:** Consistencia fuerte (síncrona, bloqueante)
- Garantiza que no se crean facturas con clientes inválidos

**Auditoría:** Consistencia eventual (síncrona pero no bloqueante)
- Eventos se registran eventualmente, no afectan operación principal

**Mecanismos:**
- Transacciones ACID locales por servicio
- Validaciones síncronas pre-transaccionales
- Idempotencia en operaciones críticas

---

---

**Versión**: 1.0  
**Última actualización**: 2025  
**Estado**: Implementación MVP (REST Síncrono)

