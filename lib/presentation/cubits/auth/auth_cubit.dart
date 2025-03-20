import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/usecase.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/is_signed_in.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../domain/usecases/sign_in_user.dart';
import '../../../domain/usecases/sign_out_user.dart';
import '../../../domain/usecases/update_balance.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUser _registerUser;
  final SignInUser _signInUser;
  final SignOutUser _signOutUser;
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final UpdateBalance _updateBalance;

  AuthCubit({
    required RegisterUser registerUser,
    required SignInUser signInUser,
    required SignOutUser signOutUser,
    required GetCurrentUser getCurrentUser,
    required IsSignedIn isSignedIn,
    required UpdateBalance updateBalance,
  })  : _registerUser = registerUser,
        _signInUser = signInUser,
        _signOutUser = signOutUser,
        _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _updateBalance = updateBalance,
        super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    
    bool isSignedIn = await _isSignedIn(NoParams());
    
    if (isSignedIn) {
      final result = await _getCurrentUser(NoParams());
      result.fold(
        (failure) => emit(const Unauthenticated()),
        (user) {
          if (user != null) {
            emit(Authenticated(user));
          } else {
            emit(const Unauthenticated());
          }
        },
      );
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    double initialBalance = 0.0,
  }) async {
    emit(const AuthLoading());
    
    final result = await _registerUser(
      RegisterParams(
        email: email,
        password: password,
        name: name,
        initialBalance: initialBalance,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(RegisterSuccess(user));
        emit(Authenticated(user));
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    
    final result = await _signInUser(
      SignInParams(
        email: email,
        password: password,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(SignInSuccess(user));
        emit(Authenticated(user));
      },
    );
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    
    final result = await _signOutUser(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        emit(const SignOutSuccess());
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> updateBalance({
    required String email,
    required double newBalance,
  }) async {
    emit(const AuthLoading());

    final result = await _updateBalance(
      email: email,
      newBalance: newBalance,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(BalanceUpdateSuccess(user, newBalance));
        emit(Authenticated(user));
      },
    );
  }
}
