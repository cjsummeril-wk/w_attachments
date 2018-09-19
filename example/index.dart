import 'dart:async';
import 'dart:html' hide Selection;
import 'dart:math';

import 'package:app_intelligence/app_intelligence_browser.dart';
import 'package:logging/logging.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as react_client;
import 'package:react/react_dom.dart' as react_dom;
import 'package:truss/truss.dart';
import 'package:uuid/uuid.dart';
import 'package:wdesk_sdk/content_extension_framework_v2.dart' as cef;
import 'package:web_skin_dart/ui_components.dart';
import 'package:web_skin_dart/ui_core.dart';
import 'package:wuri_sdk/wuri_sdk.dart';
import 'package:w_attachments_client/w_attachments_client.dart';
import 'package:w_attachments_client/w_attachments_service_api.dart';
import 'package:w_session/mock.dart';
import 'package:w_session/w_session.dart';
import 'package:messaging_sdk/messaging_sdk.dart';
import 'package:w_transport/browser.dart';
import 'package:w_transport/mock.dart';

import './src/components/context_list.dart';
import './src/example_content_extension_framework.dart' as example_cef;
import './src/sample_reader_permissions_action_provider.dart';
import './src/utils.dart';

RichAppShell shell;
NatsMessagingClient messagingClient;
Session session;
Future<int> rightPanelModelId;
var _subs = [];
const annoClientId = "anno";

enum ViewModeSettings { Regions, Headerless, Tree }

void configureLogging(AppIntelligence ai) {
  var loggerStream = Logger.root.onRecord.asBroadcastStream();
  _subs..add(loggerStream.listen(new DebugConsoleHandler()))..add(loggerStream.listen(ai.logging));
}

/// wAttachments Example App Main Function
Future main() async {
  final AppIntelligence appIntelligence =
      new AppIntelligence('wattachments', appId: Uri.base.host, captureTotalAppRunningTime: false);

  configureLogging(appIntelligence);
  react_client.setClientConfiguration();

  final sessionHost = Uri.parse('https://wk-dev.wdesk.org');

  // mock out the session.
  MockSession.install();
  MockSession.sessionHost = sessionHost;
  MockSession.grantAuthorizationForClient(annoClientId);
  MockTransports.install(fallThrough: true);

  session = new Session(clientId: annoClientId, sessionHost: sessionHost);

  configureWTransportForBrowser();

  shell = new RichAppShell(session: session);
  await shell.load();

  final frontendConfig = new FrontendConfig('http://localhost:8100');
  messagingClient = new NatsMessagingClient(session, frontendConfig);
  await messagingClient.open();

  // Render the shell
  react_dom.render(shell.components.content(), querySelector('#shell-container'));

  // Add some content
  // The right hand panel is added in the AttachmentsExampleApp componentWillMount
  shell.api.addContentItem(() => AttachmentsExampleApp({}), () => react.span({}, 'Attachments Example'));
}

/// React Component Builder
var AttachmentsExampleApp = react.registerComponent(() => new _AttachmentsExampleApp());

/// wAttachments Example App Class
class _AttachmentsExampleApp extends react.Component {
  // module configuration variables
  AttachmentsModule _attachmentsModule;
  example_cef.ExampleAttachmentsExtensionContext _extensionContext;
  AttachmentsTestService _attachmentsService;
  AttachmentsServiceApi _serviceApi;
  AttachmentsConfig _config;

  // example app specific variables
  Function sortMethod = LabelGroupSort.compare;
  bool _automaticLoading;
  int _numberOfRequestedAttachments = 10;
  List<String> observedRegionIds = [];
  List<Segment> sectionIds = [];
  List<String> contextsForLoadedAttachments = [];
  Map<String, PredicateGroup> selectedPredicateGroups = {};

  Map<String, dynamic> _inputRefs = {};

  ContextGroup defaultTestGroup = new ContextGroup(displayAsHeaderless: true, filterName: ExampleDocumentId, pivots: [
    new GroupPivot(type: GroupPivotType.ALL, id: ExampleDocumentId, selection: ExampleDocumentId)
  ] //new Selection(documentId: ExampleDocumentId))],
//    uploadSelection: new Selection(documentId: ExampleDocumentId)
      );

  // example app constants
  static const exampleApp = 'exampleApp';
  static const clickToSelect = 'clickToSelect';
  static const draggableAttachments = 'draggableAttachments';
  static const editableLabels = 'editableLabels';
  static const guaranteeErrorSetting = 'guaranteeError';
  static const numAttachments = 'numAttachments';
  static const serverDelaySetting = 'serverDelay';
  static const multipleUpload = 'multipleUpload';
  static const purgeCache = 'purgeCache';
  static const showFilenameAsLabel = 'showFilenameAsLabel';
  static const readerMode = 'readerMode';
  static const uploadDropzones = 'uploadDropzones';
  static const uploadSpeedSetting = 'uploadSpeed';
  static const viewMode = 'viewMode';
  static const zipSelectionType = 'SelectionGraphVertex';

  // TODO: [ATEAM-3087] move these predicates to a predicate generator in some sort of example store
  // Example Predicates
  List<PredicateGroup> availablePredicates;

  @override
  componentWillMount() {
    _generatePredicates();
    _extensionContext = new example_cef.ExampleAttachmentsExtensionContext();
    _attachmentsService = new AttachmentsTestService()..resetTest({exampleApp: true});

    _config = new AttachmentsConfig(
//      zipSelection: new Selection()
//        ..type = zipSelectionType
//        ..resourceId = ExampleDocumentId,
      label: 'Example',
//      primarySelection: new Selection(documentId: ExampleDocumentId),
    );

    _attachmentsModule = new AttachmentsModule(
      config: _config,
      messagingClient: messagingClient,
      session: session,
      extensionContext: _extensionContext,
      actionProviderFactory: SampleReaderPermissionsActionProvider.actionProviderFactory,
    )..load();

    _serviceApi = new AttachmentsServiceApi.fromService(service: _attachmentsService);

    _automaticLoading = true;

    // Add the right hand panel
    rightPanelModelId = shell.api.addRightPanelItem(
      _attachmentsModule.components.content,
      _attachmentsModule.components.icon,
      titleV2: _attachmentsModule.components.titleV2,
      panelToolbar: _attachmentsModule.components.panelToolbar,
    );
  }

  @override
  componentWillUnmount() async {
    await _extensionContext.dispose();
    await _serviceApi.dispose();
    await _attachmentsService.dispose();
    await _attachmentsModule.unload();

    _extensionContext = null;
    _serviceApi = null;
    _attachmentsService = null;
    _attachmentsModule = null;
  }

  @override
  render() {
    var modulePanel = (Dom.div()..className = 'module-controls')(_renderModuleSettings());
    var controlsPanel = (Dom.div()..className = 'attachment-providers')(_renderProviderSettings());
    var contextPanel = (Dom.div()..className = 'context-component')((ContextList()
      ..config = _config
      ..module = _attachmentsModule
      ..serviceApi = _serviceApi
      ..context = _extensionContext
      ..contextsToHighlight = contextsForLoadedAttachments
      ..useDefaultGroup = (_inputRefs[viewMode] != null
          ? int.parse(_inputRefs[viewMode].getValue()[0]) == ViewModeSettings.Headerless.index
          : false)
      ..defaultGroup = defaultTestGroup
      ..viewMode = (_inputRefs[viewMode] != null
              ? ViewModeSettings.values[int.parse(_inputRefs[viewMode].getValue()[0])]
              : ViewModeSettings.Regions // default value is Regions, should sync with [toggleViewMode] button default
          ))());

    var controlsPanelWrapper = (Dom.div()..className = 'attachment-controls')(controlsPanel);

    return (BlockContent()..className = 'master-app')(modulePanel, contextPanel, controlsPanelWrapper);
  }

  _renderProviderSettings() {
    var numberToLoad = (TextInput()
      ..type = TextInputType.NUMBER
      ..label = 'Number of selection keys to fetch'
      ..defaultValue = '10'
      ..step = 1
      ..ref = ((input) {
        _inputRefs[numAttachments] = input;
      }))();
    var loadAttachments = (Button()..onClick = _handleLoadClick)('Load Test Attachments from mock server');

    // automatic loading checkbox
    var autoCheckbox = (CheckboxInput()
      ..defaultChecked = _automaticLoading
      ..value = 'Automatic Loading'
      ..onChange = _toggleAutomaticLoading
      ..label = 'Automatically load on provider/module update.')();

    // purge the mock service attachments cache
    var purgeCheckbox = (CheckboxInput()
      ..defaultChecked = true
      ..value = 'Purge service attachment cache'
      ..label = 'Purge attachment cache on service (load will create new list of attachments).'
      ..ref = (input) {
        _inputRefs[purgeCache] = input;
      })();

    var cardBlock = (CardBlock()(numberToLoad, loadAttachments, autoCheckbox, purgeCheckbox));
    return (Card()..actsAs = CardActsAs.WELL)(cardBlock);
  }

  _renderModuleSettings() {
    var serverDelay = (TextInput()
      ..helpTooltip = 'The simulated delay between attachments load and update events. Used to mimic server delay.'
      ..type = TextInputType.NUMBER
      ..label = 'Server Delay (s):'
      ..defaultValue = '1'
      ..step = 1
      ..min = 0
      ..ref = (input) {
        _inputRefs[serverDelaySetting] = input;
      })();
    var toggleViewMode = (ToggleButtonGroup()
          ..groupLabel = 'Toggle View Mode'
          ..isJustified = true
          ..ref = (input) {
            _inputRefs[viewMode] = input;
          })(
        (RadioButton()
          ..value = ViewModeSettings.Regions.index
          ..defaultChecked = true)('Regions'),
        (RadioButton()..value = ViewModeSettings.Headerless.index)('Headerless'),
        (RadioButton()..value = ViewModeSettings.Tree.index)('Nested Tree'));
    var filterCreator = (DropdownButton()
      ..displayText = 'Set Filters for headerless group'
      ..skin = ButtonSkin.WARNING
      ..isDisabled = _inputRefs[viewMode] != null
          ? int.parse(_inputRefs[viewMode].getValue()[0]) != ViewModeSettings.Headerless.index
          : true
      ..isOverlay = true)((DropdownMenu())(availablePredicates.map((PredicateGroup pg) => ((CheckboxSelectOption()
      ..isChecked = selectedPredicateGroups.containsKey(pg.name)
      ..key = 'predicateOption:${pg.name}'
      ..onChange = _handleFilterChanged
      ..value = pg.name)(pg.name)))));
    var uploadSpeed = (ToggleButtonGroup()
          ..groupLabel = 'Upload Speed'
          ..isJustified = true
          ..ref = (input) {
            _inputRefs[uploadSpeedSetting] = input;
          })(
        (RadioButton()..value = UploadSpeed.Snail.index)('Snail'),
        (RadioButton()..value = UploadSpeed.Slow.index)('Slow'),
        (RadioButton()
          ..value = UploadSpeed.Normal.index
          ..defaultChecked = true)('Normal'),
        (RadioButton()..value = UploadSpeed.Fast.index)('Fast'));
    var guaranteeError = (CheckboxInput()
      ..defaultChecked = false
      ..label = 'Guarantee Error?'
      ..ref = (input) {
        _inputRefs[guaranteeErrorSetting] = input;
      })();
    var viewerModeBox = (CheckboxInput()
      ..defaultChecked = false
      ..label = 'Reader Mode'
      ..ref = (input) {
        _inputRefs[readerMode] = input;
      }
      ..onClick = (_) {
        SampleReaderPermissionsActionProvider.readOnly = _inputRefs[readerMode].getInputDomNode().checked;
        _attachmentsModule.api.refreshPanelToolbar();
      })();
    var multipleUploadBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Allow Multiple Upload'
      ..ref = (input) {
        _inputRefs[multipleUpload] = input;
      })();
    var draggableAttachmentBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Enable Draggable Attachments'
      ..ref = (input) {
        _inputRefs[draggableAttachments] = input;
      })();
    var editableLabelsBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Enable Editable Labels'
      ..ref = (input) {
        _inputRefs[editableLabels] = input;
      })();
    var showFilenameAsLabelBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Show Filename as Label'
      ..ref = (input) {
        _inputRefs[showFilenameAsLabel] = input;
      })();
    var dropzoneAttachmentBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Enable Upload Dropzones'
      ..ref = (input) {
        _inputRefs[uploadDropzones] = input;
      })();
    var clickToSelectBox = (CheckboxInput()
      ..defaultChecked = true
      ..label = 'Enable clicking attachments to select'
      ..ref = (input) {
        _inputRefs[clickToSelect] = input;
      })();

    var updateButton = (Button()
      ..skin = ButtonSkin.ALTERNATE
      ..onClick = _handleUpdateClick)('Update Module');

    var form = Form()(
        serverDelay,
        uploadSpeed,
        toggleViewMode,
        filterCreator,
        guaranteeError,
        viewerModeBox,
        multipleUploadBox,
        draggableAttachmentBox,
        editableLabelsBox,
        showFilenameAsLabelBox,
        dropzoneAttachmentBox,
        clickToSelectBox,
        updateButton);

    var cardBlock = CardBlock()(form);

    return (Card()..actsAs = CardActsAs.WELL)(cardBlock);
  }

  _toggleAutomaticLoading(_) {
    _automaticLoading = !_automaticLoading;
  }

  _generatePredicates() {
    availablePredicates = [
      new PredicateGroup(
          name: 'A-M',
          sortMethod: sortMethod,
          predicate: (Attachment attachment) {
            return new RegExp(r"^[a-m]").hasMatch(attachment.filename.toLowerCase());
          }),
      new PredicateGroup(
          name: 'N-Z',
          sortMethod: sortMethod,
          predicate: (Attachment attachment) {
            return new RegExp(r"^[n-z]").hasMatch(attachment.filename.toLowerCase());
          }),
      new PredicateGroup(
          name: 'Supported files (xlxs)',
          sortMethod: sortMethod,
          predicate: (Attachment attachment) {
            return ExampleSupportedMimeTypes.contains(attachment.filemime);
          }),
      new PredicateGroup(
          name: 'Unsupported files',
          sortMethod: sortMethod,
          predicate: (Attachment attachment) {
            return !ExampleSupportedMimeTypes.contains(attachment.filemime);
          })
    ];
  }

  _handleFilterChanged(react.SyntheticFormEvent event) {
    String predName = event.target.value;
    if (selectedPredicateGroups.containsKey(predName)) {
      selectedPredicateGroups.remove(predName);
    } else {
      PredicateGroup newPred = availablePredicates.firstWhere((pred) => pred.name == predName, orElse: () => null);
      if (newPred != null) {
        selectedPredicateGroups[predName] = newPred;
      }
    }

    Map<String, num> availablePredicatesById = availablePredicates.fold({}, (result, predGroup) {
      result[predGroup.name] = availablePredicates.indexOf(predGroup);
      return result;
    });

    List<Filter> currentFilters = new List.from(_attachmentsModule.api.filters);
    Filter newFilter = new Filter(
        name: ExampleDocumentId,
        predicates: selectedPredicateGroups.values.toList()
          ..sort((PredicateGroup a, PredicateGroup b) {
            return availablePredicatesById[a.name].compareTo(availablePredicatesById[b.name]);
          }));

    int newFilterIndex = currentFilters.indexOf(newFilter);
    if (newFilterIndex >= 0) {
      currentFilters[newFilterIndex] = newFilter;
    } else {
      currentFilters.add(newFilter);
    }
    _attachmentsModule.api.setFilters(filters: currentFilters);
  }

  _handleLoadClick(react.SyntheticMouseEvent event, {bool resettingModule: false}) async {
    _clearExtensionContext();
    _numberOfRequestedAttachments = int.parse(_inputRefs[numAttachments].getValue());
    final Uuid uuid = new Uuid();
    final Segment spreadsheetId = new Segment('spreadsheet', uuid.v4().substring(0, 22));
    Random rand = new Random();

    if (_inputRefs[purgeCache].getInputDomNode().checked || resettingModule) {
      sectionIds = new List.generate(3, (int index) => new Segment('section', uuid.v4().substring(0, 22)));
      observedRegionIds = new List.generate(
          _numberOfRequestedAttachments,
          (int index) => new Wurl('annotations', 0, [
                spreadsheetId,
                sectionIds[rand.nextInt(sectionIds.length)],
                new Segment('selection', uuid.v4().substring(0, 22))
              ]).toString());
    }
    while (observedRegionIds.length < _numberOfRequestedAttachments) {
      observedRegionIds.add(new Wurl('annotations', 0, [
        spreadsheetId,
        sectionIds[rand.nextInt(sectionIds.length)],
        new Segment('selection', uuid.v4().substring(0, 22))
      ]).toString());
    }

    await _attachmentsModule.api.getAttachmentsByProducers(producerWurlsToLoad: observedRegionIds);
    List<String> regionWuris =
        _extensionContext.observedRegionApi.regions.map((cef.ObservedRegion region) => region.wuri).toList();
    for (String wurl in observedRegionIds) {
      if (!regionWuris.contains(wurl)) {
        await _extensionContext.observedRegionApi.create(selection: new cef.Selection(scope: wurl, wuri: wurl));
        _extensionContext.highlightApi.createV3(key: wurl, wuri: wurl);
        contextsForLoadedAttachments.add(wurl);
      }
    }

    _extensionContext.highlightApi.highlights.values.forEach((AttachmentsHighlight highlight) {
      highlight.isSelected = true;
    });

    redraw();

    await _resetGroups(contextsForLoadedAttachments);
    contextsForLoadedAttachments = [];
  }

  _resetGroups(List<String> newContexts) async {
    List<ContextGroup> relatedGroups = [];
    if (newContexts != null) {
      for (String context in newContexts.toSet()) {
        var regExp = new RegExp('section:.*(?=\/)');
        String section = regExp.stringMatch(context);
        ContextGroup toAdd = _attachmentsModule.api.groups
            .firstWhere((group) => group is ContextGroup && group.name == section, orElse: () => null);
        if (toAdd != null) {
          relatedGroups.add(toAdd);
        } else {
          relatedGroups.add(new ContextGroup(
              name: section,
              childGroups: [],
              pivots: [new GroupPivot(type: GroupPivotType.ALL, id: section, selection: context)],
              sortMethod: (_inputRefs[showFilenameAsLabel].getInputDomNode().checked)
                  ? FilenameGroupSort.compare
                  : LabelGroupSort.compare,
              uploadSelection: section));
        }
      }
    }

    if (_inputRefs[viewMode] != null) {
      switch (ViewModeSettings.values[int.parse(_inputRefs[viewMode].getValue()[0])]) {
        case ViewModeSettings.Regions:
          await _attachmentsModule.api.setGroups(groups: relatedGroups);
          break;
        case ViewModeSettings.Headerless:
          await _attachmentsModule.api.setGroups(groups: [defaultTestGroup]);
          break;
        case ViewModeSettings.Tree:
          PredicateGroup parent = new PredicateGroup(
              sortMethod: sortMethod,
              predicate: ((Attachment attachment) => true),
              name: 'Attribute Matrix - Predicate Group',
              childGroups: relatedGroups,
              customIconGlyph: IconGlyph.FILE_SHEET_G2);
          PredicateGroup grandparent = new PredicateGroup(
              sortMethod: sortMethod,
              predicate: ((Attachment attachment) => true),
              name: 'Interim Testing - Predicate Group',
              childGroups: [parent],
              customIconGlyph: IconGlyph.BEAKER_BADGE);
          await _attachmentsModule.api.setGroups(groups: [grandparent]);
          break;
      }
    } else {
      await _attachmentsModule.api.setGroups(groups: relatedGroups);
    }
  }

  _handleUpdateClick(react.SyntheticMouseEvent event) async {
    SampleReaderPermissionsActionProvider.readOnly = _inputRefs[readerMode].getInputDomNode().checked;
    SampleReaderPermissionsActionProvider.allowMultiple = _inputRefs[multipleUpload].getInputDomNode().checked;

    sortMethod =
        _inputRefs[showFilenameAsLabel].getInputDomNode().checked ? FilenameGroupSort.compare : LabelGroupSort.compare;
    defaultTestGroup.sortMethod = sortMethod;
    _generatePredicates();

    bool newErrorSetting = _inputRefs[guaranteeErrorSetting]?.getInputDomNode()?.checked;
    UploadSpeed newUploadSpeed = UploadSpeed.values[int.parse(_inputRefs[uploadSpeedSetting].getValue()[0])];

    AttachmentsTestService newService;
    if (newErrorSetting != _attachmentsService.getConfigSetting(guaranteeErrorSetting) ||
        newUploadSpeed != _attachmentsService.getConfigSetting(uploadSpeedSetting)) {
      newService = new AttachmentsTestService()
        ..resetTest({exampleApp: true, guaranteeErrorSetting: newErrorSetting, uploadSpeedSetting: newUploadSpeed});
    }

    List<cef.Selection> currentSelections = _extensionContext.selectionApi.getCurrentSelections();
    AttachmentsConfig config = new AttachmentsConfig(
      enableClickToSelect: _inputRefs[clickToSelect].getInputDomNode().checked,
      enableDraggable: _inputRefs[draggableAttachments].getInputDomNode().checked,
      enableLabelEdit: _inputRefs[editableLabels].getInputDomNode().checked,
      enableUploadDropzones: _inputRefs[uploadDropzones].getInputDomNode().checked,
      label: 'Example',
      primarySelection: currentSelections.isNotEmpty ? currentSelections.first.wuri : null,
      showFilenameAsLabel: _inputRefs[showFilenameAsLabel].getInputDomNode().checked,
//      zipSelection: new Selection()
//        ..type = zipSelectionType
//        ..resourceId = ExampleDocumentId,
    );

    if (newService != null) {
      await Future.wait([_serviceApi.dispose(), _attachmentsService.dispose(), _attachmentsModule.unload()]);

      _attachmentsService = newService;
      _serviceApi = new AttachmentsServiceApi.fromService(service: _attachmentsService);
      _attachmentsModule = new AttachmentsModule(
          config: config,
          session: session,
          extensionContext: _extensionContext,
          actionProviderFactory: SampleReaderPermissionsActionProvider.actionProviderFactory);

      await _attachmentsModule.load();
    } else {
      await _attachmentsModule.api.updateAttachmentsConfig(config);
    }

    if (_automaticLoading) _handleLoadClick(event, resettingModule: true);

    switch (ViewModeSettings.values[int.parse(_inputRefs[viewMode].getValue()[0])]) {
      case ViewModeSettings.Regions:
        // clear headerless filters if they exist
        selectedPredicateGroups = {};
        break;
      case ViewModeSettings.Headerless:
        _attachmentsModule.api.setGroups(groups: [defaultTestGroup]);
        break;
      case ViewModeSettings.Tree:
        _resetGroups(
            _extensionContext.observedRegionApi.regions.map((cef.ObservedRegion region) => region?.wuri).toList());
        break;
    }
    redraw();

    shell.api.removeItem(await rightPanelModelId);
    rightPanelModelId = shell.api.addRightPanelItem(
      _attachmentsModule.components.content,
      _attachmentsModule.components.icon,
      titleV2: _attachmentsModule.components.titleV2,
      panelToolbar: _attachmentsModule.components.panelToolbar,
    );
  }

  /// Removes all highlights from the HighlightApi, all visibleRegions and regions from ObservedRegionApi.
  /// This is only applicable from within the context of example/index for test purposes.
  _clearExtensionContext() {
    for (cef.ObservedRegion visibleRegion in _extensionContext.observedRegionApi.getVisibleRegions()) {
      _extensionContext.observedRegionApi.removeVisibleRegion(visibleRegion.wuri);
    }

    _extensionContext.highlightApi.removeAllHighlights();
  }
}
