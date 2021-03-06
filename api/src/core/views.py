from flask import request, g

from core import service, auth
from service.api_definition import POST, PUBLIC, Arg, DELETE, GET, SERVICE, Enum, USER, BAD_VALUE
from service.error import NotFound, UnprocessableEntity


@service.route("/oauth/token", method=POST, permission=PUBLIC, flat_return=True)
def login(grant_type=Arg(Enum('password')), username=Arg(str), password=Arg(str)):
    """ Login user with username and password, returns token. """
    assert grant_type

    return auth.login(request.remote_addr, request.user_agent.string, username, password)


@service.route("/oauth/token/<string:token>", method=DELETE, permission=USER)
def logout(token=None):
    """ Remove token from database, returns None. """
    auth.remove_token(token, g.user_id)


@service.route("/oauth/resetpassword", method=POST, permission=PUBLIC)
def reset_password():
    """ Send a reset password link to the users email. """
    raise NotFound("Reset password functionality is not implemented yet.")


@service.route("/oauth/token", method=GET, permission=USER)
def list_tokens():
    """ List all tokens for the authorized user. """
    return auth.list_for_user(g.user_id)


@service.route("/oauth/force_token", method=POST, permission=SERVICE, flat_return=True)
def force_token(user_id: int=Arg(int)):
    """ Create force login for any user, returns token. """
    if user_id <= 0:
        raise UnprocessableEntity(fields='user_id', what=BAD_VALUE)

    return auth.force_login(request.remote_addr, request.user_agent.string, user_id)
