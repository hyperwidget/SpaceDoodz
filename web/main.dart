import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'dart:async';

@Controller(selector: '[root]', publishAs: 'ctrl')
class rootController {
  int clickValue = 1;
  double multiplier = 1.00;

  DataService dataService;
  Scope scope;

  rootController(this.dataService, this.scope) {
  }

  build() {
    dataService.modifyDoodz(clickValue * multiplier);
  }
}

@Controller(selector: '[baseDoodz]', publishAs: 'ctrl')
class doodzBaseController {
  int cost = 0;
  int count = 0;
  double value = 0;
  double multiplier = 1.0;
  double autoValue = 0.0;
  double costMultiplier = 1.0;

  double attack = 0.0;
  double armor = 0.0;

  bool canBuild = false;
  bool show = false;

  List<String> menuOptions;
  DataService dataService;
  Scope scope;

  doodzBaseController(this.dataService, this.scope) {
    value = 1.00;
    Stream listenStream = scope.on('totalChange');
    listenStream.listen(update);
  }

  void update(ScopeEvent e) {
    if (!show) {
      if (scope.context['total'] >= cost) {
        show = true;
        canBuild = true;
      }
    } else {
      if (scope.context['total'] >= cost) {
        canBuild = true;
      } else {
        canBuild = false;
      }
    }
  }

  void build() {
    if (canBuild) {
      count++;
      dataService.modifyDoodz(-cost);
      cost = (cost * costMultiplier).floor();
      calculateAuto();

      if (this is builderController) {
        dataService.builderAutoValue = autoValue;
        dataService.calculateTotalAuto();
      }
    }
  }

  void calculateAuto() {
    autoValue = count * value * multiplier;
  }
}

@Controller(selector: '[doodz]', publishAs: 'doodz')
class doodzController extends doodzBaseController {

  doodzController(DataService ds, Scope scope) : super(ds, scope) {
    value = 1.00;
    canBuild = true;
  }
}

@Controller(selector: '[builder]', publishAs: 'builder')
class builderController extends doodzBaseController {

  builderController(DataService ds, Scope scope) : super(ds, scope) {
    cost = 10.0;
    value = 0.1;
    costMultiplier = 1.1;
  }
}

class DataService {
  int total = 0;
  double auto = 0;
  double builderAutoValue = 0.0;
  Scope scope;

  DataService(this.scope) {
    scope.context['total'] = 0.0;
    scope.context['auto'] = 0.0;

    calculateTotalAuto();

    new Timer.periodic(const Duration(milliseconds: 100), (timer) {
      int i = 0;
      modifyDoodz(auto / 10);
    });
  }

  void modifyDoodz(int amount) {
    scope.context['total'] += amount;
    scope.broadcast('totalChange', total);
  }

  void calculateTotalAuto() {
    auto = builderAutoValue;
    scope.context['auto'] = auto;
  }

}

@Formatter(name: 'doodzFilter')
class DoodzFilter {
  call(value) {
    return value.floor();
  }
}

class MyAppModule extends Module {
  MyAppModule() {
    bind(rootController);
    bind(doodzController);
    bind(builderController);
    bind(DataService);
    bind(DoodzFilter);
  }
}

void main() {
  applicationFactory().addModule(new MyAppModule()).run();
}
