import 'package:angular/angular.dart';

import 'routes.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';
import 'package:teamfuse/components/guest/pieces/footer.dart';

@Component(
  selector: 'my-guest',
  templateUrl: 'guest-component.html',
  directives: [
    GuestHeaderComponent,
    GuestFooterComponent,
  ],
  providers: [
    const ClassProvider(GuestRoutes),
  ],
)
class GuestComponent {
  final GuestRoutes routes;

  GuestComponent(this.routes);
}
