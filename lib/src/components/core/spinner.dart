part of w_attachments_client.components;

/// A web-skin 'Progress Spinner'. This should be deprecated when web-skin-dart implements a Spinner
/// ref: https://api.atl.workiva.net/WebSkin/docs/build/html/components/#spinners
@Factory()
UiFactory<SpinnerProps> Spinner;

@Props()
class SpinnerProps extends UiProps {
  /// The size of a progress spinner.
  ///
  /// Default: [SpinnerSize.DEFAULT]
  SpinnerSize size;

  /// Whether the label should be displayed.
  ///
  /// Default: false
  bool showLabel;

  /// The label that should be rendered.
  String label;

  /// If the label should be stacked or default.
  ///
  /// Default: [SpinnerLabelType.DEFAULT]
  SpinnerLabelType labelType;
}

@Component()
class SpinnerComponent extends UiComponent<SpinnerProps> {
  @override
  getDefaultProps() {
    return (newProps()
      ..showLabel = false
      ..size = SpinnerSize.DEFAULT
      ..labelType = SpinnerLabelType.DEFAULT);
  }

  @override
  render() {
    var spinner = _renderSpinner();

    if (props.showLabel) {
      var label = _renderLabel();
      return _renderLabelContainer(spinner, label);
    }

    return spinner;
  }

  _renderSpinner() {
    var classes = new ClassNameBuilder()..add('progress-spinner')..add(props.size.className);
    return (Dom.i()
      ..className = classes.toClassName()
      ..addTestId('wh.SpinnerComponent.Spinner'))();
  }

  _renderLabel() {
    return (Dom.span()..className = 'progress-label')(props.label);
  }

  _renderLabelContainer(spinner, label) {
    var classes = forwardingClassNameBuilder()..add(props.labelType.className);

    return (Dom.div()
      ..className = classes.toClassName()
      ..addTestId('wh.SpinnerComponent.LabelContainer'))(spinner, label);
  }
}

class SpinnerSize {
  final String className;

  const SpinnerSize._internal(this.className);

  static const SpinnerSize MEDIUM = const SpinnerSize._internal('progress-spinner-md');
  static const SpinnerSize DEFAULT = const SpinnerSize._internal(null);
  static const SpinnerSize LARGE = const SpinnerSize._internal('progress-spinner-lg');
  static const SpinnerSize XL = const SpinnerSize._internal('progress-spinner-xl');
}

class SpinnerLabelType {
  final String className;

  const SpinnerLabelType._internal(this.className);

  static const SpinnerLabelType DEFAULT = const SpinnerLabelType._internal('progress-spinner-container');
  static const SpinnerLabelType STACKED =
      const SpinnerLabelType._internal('progress-spinner-container progress-spinner-stacked');
}
