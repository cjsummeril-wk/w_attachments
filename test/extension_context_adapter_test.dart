library w_attachments_client.test.extension_context_adapter_test;

import 'attachment_test_constants.dart';
import 'dart:async';

import 'package:mockito/mirrors.dart';
import 'package:test/test.dart';
import 'package:w_attachments_client/src/extension_context_adapter.dart';
import 'package:w_attachments_client/src/highlight_styles.dart';
import 'package:w_attachments_client/src/payloads/module_actions.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_session/mock.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart';

import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';

import './mocks/mocks_library.dart';

void main() {
//  const testWuri = 'testWuri';
//  const testScope = 'testScope';
//  const testWuri2 = 'testWuri2';
//  const testScope2 = 'testScope2';

  final obsRegion1 = new ObservedRegion(wuri: AttachmentTestConstants.testWurl);
  final obsRegion2 = new ObservedRegion(wuri: AttachmentTestConstants.existingWurl);

  MockSession session;
  ExtensionContextMock mockCEF;
  AnnotationsApiMock annotationsApiMock;

  AttachmentsStore store;
  AttachmentsActions actions;
  AttachmentsEvents events;

//  ExtensionContextAdapter adapter;

  Selection testSelection({isEmpty: false}) => new Selection(wuri: AttachmentTestConstants.testWurl, isEmpty: isEmpty);

  group('extension context adapter -', () {
    setUp(() async {
//      didChangeSelection = new StreamController<Selection>();
//      didChangeVisibleRegions = new StreamController<Null>();
//      didChangeSelectedRegions = new StreamController<Null>();
//      didChangeScopes = new StreamController<Null>();
//      when(ExtensionContextAdapter.)

      actions = new AttachmentsActions();
      events = new AttachmentsEvents();
      annotationsApiMock = new AnnotationsApiMock();
      mockCEF = new ExtensionContextMock();
      session = new MockSession();
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

      store.attachments = [AttachmentTestConstants.mockAttachment, AttachmentTestConstants.mockExistingAttachment];
      store.attachmentUsages = [AttachmentTestConstants.mockAttachmentUsage, AttachmentTestConstants.mockExistingAttachmentUsage];
      store.anchors = [AttachmentTestConstants.mockAnchor, AttachmentTestConstants.mockExistingAnchor];

//      when(mockCEF.selectionApi.didChangeSelections).thenReturn(didChangeSelection.stream);
//      when(mockCEF.observedRegionApi.didChangeVisibleRegions).thenReturn(didChangeVisibleRegions.stream);
//      when(mockCEF.observedRegionApi.didChangeSelectedRegions).thenReturn(didChangeSelectedRegions.stream);
//      when(mockCEF.observedRegionApi.didChangeScopes).thenReturn(didChangeScopes.stream);
      when(mockCEF.selectionApi.getCurrentSelections()).thenReturn(testSelection());
      when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>());

//      adapter = new ExtensionContextAdapter(extensionContext: mockCEF, actions: actions, store: store);
//      expect(store.isValidSelection, true);
    });

    tearDown(() async {
      await store.dispose();
//      didChangeSelection.close();
//      didChangeVisibleRegions.close();
//      didChangeSelectedRegions.close();
//      didChangeScopes.close();
      session = null;
    });

    group('CEF events - ', () {
      test('didChangeSelection - null payload', () async {
        // null selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn(null);
        mockCEF.selectionApi.didChangeSelectionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, false);

        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection()]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection()]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, true);
      });

      test('didChangeSelection - isEmpty selection', () async {
        // empty selection should yield non valid selection
        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection(isEmpty: true)]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection(isEmpty: true)]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, false);

        when(mockCEF.selectionApi.getCurrentSelections()).thenReturn([testSelection()]);
        mockCEF.selectionApi.didChangeSelectionsController.add([testSelection()]);
        await new Future.delayed(Duration.ZERO);
        expect(store.isValidSelection, true);
      });

      test('didChangeVisibleRegions creates and removes highlights', () async {
        when(mockCEF.highlightApi.createV3(key: any, wuri: any, styles: any)).thenReturn(new MockHighlight());
        // empty selection should yield non valid selection
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

        // remove a highlight
        when(mockCEF.observedRegionApi.getVisibleRegions()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeVisibleRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);

        verify(mockCEF.highlightApi.createV3(
          key: AttachmentTestConstants.anchorIdOne.toString(),
          styles: normalHighlightStyles,
          wuri: obsRegion1.wuri,
        ));

        // re-add the highlight, confirm createV3 was called again
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

      test('didChangeSelectedRegions sets selected state correctly', () async {
        // should not make any active if multiple regions are selected
        when(mockCEF.observedRegionApi.getSelectedRegionsV2())
          .thenReturn(new Set<ObservedRegion>.from([obsRegion1, obsRegion2]));
        mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.currentlySelectedAnchors, allOf(hasLength(2), contains(AttachmentTestConstants.anchorIdOne), contains(AttachmentTestConstants.anchorIdThree)));
        expect(store.currentlySelectedAttachments, allOf(hasLength(2), contains(AttachmentTestConstants.attachmentIdOne),
          contains(AttachmentTestConstants.attachmentIdThree)));

        // should set the selected region list
        when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.currentlySelectedAnchors, allOf(
          hasLength(1), contains(AttachmentTestConstants.anchorIdOne)));
        expect(
          store.currentlySelectedAttachments, allOf(hasLength(1), contains(AttachmentTestConstants.attachmentIdOne)));

        // should clear the selected region list
        when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>());
        mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.currentlySelectedAnchors, isEmpty);
        expect(store.currentlySelectedAttachments, isEmpty);

        // should preserve previously expanded state

        // set a thread expanded
        actions.selectAttachments(new SelectAttachmentsPayload(attachmentIds: [AttachmentTestConstants.attachmentIdOne]));

        // select thread's region
        when(mockCEF.observedRegionApi.getSelectedRegionsV2()).thenReturn(new Set<ObservedRegion>.from([obsRegion1]));
        mockCEF.observedRegionApi.didChangeSelectedRegionsController.add(null);
        await new Future.delayed(Duration.ZERO);
        expect(store.currentlySelectedAttachments, hasLength(1));
        expect(store.currentlySelectedAnchors, hasLength(1));
      });
    });
  });
}
