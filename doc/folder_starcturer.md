lib/
│
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_assets.dart
│   │   └── app_strings.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── helpers.dart
│   │   └── date_formatter.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   └── api_endpoints.dart
│   │
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_widget.dart
│       └── empty_state_widget.dart
│
├── routes/
│   ├── app_routes.dart
│   └── route_names.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── model/
│   │   │   └── user_model.dart
│   │   ├── service/
│   │   │   └── auth_service.dart
│   │   ├── provider/
│   │   │   └── auth_provider.dart
│   │   └── view/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── forgot_password_screen.dart
│   │
│   ├── home/
│   │   ├── provider/
│   │   │   └── home_provider.dart
│   │   └── view/
│   │       └── home_screen.dart
│   │
│   ├── profile/
│   │   ├── model/
│   │   │   └── profile_model.dart
│   │   ├── provider/
│   │   │   └── profile_provider.dart
│   │   └── view/
│   │       ├── profile_screen.dart
│   │       └── edit_profile_screen.dart
│   │
│   └── settings/
│       └── view/
│           └── settings_screen.dart
│
└── services/
    ├── storage_service.dart
    ├── notification_service.dart
    └── firebase_service.dart