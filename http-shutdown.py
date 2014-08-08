#!/usr/bin/env python
# -*- coding: utf-8 -*-

# HTTP Shutdown for Windows 2014.8.8
# Copyright (c) 2014 Renato Silva
# GNU GPLv2 licensed

import sys
from cgi import parse_qs, escape
from wsgiref.simple_server import make_server
from win32api import ExitWindowsEx, GetCurrentProcess
from win32security import AdjustTokenPrivileges, LookupPrivilegeValue, OpenProcessToken
from win32security import TOKEN_ADJUST_PRIVILEGES, TOKEN_QUERY
from win32con import EWX_FORCE, EWX_LOGOFF, EWX_SHUTDOWN, SE_PRIVILEGE_ENABLED, SE_SHUTDOWN_NAME

def logoff_and_shutdown():
    shutdown_privilege = ((LookupPrivilegeValue(None, SE_SHUTDOWN_NAME), SE_PRIVILEGE_ENABLED),)
    token_handle = OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY)
    AdjustTokenPrivileges(token_handle, 0, shutdown_privilege)
    ExitWindowsEx(EWX_LOGOFF | EWX_SHUTDOWN | EWX_FORCE, 0)

def application(environment, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    path = environment.get('PATH_INFO', '').lstrip('/')
    parameters = parse_qs(environment.get('QUERY_STRING', ''))
    auth = escape(parameters.get('auth', [''])[0])

    if not path == 'shutdown': return ['hi']
    if not auth == AUTHENTICATION_KEY: return ['denied']
    logoff_and_shutdown()
    return ['started']

if len(sys.argv) != 4 or sys.argv[1] in ['-h', '--help']:
    print "Usage: %s <host> <port> <path to authentication key>" % sys.argv[0]
    sys.exit()

with open(sys.argv[3]) as file: AUTHENTICATION_KEY = file.read().strip()
server = make_server(sys.argv[1], int(sys.argv[2]), application)
server.serve_forever()
