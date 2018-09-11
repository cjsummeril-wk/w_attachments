library w_attachments_client.test.models.group;

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/src/models/group.dart';

void main() {
  group('Group', () {
    String testUsername = 'Ron Swanson';
    String veryGoodResourceId = 'very good resource id';
    String veryGoodDocumentId = 'very good document id';
    String veryGoodSectionId = 'very good section id';
    String veryGoodRegionId = 'very good region id';
    String veryGoodEdgeName = 'very good edge name';
    String otherResourceId = 'resource id';
    String otherDocumentId = 'document id';
    String otherSectionId = 'section id';
    String otherRegionId = 'region id';
    String otherEdgeName = 'edge name';

    group('Context Group', () {
//      test('should filter attachments based on resource type group pivot', () async {
//        Bundle toAdd = new Bundle();
//        toAdd.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        toAdd.selection
//          ..key = new Uuid().v4()
//          ..resourceId = veryGoodResourceId;
//
//        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.RESOURCE,
//              id: veryGoodResourceId,
//              selection: new Selection(resourceId: veryGoodResourceId)
//          )
//        ]);
//        veryGoodGroup.regroup([toAdd]);
//        expect(veryGoodGroup.attachments.length, 1);
//        expect(veryGoodGroup.attachments[0], toAdd);
//
//        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.RESOURCE, id: otherResourceId, selection: new Selection(resourceId: otherResourceId))
//        ]);
//        otherGroup.regroup([toAdd]);
//        expect(otherGroup.attachments.length, 0);
//      });
//
//      test('should filter attachments based on document type group pivot', () async {
//        Bundle toAdd = new Bundle();
//        toAdd.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        toAdd.selection
//          ..key = new Uuid().v4()
//          ..documentId = veryGoodDocumentId;
//
//        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.DOCUMENT,
//              id: veryGoodDocumentId,
//              selection: new Selection(documentId: veryGoodDocumentId))
//        ]);
//        veryGoodGroup.regroup([toAdd]);
//        expect(veryGoodGroup.attachments.length, 1);
//        expect(veryGoodGroup.attachments[0], toAdd);
//
//        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.DOCUMENT, id: otherDocumentId, selection: new Selection(documentId: otherDocumentId))
//        ]);
//        otherGroup.regroup([toAdd]);
//        expect(otherGroup.attachments.length, 0);
//      });
//
//      test('should filter attachments based on section type group pivot', () async {
//        Bundle toAdd = new Bundle();
//        toAdd.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        toAdd.selection
//          ..key = new Uuid().v4()
//          ..sectionId = veryGoodSectionId;
//
//        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.SECTION,
//              id: veryGoodSectionId,
//              selection: new Selection(sectionId: veryGoodSectionId))
//        ]);
//        veryGoodGroup.regroup([toAdd]);
//        expect(veryGoodGroup.attachments.length, 1);
//        expect(veryGoodGroup.attachments[0], toAdd);
//
//        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.SECTION, id: otherSectionId, selection: new Selection(sectionId: otherSectionId))
//        ]);
//        otherGroup.regroup([toAdd]);
//        expect(otherGroup.attachments.length, 0);
//      });
//
//      test('should filter attachments based on region type group pivot', () async {
//        Bundle toAdd = new Bundle();
//        toAdd.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        toAdd.selection
//          ..key = new Uuid().v4()
//          ..regionId = veryGoodRegionId;
//
//        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.REGION, id: veryGoodRegionId, selection: new Selection(regionId: veryGoodRegionId))
//        ]);
//        veryGoodGroup.regroup([toAdd]);
//        expect(veryGoodGroup.attachments.length, 1);
//        expect(veryGoodGroup.attachments[0], toAdd);
//
//        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.REGION, id: otherRegionId, selection: new Selection(regionId: otherRegionId))
//        ]);
//        otherGroup.regroup([toAdd]);
//        expect(otherGroup.attachments.length, 0);
//      });
//
//      test('should filter attachments based on graph vertex type group pivot', () async {
//        Bundle toAdd = new Bundle();
//        toAdd.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        toAdd.selection
//          ..key = new Uuid().v4()
//          ..resourceId = veryGoodResourceId
//          ..edgeName = veryGoodEdgeName;
//
//        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.GRAPH_VERTEX,
//              id: veryGoodResourceId,
//              selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName))
//        ]);
//        veryGoodGroup.regroup([toAdd]);
//        expect(veryGoodGroup.attachments.length, 1);
//        expect(veryGoodGroup.attachments[0], toAdd);
//
//        ContextGroup otherGroup = new ContextGroup(name: 'group', pivots: [
//          new GroupPivot(
//              type: GroupPivotType.GRAPH_VERTEX,
//              id: otherResourceId,
//              selection: new Selection(resourceId: otherResourceId, edgeName: otherEdgeName))
//        ]);
//        otherGroup.regroup([toAdd]);
//        expect(otherGroup.attachments.length, 0);
//      });

      test('should filter attachments based on ALL type group pivot', () async {
        Attachment documentType = new Attachment();
//        documentType.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        documentType.selection
//          ..key = new Uuid().v4()
//          ..documentId = veryGoodDocumentId;

        Attachment sectionType = new Attachment();
//        sectionType.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        sectionType.selection
//          ..key = new Uuid().v4()
//          ..sectionId = veryGoodSectionId;

        Attachment regionType = new Attachment();
//        regionType.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        regionType.selection
//          ..key = new Uuid().v4()
//          ..regionId = veryGoodRegionId;

        Attachment resourceType = new Attachment();
//        resourceType.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        resourceType.selection
//          ..key = new Uuid().v4()
//          ..resourceId = veryGoodResourceId;

        Attachment graphVertexType = new Attachment();
//        graphVertexType.annotation
//          ..filename = 'very_good_file.docx'
//          ..author = testUsername;
//        graphVertexType.selection
//          ..key = new Uuid().v4()
//          ..resourceId = veryGoodResourceId
//          ..edgeName = veryGoodEdgeName;

        ContextGroup veryGoodGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
            type: GroupPivotType.ALL,
            id: veryGoodResourceId,
//              selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName)
          )
        ]);
        veryGoodGroup.regroup([documentType, sectionType, regionType, resourceType, graphVertexType]);
        expect(veryGoodGroup.attachments.length, 5);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == graphVertexType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == resourceType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == sectionType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == documentType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == regionType), isTrue);
      });

      test('should have ability for composite attachment pivots and single uploadSelection', () {
        Attachment documentType = new Attachment();

        Attachment sectionType = new Attachment();

        Attachment regionType = new Attachment();

//        Selection veryGoodSelection = new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName);

        ContextGroup veryGoodGroup = new ContextGroup(
          name: 'veryGoodGroup',
          pivots: [
            new GroupPivot(
              type: GroupPivotType.DOCUMENT,
              id: veryGoodDocumentId,
//                  selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName)
            ),
            new GroupPivot(
              type: GroupPivotType.SECTION,
              id: veryGoodSectionId,
//                  selection: new Selection(resourceId: veryGoodResourceId, edgeName: veryGoodEdgeName)
            )
          ],
//            uploadSelection: veryGoodSelection
        );

        veryGoodGroup.regroup([documentType, sectionType, regionType]);
        expect(veryGoodGroup.attachments.length, 2);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == documentType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == sectionType), isTrue);
        expect(veryGoodGroup.attachments.any((attachment) => attachment == regionType), isFalse);
//        expect(veryGoodGroup.uploadSelection, veryGoodSelection);
      });

      test('should have hash, toString and "==" functionality', () async {
        ContextGroup theGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
            type: GroupPivotType.RESOURCE,
            id: 'very_good_resource_id',
//              selection: new Selection(resourceId: 'very_good_resource_id')
          )
        ]);

        expect(theGroup.hashCode, isNotNull);
        expect(theGroup.toString(), isNotNull);
        expect(theGroup == theGroup, isTrue);

        ContextGroup theOtherGroup = new ContextGroup(name: 'veryGoodGroup', pivots: [
          new GroupPivot(
            type: GroupPivotType.RESOURCE,
            id: 'very_good_resource_id',
//              selection: new Selection(resourceId: 'very_good_resource_id')
          )
        ]);

        expect(theGroup == theOtherGroup, isFalse);
      });

      group('should sort properly', () {
        Attachment attachment1;
        Attachment attachment2;
        Attachment attachment3;

        setUp(() {
          attachment1 = new Attachment();

          attachment2 = new Attachment();

          attachment3 = new Attachment();
        });

        test('on filename', () {
          ContextGroup theGroup = new ContextGroup(
              name: 'theGroup',
              pivots: [
                new GroupPivot(
                  type: GroupPivotType.ALL,
                  id: veryGoodResourceId,
//                    selection: new Selection(resourceId: veryGoodResourceId)
                )
              ],
              sortMethod: FilenameGroupSort.compare);

          theGroup.regroup([attachment1, attachment2, attachment3]);
          expect(theGroup.attachments.length, 3);
          expect(theGroup.attachments[0], attachment3);
          expect(theGroup.attachments[1], attachment2);
          expect(theGroup.attachments[2], attachment1);
        });

        test('on label', () {
          ContextGroup theGroup = new ContextGroup(
              name: 'theGroup',
              pivots: [
                new GroupPivot(
                  type: GroupPivotType.ALL,
                  id: veryGoodResourceId,
//                    selection: new Selection(resourceId: veryGoodResourceId)
                )
              ],
              sortMethod: LabelGroupSort.compare);

          theGroup.regroup([attachment1, attachment2, attachment3]);
          expect(theGroup.attachments.length, 3);
          expect(theGroup.attachments[0], attachment2);
          expect(theGroup.attachments[1], attachment1);
          expect(theGroup.attachments[2], attachment3);
        });
      });
    });

    group('Predicate Group', () {
      test('should filter attachments based on the predicate', () async {
        Attachment toAdd = new Attachment();

        PredicateGroup veryGoodGroup = new PredicateGroup(
            name: 'veryGoodGroup', predicate: ((Attachment attachment) => attachment.userName == testUsername));
        veryGoodGroup.regroup([toAdd]);
        expect(veryGoodGroup.attachments.length, 1);
        expect(veryGoodGroup.attachments[0], toAdd);

        PredicateGroup otherGroup = new PredicateGroup(
            name: 'group', predicate: ((Attachment attachment) => attachment.userName == 'Bazooka Joe'));
        otherGroup.regroup([toAdd]);
        expect(otherGroup.attachments.length, 0);
      });

      test('should have hash, toString and "==" functionality', () async {
        PredicateGroup theGroup =
            new PredicateGroup(name: 'veryGoodGroup', predicate: ((Attachment attachment) => true));

        expect(theGroup.hashCode, isNotNull);
        expect(theGroup.toString(), isNotNull);
        expect(theGroup == theGroup, isTrue);

        PredicateGroup theOtherGroup =
            new PredicateGroup(name: 'otherGroup', predicate: ((Attachment attachment) => true));

        expect(theGroup == theOtherGroup, isFalse);
      });

      group('should sort properly', () {
        Attachment attachment1;
        Attachment attachment2;
        Attachment attachment3;

        setUp(() {
          attachment1 = new Attachment();

          attachment2 = new Attachment();

          attachment3 = new Attachment();
        });

        test('on filename', () {
          PredicateGroup theGroup = new PredicateGroup(
              name: 'theGroup', predicate: ((Attachment attachment) => true), sortMethod: FilenameGroupSort.compare);

          theGroup.regroup([attachment1, attachment2, attachment3]);
          expect(theGroup.attachments.length, 3);
          expect(theGroup.attachments[0], attachment3);
          expect(theGroup.attachments[1], attachment2);
          expect(theGroup.attachments[2], attachment1);
        });

        test('on label', () {
          PredicateGroup theGroup = new PredicateGroup(
              name: 'theGroup', predicate: ((Attachment attachment) => true), sortMethod: LabelGroupSort.compare);

          theGroup.regroup([attachment1, attachment2, attachment3]);
          expect(theGroup.attachments.length, 3);
          expect(theGroup.attachments[0], attachment2);
          expect(theGroup.attachments[1], attachment1);
          expect(theGroup.attachments[2], attachment3);
        });
      });
    });

    group('GroupSort', () {
      Attachment attachment1;
      Attachment attachment2;

      setUp(() {
        attachment1 = new Attachment();

        attachment2 = new Attachment();
      });

      test('on filename', () {
        expect(FilenameGroupSort.compare(attachment1, attachment1), 0);
        expect(FilenameGroupSort.compare(attachment2, attachment2), 0);
        expect(FilenameGroupSort.compare(attachment1, attachment2), -1);
        expect(FilenameGroupSort.compare(attachment2, attachment1), 1);
      });

      test('on filename with null attachment', () {
        attachment2 = null;
        expect(FilenameGroupSort.compare(attachment1, attachment2), 1);
        expect(FilenameGroupSort.compare(attachment2, attachment1), -1);
      });

      test('on filename with empty filename', () {
        attachment2.filename = '';
        expect(FilenameGroupSort.compare(attachment1, attachment2), 1);
        expect(FilenameGroupSort.compare(attachment2, attachment1), -1);
      });

      test('on label', () {
        expect(LabelGroupSort.compare(attachment1, attachment1), 0);
        expect(LabelGroupSort.compare(attachment2, attachment2), 0);
        expect(LabelGroupSort.compare(attachment1, attachment2), 1);
        expect(LabelGroupSort.compare(attachment2, attachment1), -1);
      });

      test('on label with null attachment', () {
        attachment2 = null;
        expect(LabelGroupSort.compare(attachment1, attachment2), 1);
        expect(LabelGroupSort.compare(attachment2, attachment1), -1);
      });

      test('on label with null filename', () {
        attachment2.filename = null;
        expect(LabelGroupSort.compare(attachment1, attachment2), 1);
        expect(LabelGroupSort.compare(attachment2, attachment1), -1);
      });

      test('on label with empty filename', () {
        attachment2.filename = '';
        expect(LabelGroupSort.compare(attachment1, attachment2), 1);
        expect(LabelGroupSort.compare(attachment2, attachment1), -1);
      });
    });
  });
}
