part of w_attachments_client.example.cef;

class ExampleAttachmentsSelection extends AttachmentsSelection {
  static const String _DEFAULT_SCOPE = 'lux:123:456';

  ExampleAttachmentsSelection({@required String wuri, @required String scope: _DEFAULT_SCOPE, bool isEmpty: false})
      : super(wuri: wuri, scope: scope, isEmpty: isEmpty);
}
