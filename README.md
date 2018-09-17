w_attachments_client_client
=========

A module that provides an interface to manage attachments in a side panel.

### Building
#### Install the Dart SDK

```bash
$ brew tap dart-lang/dart
$ brew install dart --with-content-shell --with-dartium
$ brew linkapps dart
```

#### Installing / Updating Dart Dependencies

Run the following from the root w_attachments_client directory.
```bash
pub get
```

#### Running

  - Run the example application inside the `example` directory to see a basic implementation of w_attachments_client
  - `pub run dart_dev examples` in the root, with dartium running.


#### Running tests

- run `pub run dart_dev test` in the root or app directory to run all the tests at those levels
- run `pub run dart_dev test -n REGEX` to tests matching a specific REGEX. It's recommended to wrap all tests in a file with a
corresponding top level group so that all tests in file can be run easily.
    - Ex. All tests in `attachments_module_test.dart` should be wrapped in a `AttachmentsModule` group so they can be run
        with `pub run dart_dev test -n AttachmentsModule` (or better yet: `pub run dart_dev test -n '^AttachmentsModule'`.
        Make sure to wrap your regex in quotes if you are using any special characters - if your terminal runs caret substitution
        or any other special zsh commands you may have unexpected results.)

#### Generating Tests
- run `pub run dart_dev gen-test-runner` in the root directory.

### Contributing
- Follow [Effective Dart](https://www.dartlang.org/effective-dart/).
- Format code using `dartformat` with 120 characters: `pub run dart_dev format`
- Verify that the example app still works correctly

## Consuming

### Attachments Module
- Add w_attachments_client to your pubspec.
- Include the following stylesheets in your html:

```bash
    <link rel="stylesheet" href="packages/web_skin/dist/css/web-skin.min.css">
    <link rel="stylesheet" href="packages/web_skin/dist/css/peripherals/grid-v2.min.css">
    <link rel="stylesheet" href="packages/w_attachments_client/style/w_attachment.css">
```

#### Rendering
- Use w_module to construct and load an `AttachmentsModule`. The module requires that you provide it a [Session](https://github.com/Workiva/w_session/blob/master/lib/src/session.dart), an
  [ExtensionContext](https://github.com/Workiva/wdesk_sdk/blob/master/lib/src/content_extension_framework/extension_context.dart),
  and an [AttachmentsService](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/attachments_service/attachments_service.dart).
  The [Session](https://github.com/Workiva/w_session/blob/master/lib/src/session.dart) should be provided by
  [w_session](https://github.com/Workiva/w_session).
  The [ExtensionContext](https://github.com/Workiva/wdesk_sdk/blob/master/lib/src/content_extension_framework/extension_context.dart) should
  be provided by the [wdesk_sdk](https://github.com/Workiva/wdesk_sdk).
  The [AttachmentsService](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/attachments_service/attachments_service.dart) is
  the server communication to w-annotation, and although it is not marked as required, it should be known that server actions like upload,
  download, etc. will not work without an [AttachmentsService](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/attachments_service/attachments_service.dart). A new one will be created with the [Session](https://github.com/Workiva/w_session/blob/master/lib/src/session.dart) if this is not provided.


```dart
class BaseModule extends Module {
  AttachmentsModule module;
  BaseModule() {
    module = new AttachmentsModule(
        session: session,
        extensionContext: extensionContext,
        attachmentsService: new AttachmentsService(
            bigskyClient: session.createBigskyClient(),
            appIntelligence: existing_appIntelligence_instance),
  }

  @override
  onLoad() async {
    loadChildModule(module)
  }
}
```

- Optional Parameters for AttachmentsModule constructor
  - `ActionProviderFactory actionProviderFactory`: see [Custom Action Configuration for the Panel menu, group header buttons and attachment card dropdown menu](#custom-action-configuration-for-the-panel-menu,-group-header-buttons-and-attachment-card-dropdown-menu)
  - `AppIntelligence appIntelligence`: is when instantiating a new module or attachmentsServiceApi without generating a new [AttachmentsService](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/attachments_service/attachments_service.dart) (one will be created using `appIntelligence`).
  If you do not provide either an AttachmentsService instance or an AppIntelligence instance, a new instance of AttachmentsService with an AppIntelligence will be created. See [app_intelligence_dart](https://github.com/Workiva/app_intelligence_dart).
  - `List<Bundle> initialAttachments`: A list of `Bundle`s that can be used to populate the panel without loading from the server, if the consumer
  knows about `Bundle`.
  - `List<ContextGroup> initialGroups`: A list of `ContextGroup`s associated with selections in the experience. Note that no attachments will be
  displayed without associated groups, see `setGroups` below.
  - `List<Filter> initialFilters`: A list of `Filter`s that can be set per group to display a subset of a group's attachments.
  - `bool enableDraggable`: `true` to allow attachments (not groups) to be draggable components, `false` if not.
  - `bool enableUploadDropzones`: `true` to allow an attachment upload to be triggered by dragging a file from the file system to the panel, `false` if not.
  - `bool enableLabelEdit`: `true` to allow editing the label through the CTE control in the card header or treenode.
  - `bool showFilenameAsLabel`: `false` to show the annotation.filename in the label card header or treenode rather than the annotation.label which is default. This setting also controls which property is being edited with the enableLabelEdit setting.
  - `Selection zipSelection`: The de facto [Selection](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/selection.dart) being used for zip download bundles, it requires a type be set, such as `SelectionGraphVertex`, `SelectionDocument`, `SelectionSection`.
  - `String label`: A short description of the Document or Section or Test Control Form or Spreadsheet from which the Attachments Panel
  has been loaded. Examples are section name or test control form name (like "Sample Selection"). This is the label applied to zip download files.



- Render the module's content using RichAppShell.

```dart
RichAppShell shell = new RichAppShell(session: session);
...
shell.api.addRightPanelItem(
  _attachmentsModule.components.content,
  _attachmentsModule.components.icon,
  titleV2: _attachmentsModule.components.titleV2,
  panelToolbar: _attachmentsModule.components.panelToolbar
);
```

#### Loading Attachments
- Load Attachments with a known list of selection keys

```dart
await module.api.loadAttachments(selectionKeysToLoad: [<some list of selection keys>]);
```

- An initial list of attachments can also be provided to the constructor

```dart
module = new AttachmentsModule(
        session: session,
        extensionContext: _extensionContext,
        attachments: [<a lot of attachment objects>]);
```

#### Setting Groups
- There are two views now supported: Region-based and VirtualTree-based.

##### Region View
- In order to display attachments in a region view, the module requires that context groups are set.
 [ContextGroup](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/group/context_group.dart)s are groups of
 attachments that are organized by a particular ID on the attachments. Supported IDs are `resourceId, documentId,
 regionId, sectionId, graphVertex and all`, if using graphVertex, a resourceId and graphVertex must both be present.
 if using all, an id is still required but all attachments provided will be set in the group. Multiple pivots can be provided
 to create a composite context group, it will filter all attachments matching either pivot ID.
 - Uploads require an uploadSelection (of type [Selection](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/selection.dart)) be provided with the ContextGroup(s).
- Note that nothing will display if no groups are supplied.

```dart
import 'package:w_attachments_client/w_attachments_client.dart';
...
Selection uploadSelection = new Selection(documentId: ExampleDocumentId);

ContextGroup someGroupOfAttachments = new ContextGroup(
    name: 'some group of attachments',
    pivots: [new GroupPivot(
      type: GroupPivotType.DOCUMENT,
      id: ExampleDocumentId,
      selection: uploadSelection)],
    displayAsHeaderless: false,
    uploadSelection: uploadSelection
);
...
await module.api.setGroups(groups: [someGroupOfAttachments]); // pass in a list of all needed groups

```

  - Alternatively, groups can be set at module construction:

```dart
module = new AttachmentsModule(
        session: session,
        extensionContext: _extensionContext,
        groups: [someGroupOfAttachments]);

```

##### Nested Attachment Tree View
- The Nested Tree View allows for a simulated directory structure by which to organize the displayed attachments.
- In order to display attachments in a Nested Tree view, the module requires a list of [ContextGroup](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/group/context_group.dart)
 or [PredicateGroup](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/group/predicate_group.dart) that have `childGroups` set within them.
 - ContextGroups and Predicates can both be set as children for both types (ContextGroup => ContextGroup, ContextGroup => PredicateGroup, PredicateGroup => ContextGroup, PredicateGroup => PredicateGroup).
 - Groups will take attachments only from its parent's attachments and filter down from that list.
  - For instance, a PredicateGroup's child ContextGroup will only display attachments that match both its `resourceId` AND the custom predicate of its parent.
 - ContextGroups can take multiple pivots in a list, filtering attachment by either pivot (union of all matching attachments). ContextGroups must have
 a provided uploadSelection (of type [Selection](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/selection.dart)) in order to allow upload.

```dart
import 'package:w_attachments_client/w_attachments_client.dart';
...
Selection uploadSelection = new Selection(documentId: ExampleDocumentId)

ContextGroup someGroupOfAttachments = new ContextGroup(
    name: 'some group of attachments',
    childGroups: [],
    pivots: [new GroupPivot(
      type: GroupPivotType.DOCUMENT,
      id: ExampleDocumentId,
      selection: uploadSelection)],
    uploadSelection: uploadSelection
);
ContextGroup parentGroup = new ContextGroup(
    name: 'parent',
    childGroups: [someGroupOfAttachments]
);
...
await module.api.setGroups(groups: [parentGroup]); // pass in a list of parent groups, the childGroups will trigger a TreeView.

```

Groups with a provided `childGroup` structure defined here can be set in the module construction the same as the example above in region view.



#### Setting Filters
  - Each group can have filters applied to it (for instance, the group needs to show files supported by some
functionality, and other files). Filters are made up of one or more PredicateGroups defining the group of attachments
matching a certain predicate.

```markdown
PredicateGroup somePredicate = new PredicateGroup(name: 'Supported files (xlxs)', predicate: (Bundle attachment) {
  return ExampleSupportedMimeTypes.contains(
    attachment.annotation.filemime
  );
})

Filter newFilter = new Filter(
  name: props.regionId,
  predicates: [somePredicate]
    ..sort((PredicateGroup a, PredicateGroup b) {
      return availablePredicatesById[a.name].compareTo(availablePredicatesById[b.name]);
    })
);

await module.api.setFilters(filters: [newFilter]);
```

#### Custom Action Configuration for the Panel menu, group header buttons and attachment card dropdown menu
- The [ActionProvider](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/action_provider.dart)
 interface can be implemented with a custom action provider, for various use cases. For example,
if there are special reader-level permissions and it is undesired to let the reader-level user manipulate the list.
- Requirement number one for an action provider is to implement the following function:

```dart
static ActionProvider actionProviderFactory(AttachmentsApi api) {
    return new CustomActionProvider(api: api);
    // replace `CustomActionProvider` with the name of your action provider class.
}
```

- You'll need to implement `getPanelActions()`, `getGroupActions(ContextGroup)` and `getBundleActions(Bundle)`.
  - Each of these 3 methods are populated with a list of
   [ActionItem](https://github.com/Workiva/w_attachments_client/blob/master/lib/src/models/action_item/action_item.dart)s that
   can then be rendered from the Panel's menu, group panel, or attachment card.
  - They are typed, so implement `PanelActionItem` for `getPanelActions`,
    `GroupActionItem` for `getGroupActions`,
    and `BundleActionItem` for `getBundleActions`.
- Lastly, when constructing the AttachmentsModule, include the actionProviderFactory method as a parameter, like so:

```dart
actionProviderFactory: CustomActionProvider.actionProviderFactory
```

- See [SampleReaderPermissionsActionProvider](https://github.com/Workiva/w_attachments_client/blob/master/example/src/sample_reader_permissions_action_provider.dart)
and its implementation in [index.dart](https://github.com/Workiva/w_attachments_client/blob/master/example/index.dart) for an example of custom implementation.

#### Drag and Drop
##### Draggable Attachments
- This feature utilizes the [dnd library](https://pub.dartlang.org/packages/dnd).
- Enabled by default, but can be toggled by setting the module's `enableDraggable` property upon module construction;
this cannot be updated on-the-fly and is static once the module is instantiated.
- To utilize draggable attachments, dnd dropzones should be registered in the experience:

```dart
import 'package:dnd/dnd.dart';
import 'package:w_attachments_client/w_attachments_client.dart'; // imports the AttachmentAvatarHandler
...
Dropzone _dropzone = new Dropzone(react_dom.findDOMNode(_card));
_dropzone.onDragEnter.listen(_onDragEnter);
_dropzone.onDragLeave.listen(_onDragLeave);
_dropzone.onDrop.listen(_onDrop);
// be sure to cancel streams on unmount e.g. sub.cancel()
...
// Add the logic to deal with your dropped attachment in your _onDrop handler
_onDrop(DropzoneEvent event) {
    if (event.avatarHandler != null) {
        Bundle oldBundle = (event.avatarHandler as AttachmentAvatarHandler).bundle;
        // removeAttachment is an example of using the attachments module's API, any endpoint from there
        // or the w_attachments_client_service_api can be leveraged, or any other action you want to take from
        // the experience.
        props.attachmentsModule.api.removeAttachment(keyToRemove: oldBundle.key);
    }
}
```

- `attachmentDragStart` and `attachmentDragEnd` Events are available to support dragged attachments, in order to modify UI as needed during a drag event

```dart
props.module.events.attachmentDragStart.listen((event) => setState(newState()..attachmentDragging = true));
props.module.events.attachmentDragEnd.listen((event) => setState(newState()..attachmentDragging = false));
```

- Note: Attachments cannot be reordered or dragged into other groups within the panel,
 only dragging to the experience from the panel is supported.

##### Panel Dropzones for uploading new attachments
- This feature utilizes the browser drag-and-drop libraries in order to support File System objects.
- Allows a user to upload new attachments to particular selections by dragging from the file system to the panel.
  - When in the grouped regions view, each context group (selection) becomes a dropzone.
  - When in the headerless region view, the entire panel uses the same selection/dropzone.
  - Nested Attachment view is TBD, ATEAM-3145
- Enabled by default, but can be toggled by setting the module's `enableUploadDropzones` property upon module construction;
this cannot be updated on-the-fly and is static once the module is instantiated.

### Attachments Service API (Headless SDK)
- w_attachments_client supports a limited number of requests without having to load the entire module.
- The Attachments Service API makes requests to bigsky w-annotation. The sdk requires that you provide it a
bigskyClient. The [bigskyClient](https://github.com/Workiva/w_session/blob/master/lib/src/session.dart#L187) should be
provided by [w_session](https://github.com/Workiva/w_session).
- UploadFiles has an associated stream that will need to be subscribed to which delivers the upload status and results.
- If you have an existing AppIntelligence instance, this will be used for the attachmentsService analytics.

```dart
_serviceApi = new AttachmentsServiceApi(
    bigskyClient: session.createBigskyClient(),
    appIntelligence: existing_appIntelligence_instance);
_serviceApi.uploadStatusStream.listen(_someHandler);
```

### Testing Signoff Template
```markdown
Performing QA plus one...
- [ ] Pulled master before testing
- [ ] Skynet passed on latest commit
- **Acceptance Criteria**
    - [ ] *Description*
- **Regression testing**
    - [ ] *Description*
- **Test Coverage**
  - [ ] Unit Tests added
```

### Known Issues
- *2016-10-05 (ghmulli):* subcomponents are constantly re-rendering when they really don't need to. add checkRender override...
- *2016-10-10 (ghmulli):* loading the example page takes an average of 1.48e+12ms when new updates are transpiled. this is most likely because of the bloated import file. figure out why it jumped so high when it was so low during the jam...
- *2016-10-10 (ghmulli):* modify GroupPivot so that it more closely aligns with the current Selection back-end model
- *2016-10-13 (ghmulli):* on the Example page, if you select an attachment and then change to another region, you can't add a new attachment because the hidden attachment row is now selected...
- *2016-10-24 (ghmulli):* use a Makefile to generate the SASS files (see w_filing)
- *2016-10-26 (ghmulli):* need unit tests for: mixins
- *2016-11-21 (pankenman):* need to add logging as appropriate
- *2016-11-21 (pankenman):* need to change all scss to be name-spaced: for example, changing the className 'attachment-controls' to 'wattachments-attachment-controls'
- *2016-11-21 (pankenman):* should componentize the example page and move business logic to a more flux-y pattern, with an example store and actions, etc. This will eliminate redraw calls, etc.

Please contact ATEAM via Hipchat if you have any questions
