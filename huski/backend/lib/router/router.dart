import "dart:async";

import "package:postgres/postgres.dart";
import "package:redis/redis.dart";
import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "../config/config.dart";
import "../repository/redis_repository.dart";
import "../repository/state_repository.dart";
import "../service/command_service.dart";
import "../service/state_service.dart";
import "../utils/notify_utils.dart";
import "cors.dart" as cors;

Future<Handler> initRoutes(ApplicationConfig config, PostgreSQLConnection database, Command redis) async {
  //* define routes
  final publicRoutes = _initPublicRoutes(config, database, redis);

  //* define fallbacks
  publicRoutes.all(_notFoundRoute, _notFoundHandler);

  //* build pipeline
  final publicPipeline = const Pipeline() //
      .addMiddleware(cors.middleware())
      .addHandler(publicRoutes);
  final handler = Cascade(statusCodes: [401, 404]) //
      .add(publicPipeline)
      .handler;
  return handler;
}

Response _notFoundHandler(Request request) => Response.notFound("Page not found");
const _notFoundRoute = "/<ignored|.*>";

Router _initPublicRoutes(ApplicationConfig config, PostgreSQLConnection database, Command redis) {
  final routes = Router();

  //* CommandService
  final redisRepository = RedisRepository(redis);
  final commandService = CommandService(redisRepository);
  routes.get("/command", commandService.get);
  routes.post("/command", commandService.post);

  //* StateService
  final notifier = Notifier(
    config.email.address,
    config.email.port,
    config.email.username,
    config.email.password,
    config.email.from,
    config.email.fromName,
    config.email.to,
  );
  final stateRepository = StateRepository(database);
  final stateService = StateService(stateRepository, redisRepository, notifier);
  routes.get("/state", stateService.get);
  routes.post("/state", stateService.post);

  final topLevelRouter = Router();
  topLevelRouter.mount("/v1/", routes.call);
  return topLevelRouter;
}
