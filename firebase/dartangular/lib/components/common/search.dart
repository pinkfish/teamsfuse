import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:teamfuse/util/algolia/algolia.dart';

import 'constants.dart';
import 'searchitem.dart';

@Component(
  selector: 'search-form',
  templateUrl: 'search.html',
  directives: [
    coreDirectives,
    formDirectives,
    SearchItemComponent,
    ModalComponent,
    MaterialButtonComponent,
    DeferredContentDirective,
  ],
)
class SearchComponent {
  Algolia algolia = new Algolia(Constants.kAlgoliaAppId, Constants.kAlgoliaKey);
  String search = "";
  SearchResult result;
  Iterable<SearchItem> items = [];

  bool showSearchResults = false;

  SearchComponent();

  void onSubmit() {
    print('onSubmit');
    // Do the search.
    algolia.search(new SearchRequest('teams', search)).then((SearchResult res) {
      print(res);
      showSearchResults = true;
      result = res;
      items = res.items;
    });
  }

  void closeDialog() {
    showSearchResults = false;
  }

  String trackBySearch(int pos, dynamic t) =>
      t is SearchItem ? t.data['objectID'] as String : pos.toString();
}
