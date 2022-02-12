/// Widgets implementing various user interface components of History of me.
///
/// To use, import `package:history_of_me/widgets.dart`.
library widgets;

import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:history_of_me/api.dart';
import 'package:history_of_me/app.dart';
import 'package:history_of_me/controllers.dart';
import 'package:history_of_me/extensions.dart';
import 'package:history_of_me/localization.dart';
import 'package:history_of_me/models.dart';
import 'package:history_of_me/screens.dart';
import 'package:history_of_me/static.dart';
import 'package:history_of_me/styles.dart';
import 'package:leitmotif/leitmotif.dart';
import 'package:lit_backup_service/lit_backup_service.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'widgets/animated_updated_label.dart';
part 'widgets/app_artwork.dart';
part 'widgets/backdrop_photo_overlay.dart';
part 'widgets/bookmark_back.dart';
part 'widgets/bookmark_back_preview.dart';
part 'widgets/bookmark_container.dart';
part 'widgets/bookmark_cover.dart';
part 'widgets/bookmark_design.dart';
part 'widgets/bookmark_front.dart';
part 'widgets/bookmark_front_preview.dart';
part 'widgets/bookmark_page_view.dart';
part 'widgets/bookmark_preview_container.dart';
part 'widgets/bookmark_title.dart';
part 'widgets/cancel_restoring_dialog.dart';
part 'widgets/change_name_dialog.dart';
part 'widgets/change_photo_dialog.dart';
part 'widgets/clean_text_field.dart';
part 'widgets/create_entry_dialog.dart';
part 'widgets/create_new_diary_action_card.dart';
part 'widgets/database_state_screen_builder.dart';
part 'widgets/deletable_container.dart';
part 'widgets/diary_backup_dialog.dart';
part 'widgets/diary_bookmark_header.dart';
part 'widgets/diary_filter_header.dart';
part 'widgets/diary_filter_header_delegate.dart';
part 'widgets/diary_list_tile.dart';
part 'widgets/diary_list_view.dart';
part 'widgets/diary_preview_card.dart';
part 'widgets/dotted_design.dart';
part 'widgets/editable_item_meta_info.dart';
part 'widgets/ellipse_icon.dart';
part 'widgets/entry_day_selection_tile.dart';
part 'widgets/entry_detail_backdrop.dart';
part 'widgets/entry_detail_card.dart';
part 'widgets/greetings_bar.dart';
part 'widgets/history_of_me_app_logo.dart';
part 'widgets/history_of_me_launcher_icon_art.dart';
part 'widgets/lit_toggle_button_group.dart';
part 'widgets/pattern_config_card.dart';
part 'widgets/primary_color_selector_card.dart';
part 'widgets/purple_pink_button.dart';
part 'widgets/purple_pink_save_button.dart';
part 'widgets/quote_card.dart';
part 'widgets/secondary_color_selector_card.dart';
part 'widgets/selectable_color_tile.dart';
part 'widgets/selected_create_tile.dart';
part 'widgets/settings_footer.dart';
part 'widgets/statistics_card.dart';
part 'widgets/striped_design.dart';
part 'widgets/unselected_create_tile.dart';
part 'widgets/updated_label_text.dart';
part 'widgets/user_icon.dart';
part 'widgets/user_profile_card.dart';
part 'widgets/word_count_badge.dart';
