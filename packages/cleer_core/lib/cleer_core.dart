library;

export 'src/cleer_core_base.dart';

// --- UTILS & HELPERS ---
export 'utils/validators/validators.dart';
export 'utils/constants.dart';
export 'utils/password_generator.dart';
export 'utils/identity_utils.dart';

// --- ENUMS ---
// (Add all the enums from your enums folder)
export 'enums/api_subscription_status.dart';
export 'enums/app_auth_status.dart';
export 'enums/app_connection_status.dart';
export 'enums/card_network.dart';
export 'enums/country_code.dart';
export 'enums/payment_method_type.dart';
export 'enums/virtual_account_type.dart';

// --- MODELS ---
// (CRITICAL: Export your data entities here so the App UI can read them)
export 'models/agreement/agreement.dart';
export 'models/agreement/agreement_preview.dart';
export 'models/agreement/agreement_enums.dart';
export 'models/auth_identity/auth_identity.dart';
export 'models/bank/bank.dart';
export 'models/charge/charge.dart';
export 'models/milestone/milestone.dart';
export 'models/payout_destination/payout_destination.dart';
export 'models/status_history/status_history.dart';
export 'models/transaction/transaction.dart';
export 'models/user/user.dart';
export 'models/user/user_preview.dart';
// Note: Add any other models from your models/ folder you need in the UI.

// --- FAILURES ---
export 'src/failures/auth_failures.dart';
export 'src/failures/data_failures.dart';
export 'src/failures/storage_failures.dart';

// --- REPOSITORIES (INTERFACES) ---
export 'src/repositories/api/agreement/agreement_repository.dart';
export 'src/repositories/api/flutterwave/flutterwave_repository.dart';
export 'src/repositories/api/milestone/milestone_repository.dart';
export 'src/repositories/api/payout_destination/payout_destination_repository.dart';
export 'src/repositories/api/subscription/subscription_repository.dart';
export 'src/repositories/api/transaction/transaction_repository.dart';
export 'src/repositories/api/user/user_repository.dart';
export 'src/repositories/auth/auth_repository.dart';
export 'src/repositories/media/media_repository.dart';
export 'src/repositories/network/network_repository.dart';
export 'src/repositories/storage/storage_repository.dart';

// --- PARAMS ---

export 'src/params/auth/confirm_reset_password_params.dart';
export 'src/params/auth/confirm_sign_up_params.dart';
export 'src/params/auth/sign_in_params.dart';
export 'src/params/auth/sign_up_params.dart';
export 'src/params/auth/update_password_params.dart';
export 'src/params/payout_destination/get_payout_destination_params.dart';
export 'src/params/flutterwave/create_charge_params.dart';
export 'src/params/flutterwave/create_customer_params.dart';
export 'src/params/flutterwave/create_payment_method_params.dart';
export 'src/params/flutterwave/create_virtual_account_params.dart';
export 'src/params/flutterwave/list_charges_params.dart';
export 'src/params/flutterwave/resolve_account_params.dart';
export 'src/params/storage/process_image_params.dart';
export 'src/params/storage/upload_file_params.dart';
