library w_attachments_client.test.extension_context_adapter_test;

import 'attachment_test_constants.dart';
import 'dart:async';

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';
import 'package:w_attachments_client/src/highlight_styles.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_payloads.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart';

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import './mocks/mocks_library.dart';

void main() {
  final obsRegion1 =
      new ObservedRegion(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope);
  final obsRegion2 =
      new ObservedRegion(wuri: AttachmentTestConstants.existingWurl, scope: AttachmentTestConstants.testScope);

  ExtensionContextMock mockCEF;
  AnnotationsApiMock annotationsApiMock;

  AttachmentsStore store;
  AttachmentsActions actions;
  AttachmentsEvents events;

  Selection testSelection({isEmpty: false}) =>
      new Selection(wuri: AttachmentTestConstants.testWurl, scope: AttachmentTestConstants.testScope, isEmpty: isEmpty);

  group('extension context adapter -', () {
    setUp(() async {
      actions = new AttachmentsActions();
      events = new AttachmentsEvents();
      annotationsApiMock = new AnnotationsApiMock();
      mockCEF = new ExtensionContextMock();
      store = new AttachmentsStore(
          actionProviderFactory: StandardActionProvider.actionProviderFactory,
          attachmentsActions: actions,
          attachmentsEvents: events,
          annotationsApi: annotationsApiMock,
          extensionContext: mockCEF,
          dispatchKey: attachmentsModuleDispatchKey,
          attachments: [],
          groups: [],
          moduleConfig: new AttachmentsConfig(label: 'AttachmentPackage'));

      store.attachments = [AttachmentTestConstants.defaultAttachment, AttachmentTestConstants.existingAttachment];
      store.attachmentUsages = [AttachmentTestConstants.defaultUsage, AttachmentTestConstants.existingUsage];
      store.anchors = [AttachmentTestConstants.mockAnchor, AttachmentTestConstants.mockExistingAnchor];

      when(mockCEF.selectionApi.getCurrentSelections()).thenReturn(testSelection());
      when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>());
    });

    tearDown(() async {
      await store.dispose();
      await annotationsApiMock.dispose();
    });

    group('CEF events - ', () {
      test('didChangeSelection - null payload', () async {
        // null selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn(null);
        mockCEF.selectionApi.didChangeSelectionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, false);
      });

      test('didChangeSelection - isValidSelection recovers after null payload', () async {
        // null selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn(null);
        mockCEF.selectionApi.didChangeSelectionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection()]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection()]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, true);
        expect(store.currentSelection, new isInstanceOf<Selection>());
      });

      test('didChangeSelection - isEmpty selection', () async {
        // empty selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection(isEmpty: true)]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection(isEmpty: true)]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, false);
      });

      test('didChangeSelection - isValidSelection recovers after an isEmpty selection', () async {
        // empty selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection(isEmpty: true)]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection(isEmpty: true)]);
        await new Future.delayed(Duration.ZERO);

        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection()]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection()]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, true);
        expect(store.currentSelection, new isInstanceOf<Selection>());
      });

      test('didChangeVisibleRegions creates highlights', () async {
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(new MockHighlight());
        when(mockCEF.observedRegionApi.getVisibleRegions())
            .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        verify(mockCEF.highlightApi.createV3(
          key: AttachmentTestConstants.anchorIdOne.toString(),
          styles: normalHighlightStyles,
          wuri: obsRegion1.wuri,
        ));

        verify(mockCEF.highlightApi.createV3(
          key: AttachmentTestConstants.anchorIdThree.toString(),
          styles: normalHighlightStyles,
          wuri: obsRegion2.wuri,
        ));
      });

      test('didChangeVisibleRegions recreates highlights that have been removed and need re-added', () async {
        // create two highlights
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(new MockHighlight());
        when(mockCEF.observedRegionApi.getVisibleRegions())
            .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        // remove a highlight, note that existent highlights do not get recreated
        when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        // re-add the highlight, confirm createV3 was called again
        when(mockCEF.observedRegionApi.getVisibleRegions())
            .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        verify(mockCEF.highlightApi.createV3(
          key: AttachmentTestConstants.anchorIdThree.toString(),
          styles: normalHighlightStyles,
          wuri: obsRegion2.wuri,
        ))
            .called(2);
      });

      group('didChangeSelectedRegions sets selected state correctly, given ViewModeSetting.References ', () {
        setUp(() {
          actions.updateAttachmentsConfig(
              new AttachmentsConfig(label: 'AttachmentPackage', viewModeSetting: ViewModeSettings.References));
        });

        test('add new selected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(
              store.currentlySelectedAnchors,
              allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne),
                  contains(AttachmentTestConstants.anchorIdThree)));
          expect(
              store.currentlySelectedAttachmentUsages,
              allOf(hasLength(2), contains(AttachmentTestConstants.attachmentUsageIdOne),
                  contains(AttachmentTestConstants.attachmentUsageIdThree)));
        });

        test('remove deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should set the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, allOf(hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
          expect(store.currentlySelectedAttachmentUsages,
              allOf(hasLength(1), contains(AttachmentTestConstants.attachmentUsageIdOne)));
        });

        test('remove all deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should clear the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>());
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, isEmpty);
          expect(store.currentlySelectedAttachmentUsages, isEmpty);
        });

        test('selected regions override prior selection', () async {
          // select an attachment
          actions.selectAttachmentUsages(
              new SelectAttachmentUsagesPayload(usageIds: [AttachmentTestConstants.attachmentUsageIdOne]));

          // select attachmentUsage's region
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          expect(store.currentlySelectedAttachmentUsages, hasLength(1));
          expect(store.currentlySelectedAnchors, hasLength(1));
        });
      });

      group('didChangeSelectedRegions sets selected state correctly, given ViewModeSetting.Groups ', () {
        setUp(() {
          actions.updateAttachmentsConfig(
              new AttachmentsConfig(label: 'AttachmentPackage', viewModeSetting: ViewModeSettings.Groups));
        });

        test('add new selected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(
              store.currentlySelectedAnchors,
              allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne),
                  contains(AttachmentTestConstants.anchorIdThree)));
          expect(
              store.currentlySelectedAttachments,
              allOf(hasLength(2), contains(AttachmentTestConstants.attachmentIdOne),
                  contains(AttachmentTestConstants.attachmentIdThree)));
        });

        test('remove deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should set the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, allOf(hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
          expect(store.currentlySelectedAttachments,
              allOf(hasLength(1), contains(AttachmentTestConstants.attachmentIdOne)));
        });

        test('remove all deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should clear the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>());
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, isEmpty);
          expect(store.currentlySelectedAttachments, isEmpty);
        });

        test('selected regions override prior selection', () async {
          // select an attachment
          actions.selectAttachments(
              new SelectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.attachmentIdOne]));

          // select attachmentUsage's region
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          expect(store.currentlySelectedAttachments, hasLength(1));
          expect(store.currentlySelectedAnchors, hasLength(1));
        });
      });

      group('didChangeSelectedRegions sets selected state correctly, given ViewModeSetting.Headerless ', () {
        setUp(() {
          actions.updateAttachmentsConfig(
              new AttachmentsConfig(label: 'AttachmentPackage', viewModeSetting: ViewModeSettings.Headerless));
        });

        test('add new selected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(
              store.currentlySelectedAnchors,
              allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne),
                  contains(AttachmentTestConstants.anchorIdThree)));
          expect(
              store.currentlySelectedAttachments,
              allOf(hasLength(2), contains(AttachmentTestConstants.attachmentIdOne),
                  contains(AttachmentTestConstants.attachmentIdThree)));
        });

        test('remove deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should set the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, allOf(hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
          expect(store.currentlySelectedAttachments,
              allOf(hasLength(1), contains(AttachmentTestConstants.attachmentIdOne)));
        });

        test('remove all deselected regions', () async {
          // create multiple initial highlights
          when(mockCEF.observedRegionApi.getSelectedRegionsV2())
              .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          // should clear the selected region list
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>());
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);
          expect(store.currentlySelectedAnchors, isEmpty);
          expect(store.currentlySelectedAttachments, isEmpty);
        });

        test('selected regions override prior selection', () async {
          // select an attachment
          actions.selectAttachments(
              new SelectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.attachmentIdOne]));

          // select attachmentUsage's region
          when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
          mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
          await new Future.delayed(Duration.ZERO);

          expect(store.currentlySelectedAttachments, hasLength(1));
          expect(store.currentlySelectedAnchors, hasLength(1));
        });
      });

      test('didChangeScopes calls getScopes and getAttachmentsByProducers', () async {
        when(annotationsApiMock.getAttachmentsByProducers(producerWurls: any))
            .thenReturn(new GetAttachmentsByProducersResponse(anchors: [], attachments: [], attachmentUsages: []));
        when(mockCEF.observedRegionApi.getScopes()).thenReturn(new Set.from([AttachmentTestConstants.testScope]));

        mockCEF.observedRegionApi.didChangeScopesController.add(null);
        await new Future.delayed(Duration.ZERO);

        expect(store.isValidSelection, false);
        verify(mockCEF.observedRegionApi.getScopes());
        verify(annotationsApiMock.getAttachmentsByProducers(producerWurls: any));
        expect(store.currentScopes, allOf(isNotEmpty, contains(AttachmentTestConstants.testScope)));
      });

      test('hoverChanged updates currentlyHovered and sets new style', () async {
        var mockHighlight = new MockHighlight();
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(mockHighlight);

        when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        await actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: null, nextAttachmentId: AttachmentTestConstants.attachmentIdOne));
        await new Future.delayed(Duration.ZERO);

        verify(mockHighlight.updateV2(styles: normalPanelHoverStyles));
      });

      test('selectedChanged updates style on selected entity', () async {
        var mockHighlight = new MockHighlight();
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(mockHighlight);

        when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        await actions.selectAttachmentUsages(
            new SelectAttachmentUsagesPayload(usageIds: [AttachmentTestConstants.attachmentUsageIdOne]));
        await new Future.delayed(Duration.ZERO);

        verify(mockHighlight.updateV2(styles: selectedHighlightStyles));
      });

      test('hoverChanged on a selected updates currentlyHovered and sets new style', () async {
        var mockHighlight = new MockHighlight();
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(mockHighlight);

        when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        await actions.selectAttachmentUsages(
            new SelectAttachmentUsagesPayload(usageIds: [AttachmentTestConstants.attachmentUsageIdOne]));
        await new Future.delayed(Duration.ZERO);
        await actions.hoverAttachment(new HoverAttachmentPayload(
            previousAttachmentId: null, nextAttachmentId: AttachmentTestConstants.attachmentIdOne));
        await new Future.delayed(Duration.ZERO);

        verify(mockHighlight.updateV2(styles: selectedPanelHoverStyles));
      });
    });
  });
}
