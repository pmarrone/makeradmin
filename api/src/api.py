import flask_cors
from flask import Flask, jsonify
from sqlalchemy.exc import OperationalError

from core.auth import authenticate_request
from membership.permissions import register_permissions
from service.api_definition import ALL_PERMISSIONS
from service.config import get_mysql_config
from service.db import create_mysql_engine, shutdown_session, populate_fields_by_index
from service.error import ApiError, error_handler_api, error_handler_db, error_handler_500, error_handler_404
from services import services

app = Flask(__name__)

flask_cors.CORS(
    app,
    max_age='1728000',
    allow_headers=['Origin', 'Content-Type', 'Accept', 'Authorization', 'X-Request-With',
                   'Access-Control-Allow-Origin'],
)

for path, service in services:
    app.register_blueprint(service, url_prefix=path)


app.register_error_handler(OperationalError, error_handler_db)
app.register_error_handler(ApiError, error_handler_api)
app.register_error_handler(500, error_handler_500)
app.register_error_handler(404, error_handler_404)
app.teardown_appcontext(shutdown_session)
app.before_request(authenticate_request)

engine = create_mysql_engine(**get_mysql_config())

populate_fields_by_index(engine)
register_permissions(ALL_PERMISSIONS)


@app.route("/")
def index():
    return jsonify(dict(status="ok")), 200


@app.route("/routes")
def routes():
    # TODO Fix machine readable.
    # TODO Why do we serve static?
    return "\n".join(sorted([f"{rule.rule}: {', '.join(sorted(rule.methods))}" for rule in app.url_map.iter_rules()]))


# TODO Use Sentry?
