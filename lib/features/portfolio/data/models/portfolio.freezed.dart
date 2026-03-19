// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portfolio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Portfolio {
  List<Asset> get assets => throw _privateConstructorUsedError;
  double get totalValue => throw _privateConstructorUsedError;
  double get totalPnl => throw _privateConstructorUsedError;
  double get totalPnlPercent => throw _privateConstructorUsedError;

  /// Create a copy of Portfolio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PortfolioCopyWith<Portfolio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortfolioCopyWith<$Res> {
  factory $PortfolioCopyWith(Portfolio value, $Res Function(Portfolio) then) =
      _$PortfolioCopyWithImpl<$Res, Portfolio>;
  @useResult
  $Res call({
    List<Asset> assets,
    double totalValue,
    double totalPnl,
    double totalPnlPercent,
  });
}

/// @nodoc
class _$PortfolioCopyWithImpl<$Res, $Val extends Portfolio>
    implements $PortfolioCopyWith<$Res> {
  _$PortfolioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Portfolio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assets = null,
    Object? totalValue = null,
    Object? totalPnl = null,
    Object? totalPnlPercent = null,
  }) {
    return _then(
      _value.copyWith(
            assets: null == assets
                ? _value.assets
                : assets // ignore: cast_nullable_to_non_nullable
                      as List<Asset>,
            totalValue: null == totalValue
                ? _value.totalValue
                : totalValue // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPnl: null == totalPnl
                ? _value.totalPnl
                : totalPnl // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPnlPercent: null == totalPnlPercent
                ? _value.totalPnlPercent
                : totalPnlPercent // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PortfolioImplCopyWith<$Res>
    implements $PortfolioCopyWith<$Res> {
  factory _$$PortfolioImplCopyWith(
    _$PortfolioImpl value,
    $Res Function(_$PortfolioImpl) then,
  ) = __$$PortfolioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Asset> assets,
    double totalValue,
    double totalPnl,
    double totalPnlPercent,
  });
}

/// @nodoc
class __$$PortfolioImplCopyWithImpl<$Res>
    extends _$PortfolioCopyWithImpl<$Res, _$PortfolioImpl>
    implements _$$PortfolioImplCopyWith<$Res> {
  __$$PortfolioImplCopyWithImpl(
    _$PortfolioImpl _value,
    $Res Function(_$PortfolioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Portfolio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assets = null,
    Object? totalValue = null,
    Object? totalPnl = null,
    Object? totalPnlPercent = null,
  }) {
    return _then(
      _$PortfolioImpl(
        assets: null == assets
            ? _value._assets
            : assets // ignore: cast_nullable_to_non_nullable
                  as List<Asset>,
        totalValue: null == totalValue
            ? _value.totalValue
            : totalValue // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPnl: null == totalPnl
            ? _value.totalPnl
            : totalPnl // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPnlPercent: null == totalPnlPercent
            ? _value.totalPnlPercent
            : totalPnlPercent // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$PortfolioImpl implements _Portfolio {
  const _$PortfolioImpl({
    required final List<Asset> assets,
    required this.totalValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  }) : _assets = assets;

  final List<Asset> _assets;
  @override
  List<Asset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  final double totalValue;
  @override
  final double totalPnl;
  @override
  final double totalPnlPercent;

  @override
  String toString() {
    return 'Portfolio(assets: $assets, totalValue: $totalValue, totalPnl: $totalPnl, totalPnlPercent: $totalPnlPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortfolioImpl &&
            const DeepCollectionEquality().equals(other._assets, _assets) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.totalPnl, totalPnl) ||
                other.totalPnl == totalPnl) &&
            (identical(other.totalPnlPercent, totalPnlPercent) ||
                other.totalPnlPercent == totalPnlPercent));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_assets),
    totalValue,
    totalPnl,
    totalPnlPercent,
  );

  /// Create a copy of Portfolio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PortfolioImplCopyWith<_$PortfolioImpl> get copyWith =>
      __$$PortfolioImplCopyWithImpl<_$PortfolioImpl>(this, _$identity);
}

abstract class _Portfolio implements Portfolio {
  const factory _Portfolio({
    required final List<Asset> assets,
    required final double totalValue,
    required final double totalPnl,
    required final double totalPnlPercent,
  }) = _$PortfolioImpl;

  @override
  List<Asset> get assets;
  @override
  double get totalValue;
  @override
  double get totalPnl;
  @override
  double get totalPnlPercent;

  /// Create a copy of Portfolio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PortfolioImplCopyWith<_$PortfolioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
