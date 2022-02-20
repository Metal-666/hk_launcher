import 'package:flutter_bloc/flutter_bloc.dart';

import 'events.dart';
import 'states.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(RootState(0)) {
    on<Navigate>(
        (event, emit) => emit(state.copyWith(navIndex: () => event.index)));
  }
}
