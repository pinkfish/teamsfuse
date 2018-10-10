import 'package:angular/angular.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';
import '../../../../util/algolia/algolia.dart';
import '../../../../util/algolia/searchresult.dart';

@Component(
  selector: 'my-league',
  templateUrl: 'league.html',
  directives: [
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
  ],
  styleUrls: const [
    'league.css',
  ],
)
class LeagueComponent implements OnInit {
  LeagueComponent();

  @override
  void ngOnInit() {
    SearchRequest req = new SearchRequest('leagues', 'bing');
    Algolia algolia =
        new Algolia('588269MZO8', '32b210cdab0b0eb11b2b1f35a89b7b38');
    algolia
        .search(req)
        .then((SearchResult result) => print(result));
  }

  void search(String text) {}
}
