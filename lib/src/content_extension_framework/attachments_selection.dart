part of w_attachments_client.cef;

class AttachmentsSelection extends Selection {
  AttachmentsSelection({@required String wuri, @required String scope, bool isEmpty: false})
      : super(wuri: wuri, scope: scope, isEmpty: isEmpty);
}
