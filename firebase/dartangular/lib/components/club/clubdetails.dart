import 'package:angular/angular.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';

@Component(
  selector: 'club-details',
  directives: const [
    NgIf,
    NgFor,
    MaterialExpansionPanel
  ],
  templateUrl: 'clubdetails.html',
  pipes: const [AsyncPipe],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class ClubDetailsComponent implements OnDestroy, OnInit {
  @Input()
  Club club;

  ClubDetailsComponent();

  @override
  void ngOnInit() {
    print('New details $club');
  }

  String get clubUrl {
    if (club.photoUrl != null && !club.photoUrl.isEmpty) {
      return club.photoUrl;
    }
    // Default asset.
    return "assets/" + club.sport.toString() + ".png";
  }

  void ngOnDestroy() {
    print('Destroy them my robots');
  }

  Object trackBySeason(int index, dynamic season) => season is Season ? season.uid : "";
}
