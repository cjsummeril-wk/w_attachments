import 'dart:async';

import 'package:messaging_sdk/messaging_sdk.dart' as msg;
import 'package:meta/meta.dart';
import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_module/w_module.dart';
import 'package:w_session/w_session.dart';
import 'package:wdesk_sdk/experience_framework.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;

import 'package:w_attachments_client/src/action_provider.dart';
import 'package:w_attachments_client/src/attachments_actions.dart';
import 'package:w_attachments_client/src/attachments_config.dart';
import 'package:w_attachments_client/src/attachments_events.dart';
import 'package:w_attachments_client/src/attachments_store.dart';
import 'package:w_attachments_client/src/models/models.dart';

import 'package:w_attachments_client/src/w_annotations_service/w_annotations_api.dart';
import 'package:w_attachments_client/src/w_annotations_service/w_annotations_models.dart';

typedef ActionProvider ActionProviderFactory(AttachmentsApi api);

DispatchKey attachmentsModuleDispatchKey = new DispatchKey('AttachmentsModule');

class AttachmentsModule extends Module {
  StaticAssetLoader _staticAssetLoader;
  @deprecated
  static const defaultZipName = 'AttachmentPackage';

  AttachmentsActions attachmentsActions;

  AttachmentsEvents _events;
  AttachmentsComponents _components;
  AttachmentsStore _store;
  AnnotationsApi _annotationsApi;

  AttachmentsModule(
      {@required cef.ExtensionContext extensionContext,
      @required msg.NatsMessagingClient messagingClient,
      // TODO: remove in RAM-681
      Session session,
      AppIntelligence appIntelligence,
      ActionProviderFactory actionProviderFactory,
      List<Attachment> initialAttachments,
      List<ContextGroup> initialGroups,
      List<Filter> initialFilters,
      AttachmentsConfig config,
      StaticAssetLoader staticAssetLoader}) {
    // Default the config if one wasn't provided
    config ??= new AttachmentsConfig();

    attachmentsActions = manageAndReturnDisposable(new AttachmentsActions());
    _staticAssetLoader = staticAssetLoader ?? manageAndReturnDisposable(new StaticAssetLoader());

    _annotationsApi = manageAndReturnDisposable(
        new AnnotationsApi(messagingClient: messagingClient, appIntelligence: appIntelligence));

    _events = manageAndReturnDisposable(new AttachmentsEvents());
    _store = manageAndReturnDisposable(new AttachmentsStore(
        actionProviderFactory: actionProviderFactory,
        attachmentsActions: attachmentsActions,
        attachmentsEvents: _events,
        dispatchKey: attachmentsModuleDispatchKey,
        annotationsApi: _annotationsApi,
        extensionContext: extensionContext,
        attachments: initialAttachments ?? [],
        groups: initialGroups ?? [],
        initialFilters: initialFilters ?? [],
        moduleConfig: config));
    _components = new AttachmentsComponents(
        store: _store, actionProvider: actionProvider, attachmentsActions: attachmentsActions);
  }

  @override
  AttachmentsApi get api => _store.api;
  ActionProvider get actionProvider => _store.actionProvider;
  @override
  AttachmentsComponents get components => _components;
  AttachmentsStore get store => _store;
  @override
  AttachmentsEvents get events => _events;

  @override
  onLoad() async {
    // Frugal setup
    await _annotationsApi.initialize();
    await _staticAssetLoader.loadAll([
      'packages/web_skin/dist/css/peripherals/icons-xbrl.min.css',
      'packages/web_skin/dist/css/peripherals/form-click-to-edit.min.css'
    ]);
  }

  @override
  Future<Null> onUnload() async {
    _components = null;
  }
}
