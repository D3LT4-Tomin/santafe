# Sistema de Suscripción - Guía Rápida

## Estructura

El sistema de suscripción está compuesto por:

```
lib/
├── models/
│   └── user_model.dart          # Modelo de usuario con plan
├── services/
│   └── subscription_service.dart # Lógica de suscripción
├── providers/
│   └── subscription_provider.dart # Estado de la suscripción
└── screens/
    └── subscription_screen.dart   # Interfaz de usuario
```

## Modelos

### SubscriptionPlan (enum)
```dart
enum SubscriptionPlan { free, premium }
```

### SubscriptionLimits (class)
Contiene los límites para cada plan:
- `maxAccounts`: Máximo de cuentas permitidas
- `maxTransactions`: Máximo de transacciones (-1 = ilimitado)
- `advancedFeatures`: Si tiene acceso a funciones avanzadas

```dart
// Valores actuales:
const SubscriptionLimits free = SubscriptionLimits(
  maxAccounts: 3,
  maxTransactions: 100,
  advancedFeatures: false,
);

const SubscriptionLimits premium = SubscriptionLimits(
  maxAccounts: 10,
  maxTransactions: -1,
  advancedFeatures: true,
);
```

## Uso

### Provider
```dart
final provider = context.read<SubscriptionProvider>();

// Cargar plan actual
await provider.loadPlan();

// Cambiar plan
await provider.updatePlan(SubscriptionPlan.premium);

// Verificar si es premium
provider.isPremium  // true o false

// Ver límites
provider.limits.maxAccounts  // 3 o 10
```

### Servicio
```dart
// Actualizar plan en Firebase
await SubscriptionService.updatePlan(userId, SubscriptionPlan.premium);

// Obtener plan
final plan = await SubscriptionService.getPlan(userId);

// Verificar si puede crear cuenta
final canCreate = await SubscriptionService.canCreateAccount(userId);
```

## Personalización de Límites

Para cambiar los límites, edita `lib/models/user_model.dart`:

```dart
const SubscriptionLimits free = SubscriptionLimits(
  maxAccounts: 5,        // Cambia el límite
  maxTransactions: 200,  // Cambia el límite
  advancedFeatures: false,
);
```

## Acceder a la Pantalla de Planes

Desde Configuración > Planes de suscripción

## Notas

- Los límites están listos para personalizar cuando definas tu modelo de negocio
- La validación de límites se hace en `AccountService`
- Las reglas de Firestore son básicas y se pueden mejorar después
