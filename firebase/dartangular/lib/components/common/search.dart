import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:teamfuse/util/algolia/algolia.dart';

@Component(
  selector: 'search-form',
  templateUrl: 'search.html',
  directives: [coreDirectives, formDirectives],
)
class SearchComponent {
  Algolia algolia =
      new Algolia('588269MZO8', '32b210cdab0b0eb11b2b1f35a89b7b38');
  String search;

  void onSubmit() {
    print('onSubmit');
    // Do the search.
    algolia.search(new SearchRequest('leagues', search)).then((SearchResult res) {
      print(res);
    });
  }
}
