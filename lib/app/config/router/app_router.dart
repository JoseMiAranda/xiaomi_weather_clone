import 'package:auto_route/auto_route.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.gr.dart';

CustomRoute<dynamic> slideLeftTransitionRoute({
  required String path,
  required PageInfo page,
  bool initial = false,
}) {
  return CustomRoute<dynamic>(
    path: path,
    page: page,
    initial: initial,
    transitionsBuilder: TransitionsBuilders.slideLeft,
  );
}

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        CustomRoute<dynamic>(
          path: '/',
          page: HomeRoute.page,
          initial: true,
          children: [
            slideLeftTransitionRoute(
          path: 'weather',
          page: WeatherRoute.page,
          initial: true,
        ),
        slideLeftTransitionRoute(
          path: 'air-quality',
          page: AirQualityRoute.page,
        ),
        slideLeftTransitionRoute(
          path: 'confirm-city',
          page: ConfirmLocationRoute.page,
        ),
        slideLeftTransitionRoute(
          path: 'saved-weathers',
          page: SavedWeathersRoute.page,
        ),
        CustomRoute<dynamic>(
          path: 'search',
          page: SearchRoute.page,
          transitionsBuilder: TransitionsBuilders.fadeIn,
        ),
        slideLeftTransitionRoute(
          path: 'settings',
          page: SettingsRoute.page,
        ),
          ]
        )   
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}
