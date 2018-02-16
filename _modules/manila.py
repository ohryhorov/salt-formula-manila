# -*- coding: utf-8 -*-
'''
Module for configuring Manila services
======================================
'''

import json
import logging
import requests
import os

from keystoneclient.auth.identity import v2
from keystoneauth1 import session

from functools import wraps
from collections import OrderedDict

from lxml import etree
from lxml import objectify


log = logging.getLogger(__name__)

# Import third party libs                                                                                                                                                                                                                    
HAS_MANILA = False
try:
    from manilaclient.v2 import client
    HAS_MANILA = True
except ImportError:
    pass

__opts__ = {}

def __virtual__():
    """
    Only load this module if manila
    is installed on this minion.
    """
    if HAS_MANILA:
        return 'manila'
    return False

def _authenticate(func_name):
    '''
    Authenticate requests with the salt keystone module and format return data
    '''
    @wraps(func_name)
    def decorator_method(*args, **kwargs):
        '''
        Authenticate request and format return data
        '''
        connection_args = {'profile': kwargs.pop('profile', None)}
        nkwargs = {}
        for kwarg in kwargs:
            if 'connection_' in kwarg:
                connection_args.update({kwarg: kwargs[kwarg]})
            elif '__' not in kwarg:
                nkwargs.update({kwarg: kwargs[kwarg]})
        kstone = __salt__['keystone.auth'](**connection_args)
#        import rpdb; rpdb.set_trace()

        if kwargs.get('connection_endpoint_type') == None:
            endpoint_type = 'internalURL'
        else:
            endpoint_type = kwargs.get('connection_endpoint_type')

        endpoint = kstone.service_catalog.url_for(
            service_type='sharev2',
            endpoint_type=endpoint_type)

        manila = client.Client('2', service_catalog_url=endpoint, session=kstone.session)
        return_data = func_name(manila, *args, **nkwargs)

        return return_data

    return decorator_method

@_authenticate
def shares_list(manila, **kwargs):
    ret = str(manila.shares.list())
    if ret:
        return True, ret
    else:
        return False, 'share_list has not been processed'

