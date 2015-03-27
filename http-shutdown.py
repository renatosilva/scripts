#!/usr/bin/env python
# -*- coding: utf-8 -*-

# HTTP Shutdown for Windows 2015.3.27
# Copyright (c) 2014, 2015 Renato Silva
# GNU GPLv2 licensed

import sys
from cgi import parse_qs, escape
from wsgiref.simple_server import make_server
from ctypes import windll, wintypes, byref, Structure

SE_SHUTDOWN_NAME = 'SeShutdownPrivilege'
SE_PRIVILEGE_ENABLED = 0x2
TOKEN_ADJUST_PRIVILEGES = 0x20
EWX_SHUTDOWN = 0x1
EWX_FORCE = 0x4

class LUID(Structure): _fields_ = [('LowPart',  wintypes.DWORD), ('HighPart', wintypes.LONG)]
class LUID_AND_ATTRIBUTES(Structure): _fields_ = [('Luid', LUID), ('Attributes', wintypes.DWORD)]
class TOKEN_PRIVILEGES(Structure): _fields_ = [('PrivilegeCount', wintypes.DWORD), ('Privileges', LUID_AND_ATTRIBUTES)]

def logoff_and_shutdown():
    token_handle = wintypes.HANDLE()
    shutdown_privilege = TOKEN_PRIVILEGES(1, LUID_AND_ATTRIBUTES(LUID(), SE_PRIVILEGE_ENABLED))
    windll.advapi32.LookupPrivilegeValueA(None, SE_SHUTDOWN_NAME, byref(shutdown_privilege.Privileges.Luid))
    windll.advapi32.OpenProcessToken(windll.kernel32.GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, byref(token_handle))
    windll.advapi32.AdjustTokenPrivileges(token_handle, False, byref(shutdown_privilege), 0, None, None)
    windll.user32.ExitWindowsEx(EWX_SHUTDOWN | EWX_FORCE, 0)

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
