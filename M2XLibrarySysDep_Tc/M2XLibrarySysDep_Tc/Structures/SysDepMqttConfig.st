// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepMqttConfig
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Configuration of the MQTT client
//
//  Copyright:
//    (C) 2026 Thorsten Brach. All rights reserved
//             Licensed under the MIT License.
//
//  Disclaimer:
//    This project is provided without any guarantee and can be used for
//    private and commercial purposes. Any use is at the user's
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
/// Configuration of the MQTT client
TYPE SysDepMqttConfig :
STRUCT
  /// Host name or IP address of the broker
  HostName             : STRING(255) := '127.0.0.1';
  /// Port of the broker
  Port                 : UINT := 1883;
  /// Client id (unique per connection)
  ClientId             : STRING(64);
  /// User name (optional)
  UserName             : STRING(64);
  /// Password (optional)
  Password             : STRING(64);
  /// Keep alive in seconds
  KeepAlive            : UINT := 60;
  /// Use TLS
  TlsEnabled           : BOOL;
  /// CA file
  TlsCaFile            : STRING(255);
  /// Client certificate file
  TlsCertFile          : STRING(255);
  /// Client key file
  TlsKeyFile           : STRING(255);
  /// Password of the client key
  TlsKeyPassword       : STRING(64);
  /// Do not check the server certificate
  TlsNoServerCertCheck : BOOL;
END_STRUCT
END_TYPE
