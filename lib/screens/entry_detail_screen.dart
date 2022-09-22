import 'package:flutter/material.dart';
import 'package:history_of_me/api.dart';
import 'package:history_of_me/controllers.dart';
import 'package:history_of_me/localization.dart';
import 'package:history_of_me/models.dart';
import 'package:history_of_me/widgets.dart';
import 'package:leitmotif/leitmotif.dart';

/// A `screen` widget showing a preview of the provided entry's data.
/// The entry will be fetched from Hive using the provided [diaryEntryUid].
///
/// Allows to navigate to the editing screen.
class EntryDetailScreen extends StatefulWidget {
  /// The entry's index on the chronological list of diary entries.
  final int listIndex;

  /// The entry's uid.
  final String diaryEntryUid;

  /// Creates a [EntryDetailScreen].
  const EntryDetailScreen({
    Key? key,
    required this.listIndex,
    required this.diaryEntryUid,
  }) : super(key: key);

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen>
    with TickerProviderStateMixin {
  late QueryController _queryController;

  late ScrollController _scrollController;

  late HOMNavigator _screenRouter;

  late DiaryPhotoPicker _diaryPhotoPicker;

  void _onDeleteEntry() {
    LitRouteController(context).clearNavigationStack();
    AppAPI().deleteDiaryEntry(widget.diaryEntryUid);
  }

  void _showConfirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        onDelete: _onDeleteEntry,
      ),
    );
  }

  bool _isAvailableNextEntry(DiaryEntry diaryEntry) {
    return _queryController.nextEntryExistsByUID(diaryEntry.uid);
  }

  bool _isAvailablePreviousEntry(DiaryEntry diaryEntry) {
    return _queryController.previousEntryExistsByUID(diaryEntry.uid);
  }

  void _onEdit(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) => _screenRouter.toEntryEditingScreen(diaryEntry: diaryEntry),
    );
  }

  /// Delays the [_onEdit] call by the button animation duration to allow the
  /// animation to fully play back before transitioning to the next screen.
  void _onEditDelayed(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) => _onEdit(diaryEntry),
    );
  }

  void _onNextPressed(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) {
        LitRouteController(context).replaceCurrentCupertinoWidget(
          newWidget: EntryDetailScreen(
            listIndex: widget.listIndex,
            diaryEntryUid: _queryController.getNextDiaryEntry(diaryEntry).uid,
          ),
        );
      },
    );
  }

  void _onPreviousPressed(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) {
        LitRouteController(context).replaceCurrentCupertinoWidget(
          newWidget: EntryDetailScreen(
            listIndex: widget.listIndex,
            diaryEntryUid:
                _queryController.getPreviousDiaryEntry(diaryEntry).uid,
          ),
        );
      },
    );
  }

  /// Flips the currently displayed entry of the diary by either navigating
  /// to the next entry on a negative drag velocity or by navigating to the
  /// next entry in case of a positive velocity.
  void _flipPage(DragEndDetails details, DiaryEntry diaryEntry) {
    print(details.primaryVelocity.toString());
    if (details.primaryVelocity == null) return;

    // Next
    if (details.primaryVelocity! < 0) {
      if (_isAvailableNextEntry(diaryEntry)) {
        _onNextPressed(diaryEntry);
      }
    }

    // Previous
    if (details.primaryVelocity! > 0) {
      if (_isAvailablePreviousEntry(diaryEntry)) {
        _onPreviousPressed(diaryEntry);
      }
    }
  }

  void _onPickedUnsupportedFile() {
    showDialog(
      context: context,
      builder: (context) => UnsupportedFileDialog(),
    );
  }

  void _onDeleteAllPhotos(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => DeleteAllPhotosDialog(entry: entry),
    );
  }

  void _onPressedOptions(DiaryEntry diaryEntry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _EntryOptionsBottomSheet(
        onPressedEdit: () => _onEditDelayed(diaryEntry),
        onPressedDelete: _showConfirmDeleteDialog,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _queryController = QueryController();
    _screenRouter = HOMNavigator(context);
    _diaryPhotoPicker = DiaryPhotoPicker(
      onPickedUnsupportedFile: _onPickedUnsupportedFile,
      onDeleteAllPhotos: _onDeleteAllPhotos,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QueryDiaryEntryProvider(
      diaryEntryUid: widget.diaryEntryUid,
      builder: (context, diaryEntry, isFirst, isLast, boxLength) {
        /// Verify the entry has not been deleted yet.
        if (diaryEntry != null) {
          return LitScaffold(
            appBar: FixedOnScrollTitledAppbar(
              scrollController: _scrollController,
              title: diaryEntry.title != DefaultData.diaryEntryTitle
                  ? diaryEntry.title
                  : AppLocalizations.of(context).untitledLabel,
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return Container(
                child: Stack(
                  children: [
                    LitScrollbar(
                      child: ScrollableColumn(
                        controller: _scrollController,
                        children: [
                          SizedBox(
                            height: 384.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                EntryDetailBackdrop(
                                  diaryEntry: diaryEntry,
                                  diaryPhotoPicker: _diaryPhotoPicker,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 64.0 + 16.0,
                                      top: 16.0,
                                      left: 16.0,
                                      right: 20.0,
                                    ),
                                    child: PickPhotosButton(
                                      onPressed: () {
                                        _diaryPhotoPicker
                                            .pickPhotosAndSave(diaryEntry);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform(
                            transform: Matrix4.translationValues(0, -64.0, 0),
                            child: EntryDetailCard(
                              boxLength: boxLength,
                              listIndex: widget.listIndex,
                              isFirst: isFirst,
                              isLast: isLast,
                              diaryEntry: diaryEntry,
                              onEdit: () => _onEdit(diaryEntry),
                              queryController: _queryController,
                              flipPage: _flipPage,
                            ),
                          ),
                          Divider(color: Colors.black26),
                          _BottomNavigationBar(
                            showNextButton: _isAvailableNextEntry(diaryEntry),
                            showPreviousButton:
                                _isAvailablePreviousEntry(diaryEntry),
                            onPrevious: () => _onPreviousPressed(diaryEntry),
                            onNext: () => _onNextPressed(diaryEntry),
                            onPressedOptions: () =>
                                _onPressedOptions(diaryEntry),
                          ),
                          _isAvailableNextEntry(diaryEntry) &&
                                  _isAvailablePreviousEntry(diaryEntry)
                              ? Column(
                                  children: [
                                    Divider(color: Colors.black26),
                                    _OptionsBar(
                                      onPressedOptions: () =>
                                          _onPressedOptions(diaryEntry),
                                    )
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }
        // Return empty page if the entry has been deleted.
        return SizedBox();
      },
    );
  }
}

class _OptionsBar extends StatelessWidget {
  final void Function() onPressedOptions;
  const _OptionsBar({
    Key? key,
    required this.onPressedOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          _MoreButton(
            onPressed: onPressedOptions,
          ),
        ],
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final void Function() onPressed;
  const _MoreButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LitPushedThroughButton(
      child: Row(
        children: [
          Icon(Icons.more_vert, size: 18.0),
          ClippedText(
            AppLocalizations.of(context).moreLabel.toUpperCase(),
            style: LitSansSerifStyles.button,
          ),
          const SizedBox(width: 4.0),
        ],
      ),
      accentColor: LitColors.grey100,
      onPressed: onPressed,
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  /// Flag to force the `next` button to show up.
  final bool showNextButton;

  /// Flag to force the `previous` button to show up.
  final bool showPreviousButton;

  final void Function() onNext;
  final void Function() onPrevious;
  final void Function() onPressedOptions;

  /// Creates a [_BottomNavigationBar].
  const _BottomNavigationBar({
    Key? key,
    required this.onNext,
    required this.onPrevious,
    required this.showNextButton,
    required this.showPreviousButton,
    required this.onPressedOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showPreviousButton
              ? _PreviousNavigationButton(
                  onPressed: onPrevious,
                )
              : _MoreButton(
                  onPressed: onPressedOptions,
                ),
          showNextButton
              ? _NextNavigationButton(
                  onPressed: onNext,
                )
              : _MoreButton(
                  onPressed: onPressedOptions,
                ),
        ],
      ),
    );
  }
}

class _NextNavigationButton extends StatelessWidget {
  final void Function() onPressed;

  /// Creates a [_NextNavigationButton].
  const _NextNavigationButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _NavigationButton(
      label: LeitmotifLocalizations.of(context).nextLabel.toUpperCase(),
      mode: LitLinearNavigationMode.next,
      onPressed: onPressed,
    );
  }
}

class _PreviousNavigationButton extends StatelessWidget {
  final void Function() onPressed;

  /// Creates a [_PreviousNavigationButton].
  const _PreviousNavigationButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _NavigationButton(
      label:
          LeitmotifLocalizations.of(context).previousLabelShort.toUpperCase(),
      mode: LitLinearNavigationMode.previous,
      onPressed: onPressed,
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final LitLinearNavigationMode mode;
  final String label;
  final void Function() onPressed;
  const _NavigationButton({
    Key? key,
    required this.label,
    required this.mode,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LitPushedThroughButton(
      child: Row(
        children: [
          LinearNavigationIcon(
            mode: mode,
          ),
          const SizedBox(width: 4.0),
          ClippedText(
            label,
            style: LitSansSerifStyles.button,
          ),
          const SizedBox(width: 4.0),
        ],
      ),
      accentColor: LitColors.grey100,
      onPressed: onPressed,
    );
  }
}

class _EntryOptionsBottomSheet extends StatelessWidget {
  final void Function() onPressedEdit;
  final void Function() onPressedDelete;
  const _EntryOptionsBottomSheet({
    Key? key,
    required this.onPressedEdit,
    required this.onPressedDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16.0),
        Text(
          AppLocalizations.of(context).optionsLabel.capitalize(),
          style: LitSansSerifStyles.h6.copyWith(color: LitColors.grey380),
        ),
        Divider(),
        SizedBox(
          height: 142.0,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              LitPushedThroughButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LitIcons.pencil_alt,
                      color: LitSansSerifStyles.button.color,
                      size: LitSansSerifStyles.button.fontSize,
                    ),
                    SizedBox(width: 8.0),
                    ClippedText(
                      AppLocalizations.of(context).editLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: LitSansSerifStyles.button,
                    ),
                  ],
                ),
                accentColor: LitColors.grey100,
                onPressed: onPressedEdit,
              ),
              SizedBox(height: 16.0),
              LitDeleteButton(
                textAlign: TextAlign.center,
                showIcon: true,
                onPressed: onPressedDelete,
              )
            ],
          ),
        )
      ],
    );
  }
}
