part of w_attachments_client.models.group;

abstract class GroupSort {
  static int compare(Attachment a, Attachment b) {
    throw new UnimplementedError('You can only call compare on a child class');
  }
}

class FilenameGroupSort extends GroupSort {
  static int compare(Attachment a, Attachment b) {
    if (a.filename == null || a.filename.isEmpty) {
      return -1;
    }

    if (b.filename == null || b.filename.isEmpty) {
      return 1;
    }

    return a.filename.compareTo(b.filename);
  }
}

class LabelGroupSort extends GroupSort {
  static int compare(Attachment a, Attachment b) {
    if (a.label == null || a.label.isEmpty) {
      return -1;
    }

    if (b.label == null || b.label.isEmpty) {
      return 1;
    }

    return a.label.compareTo(b.label);
  }
}
