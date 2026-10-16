/// Checks whether a topic matches an MQTT topic filter (wildcards + and #)
FUNCTION TopicMatches : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      TopicMatches
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Checks whether a topic matches an MQTT topic filter (wildcards + and #)
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
VAR_INPUT
  /// Topic filter
  Filter : STRING(255);
  /// Topic
  Topic  : STRING(255);
END_VAR
VAR
  /// Position in the filter
 _fi        : UDINT;
  /// Position in the topic
 _ti        : UDINT;
  /// Length of the filter
 _filterLen : UDINT;
  /// Length of the topic
 _topicLen  : UDINT;
END_VAR
 _filterLen := StringLength(pText := ADR(Filter), Size := SIZEOF(Filter));
 _topicLen  := StringLength(pText := ADR(Topic),  Size := SIZEOF(Topic));

  WHILE ( _fi < _filterLen ) DO
    // '#' matches the rest
    IF ( Filter[_fi] = 35 )
    THEN
      TopicMatches := TRUE;
      RETURN;
    END_IF

    // '+' matches one level
    IF ( Filter[_fi] = 43 )
    THEN
      WHILE (( _ti < _topicLen ) AND ( Topic[_ti] <> 47 )) DO
       _ti := _ti + 1;
      END_WHILE
     _fi := _fi + 1;
    ELSE
      IF (( _ti >= _topicLen ) OR ( Filter[_fi] <> Topic[_ti] ))
      THEN
        RETURN;
      END_IF
     _fi := _fi + 1;
     _ti := _ti + 1;
    END_IF
  END_WHILE

  TopicMatches := ( _ti = _topicLen );
END_FUNCTION
