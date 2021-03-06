import requests

from flask import Blueprint, g, request, Response
from requests import RequestException

from service.api_definition import POST, SERVICE_USER_ID, SERVICE_PERMISSIONS, GET, PUT, DELETE
from service.error import InternalServerError, ApiError, EXCEPTION, GENERIC_500_ERROR_MESSAGE
from service.logging import logger
from service.traffic_logger import log_traffic


class ExternalService(Blueprint):
    """ Flask blueprint for external services that sends all requests to an external service. Authentication is done
    here and permission information is forwarded as HTTP headers. """
    
    def __init__(self, name, url, timeout=30):
        super().__init__(name, name)
        self.name = name
        self.url = url
        self.timeout = timeout

        @self.route("/", methods=(GET, PUT, POST, DELETE))
        @self.route("/<path:path>", methods=(GET, PUT, POST, DELETE))
        def upstream_service(path=""):
            url = self.get_url("/" + path)
            response = self.raw_request("forwarding", url, request.method,
                                        data=request.get_data(), params=request.args,
                                        content_type=request.headers.get('Content-Type', None))
            
            headers = {k: response.headers.get(k) for k in ('Content-Type', 'Cache-Control') if k in response.headers}
            
            return Response(response.content, headers=headers, status=response.status_code)
        
    def migrate(self, *args, **kwargs):
        pass

    def get_url(self, path):
        return f"{self.url}/{self.name}{path}"

    def raw_request(self, what, url, method, user_id=None, permissions=None, content_type=None, **kwargs):
        permissions = permissions or g.permissions
        headers = {
            'X-User-Permissions': ','.join(permissions)
        }

        user_id = user_id or g.user_id
        if user_id:
            headers['X-User-Id'] = str(user_id)

        if content_type:
            headers['Content-Type'] = content_type
        
        stripe_signatrue = request.headers.get('Stripe-Signature')
        if stripe_signatrue:
            headers['Stripe-Signature'] = stripe_signatrue
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=headers,
                timeout=self.timeout,
                **kwargs,
            )
            log_traffic(response)
        except RequestException as e:
            raise InternalServerError(GENERIC_500_ERROR_MESSAGE, service=self.name,
                                      log=f"{method} to {url} failed: {str(e)}", level=EXCEPTION)

        return response

    def request(self, path, method, **kwargs):
        url = self.get_url(path)

        response = self.raw_request("own request", url, method, **kwargs)
        
        if response.status_code >= 500:
            raise ApiError.parse(response, service=self.name, message=GENERIC_500_ERROR_MESSAGE,
                                 log=f"{method} to {url} failed")
        
        if response.status_code >= 400:
            raise ApiError.parse(response, service=self.name)

        data = response.json()
        
        return data.get('data')

    def user_post(self, path, **data):
        return self.request(path, method=POST, data=data)

    def service_post(self, path, **data):
        return self.request(path, method=POST, data=data,
                            user_id=SERVICE_USER_ID, permissions=SERVICE_PERMISSIONS)

    def user_get(self, path):
        return self.request(path, method=GET)

    def service_get(self, path):
        return self.request(path, method=GET,
                            user_id=SERVICE_USER_ID, permissions=SERVICE_PERMISSIONS)
