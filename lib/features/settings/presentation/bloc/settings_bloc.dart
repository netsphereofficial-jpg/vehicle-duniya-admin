import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing app settings state and operations with real-time updates
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const _tag = 'SettingsBloc';
  final SettingsRepository _repository;
  StreamSubscription? _settingsSubscription;

  SettingsBloc({
    required SettingsRepository repository,
  })  : _repository = repository,
        super(const SettingsState.initial()) {
    on<LoadSettingsRequested>(_onLoadSettings);
    on<SettingsUpdated>(_onSettingsUpdated);
    on<UpdateGeneralSettingsRequested>(_onUpdateGeneralSettings);
    on<UpdateAboutUsRequested>(_onUpdateAboutUs);
    on<UpdateBiddingTermsRequested>(_onUpdateBiddingTerms);
    on<UpdatePaymentSettingsRequested>(_onUpdatePaymentSettings);
    on<UploadPaymentQrCodeRequested>(_onUploadPaymentQrCode);
    on<UpdateAppVersionRequested>(_onUpdateAppVersion);
    on<UpdateSocialLinksRequested>(_onUpdateSocialLinks);
    on<ClearSettingsError>(_onClearError);
    on<ClearSettingsSuccess>(_onClearSuccess);
  }

  Future<void> _onLoadSettings(
    LoadSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'LoadSettingsRequested');
    emit(state.copyWith(status: SettingsStateStatus.loading));

    try {
      // Cancel existing subscription if any
      await _settingsSubscription?.cancel();

      // Subscribe to real-time updates
      _settingsSubscription = _repository.watchSettings().listen(
        (settings) {
          AppLogger.info(_tag, 'Real-time settings update received');
          add(SettingsUpdated(settings));
        },
        onError: (error) {
          AppLogger.error(_tag, 'Stream error', error);
          add(const ClearSettingsError());
        },
      );
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load settings', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to load settings: ${e.toString()}',
      ));
    }
  }

  void _onSettingsUpdated(
    SettingsUpdated event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      status: SettingsStateStatus.loaded,
      settings: event.settings,
    ));
  }

  Future<void> _onUpdateGeneralSettings(
    UpdateGeneralSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateGeneralSettingsRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updateGeneralSettings(
        officeAddress: event.officeAddress,
        phone: event.phone,
        email: event.email,
        fax: event.fax,
      );

      AppLogger.info(_tag, 'General settings updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'Contact information updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update general settings', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update settings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateAboutUs(
    UpdateAboutUsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateAboutUsRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updateAboutUs(event.aboutUs);

      AppLogger.info(_tag, 'About Us updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'About Us updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update About Us', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update About Us: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateBiddingTerms(
    UpdateBiddingTermsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateBiddingTermsRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updateBiddingTerms(event.biddingTerms);

      AppLogger.info(_tag, 'Bidding terms updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'Bidding terms updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update bidding terms', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update bidding terms: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdatePaymentSettings(
    UpdatePaymentSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdatePaymentSettingsRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updatePaymentSettings(
        paymentPageEnabled: event.paymentPageEnabled,
        paymentQrCodeUrl: event.paymentQrCodeUrl,
      );

      AppLogger.info(_tag, 'Payment settings updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'Payment settings updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update payment settings', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update payment settings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadPaymentQrCode(
    UploadPaymentQrCodeRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UploadPaymentQrCodeRequested');
    emit(state.copyWith(status: SettingsStateStatus.uploading));

    try {
      // Delete old QR code if exists
      if (state.settings.paymentQrCodeUrl.isNotEmpty) {
        await _repository.deletePaymentQrCode(state.settings.paymentQrCodeUrl);
      }

      // Upload new QR code
      final url = await _repository.uploadPaymentQrCode(
        event.imageBytes,
        event.fileName,
      );

      // Update payment settings with new URL
      await _repository.updatePaymentSettings(
        paymentPageEnabled: event.paymentPageEnabled,
        paymentQrCodeUrl: url,
      );

      AppLogger.info(_tag, 'Payment QR code uploaded successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.uploaded,
        successMessage: 'Payment QR code uploaded successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to upload payment QR code', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to upload QR code: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateAppVersion(
    UpdateAppVersionRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateAppVersionRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updateAppVersion(
        appVersion: event.appVersion,
        minAppVersion: event.minAppVersion,
        forceUpdate: event.forceUpdate,
      );

      AppLogger.info(_tag, 'App version updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'App version settings updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update app version', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update app version: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateSocialLinks(
    UpdateSocialLinksRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateSocialLinksRequested');
    emit(state.copyWith(status: SettingsStateStatus.saving));

    try {
      await _repository.updateSocialLinks(event.socialLinks);

      AppLogger.info(_tag, 'Social links updated successfully');
      emit(state.copyWith(
        status: SettingsStateStatus.saved,
        successMessage: 'Social links updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update social links', e);
      emit(state.copyWith(
        status: SettingsStateStatus.error,
        errorMessage: 'Failed to update social links: ${e.toString()}',
      ));
    }
  }

  void _onClearError(
    ClearSettingsError event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      status: SettingsStateStatus.loaded,
      clearError: true,
    ));
  }

  void _onClearSuccess(
    ClearSettingsSuccess event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      clearSuccess: true,
    ));
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
