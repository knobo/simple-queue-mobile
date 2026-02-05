# Simple Queue Mobile

Flutter mobilapp for Simple Queue - et køstyringssystem for kunder og selgere.

## Funksjoner

- 🔍 **QR-scanning** - Bli med i køer ved å scanne QR-koder
- 🎫 **Digital billett** - Se din plass i køen og estimert ventetid
- 🔔 **Push-varsler** - Få beskjed når det er din tur
- 📜 **Historikk** - Se tidligere køer
- 💾 **Lokal lagring** - Lagre favoritt-køer og innstillinger

## Kom i gang

### Forutsetninger

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versjon 3.0+)
- Android Studio eller Xcode (for emulator/simulator)
- Git

### Installasjon

1. **Klon repoet:**
   ```bash
   git clone https://github.com/knobo/simple-queue-mobile.git
   cd simple-queue-mobile
   ```

2. **Installer avhengigheter:**
   ```bash
   flutter pub get
   ```

3. **Konfigurer Firebase (valgfritt, for push-varsler):**
   ```bash
   flutterfire configure
   ```

4. **Kjør appen:**
   ```bash
   flutter run
   ```

## Prosjektstruktur

```
lib/
├── main.dart              # Entry point
├── models/                # Data-modeller
│   └── queue_models.dart
├── providers/             # State management (Riverpod)
│   ├── queue_provider.dart
│   ├── ticket_provider.dart
│   └── storage_provider.dart
├── screens/               # UI-skjermer
│   ├── home_screen.dart
│   ├── scan_screen.dart
│   ├── ticket_screen.dart
│   └── history_screen.dart
├── services/              # API-kall, Firebase
│   ├── api_service.dart
│   └── firebase_service.dart
└── widgets/               # Gjenbrukbare widgets
    └── queue_card.dart
```

## Avhengigheter

| Pakke | Bruk |
|-------|------|
| `mobile_scanner` | QR-scanning |
| `flutter_riverpod` | State management |
| `dio` | HTTP-klient |
| `firebase_messaging` | Push-notifikasjoner |
| `shared_preferences` | Lokal lagring |
| `intl` | Datoformatering |

## API

Appen kommuniserer med Simple Queue backend API. Se [API-dokumentasjon](https://github.com/knobo/simple-queue-core) for detaljer.

## Miljøvariabler

Opprett en `.env` fil i rot-mappen:

```
API_BASE_URL=https://api.simplequeue.knobo.no
```

## Bygging

### Android
```bash
flutter build apk --release          # APK
flutter build appbundle --release    # App Bundle (Play Store)
```

### iOS
```bash
flutter build ios --release
```

## Testing

```bash
flutter test
```

## Lisens

MIT License - se [LICENSE](LICENSE) for detaljer.

## Utvikler

Lagd med ❤️ av [knobo](https://github.com/knobo)
